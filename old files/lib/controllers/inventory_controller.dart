import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/services/supabase_service.dart';

class InventoryController extends GetxController {
  final _dbService = SupabaseService();
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final searchQuery = ''.obs;
  final stockFilter = StockFilter.all.obs;

  // Pagination

  // Pagination
  int _page = 0;
  final int _limit = 20;
  var hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Re-fetch when company loads/changes
    ever(Get.find<CompanyController>().company, (_) => fetchMyProducts(isRefresh: true));
    fetchMyProducts(isRefresh: true);
  }

  Future<void> fetchMyProducts({bool isRefresh = false}) async {
    final companyId = Get.find<CompanyController>().company.value?.id;
    if (companyId == null) {
      debugPrint('server @fetchMyProducts: companyId is null, skipping fetch.');
      return;
    }

    if (isRefresh) {
      _page = 0;
      hasMore.value = true;
      isLoading.value = true;
    } else {
      if (!hasMore.value) return;
      isMoreLoading.value = true;
    }

    try {
      final rangeStart = _page * _limit;
      final rangeEnd = rangeStart + _limit - 1;

      var query = _dbService.client
          .from('products')
          .select('*, product_pricing_tiers(*), product_options(*, product_option_values(*)), product_company_categories(company_categories(*))')
          .eq('company_id', companyId);

      // 1. Text Search (Name or SKU)
      final search = searchQuery.value.trim();
      if (search.isNotEmpty) {
        query = query.or('name.ilike.%$search%,sku.ilike.%$search%');
      }

      // 2. Stock Filter
      if (stockFilter.value == StockFilter.outOfStock) {
        query = query.eq('stock_quantity', 0);
      } else if (stockFilter.value == StockFilter.inStock) {
        query = query.gt('stock_quantity', 0);
      } else if (stockFilter.value == StockFilter.lowStock) {
        // Simple logic: stock <= min_stock_alert (requires raw filter as min_stock_alert is a col)
        // Or simpler: stock <= 5 if generic.
        // Supabase Postgrest supports col comparisons? Not easily in standard SDK without raw filter.
        // Let's use a simpler heuristic or do it client side if list small? No, pagination.
        // Using filter syntax:
        query = query.lte('stock_quantity', 5); // Fallback to 5 or generic low stock
      }

      final response = await query.order('created_at', ascending: false).range(rangeStart, rangeEnd);

      final data = List<Map<String, dynamic>>.from(response);
      final newProducts = data.map((e) => ProductModel.fromJson(e)).toList();

      if (isRefresh) {
        products.assignAll(newProducts);
      } else {
        products.addAll(newProducts);
      }

      if (newProducts.length < _limit) {
        hasMore.value = false;
      } else {
        _page++;
      }

      debugPrint('server @fetchMyProducts: Fetched ${newProducts.length} items. Total: ${products.length}');
    } catch (e) {
      debugPrint('server error @fetchMyProducts: $e');
      Get.snackbar('Error', 'Failed to fetch inventory: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  /// Adds stock from a B2B purchase.
  /// Handles weighted average cost price calculation.
  Future<void> addStockFromPurchase({
    required String companyId,
    required String productNameSnapshot,
    required int quantityAdded,
    required double unitCostPrice,
  }) async {
    try {
      debugPrint('[STOCK_ADD] Attempting stock add for company $companyId: $productNameSnapshot x$quantityAdded at \$$unitCostPrice');
      await _dbService.client.rpc(
        'add_stock_from_purchase',
        params: {'p_company_id': companyId, 'p_product_name': productNameSnapshot, 'p_quantity': quantityAdded, 'p_unit_cost': unitCostPrice},
      );
      debugPrint('[STOCK_ADD] Success: Stock added via RPC for $productNameSnapshot');
    } catch (e) {
      debugPrint('[STOCK_ADD] Error adding stock via RPC for $productNameSnapshot: $e');
      // Don't rethrow, just log.
    }
  }

  Future<void> reduceStockForSale(String productId, int quantitySold) async {
    try {
      debugPrint('[STOCK_REDUCE] Attempting stock reduction for product $productId by $quantitySold via RPC');

      await _dbService.client.rpc('reduce_stock_secure', params: {'p_product_id': productId, 'p_quantity_sold': quantitySold});

      // Update local state if the product exists in the list
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final currentQty = products[index].stockQuantity;
        products[index] = products[index].copyWith(stockQuantity: currentQty - quantitySold);
        debugPrint('[STOCK_REDUCE] Success: Local state updated for product $productId');
      }

      debugPrint('[STOCK_REDUCE] Success: Product $productId reduced via RPC.');
    } catch (e) {
      debugPrint('[STOCK_REDUCE] Error reducing stock for product $productId: $e');
      rethrow; // Let POS handle error
    }
  }

  // Returns true if success, rethrows error if failed (caught by UI)
  Future<void> addProduct(Map<String, dynamic> productData, {List<ProductPricingTier>? tiers, List<ProductOption>? options, List<String>? categoryIds}) async {
    final companyId = Get.find<CompanyController>().company.value?.id;
    if (companyId == null) throw Exception("No company ID");

    productData['company_id'] = companyId;
    if (productData['sku'] != null && productData['sku'].toString().trim().isEmpty) {
      productData['sku'] = null;
    }

    // Prepare JSON structures for RPC
    final tiersJson = tiers?.map((e) => e.toJson()).toList() ?? [];
    final optionsJson = options?.map((e) => e.toJson()).toList() ?? [];
    final catIdsJson = categoryIds ?? <String>[];

    try {
      final response = await _dbService.client.rpc(
        'create_product_full',
        params: {
          'product_data': productData, // Main fields
          'pricing_tiers': tiersJson,
          'options': optionsJson,
          'category_ids': catIdsJson,
        },
      );

      if (response['success'] == true) {
        debugPrint('server @addProduct: Created product ${response['id']} via RPC');
        // Refresh list
        fetchMyProducts(isRefresh: true);
      } else {
        throw Exception("RPC returned failure without error: $response");
      }
    } catch (e) {
      debugPrint("server error @addProduct RPC: $e");
      rethrow;
    }
  }

  // Returns true if success
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> productData, {
    List<ProductPricingTier>? tiers,
    List<ProductOption>? options,
    List<String>? categoryIds,
  }) async {
    try {
      // 1. Update Product Base
      if (productData.containsKey('sku') && (productData['sku'] == null || productData['sku'].toString().trim().isEmpty)) {
        productData['sku'] = null;
      }
      await _dbService.client.from('products').update(productData).eq('id', productId);
      debugPrint('server @updateProduct: Updated product base $productId');

      // 2. Update Tiers (Delete & Re-insert)
      if (tiers != null) {
        await _dbService.client.from('product_pricing_tiers').delete().eq('product_id', productId);
        if (tiers.isNotEmpty) {
          final tiersData = tiers.map((t) => {'product_id': productId, 'min_quantity': t.minQuantity, 'unit_price': t.unitPrice}).toList();
          await _dbService.client.from('product_pricing_tiers').insert(tiersData);
        }
      }

      // 3. Update Options (Delete & Re-insert) - Simplest for handling structure changes
      if (options != null) {
        await _dbService.client.from('product_options').delete().eq('product_id', productId);

        if (options.isNotEmpty) {
          for (var opt in options) {
            final optResp = await _dbService.client
                .from('product_options')
                .insert({'product_id': productId, 'name': opt.name, 'is_required': opt.isRequired})
                .select()
                .single();

            final newOptId = optResp['id'];
            if (opt.values.isNotEmpty) {
              final valsData = opt.values.map((v) => {'option_id': newOptId, 'value': v.value, 'extra_cost': v.extraCost}).toList();
              await _dbService.client.from('product_option_values').insert(valsData);
            }
          }
        }
      }

      // 4. Update Categories (Delete & Re-insert)
      if (categoryIds != null) {
        await _dbService.client.from('product_company_categories').delete().eq('product_id', productId);
        if (categoryIds.isNotEmpty) {
          final catsData = categoryIds.map((cid) => {'product_id': productId, 'category_id': cid}).toList();
          await _dbService.client.from('product_company_categories').insert(catsData);
        }
      }

      fetchMyProducts(isRefresh: true);
    } catch (e) {
      debugPrint("server error @updateProduct: $e");
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _dbService.client.from('products').delete().eq('id', productId);
      products.removeWhere((p) => p.id == productId);
      debugPrint('server @deleteProduct: Deleted product $productId');
    } catch (e) {
      debugPrint("server error @deleteProduct: $e");
      Get.snackbar('Error', 'Failed to delete product: $e');
      rethrow;
    }
  }

  Future<String?> uploadProductImage(File imageFile) async {
    final companyId = Get.find<CompanyController>().company.value?.id;
    if (companyId == null) return null;

    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${companyId}_product.$fileExt';
      const bucketName = 'products';

      await _dbService.client.storage.from(bucketName).upload(fileName, imageFile);
      final publicUrl = _dbService.client.storage.from(bucketName).getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint('server error @uploadProductImage: $e');
      Get.snackbar('Error', 'Failed to upload image: $e');
      return null;
    }
  }
}

enum StockFilter { all, inStock, outOfStock, lowStock }
