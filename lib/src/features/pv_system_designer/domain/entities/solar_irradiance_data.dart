import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Real (or, when the API is unreachable, estimated) horizontal irradiance
/// and ambient-temperature climate data for a site, used as the input to
/// [EnergyEstimator]'s plane-of-array transposition and temperature-derate
/// calculations.
///
/// This intentionally stores *horizontal*-plane irradiance (GHI), not
/// panel-tilted irradiance — transposing onto the array's actual tilt and
/// azimuth is done in [EnergyEstimator] using real sun-position geometry,
/// rather than being baked into this data source. That keeps "what the sky
/// delivered" (this class) separate from "what the array captures of it"
/// (the energy estimator), which is the standard way PV yield tools are
/// structured.
@immutable
class SolarIrradianceData {
  /// Average daily global horizontal irradiance, in kWh/m²/day, for each
  /// calendar month (index 0 = January … 11 = December). Numerically this
  /// is also "peak sun hours" for that month on a horizontal surface,
  /// since 1 kWh/m²/day of insolation is defined as 1 peak sun hour at the
  /// 1 kW/m² STC reference irradiance.
  final List<double> monthlyAvgDailyGhiKwhM2;

  /// Average ambient (dry-bulb) temperature, °C, for each calendar month.
  final List<double> monthlyAvgTempC;

  /// Rough cold/hot ambient-temperature extremes observed in the source
  /// data window, used as a simplified proxy for inverter/string
  /// cold-Voc / hot-Vmp design-temperature checks. Not a substitute for a
  /// proper ASHRAE 2%/97.5% design-temperature lookup, but far better than
  /// a fixed guess.
  final double approxMinTempC;
  final double approxMaxTempC;

  final double latitude;
  final double longitude;

  /// True when this data came from a real weather API call; false when it
  /// is the latitude-only synthetic fallback (used when the API call
  /// fails, e.g. no network). The UI should disclose this to the user so
  /// energy numbers aren't presented as more precise than they are.
  final bool isRealData;

  const SolarIrradianceData({
    required this.monthlyAvgDailyGhiKwhM2,
    required this.monthlyAvgTempC,
    required this.approxMinTempC,
    required this.approxMaxTempC,
    required this.latitude,
    required this.longitude,
    required this.isRealData,
  });

  double get annualAvgDailyGhiKwhM2 => monthlyAvgDailyGhiKwhM2.isEmpty
      ? 0
      : monthlyAvgDailyGhiKwhM2.reduce((a, b) => a + b) / monthlyAvgDailyGhiKwhM2.length;

  /// "Peak sun hours" — kept as a named getter since it's the term shown
  /// in the UI and used throughout solar-industry documentation.
  double get averagePeakSunHours => annualAvgDailyGhiKwhM2;

  /// Latitude-only synthetic fallback for when no network/API data is
  /// available. This is deliberately a *documented last resort*: it uses a
  /// smooth analytic model (better than a 5-bucket lookup table) but is
  /// still a rough estimate, not real climate data for the site.
  factory SolarIrradianceData.estimate(double latitude, {double longitude = 0}) {
    final lat = latitude.abs();
    final double basePsh;
    if (lat < 15) {
      basePsh = 6.0;
    } else if (lat < 30) {
      basePsh = 5.5;
    } else if (lat < 45) {
      basePsh = 4.5;
    } else if (lat < 60) {
      basePsh = 3.5;
    } else {
      basePsh = 2.5;
    }

    final isNorthern = latitude >= 0;
    final monthlyGhi = List<double>.generate(12, (i) {
      // Peaks at the local summer solstice month, trough at local winter
      // solstice month, using a smooth cosine seasonal shape rather than a
      // fixed lookup table.
      final monthAngle = 2 * math.pi * (i - (isNorthern ? 5 : 11)) / 12;
      final seasonalFactor = 1.0 + 0.28 * math.cos(monthAngle);
      return basePsh * seasonalFactor;
    });

    final baseTempC = 28 - lat * 0.45;
    final monthlyTemp = List<double>.generate(12, (i) {
      final monthAngle = 2 * math.pi * (i - (isNorthern ? 6 : 0)) / 12;
      final amplitude = 6 + lat * 0.25;
      return baseTempC + amplitude * math.cos(monthAngle);
    });

    return SolarIrradianceData(
      monthlyAvgDailyGhiKwhM2: monthlyGhi,
      monthlyAvgTempC: monthlyTemp,
      approxMinTempC: monthlyTemp.reduce(math.min) - 8,
      approxMaxTempC: monthlyTemp.reduce(math.max) + 12,
      latitude: latitude,
      longitude: longitude,
      isRealData: false,
    );
  }
}
