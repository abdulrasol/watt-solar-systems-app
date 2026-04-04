import 'package:solar_hub/src/features/admin/domain/entities/app_config.dart';

abstract class AppConfigRemoteDataSource {
  Future<List<AppConfig>> getAllConfigs();
  Future<AppConfig> createConfig(AppConfig config);
  Future<AppConfig> updateConfig(String id, AppConfig config);
  Future<void> deleteConfig(String id);
  Future<AppConfig> toggleConfig(String id, bool value);
}
