import 'dart:math';

import 'package:solar_hub/src/features/pv_system_designer/domain/entities/energy_estimate.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/panel_layout.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_panel_spec.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/shading_analysis.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/site_profile.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/solar_irradiance_data.dart';

class EnergyEstimator {
  const EnergyEstimator({
    this.performanceRatio = 0.8,
    this.co2FactorKgPerKwh = 0.5,
  });

  final double performanceRatio;
  final double co2FactorKgPerKwh;

  Future<EnergyEstimate> estimateFromIrradiance({
    required SiteProfile site,
    required PvPanelSpec panelSpec,
    required PanelLayout layout,
    required ShadingAnalysis shading,
    required SolarIrradianceData data,
    double avgTariffPerKwh = 0.18,
  }) async {
    final monthlyKwh = <int, double>{};
    final panelArea = panelSpec.areaM2;
    final panelCount = layout.panelCount;

    if (panelCount == 0 || data.hourlyGtiWm2.isEmpty) {
      return EnergyEstimate(avgTariffPerKwh: avgTariffPerKwh);
    }

    for (var i = 0; i < data.hourlyTimes.length && i < data.hourlyGtiWm2.length; i++) {
      final dt = data.hourlyTimes[i];
      final gti = data.hourlyGtiWm2[i];
      if (gti <= 0) continue;

      // GTI is average W/m² over the hour -> Wh/m².
      final whPerPanel = gti * panelArea * performanceRatio;
      final monthFactor = shading.monthlyShadingFactors[dt.month] ?? 1.0;
      final kwh = whPerPanel * panelCount * monthFactor / 1000.0;

      monthlyKwh[dt.month] = (monthlyKwh[dt.month] ?? 0.0) + kwh;
    }

    final yearly = monthlyKwh.values.fold<double>(0.0, (a, b) => a + b);
    final peakKw = panelCount * panelSpec.powerW / 1000.0;
    final capacityFactor = peakKw > 0 ? yearly / (peakKw * 8760.0) : 0.0;

    return EnergyEstimate(
      monthlyKwh: monthlyKwh,
      yearlyKwh: yearly,
      peakKw: peakKw,
      capacityFactor: capacityFactor.clamp(0.0, 1.0),
      co2OffsetKg: yearly * co2FactorKgPerKwh,
      estimatedSavings: yearly * avgTariffPerKwh,
      avgTariffPerKwh: avgTariffPerKwh,
      dataSource: data.source,
    );
  }

  /// Offline fallback using a clear-sky model scaled by a latitude-dependent
  /// clearness index. Good enough when the user has no connectivity.
  EnergyEstimate estimateFallback({
    required SiteProfile site,
    required PvPanelSpec panelSpec,
    required PanelLayout layout,
    required ShadingAnalysis shading,
    double avgTariffPerKwh = 0.18,
  }) {
    final monthlyKwh = <int, double>{};
    final panelCount = layout.panelCount;
    final peakKw = panelCount * panelSpec.powerW / 1000.0;

    if (panelCount == 0) {
      return EnergyEstimate(avgTariffPerKwh: avgTariffPerKwh);
    }

    final absLat = site.latitude.abs();
    final clearnessIndex = _clearnessIndex(absLat);

    for (var month = 1; month <= 12; month++) {
      final dayOfYear = _dayOfYearForMonth(month);
      final declination = _declination(dayOfYear);
      final sunsetHourAngle = _sunsetHourAngle(site.latitude, declination);
      final daylightHours = _radToDeg(sunsetHourAngle) * 2.0 / 15.0;

      if (daylightHours <= 0) {
        monthlyKwh[month] = 0.0;
        continue;
      }

      final extraterrestrialRadiation =
          _extraterrestrialRadiation(dayOfYear, site.latitude, declination, sunsetHourAngle);
      final horizontalRadiation = extraterrestrialRadiation * clearnessIndex;

      // Simple tilt/azimuth factor.
      final tiltFactor = _tiltFactor(
        site.latitude,
        declination,
        _degToRad(site.roofAzimuthDeg),
        _degToRad(_effectiveTilt(site)),
      );

      final monthFactor = shading.monthlyShadingFactors[month] ?? 1.0;
      final monthlyHours = _daysInMonth(month) * daylightHours;
      final avgGti = horizontalRadiation * tiltFactor / max(monthlyHours, 1.0);
      final monthlyEnergy = avgGti *
          panelSpec.areaM2 *
          panelCount *
          monthlyHours *
          performanceRatio *
          monthFactor /
          1000.0;

      monthlyKwh[month] = monthlyEnergy.clamp(0.0, double.infinity);
    }

    final yearly = monthlyKwh.values.fold<double>(0.0, (a, b) => a + b);
    final capacityFactor = peakKw > 0 ? yearly / (peakKw * 8760.0) : 0.0;

    return EnergyEstimate(
      monthlyKwh: monthlyKwh,
      yearlyKwh: yearly,
      peakKw: peakKw,
      capacityFactor: capacityFactor.clamp(0.0, 1.0),
      co2OffsetKg: yearly * co2FactorKgPerKwh,
      estimatedSavings: yearly * avgTariffPerKwh,
      avgTariffPerKwh: avgTariffPerKwh,
      dataSource: 'Offline fallback',
    );
  }

  double _effectiveTilt(SiteProfile site) {
    return switch (site.mountType) {
      _ => site.roofPitchDeg,
    };
  }

  double _clearnessIndex(double absLat) {
    // Empirical: clearer skies near tropics, lower at high latitudes.
    return 0.55 + 0.15 * cos(_degToRad(absLat.clamp(0.0, 90.0)));
  }

  double _declination(int dayOfYear) {
    return _degToRad(23.45 * sin(_degToRad((360.0 / 365.0) * (dayOfYear - 81))));
  }

  double _sunsetHourAngle(double lat, double declination) {
    final arg = -tan(_degToRad(lat)) * tan(declination);
    if (arg <= -1.0) return pi;
    if (arg >= 1.0) return 0.0;
    return acos(arg);
  }

  double _extraterrestrialRadiation(
    int dayOfYear,
    double lat,
    double declination,
    double sunsetHourAngle,
  ) {
    final gsc = 1367.0; // W/m²
    final dr = 1.0 + 0.033 * cos(_degToRad((360.0 * dayOfYear) / 365.0));
    final latRad = _degToRad(lat);
    final omega = sunsetHourAngle;
    final ho = (24.0 * 3600.0 / pi) *
        gsc *
        dr *
        (cos(latRad) * cos(declination) * sin(omega) +
            omega * sin(latRad) * sin(declination));
    return max(ho, 0.0); // J/m²/day
  }

  double _tiltFactor(double lat, double declination, double azimuth, double tilt) {
    final latRad = _degToRad(lat);
    final cosTheta = sin(declination) * sin(latRad) * cos(tilt) -
        sin(declination) * cos(latRad) * sin(tilt) * cos(azimuth) +
        cos(declination) * cos(latRad) * cos(tilt) * cos(0) +
        cos(declination) * sin(latRad) * sin(tilt) * cos(azimuth) * cos(0);
    final cosZenith = sin(declination) * sin(latRad) +
        cos(declination) * cos(latRad) * cos(0);
    return max(cosTheta / max(cosZenith, 0.001), 0.0);
  }

  int _dayOfYearForMonth(int month) {
    return [15, 45, 74, 105, 135, 166, 196, 227, 258, 288, 319, 349][month - 1];
  }

  int _daysInMonth(int month) {
    return [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1];
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
  static double _radToDeg(double rad) => rad * 180.0 / pi;
}
