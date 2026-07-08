import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/features/admin/domain/entities/app_config.dart';

abstract class AppConfigRepository {
  Future<Either<Exception, List<AppConfig>>> getAllConfigs();
  Future<Either<Exception, AppConfig>> createConfig(AppConfig config);
  Future<Either<Exception, AppConfig>> updateConfig(String key, AppConfig config);
  Future<Either<Exception, void>> deleteConfig(String key);
  Future<Either<Exception, AppConfig>> toggleConfig(String key, bool value);
}
