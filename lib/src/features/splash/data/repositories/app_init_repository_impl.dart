import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/exceptions.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/splash/data/datasources/app_init_remote_data_source.dart';
import 'package:solar_hub/src/features/splash/data/datasources/app_init_local_data_source.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config.dart';
import 'package:solar_hub/src/features/splash/domain/repositories/app_init_repository.dart';

class AppInitRepositoryImpl implements AppInitRepository {
  final AppInitRemoteDataSource remoteDataSource;
  final AppInitLocalDataSource localDataSource;

  AppInitRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Config>>> getConfigs() async {
    try {
      final remoteConfigs = await remoteDataSource.getConfigs();
      localDataSource.cacheConfigs(remoteConfigs);
      return Right(remoteConfigs);
    } on ServerException catch (e) {
      try {
        final localConfigs = await localDataSource.getLastConfigs();
        return Right(localConfigs);
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      try {
        final localConfigs = await localDataSource.getLastConfigs();
        return Right(localConfigs);
      } on CacheException {
        return Left(ServerFailure(e.toString()));
      }
    }
  }
}
