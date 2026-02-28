import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/core/services/dio.dart';
import 'package:solar_hub/features/admin/models/config.dart';
import 'package:solar_hub/utils/app_urls.dart';

class AdminServices {
  final DioService _dioService = getIt<DioService>();

  Future<List<Config>> getConfigs() async {
    final response = await _dioService.get(AppUrls.configs, isList: true);
    return (response.body as List).map((e) => Config.fromJson(e)).toList().cast<Config>();
  }

  Future<void> createConfig(Config flag) async {
    await _dioService.post(AppUrls.configs, data: flag.toJson());
  }

  Future<void> updateConfig(Config flag) async {
    await _dioService.put('${AppUrls.configs}/${flag.key}', data: flag.toJson());
  }

  Future<void> deleteConfig(String key) async {
    await _dioService.delete('${AppUrls.configs}/$key');
  }
}
