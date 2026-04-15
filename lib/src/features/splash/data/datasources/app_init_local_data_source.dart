import 'dart:convert';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/errors/exceptions.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config_snapshot.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class AppInitLocalDataSource {
  Future<ConfigSnapshot> getCachedConfigs();

  Future<void> cacheConfigs(List<Config> configs);
}

const cashedConfigs = 'CACHED_CONFIGS';
const _configCacheSchemaVersion = 1;

class AppInitLocalDataSourceImpl implements AppInitLocalDataSource {
  final CasheInterface casheInterface;

  AppInitLocalDataSourceImpl({required this.casheInterface});

  @override
  Future<ConfigSnapshot> getCachedConfigs() async {
    try {
      final rawCache = casheInterface.get(cashedConfigs);
      if (rawCache == null) {
        throw const CacheException();
      }

      final Map<String, dynamic> decodedCache = _decodeCache(rawCache);
      final schemaVersion = decodedCache['schema_version'] as int?;
      if (schemaVersion != _configCacheSchemaVersion) {
        throw const CacheException('Unsupported config cache schema');
      }

      final List<dynamic> configsJson =
          decodedCache['configs'] as List<dynamic>? ?? const [];
      final lastUpdatedRaw = decodedCache['last_updated'] as String?;

      return ConfigSnapshot(
        configs: configsJson
            .map((item) => Config.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        lastUpdated: lastUpdatedRaw == null
            ? null
            : DateTime.tryParse(lastUpdatedRaw),
        isFromCache: true,
        schemaVersion: schemaVersion!,
      );
    } catch (e, stackTrace) {
      dPrint(
        'getCachedConfigs error: $e',
        stackTrace: stackTrace,
        tag: 'AppInitLocalDataSourceImpl',
      );
      rethrow;
    }
  }

  @override
  Future<void> cacheConfigs(List<Config> configs) async {
    try {
      final jsonString = jsonEncode({
        'schema_version': _configCacheSchemaVersion,
        'last_updated': DateTime.now().toUtc().toIso8601String(),
        'configs': configs.map((e) => e.toJson()).toList(),
      });
      await casheInterface.save(cashedConfigs, jsonString);
    } catch (e, stackTrace) {
      dPrint('cacheConfigs error: $e', stackTrace: stackTrace, tag: 'AppInitLocalDataSourceImpl');
      rethrow;
    }
  }

  Map<String, dynamic> _decodeCache(dynamic rawCache) {
    if (rawCache is String) {
      final decoded = jsonDecode(rawCache);
      if (decoded is List) {
        return {
          'schema_version': _configCacheSchemaVersion,
          'last_updated': null,
          'configs': decoded,
        };
      }
      return Map<String, dynamic>.from(decoded as Map);
    }

    if (rawCache is List) {
      return {
        'schema_version': _configCacheSchemaVersion,
        'last_updated': null,
        'configs': rawCache,
      };
    }

    if (rawCache is Map) {
      return Map<String, dynamic>.from(rawCache);
    }

    throw const CacheException('Invalid config cache payload');
  }
}
