import 'dart:convert';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/errors/exceptions.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config.dart';

abstract class AppInitLocalDataSource {
  /// Gets the cached [List<Config>] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<List<Config>> getLastConfigs();

  Future<void> cacheConfigs(List<Config> configs);
}

const CACHED_CONFIGS = 'CACHED_CONFIGS';

class AppInitLocalDataSourceImpl implements AppInitLocalDataSource {
  final CasheInterface casheInterface;

  AppInitLocalDataSourceImpl({required this.casheInterface});

  @override
  Future<List<Config>> getLastConfigs() async {
    final jsonString = casheInterface.get(CACHED_CONFIGS);
    if (jsonString != null) {
      final List decodedJson = jsonDecode(jsonString);
      return decodedJson.map<Config>((e) => Config.fromJson(e)).toList();
    } else {
      throw const CacheException();
    }
  }

  @override
  Future<void> cacheConfigs(List<Config> configs) async {
    final jsonString = jsonEncode(configs.map((e) => e.toJson()).toList());
    await casheInterface.save(CACHED_CONFIGS, jsonString);
  }
}
