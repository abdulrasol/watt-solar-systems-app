import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/services/supabase_service.dart';

class AdminSystemsController extends GetxController {
  final _supabase = SupabaseService().client;
  final isLoading = false.obs;
  // Dynamic list for flexibility
  final systems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSystems();
  }

  Future<void> fetchSystems() async {
    isLoading.value = true;
    try {
      final response = await _supabase.from('systems').select('*, companies(name)').order('created_at', ascending: false);

      systems.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint("Error fetching admin systems: $e");
      Get.snackbar("Error", "Failed to load systems");
    } finally {
      isLoading.value = false;
    }
  }
}
