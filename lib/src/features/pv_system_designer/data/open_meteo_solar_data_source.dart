import 'package:solar_hub/src/features/pv_system_designer/domain/entities/solar_irradiance_data.dart';

class OpenMeteoSolarDataSource {
  Future<SolarIrradianceData> fetchSolarData({required double latitude, required double longitude}) async {
    // TODO: Integrate with http package or dio for actual API calls
    // For now, falls back to latitude-based estimation
    return SolarIrradianceData.estimate(latitude);
  }

  SolarIrradianceData parseApiResponse(Map<String, dynamic> data, double latitude, double longitude) {
    final daily = data['daily'] as Map<String, dynamic>?;
    final radiationValues = daily?['shortwave_radiation_sum'] as List<dynamic>?;

    final todayRadiation = radiationValues?.isNotEmpty == true ? (radiationValues![0] as num).toDouble() : null;
    final psh = todayRadiation ?? _estimatePshFromLatitude(latitude);

    const seasonalVariation = [0.7, 0.8, 0.95, 1.1, 1.2, 1.25, 1.2, 1.1, 0.95, 0.8, 0.7, 0.65];
    final monthly = seasonalVariation.map((f) => psh * f * 30).toList();
    final annualGhi = psh * 365;

    return SolarIrradianceData(
      latitude: latitude,
      longitude: longitude,
      monthlyGlobalTilted: monthly,
      annualGlobalHorizontal: annualGhi,
      averagePeakSunHours: psh,
    );
  }

  double _estimatePshFromLatitude(double latitude) {
    final lat = latitude.abs();
    if (lat < 15) return 6.0;
    if (lat < 30) return 5.5;
    if (lat < 45) return 4.5;
    if (lat < 60) return 3.5;
    return 2.5;
  }
}
