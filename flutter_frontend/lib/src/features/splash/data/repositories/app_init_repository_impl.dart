import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watt/src/core/errors/failure.dart';
import 'package:watt/src/features/splash/data/data_sources/app_init_remote_data_source.dart';
import 'package:watt/src/features/splash/data/data_sources/app_init_local_data_source.dart';
import 'package:watt/src/features/splash/domain/entities/config_snapshot.dart';
import 'package:watt/src/features/splash/domain/repositories/app_init_repository.dart';

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
      if (_isConnectivityError(e)) {
        try {
          final cachedConfigs = await localDataSource.getCachedConfigs();
          return Right(cachedConfigs);
        } catch (_) {
          return Left(NetworkFailure(e.toString()));
        }
      }

      return Left(ServerFailure(e.toString()));
    }
  }

  bool _isConnectivityError(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout;
    }
    return false;
  }
}
