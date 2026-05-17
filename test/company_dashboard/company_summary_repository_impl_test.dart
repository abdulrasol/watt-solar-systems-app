import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import 'package:solar_hub/src/features/company_dashboard/data/data_sources/local_datasource.dart';
import 'package:solar_hub/src/features/company_dashboard/data/data_sources/remote_datasource.dart';
import 'package:solar_hub/src/features/company_dashboard/data/repositories/company_summary_repository_impl.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/summary.dart';
import 'package:solar_hub/src/features/settings/domain/entiteis/settings.dart';

void main() {
  group('CompanySummaryRepositoryImpl', () {
    test('returns fresh remote summary and updates cache', () async {
      final fresh = _company(id: 1, name: 'Fresh');
      final remote = _FakeRemoteDataSource(Right(fresh));
      final local = _FakeLocalDataSource();
      final repository = CompanySummaryRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final result = await repository.getCompanySummary(1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected remote summary'),
        (summary) => expect(summary.name, 'Fresh'),
      );
      expect(local.savedSummary?.name, 'Fresh');
      expect(local.getCalls, 0);
    });

    test('uses cached summary only for NetworkFailure', () async {
      final cached = _company(id: 1, name: 'Cached');
      final remote = _FakeRemoteDataSource(
        const Left(NetworkFailure('offline')),
      );
      final local = _FakeLocalDataSource(cachedSummary: cached);
      final repository = CompanySummaryRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final result = await repository.getCompanySummary(1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected cached summary'),
        (summary) => expect(summary.name, 'Cached'),
      );
      expect(local.getCalls, 1);
    });

    test('does not use cached summary for server failures', () async {
      final cached = _company(id: 1, name: 'Cached');
      final remote = _FakeRemoteDataSource(const Left(ServerFailure('server')));
      final local = _FakeLocalDataSource(cachedSummary: cached);
      final repository = CompanySummaryRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final result = await repository.getCompanySummary(1);

      expect(result.isLeft(), isTrue);
      expect(local.getCalls, 0);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });
  });

  group('LocalDataSourceImpl', () {
    test('reads summary cache stored as a map', () async {
      final cache = _FakeCache();
      final local = LocalDataSourceImpl(casheInterface: cache);
      final company = _company(id: 7, name: 'Map Payload');
      await cache.save('company_summary_7', company.toJson());

      final result = await local.getCompanySummary(7);

      expect(result.name, 'Map Payload');
    });

    test('reads summary cache stored as a JSON string', () async {
      final cache = _FakeCache();
      final local = LocalDataSourceImpl(casheInterface: cache);
      final company = _company(id: 8, name: 'String Payload');
      await cache.save('company_summary_8', jsonEncode(company.toJson()));

      final result = await local.getCompanySummary(8);

      expect(result.name, 'String Payload');
    });
  });
}

CompanySummary _company({required int id, required String name}) {
  return CompanySummary(
    id: id,
    name: name,
    allowsB2B: true,
    allowsB2C: true,
    status: 'active',
  );
}

class _FakeRemoteDataSource implements RemoteDataSource {
  _FakeRemoteDataSource(this.result);

  final Either<Failure, CompanySummary> result;

  @override
  Future<Either<Failure, CompanySummary>> getCompanySummary(int id) async {
    return result;
  }
}

class _FakeLocalDataSource implements LocalDataSource {
  _FakeLocalDataSource({this.cachedSummary});

  final CompanySummary? cachedSummary;
  CompanySummary? savedSummary;
  int getCalls = 0;

  @override
  Future<CompanySummary> getCompanySummary(int id) async {
    getCalls += 1;
    final cachedSummary = this.cachedSummary;
    if (cachedSummary == null) {
      throw Exception('missing cache');
    }
    return cachedSummary;
  }

  @override
  Future<void> saveCompanySummary(int id, CompanySummary summary) async {
    savedSummary = summary;
  }
}

class _FakeBox implements CacheBox {
  @override
  VoidCallback listenKey(String key, void Function(dynamic value) callback) =>
      () {};
}

class _FakeCache implements CasheInterface {
  @override
  CacheBox box = _FakeBox();

  final Map<String, dynamic> _values = <String, dynamic>{};

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> deleteByPrefix(String prefix) async {
    _values.removeWhere((key, value) => key.startsWith(prefix));
  }

  @override
  dynamic get(String key) => _values[key];

  @override
  Future<void> save(String key, dynamic value) async {
    _values[key] = value;
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    _values['settings'] = settings.toJson();
  }

  @override
  Future<void> saveToken(String token) async {
    _values['token'] = token;
  }

  @override
  Future<void> saveUser(User user) async {
    _values['user'] = user.toJson();
  }

  @override
  Settings settings() => Settings(
    isDark: false,
    isNotificationEnabled: true,
    language: 'en',
    saveRolePageSelection: false,
  );

  @override
  String? token() => _values['token'] as String?;

  @override
  User? user() {
    final raw = _values['user'];
    if (raw is Map<String, dynamic>) {
      return User.fromJson(raw);
    }
    return null;
  }
}
