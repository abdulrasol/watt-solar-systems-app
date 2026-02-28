import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/features/admin/models/config.dart';
import 'package:solar_hub/features/admin/services/admin_services.dart';
import 'package:solar_hub/utils/helper_methods.dart';

class AdminController extends GetxService {
  final _services = getIt<AdminServices>();
  RxList<Config> configs = <Config>[].obs;
  RxList<String> keys = <String>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConfigs();
  }

  Future<void> fetchConfigs() async {
    try {
      isLoading.value = true;
      final response = await _services.getConfigs();
      final newFlags = <Config>[];

      for (var item in response) {
        newFlags.add(item);
      }

      configs.assignAll(newFlags);
      keys.assignAll(configs.map((flag) => flag.key).toList());
    } catch (e, s) {
      dPrint("Error fetching app config: $e", tag: 'AppConfigController error', stackTrace: s);
    } finally {
      isLoading.value = false;
    }
  }

  bool isEnabled(String key, {bool defaultValue = true}) {
    if (configs.isEmpty) return defaultValue;
    return configs.firstWhereOrNull((flag) => flag.key == key)?.value ?? defaultValue;
  }

  Future<void> updateConfig(Config flag, {bool isCreate = false}) async {
    try {
      isLoading.value = true;
      if (isCreate) {
        await _services.createConfig(flag);
      } else {
        await _services.updateConfig(flag);
      }
      // Update local state
      // Use 'f' to avoid shadowing 'flag'
      final index = configs.indexWhere((f) => f.key == flag.key);
      if (index != -1) {
        configs[index] = flag;
      } else {
        configs.add(flag);
      }
      // Refresh keys list just in case
      keys.assignAll(configs.map((f) => f.key).toList());
      configs.refresh(); // Ensure UI updates
    } catch (e) {
      debugPrint("Error updating config: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Admin: Delete Config
  Future<void> deleteConfig(String key) async {
    try {
      await _services.deleteConfig(key);
      configs.removeWhere((f) => f.key == key);
      keys.assignAll(configs.map((f) => f.key).toList());
    } catch (e) {
      rethrow;
    }
  }
}
