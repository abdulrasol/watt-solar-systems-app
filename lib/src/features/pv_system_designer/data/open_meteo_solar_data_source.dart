import 'package:dio/dio.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/solar_irradiance_data.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

/// Fetches real historical solar-irradiance and temperature climate data
/// for a site from Open-Meteo's free, no-API-key Historical Weather
/// (Archive) API, and buckets it into monthly averages for
/// [EnergyEstimator].
///
/// Previously this class was a stub that always returned the latitude-only
/// synthetic estimate regardless of location — this is the real
/// implementation. On any network/parsing failure it falls back to the
/// same synthetic estimate rather than surfacing an error, so the wizard
/// always has usable (if less precise) numbers to show.
class OpenMeteoSolarDataSource {
  OpenMeteoSolarDataSource({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _archiveBaseUrl = 'https://archive-api.open-meteo.com/v1/archive';

  Future<SolarIrradianceData> fetchSolarData({required double latitude, required double longitude}) async {
    try {
      // Archive data typically lags a few days behind "today"; use the
      // most recent full year available rather than requesting up to
      // today and risking an incomplete/erroring last few rows.
      final endDate = DateTime.now().subtract(const Duration(days: 4));
      final startDate = endDate.subtract(const Duration(days: 365));

      final response = await _dio.get(
        _archiveBaseUrl,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'start_date': _formatDate(startDate),
          'end_date': _formatDate(endDate),
          'daily': 'shortwave_radiation_sum,temperature_2m_mean',
          'timezone': 'auto',
        },
        options: Options(receiveTimeout: const Duration(seconds: 20), sendTimeout: const Duration(seconds: 20)),
      );

      final data = response.data;
      if (data is! Map) {
        throw const FormatException('Unexpected Open-Meteo response shape');
      }
      final parsed = parseApiResponse(Map<String, dynamic>.from(data), latitude, longitude);
      return parsed;
    } catch (e, stackTrace) {
      dPrint('OpenMeteo fetchSolarData failed, falling back to estimate: $e', stackTrace: stackTrace, tag: 'OpenMeteoSolarDataSource');
      return SolarIrradianceData.estimate(latitude, longitude: longitude);
    }
  }

  /// Buckets daily `shortwave_radiation_sum` (MJ/m², converted to
  /// kWh/m²/day) and `temperature_2m_mean` (°C) into calendar-month
  /// averages. Exposed separately from [fetchSolarData] so it can be unit
  /// tested against a fixture response without a network call.
  SolarIrradianceData parseApiResponse(Map<String, dynamic> data, double latitude, double longitude) {
    final daily = data['daily'] as Map<String, dynamic>?;
    final times = (daily?['time'] as List<dynamic>?) ?? const [];
    final radiationMjValues = (daily?['shortwave_radiation_sum'] as List<dynamic>?) ?? const [];
    final tempValues = (daily?['temperature_2m_mean'] as List<dynamic>?) ?? const [];

    if (times.isEmpty || radiationMjValues.isEmpty) {
      return SolarIrradianceData.estimate(latitude, longitude: longitude);
    }

    final monthlyGhiSum = List<double>.filled(12, 0);
    final monthlyGhiCount = List<int>.filled(12, 0);
    final monthlyTempSum = List<double>.filled(12, 0);
    final monthlyTempCount = List<int>.filled(12, 0);
    double minTemp = double.infinity;
    double maxTemp = -double.infinity;

    for (int i = 0; i < times.length; i++) {
      final dateStr = times[i] as String?;
      if (dateStr == null || dateStr.length < 7) continue;
      final month = int.tryParse(dateStr.substring(5, 7));
      if (month == null || month < 1 || month > 12) continue;
      final monthIndex = month - 1;

      if (i < radiationMjValues.length) {
        final mj = (radiationMjValues[i] as num?)?.toDouble();
        if (mj != null) {
          final kwhM2 = mj / 3.6; // 1 kWh/m² = 3.6 MJ/m²
          monthlyGhiSum[monthIndex] += kwhM2;
          monthlyGhiCount[monthIndex]++;
        }
      }
      if (i < tempValues.length) {
        final t = (tempValues[i] as num?)?.toDouble();
        if (t != null) {
          monthlyTempSum[monthIndex] += t;
          monthlyTempCount[monthIndex]++;
          if (t < minTemp) minTemp = t;
          if (t > maxTemp) maxTemp = t;
        }
      }
    }

    final fallback = SolarIrradianceData.estimate(latitude, longitude: longitude);
    final monthlyGhi = List<double>.generate(12, (m) => monthlyGhiCount[m] > 0 ? monthlyGhiSum[m] / monthlyGhiCount[m] : fallback.monthlyAvgDailyGhiKwhM2[m]);
    final monthlyTemp = List<double>.generate(12, (m) => monthlyTempCount[m] > 0 ? monthlyTempSum[m] / monthlyTempCount[m] : fallback.monthlyAvgTempC[m]);

    final hasAnyRealData = monthlyGhiCount.any((c) => c > 0);
    if (!hasAnyRealData) return fallback;

    return SolarIrradianceData(
      monthlyAvgDailyGhiKwhM2: monthlyGhi,
      monthlyAvgTempC: monthlyTemp,
      approxMinTempC: minTemp.isFinite ? minTemp : fallback.approxMinTempC,
      approxMaxTempC: maxTemp.isFinite ? maxTemp : fallback.approxMaxTempC,
      latitude: latitude,
      longitude: longitude,
      isRealData: true,
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
