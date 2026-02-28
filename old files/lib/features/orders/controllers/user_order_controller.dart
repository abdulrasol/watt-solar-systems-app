import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserOrderController extends GetxController {
  final _client = Supabase.instance.client;
  var orders = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      // Fetch orders where this user is the buyer
      final response = await _client
          .from('orders')
          .select('*, companies:seller_company_id(name, logo_url)')
          .eq('buyer_user_id', userId)
          .order('created_at', ascending: false);

      orders.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getStatusText(String status) {
    return status.capitalizeFirst ?? status;
  }
}
