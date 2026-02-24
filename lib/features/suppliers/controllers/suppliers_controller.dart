import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/services/supabase_service.dart';

class SuppliersController extends GetxController {
  final _supabase = SupabaseService().client;

  final isLoading = false.obs;
  final wholesalers = <CompanyModel>[].obs;
  final supplierProducts = <ProductModel>[].obs;

  // Cache for pricing tiers: productId -> List<ProductPricingTier>
  final productTiers = <String, List<ProductPricingTier>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSuppliers();
  }

  /// Fetch all companies that are wholesalers
  Future<void> fetchSuppliers() async {
    try {
      isLoading.value = true;
      // Fetch companies with tier 'wholesaler' or 'distributor'
      // Note: Adjust the 'tier' check based on actual data values if needed
      var query = _supabase
          .from('companies')
          .select()
          .or('tier.eq.wholesaler,tier.eq.intermediary') // B2B tiers
          .eq('status', 'active') // Only show active companies (subscribed/verified)
          .eq('allows_b2b', true);

      // Filter out my own company if I am logged in as one
      try {
        if (Get.isRegistered<CompanyController>()) {
          final myCompanyId = Get.find<CompanyController>().company.value?.id;
          if (myCompanyId != null) {
            query = query.neq('id', myCompanyId);
          }
        }
      } catch (_) {}

      final response = await query.order('name', ascending: true);

      final List<dynamic> data = response;
      wholesalers.assignAll(data.map((json) => CompanyModel.fromJson(json)).toList());
    } catch (e) {
      debugPrint('Error fetching suppliers: $e');
      // Get.snackbar('Error', 'Failed to load suppliers'); // Avoid calling on init if no overlay
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch products for a specific supplier
  Future<void> fetchSupplierProducts(String companyId) async {
    try {
      isLoading.value = true;
      supplierProducts.clear();
      productTiers.clear();

      // Get active products with wholesale price
      final response = await _supabase
          .from('products')
          .select('*, product_pricing_tiers(*), product_options(*, product_option_values(*))')
          .eq('company_id', companyId)
          .eq('status', 'active')
          .gt('wholesale_price', 0)
          .order('name', ascending: true);

      final List<dynamic> data = response;

      final List<ProductModel> loadedProducts = [];

      for (var item in data) {
        final product = ProductModel.fromJson(item);
        loadedProducts.add(product);

        // ProductModel.fromJson handles nested 'product_pricing_tiers' if structured correctly
        // But let's ensure we cache them for easy access if needed separately
        if (product.pricingTiers.isNotEmpty) {
          productTiers[product.id!] = product.pricingTiers;
        }
      }

      supplierProducts.assignAll(loadedProducts);
    } catch (e) {
      debugPrint('Error fetching supplier products: $e');
      // Get.snackbar('Error', 'Failed to load supplier catalog');
    } finally {
      isLoading.value = false;
    }
  }
}
