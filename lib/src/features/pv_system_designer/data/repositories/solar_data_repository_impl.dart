import 'package:solar_hub/src/features/pv_system_designer/data/data_sources/open_meteo_solar_data_source.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/solar_irradiance_data.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/repositories/solar_data_repository.dart';

class SolarDataRepositoryImpl implements SolarDataRepository {
  const SolarDataRepositoryImpl({required OpenMeteoSolarDataSource dataSource})
      : _dataSource = dataSource;

  final OpenMeteoSolarDataSource _dataSource;

  @override
  Future<SolarIrradianceData> fetchHistoricalTiltedIrradiance({
    required double latitude,
    required double longitude,
    required double tiltDeg,
    required double azimuthDeg,
    DateTime? start,
    DateTime? end,
  }) {
    return _dataSource.fetchHistoricalTiltedIrradiance(
      latitude: latitude,
      longitude: longitude,
      tiltDeg: tiltDeg,
      azimuthDeg: azimuthDeg,
      start: start,
      end: end,
    );
  }
}
