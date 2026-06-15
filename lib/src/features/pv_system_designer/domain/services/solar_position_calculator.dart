import 'dart:math';

/// Solar position result for a given moment and location.
class SolarPosition {
  const SolarPosition({
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.zenithDeg,
    required this.azimuthDeg,
    required this.elevationDeg,
    required this.declinationDeg,
    required this.hourAngleDeg,
  });

  final DateTime dateTime;
  final double latitude;
  final double longitude;

  /// Zenith angle in degrees (0 = overhead, 90 = horizon).
  final double zenithDeg;

  /// Solar azimuth in degrees, measured clockwise from true north.
  final double azimuthDeg;

  /// Solar elevation above horizon in degrees.
  final double elevationDeg;

  /// Solar declination in degrees.
  final double declinationDeg;

  /// Solar hour angle in degrees.
  final double hourAngleDeg;

  bool get isDaytime => elevationDeg > 0;
}

/// Calculates solar position using a simplified SPA-like algorithm.
///
/// Reference: Blanco-Muriel et al., "Computing the Solar Vector", 2001.
class SolarPositionCalculator {
  const SolarPositionCalculator();

  SolarPosition calculate({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
  }) {
    final dt = dateTime.toUtc();
    final jd = _julianDay(dt);
    final d = jd - 2451545.0;

    // Mean longitude (deg)
    var L = (280.460 + 0.9856474 * d) % 360.0;
    if (L < 0) L += 360.0;

    // Mean anomaly (deg)
    var g = (357.528 + 0.9856003 * d) % 360.0;
    if (g < 0) g += 360.0;
    final gRad = _degToRad(g);

    // Ecliptic longitude (deg)
    var lambda = L + 1.915 * sin(gRad) + 0.020 * sin(2 * gRad);
    lambda = lambda % 360.0;
    if (lambda < 0) lambda += 360.0;

    // Obliquity of the ecliptic (deg)
    final epsilon = 23.439 - 0.0000004 * d;

    // Right ascension (deg)
    final alpha = _radToDeg(
      atan2(
        cos(_degToRad(epsilon)) * sin(_degToRad(lambda)),
        cos(_degToRad(lambda)),
      ),
    );

    // Declination (deg)
    final delta = _radToDeg(
      asin(sin(_degToRad(epsilon)) * sin(_degToRad(lambda))),
    );

    // Greenwich Mean Sidereal Time (deg)
    var gmst = (6.697375 + 0.0657098242 * d + dt.hour + dt.minute / 60.0 + dt.second / 3600.0) * 15.0;
    gmst = gmst % 360.0;
    if (gmst < 0) gmst += 360.0;

    // Local hour angle (deg)
    var h = gmst + longitude - alpha;
    h = ((h + 180.0) % 360.0) - 180.0;

    final latRad = _degToRad(latitude);
    final hRad = _degToRad(h);
    final deltaRad = _degToRad(delta);

    // Elevation
    final sinElev =
        sin(deltaRad) * sin(latRad) + cos(deltaRad) * cos(latRad) * cos(hRad);
    final elevation = _radToDeg(asin(sinElev));

    // Azimuth
    final y = -sin(hRad);
    final x = tan(deltaRad) * cos(latRad) - sin(latRad) * cos(hRad);
    var azimuth = _radToDeg(atan2(y, x));
    if (azimuth < 0) azimuth += 360.0;

    final zenith = 90.0 - elevation;

    return SolarPosition(
      dateTime: dateTime,
      latitude: latitude,
      longitude: longitude,
      zenithDeg: zenith.clamp(0.0, 180.0),
      azimuthDeg: azimuth,
      elevationDeg: elevation,
      declinationDeg: delta,
      hourAngleDeg: h,
    );
  }

  /// Solar elevation and azimuth for a specific hour of a given day.
  SolarPosition forHour({
    required DateTime date,
    required double hour,
    required double latitude,
    required double longitude,
  }) {
    final h = hour.floor();
    final min = ((hour - h) * 60).round();
    final dt = DateTime(date.year, date.month, date.day, h, min);
    return calculate(dateTime: dt, latitude: latitude, longitude: longitude);
  }

  /// Lists solar positions for every hour of the given day.
  List<SolarPosition> hourlyForDay({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    return List.generate(24, (i) {
      return calculate(
        dateTime: DateTime(date.year, date.month, date.day, i),
        latitude: latitude,
        longitude: longitude,
      );
    });
  }

  double _julianDay(DateTime dt) {
    var y = dt.year;
    var m = dt.month.toDouble();
    final d = dt.day + dt.hour / 24.0 + dt.minute / 1440.0 + dt.second / 86400.0;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
  static double _radToDeg(double rad) => rad * 180.0 / pi;
}
