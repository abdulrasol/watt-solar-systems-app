import 'dart:math' as math;

import 'package:watt/src/features/pv_system_designer/domain/entities/energy_estimate.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/solar_irradiance_data.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/system_losses.dart';
import 'package:watt/src/features/pv_system_designer/domain/services/solar_position_calculator.dart';

/// Estimates monthly/annual AC energy production for the array.
///
/// Replaces the previous single-multiplication model
/// (`power × peakSunHours × performanceRatio`, identical for every
/// orientation and climate) with a real, if intentionally simplified,
/// chain:
///  1. Decompose each month's horizontal irradiance (GHI) into beam/diffuse
///     components via the Erbs daily correlation (driven by the day's
///     clearness index).
///  2. Transpose onto the array's actual tilt/azimuth using an isotropic-
///     sky model, with the beam component scaled by a solar-noon
///     incidence-angle ratio computed from real sun-position geometry
///     ([SolarPositionCalculator]) on a Klein-recommended representative
///     day for each month.
///  3. Apply a temperature derate from an NOCT cell-temperature estimate.
///  4. Apply the structured [SystemLosses] diagram (soiling, mismatch,
///     wiring, inverter efficiency, availability).
///
/// This is still a simplified (daily-representative-day, isotropic-sky,
/// noon-ratio) model rather than an hourly Perez-model simulation like
/// PVsyst — but it now actually responds to tilt, azimuth, and local
/// climate, which the previous flat model never did.
class EnergyEstimator {
  const EnergyEstimator({SolarPositionCalculator? sunCalculator}) : _sunCalculator = sunCalculator ?? const SolarPositionCalculator();

  final SolarPositionCalculator _sunCalculator;

  static const double _albedo = 0.2;
  static const double _noctC = 45.0;
  static const double _tempCoeffPercentPerC = -0.35;

  static const List<int> _daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  // Klein (1977) recommended "average day of month" — day-of-year for each
  // calendar month, chosen so that day's declination is close to that
  // month's mean declination.
  static const List<int> _representativeDayOfYear = [17, 47, 75, 105, 135, 162, 198, 228, 258, 288, 318, 344];

  EnergyEstimate estimate({
    required double peakPowerKwp,
    required double latitude,
    required double longitude,
    required double tiltDegrees,
    required double azimuthDegrees,
    SolarIrradianceData? irradianceData,
    SystemLosses? losses,
  }) {
    if (peakPowerKwp <= 0) return EnergyEstimate.empty();

    final irradiance = irradianceData ?? SolarIrradianceData.estimate(latitude, longitude: longitude);
    final systemLosses = losses ?? SystemLosses.standard();
    final tiltRad = tiltDegrees * math.pi / 180.0;

    final monthlyProduction = List<double>.filled(12, 0);
    double totalIdealHorizontalKwh = 0;
    double totalTempLossWeighted = 0;
    //double totalPoaKwh = 0;

    for (int m = 0; m < 12; m++) {
      final ghiDaily = math.max(0.0, irradiance.monthlyAvgDailyGhiKwhM2[m]);
      final dayOfYear = _representativeDayOfYear[m];
      final daysInMonth = _daysInMonth[m];

      final h0 = _sunCalculator.extraterrestrialDailyKwhM2(dayOfYear: dayOfYear, latitude: latitude);
      final kt = h0 > 0 ? (ghiDaily / h0).clamp(0.0, 1.0) : 0.0;

      // Sunset hour angle in degrees, needed to pick the correct branch of
      // the Erbs correlation.
      final latRad = latitude * math.pi / 180.0;
      final gamma = 2 * math.pi / 365 * (dayOfYear - 1);
      final declination =
          0.006918 -
          0.399912 * math.cos(gamma) +
          0.070257 * math.sin(gamma) -
          0.006758 * math.cos(2 * gamma) +
          0.000907 * math.sin(2 * gamma) -
          0.002697 * math.cos(3 * gamma) +
          0.00148 * math.sin(3 * gamma);
      final cosSunsetHourAngle = (-math.tan(latRad) * math.tan(declination)).clamp(-1.0, 1.0);
      final sunsetHourAngleDeg = math.acos(cosSunsetHourAngle) * 180.0 / math.pi;

      // Erbs (1982) daily diffuse-fraction correlation.
      double diffuseFraction;
      if (sunsetHourAngleDeg <= 81.4) {
        diffuseFraction = 1.391 - 3.560 * kt + 4.189 * kt * kt - 2.137 * kt * kt * kt;
      } else {
        diffuseFraction = 1.311 - 3.022 * kt + 3.427 * kt * kt - 1.821 * kt * kt * kt;
      }
      diffuseFraction = diffuseFraction.clamp(0.0, 1.0).toDouble();

      final diffuseHorizontalDaily = ghiDaily * diffuseFraction;
      final beamHorizontalDaily = math.max(0.0, ghiDaily - diffuseHorizontalDaily);

      // Solar-noon incidence-angle ratio Rb = cos(incidence)/cos(zenith),
      // used to scale the beam component onto the tilted/oriented array —
      // a standard simplification for daily/monthly (non-hourly) modeling.
      final noonSun = _sunCalculator.atSolarNoon(dayOfYear: dayOfYear, latitude: latitude);
      final sunZenithRad = (90 - noonSun.elevationDeg) * math.pi / 180.0;
      final sunAzimuthRad = noonSun.azimuthDeg * math.pi / 180.0;
      final panelAzimuthRad = azimuthDegrees * math.pi / 180.0;
      final cosZenith = math.cos(sunZenithRad);
      final cosIncidence = cosZenith * math.cos(tiltRad) + math.sin(sunZenithRad) * math.sin(tiltRad) * math.cos(sunAzimuthRad - panelAzimuthRad);
      double rb = cosZenith > 1e-4 ? (cosIncidence / cosZenith) : 0.0;
      rb = math.max(0.0, rb); // never allow a negative (self-shaded / sun-behind-panel) contribution

      final poaBeam = beamHorizontalDaily * rb;
      final poaDiffuse = diffuseHorizontalDaily * (1 + math.cos(tiltRad)) / 2.0;
      final poaGround = ghiDaily * _albedo * (1 - math.cos(tiltRad)) / 2.0;
      final poaDaily = math.max(0.0, poaBeam + poaDiffuse + poaGround);

      // NOCT cell-temperature model using an approximate "while the sun is
      // up" average irradiance for the month (POA daily total spread over
      // the day's actual daylight hours), then a linear power/temp
      // coefficient relative to the 25°C STC rating.
      final daylightHours = math.max(1.0, 2 * sunsetHourAngleDeg / 15.0);
      final avgDaylightIrradianceWm2 = (poaDaily / daylightHours) * 1000.0;
      final cellTempC = irradiance.monthlyAvgTempC[m] + (_noctC - 20) / 800.0 * avgDaylightIrradianceWm2;
      final tempLossFraction = (-_tempCoeffPercentPerC / 100.0 * (cellTempC - 25)).clamp(-0.5, 0.5);
      final tempDeratedFactor = (1 - tempLossFraction).clamp(0.0, 1.5);

      final dcEnergyDaily = peakPowerKwp * poaDaily * tempDeratedFactor;
      final acEnergyDaily = dcEnergyDaily * systemLosses.combinedDerateFactor();
      final monthTotal = acEnergyDaily * daysInMonth;

      monthlyProduction[m] = monthTotal;
      // totalPoaKwh += poaDaily * daysInMonth;
      totalIdealHorizontalKwh += ghiDaily * daysInMonth;
      totalTempLossWeighted += tempLossFraction * daysInMonth;
    }

    final yearlyKwh = monthlyProduction.fold<double>(0, (a, b) => a + b);
    final dailyKwh = yearlyKwh / 365.25;
    final monthlyKwh = yearlyKwh / 12.0;
    final capacityFactor = peakPowerKwp > 0 ? yearlyKwh / (peakPowerKwp * 8766) : 0.0;
    final co2Offset = yearlyKwh * EnergyEstimate.co2PerKwh;
    final avgTempLossFraction = totalTempLossWeighted / 365.0;

    // Headline performance ratio: realized AC energy vs. the simplified
    // "ideal" energy an array of this kWp would produce if every kWh/m² of
    // horizontal irradiance converted 1:1 with no losses at all — a
    // common, if approximate, way to express one PR number to users.
    final idealYearlyKwh = peakPowerKwp * totalIdealHorizontalKwh;
    final double performanceRatio = idealYearlyKwh > 0 ? (yearlyKwh / idealYearlyKwh).clamp(0.0, 1.5).toDouble() : systemLosses.combinedDerateFactor();

    return EnergyEstimate(
      dailyKwh: dailyKwh,
      monthlyKwh: monthlyKwh,
      yearlyKwh: yearlyKwh,
      monthlyProductionKwh: monthlyProduction,
      capacityFactor: capacityFactor,
      performanceRatio: performanceRatio,
      peakSunHours: irradiance.averagePeakSunHours,
      peakPowerKwp: peakPowerKwp,
      annualCo2OffsetKg: co2Offset,
      losses: systemLosses,
      avgTemperatureLossFraction: avgTempLossFraction,
      isRealWeatherData: irradiance.isRealData,
    );
  }
}
