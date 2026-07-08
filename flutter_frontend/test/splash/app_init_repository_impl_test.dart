import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watt/src/core/errors/failure.dart';
import 'package:watt/src/features/splash/data/data_sources/app_init_local_data_source.dart';
import 'package:watt/src/features/splash/data/data_sources/app_init_remote_data_source.dart';
import 'package:watt/src/features/splash/data/repositories/app_init_repository_impl.dart';
import 'package:watt/src/features/splash/domain/entities/config.dart';
import 'package:watt/src/features/splash/domain/entities/config_snapshot.dart';

void main() {
  test('refreshConfigs caches and returns fresh remote configs', () async {
    final remote = _FakeAppInitRemoteDataSource(
      configs: [Config(key: 'fresh', value: true)],
    );
    final local = _FakeAppInitLocalDataSource();
    final repository = AppInitRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );

    final result = await repository.refreshConfigs();

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('Expected fresh configs'), (snapshot) {
      expect(snapshot.isFromCache, isFalse);
      expect(snapshot.configs.single.key, 'fresh');
    });
    expect(local.cacheConfigsCalls, 1);
    expect(local.cachedConfigs.single.key, 'fresh');
  });

  test('refreshConfigs falls back to cached configs when offline', () async {
    final remote = _FakeAppInitRemoteDataSource(
      error: DioException(
        requestOptions: RequestOptions(path: '/configs'),
        type: DioExceptionType.connectionError,
      ),
    );
    final local = _FakeAppInitLocalDataSource(
      cachedConfigs: [Config(key: 'cached', value: true)],
    );
    final repository = AppInitRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );

    final result = await repository.refreshConfigs();

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('Expected cached configs'), (snapshot) {
      expect(snapshot.isFromCache, isTrue);
      expect(snapshot.configs.single.key, 'cached');
    });
  });

  test(
    'refreshConfigs returns NetworkFailure when offline cache is empty',
    () async {
      final remote = _FakeAppInitRemoteDataSource(
        error: DioException(
          requestOptions: RequestOptions(path: '/configs'),
          type: DioExceptionType.receiveTimeout,
        ),
      );
      final local = _FakeAppInitLocalDataSource(throwOnGetCached: true);
      final repository = AppInitRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final result = await repository.refreshConfigs();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected NetworkFailure'),
      );
    },
  );

  test('refreshConfigs does not use cache for non-network failures', () async {
    final remote = _FakeAppInitRemoteDataSource(error: Exception('server'));
    final local = _FakeAppInitLocalDataSource(
      cachedConfigs: [Config(key: 'cached', value: true)],
    );
    final repository = AppInitRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );

    final result = await repository.refreshConfigs();

    expect(result.isLeft(), isTrue);
    expect(local.getCachedConfigsCalls, 0);
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected ServerFailure'),
    );
  });
}

class _FakeAppInitRemoteDataSource implements AppInitRemoteDataSource {
  _FakeAppInitRemoteDataSource({this.configs = const [], this.error});

  final List<Config> configs;
  final Object? error;

  @override
  Future<List<Config>> getConfigs() async {
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return configs;
  }
}

class _FakeAppInitLocalDataSource implements AppInitLocalDataSource {
  _FakeAppInitLocalDataSource({
    this.cachedConfigs = const [],
    this.throwOnGetCached = false,
  });

  List<Config> cachedConfigs;
  final bool throwOnGetCached;
  int cacheConfigsCalls = 0;
  int getCachedConfigsCalls = 0;

  @override
  Future<void> cacheConfigs(List<Config> configs) async {
    cacheConfigsCalls += 1;
    cachedConfigs = configs;
  }

  @override
  Future<ConfigSnapshot> getCachedConfigs() async {
    getCachedConfigsCalls += 1;
    if (throwOnGetCached) {
      throw Exception('no cache');
    }
    return ConfigSnapshot(
      configs: cachedConfigs,
      lastUpdated: DateTime.utc(2026, 1, 1),
      isFromCache: true,
      schemaVersion: 1,
    );
  }
}
