import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/services/supabase_service.dart';

class AdminOrdersController extends GetxController {
  final _supabase = SupabaseService().client;
  final isLoading = false.obs;
  // Using dynamic list for now as OrderModel structure might be complex and I want to avoid import issues if I don't know the exact path.
  // Ideally we should use OrderModel if known.
  final orders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      // Fetch orders with some related data if possible
      final response = await _supabase
          .from('orders')
          .select('*, items:order_items(count)') // simplified query
          .order('created_at', ascending: false);

      orders.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint("Error fetching admin orders: $e");
      Get.snackbar("Error", "Failed to load orders");
    } finally {
      isLoading.value = false;
    }
  }
}
