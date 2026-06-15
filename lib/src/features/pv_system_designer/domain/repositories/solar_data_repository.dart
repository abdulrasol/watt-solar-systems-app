import 'package:solar_hub/src/features/pv_system_designer/domain/entities/solar_irradiance_data.dart';

abstract class SolarDataRepository {
  Future<SolarIrradianceData> fetchHistoricalTiltedIrradiance({
    required double latitude,
    required double longitude,
    required double tiltDeg,
    required double azimuthDeg,
    DateTime? start,
    DateTime? end,
  });
}
