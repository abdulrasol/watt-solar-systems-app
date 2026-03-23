import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config.dart';
import 'package:solar_hub/src/utils/app_urls.dart';

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
    final response = await _dioService.get(AppUrls.configs, isList: true);
    final List<Config> configs = (response.body as List).map((e) => Config.fromJson(e)).toList();
    return configs;
  }
}
