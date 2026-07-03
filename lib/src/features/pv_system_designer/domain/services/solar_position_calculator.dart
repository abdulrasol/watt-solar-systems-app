import 'dart:math' as math;

/// The sun's position in the sky for a given place and instant in time.
///
/// `elevationDeg` is the angle above the horizon (negative = below horizon,
/// i.e. nighttime). `azimuthDeg` is measured clockwise from true north
/// (0=N, 90=E, 180=S, 270=W), which matches the convention already used by
/// [FacingDirectionPreference] and the wall-orientation logic elsewhere in
/// this feature.
class SunPosition {
  const SunPosition({required this.elevationDeg, required this.azimuthDeg});

  final double elevationDeg;
  final double azimuthDeg;

  bool get isDaylight => elevationDeg > 0;

  /// Shadow length cast by an object of [objectHeight], projected
  /// horizontally, for this sun position. Returns null when the sun is at
  /// or below the horizon (shadow is effectively infinite/undefined).
  double? shadowLengthFor(double objectHeight) {
    if (elevationDeg <= 0.5) return null;
    final elevationRad = elevationDeg * math.pi / 180.0;
    return objectHeight / math.tan(elevationRad);
  }
}

/// Computes real sun-position geometry (declination, hour angle, elevation,
/// azimuth) from latitude/longitude/date/time, replacing ad-hoc heuristics
/// that don't actually track where the sun is.
///
/// Formulas follow the standard NOAA/Spencer solar-position approximations
/// used throughout solar-engineering practice (accurate to a fraction of a
/// degree, which is more than sufficient for rooftop shading/row-spacing
/// analysis — full ephemeris-grade precision is not needed here).
class SolarPositionCalculator {
  const SolarPositionCalculator();

  /// [date] should be a local wall-clock date/time at the site (the hour
  /// the user picked on the simulation slider, on the date they picked).
  /// [latitude]/[longitude] in degrees. [utcOffsetHours] is the site's
  /// standard UTC offset (e.g. 3.0 for Baghdad); defaults to estimating it
  /// from longitude (15° per hour) when not supplied, which is a reasonable
  /// fallback when the app doesn't have timezone data for the site.
  SunPosition calculate({
    required DateTime date,
    required double latitude,
    required double longitude,
    double? utcOffsetHours,
  }) {
    final dayOfYear = _dayOfYear(date);
    final gamma = 2 * math.pi / 365 * (dayOfYear - 1 + (date.hour - 12) / 24);

    // Solar declination (Spencer's Fourier series), radians.
    final declination = 0.006918 -
        0.399912 * math.cos(gamma) +
        0.070257 * math.sin(gamma) -
        0.006758 * math.cos(2 * gamma) +
        0.000907 * math.sin(2 * gamma) -
        0.002697 * math.cos(3 * gamma) +
        0.00148 * math.sin(3 * gamma);

    // Equation of time (minutes) — corrects clock time to true solar time.
    final eqTimeMinutes = 229.18 *
        (0.000075 +
            0.001868 * math.cos(gamma) -
            0.032077 * math.sin(gamma) -
            0.014615 * math.cos(2 * gamma) -
            0.040849 * math.sin(2 * gamma));

    final assumedUtcOffset = utcOffsetHours ?? (longitude / 15.0);
    final timeOffsetMinutes = eqTimeMinutes + 4 * longitude - 60 * assumedUtcOffset;
    final trueSolarTimeMinutes = date.hour * 60 + date.minute + date.second / 60.0 + timeOffsetMinutes;

    // Hour angle: 15° per hour from solar noon, radians.
    final hourAngleDeg = (trueSolarTimeMinutes / 4.0) - 180.0;
    final hourAngle = hourAngleDeg * math.pi / 180.0;

    final latRad = latitude * math.pi / 180.0;

    final cosZenith = math.sin(latRad) * math.sin(declination) + math.cos(latRad) * math.cos(declination) * math.cos(hourAngle);
    final zenithRad = math.acos(cosZenith.clamp(-1.0, 1.0));
    final elevationDeg = 90.0 - (zenithRad * 180.0 / math.pi);

    // Azimuth (clockwise from north), using the standard atan2-based form
    // to stay numerically stable near solar noon and near the horizon.
    final sinAzimuth = -math.sin(hourAngle) * math.cos(declination) / math.sin(zenithRad).clamp(1e-9, double.infinity);
    final cosAzimuth = (math.sin(declination) - math.sin(latRad) * cosZenith) / (math.cos(latRad) * math.sin(zenithRad).clamp(1e-9, double.infinity));
    var azimuthDeg = math.atan2(sinAzimuth, cosAzimuth) * 180.0 / math.pi + 180.0;
    azimuthDeg = azimuthDeg % 360.0;
    if (azimuthDeg < 0) azimuthDeg += 360.0;

    return SunPosition(elevationDeg: elevationDeg, azimuthDeg: azimuthDeg);
  }

  /// Approximate sunrise/sunset as decimal local hours (e.g. 6.25 = 6:15am),
  /// used to size the "simulation time" slider realistically for the
  /// selected site/date instead of a fixed 8:00–17:00 range.
  ({double sunrise, double sunset}) sunriseSunset({
    required DateTime date,
    required double latitude,
    required double longitude,
    double? utcOffsetHours,
  }) {
    final dayOfYear = _dayOfYear(date);
    final gamma = 2 * math.pi / 365 * (dayOfYear - 1);
    final declination = 0.006918 -
        0.399912 * math.cos(gamma) +
        0.070257 * math.sin(gamma) -
        0.006758 * math.cos(2 * gamma) +
        0.000907 * math.sin(2 * gamma) -
        0.002697 * math.cos(3 * gamma) +
        0.00148 * math.sin(3 * gamma);
    final eqTimeMinutes = 229.18 *
        (0.000075 +
            0.001868 * math.cos(gamma) -
            0.032077 * math.sin(gamma) -
            0.014615 * math.cos(2 * gamma) -
            0.040849 * math.sin(2 * gamma));
    final latRad = latitude * math.pi / 180.0;

    final cosHourAngle = (math.cos(90.833 * math.pi / 180.0) / (math.cos(latRad) * math.cos(declination))) - (math.tan(latRad) * math.tan(declination));
    if (cosHourAngle > 1) {
      // Polar night: sun never rises.
      return (sunrise: 12.0, sunset: 12.0);
    }
    if (cosHourAngle < -1) {
      // Midnight sun: sun never sets.
      return (sunrise: 0.0, sunset: 24.0);
    }
    final hourAngleSunrise = math.acos(cosHourAngle) * 180.0 / math.pi;
    final assumedUtcOffset = utcOffsetHours ?? (longitude / 15.0);

    final solarNoonMinutes = 720 - 4 * longitude - eqTimeMinutes + 60 * assumedUtcOffset;
    final sunriseMinutes = solarNoonMinutes - hourAngleSunrise * 4;
    final sunsetMinutes = solarNoonMinutes + hourAngleSunrise * 4;

    return (sunrise: (sunriseMinutes / 60.0).clamp(0.0, 24.0).toDouble(), sunset: (sunsetMinutes / 60.0).clamp(0.0, 24.0).toDouble());
  }

  int _dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }

  /// Sun position at true solar noon (hour angle = 0) for the given day of
  /// year, skipping clock-time/timezone/equation-of-time corrections
  /// entirely since solar noon is defined directly by the hour angle. Used
  /// by [EnergyEstimator] for monthly plane-of-array transposition, where
  /// a single representative-day, solar-noon sun position is a standard
  /// simplification for daily/monthly (not hourly) irradiance modeling.
  SunPosition atSolarNoon({required int dayOfYear, required double latitude}) {
    final gamma = 2 * math.pi / 365 * (dayOfYear - 1);
    final declination = 0.006918 -
        0.399912 * math.cos(gamma) +
        0.070257 * math.sin(gamma) -
        0.006758 * math.cos(2 * gamma) +
        0.000907 * math.sin(2 * gamma) -
        0.002697 * math.cos(3 * gamma) +
        0.00148 * math.sin(3 * gamma);

    final latRad = latitude * math.pi / 180.0;
    const hourAngle = 0.0; // solar noon by definition

    final cosZenith = math.sin(latRad) * math.sin(declination) + math.cos(latRad) * math.cos(declination) * math.cos(hourAngle);
    final zenithRad = math.acos(cosZenith.clamp(-1.0, 1.0));
    final elevationDeg = 90.0 - (zenithRad * 180.0 / math.pi);

    final sinAzimuth = -math.sin(hourAngle) * math.cos(declination) / math.sin(zenithRad).clamp(1e-9, double.infinity);
    final cosAzimuth = (math.sin(declination) - math.sin(latRad) * cosZenith) / (math.cos(latRad) * math.sin(zenithRad).clamp(1e-9, double.infinity));
    var azimuthDeg = math.atan2(sinAzimuth, cosAzimuth) * 180.0 / math.pi + 180.0;
    azimuthDeg = azimuthDeg % 360.0;
    if (azimuthDeg < 0) azimuthDeg += 360.0;

    return SunPosition(elevationDeg: elevationDeg, azimuthDeg: azimuthDeg);
  }

  /// Extraterrestrial daily horizontal irradiation H0 (kWh/m²/day) for the
  /// given day of year and latitude — the theoretical maximum irradiation
  /// with no atmosphere, used as the denominator for the daily clearness
  /// index (KT) that drives the Erbs diffuse-fraction correlation.
  double extraterrestrialDailyKwhM2({required int dayOfYear, required double latitude}) {
    const solarConstantKw = 1.367;
    final gamma = 2 * math.pi / 365 * (dayOfYear - 1);
    final declination = 0.006918 -
        0.399912 * math.cos(gamma) +
        0.070257 * math.sin(gamma) -
        0.006758 * math.cos(2 * gamma) +
        0.000907 * math.sin(2 * gamma) -
        0.002697 * math.cos(3 * gamma) +
        0.00148 * math.sin(3 * gamma);
    final eccentricityCorrection = 1.000110 +
        0.034221 * math.cos(gamma) +
        0.001280 * math.sin(gamma) +
        0.000719 * math.cos(2 * gamma) +
        0.000077 * math.sin(2 * gamma);

    final latRad = latitude * math.pi / 180.0;
    final cosSunsetHourAngle = (-math.tan(latRad) * math.tan(declination)).clamp(-1.0, 1.0);
    final sunsetHourAngle = math.acos(cosSunsetHourAngle);

    final h0 = (24 / math.pi) *
        solarConstantKw *
        eccentricityCorrection *
        (math.cos(latRad) * math.cos(declination) * math.sin(sunsetHourAngle) + sunsetHourAngle * math.sin(latRad) * math.sin(declination));
    return math.max(0.0, h0);
  }
}
