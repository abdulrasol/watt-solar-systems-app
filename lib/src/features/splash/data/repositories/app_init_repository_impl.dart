import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/splash/data/datasources/app_init_remote_data_source.dart';
import 'package:solar_hub/src/features/splash/data/datasources/app_init_local_data_source.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config_snapshot.dart';
import 'package:solar_hub/src/features/splash/domain/repositories/app_init_repository.dart';

class AppInitRepositoryImpl implements AppInitRepository {
  final AppInitRemoteDataSource remoteDataSource;
  final AppInitLocalDataSource localDataSource;

  AppInitRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ConfigSnapshot>> getCachedConfigs() async {
    try {
      final cachedConfigs = await localDataSource.getCachedConfigs();
      return Right(cachedConfigs);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConfigSnapshot>> refreshConfigs() async {
    try {
      final remoteConfigs = await remoteDataSource.getConfigs();
      await localDataSource.cacheConfigs(remoteConfigs);
      final cachedSnapshot = await localDataSource.getCachedConfigs();
      return Right(cachedSnapshot.copyWith(isFromCache: false));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
