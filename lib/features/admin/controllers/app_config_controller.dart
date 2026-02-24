import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/admin/models/flag.dart';
import 'package:solar_hub/services/supabase_service.dart';

class AppConfigController extends GetxService {
  final _dbService = SupabaseService();

  // Reactive map of feature flags
  RxList<Flag> flags = <Flag>[].obs;
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
      final response = await _dbService.client.from('app_config').select();
      final data = List<Map<String, dynamic>>.from(response);
      final newFlags = <Flag>[];

      for (var item in data) {
        newFlags.add(Flag.fromJson(item));
      }

      flags.assignAll(newFlags);
      keys.assignAll(flags.map((flag) => flag.key).toList());
    } catch (e) {
      // print("Error fetching app config: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Sync check
  bool isEnabled(String key, {bool defaultValue = false}) {
    return flags.where((flag) => flag.key == key).first.value;
  }

  // Admin: Update Config
  Future<void> updateConfig(Flag flag) async {
    try {
      // isLoading.value = true;
      await _dbService.client.from('app_config').upsert({
        'key': flag.key,
        'value': flag.value, // Ensure value is updated
        'description': flag.description,
        'updated_at': DateTime.now().toIso8601String(),
      });
      // Update local state
      // Use 'f' to avoid shadowing 'flag'
      final index = flags.indexWhere((f) => f.key == flag.key);
      if (index != -1) {
        flags[index] = flag;
      } else {
        flags.add(flag);
      }
      // Refresh keys list just in case
      keys.assignAll(flags.map((f) => f.key).toList());
      flags.refresh(); // Ensure UI updates
    } catch (e) {
      debugPrint("Error updating config: $e");
      rethrow;
    } finally {
      // isLoading.value = false;
    }
  }

  // Admin: Delete Config
  Future<void> deleteConfig(String key) async {
    try {
      await _dbService.client.from('app_config').delete().eq('key', key);
      flags.removeWhere((f) => f.key == key);
      keys.assignAll(flags.map((f) => f.key).toList());
    } catch (e) {
      rethrow;
    }
  }
}
