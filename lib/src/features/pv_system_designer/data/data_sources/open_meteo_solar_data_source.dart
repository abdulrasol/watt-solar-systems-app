import 'package:dio/dio.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/solar_irradiance_data.dart';

class OpenMeteoSolarDataSource {
  const OpenMeteoSolarDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<SolarIrradianceData> fetchHistoricalTiltedIrradiance({
    required double latitude,
    required double longitude,
    required double tiltDeg,
    required double azimuthDeg,
    DateTime? start,
    DateTime? end,
  }) async {
    final now = DateTime.now();
    final s = start ?? DateTime(now.year - 1, 1, 1);
    final e = end ?? DateTime(now.year - 1, 12, 31);

    final startStr = _dateString(s);
    final endStr = _dateString(e);

    // Open-Meteo azimuth: 0=south, -90=east, 90=west, ±180=north
    // Our convention: 0=north, 90=east, 180=south, 270=west
    final openMeteoAzimuth = _toOpenMeteoAzimuth(azimuthDeg);

    final response = await _dio.get(
      'https://archive-api.open-meteo.com/v1/archive',
      queryParameters: {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'start_date': startStr,
        'end_date': endStr,
        'hourly': 'global_tilted_irradiance',
        'tilt': tiltDeg.toStringAsFixed(1),
        'azimuth': openMeteoAzimuth.toStringAsFixed(1),
        'timezone': 'auto',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Open-Meteo error: ${response.statusCode} ${response.data}');
    }

    final json = response.data as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>?;
    final times = (hourly?['time'] as List<dynamic>? ?? []).cast<String>();
    final values = (hourly?['global_tilted_irradiance'] as List<dynamic>? ?? [])
        .map((v) => (v as num?)?.toDouble() ?? 0.0)
        .toList();

    return SolarIrradianceData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? latitude,
      longitude: (json['longitude'] as num?)?.toDouble() ?? longitude,
      startDate: s,
      endDate: e,
      hourlyTimes: times.map(DateTime.parse).toList(),
      hourlyGtiWm2: values,
      source: 'Open-Meteo',
    );
  }

  static String _dateString(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  static double _toOpenMeteoAzimuth(double azimuthDeg) {
    // Convert clockwise-from-north to Open-Meteo's south=0 convention.
    var converted = azimuthDeg - 180.0;
    while (converted > 180.0) {
      converted -= 360.0;
    }
    while (converted < -180.0) {
      converted += 360.0;
    }
    return converted;
  }
}
