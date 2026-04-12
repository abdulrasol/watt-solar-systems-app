import 'dart:convert';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/errors/exceptions.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class AppInitLocalDataSource {
  /// Gets the cached [List<Config>] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<List<Config>> getLastConfigs();

  Future<void> cacheConfigs(List<Config> configs);
}

const cashedConfigs = 'CACHED_CONFIGS';

class AppInitLocalDataSourceImpl implements AppInitLocalDataSource {
  final CasheInterface casheInterface;

  AppInitLocalDataSourceImpl({required this.casheInterface});

  @override
  Future<List<Config>> getLastConfigs() async {
    try {
      final jsonString = casheInterface.get(cashedConfigs);
      if (jsonString != null) {
        final List decodedJson = jsonDecode(jsonString);
        return decodedJson.map<Config>((e) => Config.fromJson(e)).toList();
      } else {
        throw const CacheException();
      }
    } catch (e, stackTrace) {
      dPrint('getLastConfigs error: $e', stackTrace: stackTrace, tag: 'AppInitLocalDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<void> cacheConfigs(List<Config> configs) async {
    try {
      final jsonString = jsonEncode(configs.map((e) => e.toJson()).toList());
      await casheInterface.save(cashedConfigs, jsonString);
    } catch (e, stackTrace) {
      dPrint('cacheConfigs error: $e', stackTrace: stackTrace, tag: 'AppInitLocalDataSourceImpl');
      rethrow;
    }
  }
}
