import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/features/splash/domain/entities/config.dart';
import 'package:watt/src/utils/app_urls.dart';
import 'package:watt/src/utils/helper_methods.dart';

abstract class AppInitRemoteDataSource {
  /// Calls the endpoint to get the app configurations.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<Config>> getConfigs();
}

class AppInitRemoteDataSourceImpl implements AppInitRemoteDataSource {
  final DioService _dioService;

  AppInitRemoteDataSourceImpl(this._dioService);

  @override
  Future<List<Config>> getConfigs() async {
    try {
      final response = await _dioService.get(AppUrls.appConfigs);
      final List<Config> configs = (response.body as List).map((e) => Config.fromJson(e)).toList();
      return configs;
    } catch (e, stackTrace) {
      dPrint('getConfigs error: $e', stackTrace: stackTrace, tag: 'AppInitRemoteDataSourceImpl');
      rethrow;
    }
  }
}
