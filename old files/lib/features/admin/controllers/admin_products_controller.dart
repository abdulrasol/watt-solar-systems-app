import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/services/supabase_service.dart';

class AdminProductsController extends GetxController {
  final _supabase = SupabaseService().client;
  final isLoading = false.obs;
  final products = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final response = await _supabase.from('products').select('*, companies(name)').order('created_at', ascending: false);

      // Note: ProductModel might need adjustment if it doesn company name directly,
      // but for now we will try to map common fields.
      // Assuming ProductModel.fromJson handles the standard fields.
      // If we need company name, we might need a custom model or just use Map for this admin view if the model is strict.
      // Let's check ProductModel if possible, but for now I'll stick to a dynamic list or reuse the model if it fits.
      // To be safe and fast, I'll use the Model but we might need to be careful about the joined data.

      final List<ProductModel> loadedProducts = [];
      for (var item in response) {
        loadedProducts.add(ProductModel.fromJson(item));
      }
      products.assignAll(loadedProducts);
    } catch (e) {
      debugPrint("Error fetching products: $e");
      Get.snackbar("Error", "Failed to load products");
    } finally {
      isLoading.value = false;
    }
  }
}
