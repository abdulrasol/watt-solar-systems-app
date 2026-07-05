import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/features/admin/data/data_sources/app_config_remote_data_source.dart';
import 'package:solar_hub/src/features/admin/domain/entities/app_config.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/app_config_repository.dart';

class AppConfigRepositoryImpl implements AppConfigRepository {
  final AppConfigRemoteDataSource remoteDataSource;

  AppConfigRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, List<AppConfig>>> getAllConfigs() async {
    try {
      final configs = await remoteDataSource.getAllConfigs();
      return Right(configs);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, AppConfig>> createConfig(AppConfig config) async {
    try {
      final createdConfig = await remoteDataSource.createConfig(config);
      return Right(createdConfig);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, AppConfig>> updateConfig(String key, AppConfig config) async {
    try {
      final updatedConfig = await remoteDataSource.updateConfig(key, config);
      return Right(updatedConfig);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> deleteConfig(String key) async {
    try {
      await remoteDataSource.deleteConfig(key);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, AppConfig>> toggleConfig(String key, bool value) async {
    try {
      final toggledConfig = await remoteDataSource.toggleConfig(key, value);
      return Right(toggledConfig);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
