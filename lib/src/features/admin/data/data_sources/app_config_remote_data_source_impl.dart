import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/admin/data/data_sources/app_config_remote_data_source.dart';
import 'package:solar_hub/src/features/admin/domain/entities/app_config.dart';
import 'package:solar_hub/src/utils/app_urls.dart';

class AppConfigRemoteDataSourceImpl implements AppConfigRemoteDataSource {
  final DioService dioService;

  AppConfigRemoteDataSourceImpl({required this.dioService});

  @override
  Future<List<AppConfig>> getAllConfigs() async {
    final response = await dioService.get(AppUrls.appConfigs, isList: true);
    if (response.status == 200 && !response.error) {
      final List<dynamic> configsJson = response.body;
      return configsJson.map((json) => AppConfig.fromJson(json)).toList();
    }
    throw Exception(response.messageUser.isNotEmpty ? response.messageUser : response.message);
  }

  @override
  Future<AppConfig> createConfig(AppConfig config) async {
    final response = await dioService.post(AppUrls.appConfigs, data: {'key': config.key, 'value': config.value, 'description': config.description});
    if ((response.status == 201 || response.status == 200) && !response.error) {
      return AppConfig.fromJson(response.body);
    }
    throw Exception(response.messageUser.isNotEmpty ? response.messageUser : response.message);
  }

  @override
  Future<AppConfig> updateConfig(String key, AppConfig config) async {
    final response = await dioService.put('${AppUrls.appConfigs}/$key', data: {'key': config.key, 'value': config.value, 'description': config.description});
    if (response.status == 200 && !response.error) {
      return AppConfig.fromJson(response.body);
    }
    throw Exception(response.messageUser.isNotEmpty ? response.messageUser : response.message);
  }

  @override
  Future<void> deleteConfig(String key) async {
    try {
      final response = await dioService.delete('${AppUrls.appConfigs}/$key');
      // Check if response indicates success (status 200/204 or no error flag)
      if (response.error) {
        throw Exception(response.messageUser.isNotEmpty ? response.messageUser : response.message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to delete config: ${e.toString()}');
    }
  }

  @override
  Future<AppConfig> toggleConfig(String key, bool value) async {
    final response = await dioService.put('${AppUrls.appConfigs}/$key', data: {'value': value});
    if (response.status == 200 && !response.error) {
      return AppConfig.fromJson(response.body);
    }
    throw Exception(response.messageUser.isNotEmpty ? response.messageUser : response.message);
  }
}
