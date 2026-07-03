import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/data/data_sources/admin_remote_data_source.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

class AdminProductsState {
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final List<StorefrontProduct> products;
  final int page;

  AdminProductsState({
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
    this.products = const [],
    this.page = 1,
  });

  AdminProductsState copyWith({
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    List<StorefrontProduct>? products,
    int? page,
  }) {
    return AdminProductsState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      products: products ?? this.products,
      page: page ?? this.page,
    );
  }
}

class AdminProductsController extends Notifier<AdminProductsState> {
  late AdminRemoteDataSource _adminDataSource;

  @override
  AdminProductsState build() {
    _adminDataSource = getIt<AdminRemoteDataSource>();
    return AdminProductsState();
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        page: 1,
        error: null,
        products: [],
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final response = await _adminDataSource.listAdminProducts(
        page: state.page,
        pageSize: 12,
      );
      final productsList = (response.body as List)
          .map((e) => StorefrontProduct.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        products: isRefresh ? productsList : [...state.products, ...productsList],
        hasMore: productsList.length >= 12,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        error: 'Failed to load products: ${e.toString()}',
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchProducts();
  }

  /// [companyId] is required by the backend's `AdminProductCreateSchema` —
  /// this is the field that was entirely missing before: admins could only
  /// view products, never create one (or reassign one to a different
  /// company on edit).
  Future<void> createProduct({
    required int companyId,
    required String name,
    String? sku,
    int? globalCategoryId,
    String? description,
    double costPrice = 0,
    double retailPrice = 0,
    double wholesalePrice = 0,
    double discount = 0,
    int stockQuantity = 0,
    int minStockAlert = 5,
    String status = 'active',
  }) async {
    final payload = jsonEncode({
      'company_id': companyId,
      'name': name,
      'sku': sku,
      'global_category_id': globalCategoryId,
      'description': description,
      'cost_price': costPrice,
      'retail_price': retailPrice,
      'wholesale_price': wholesalePrice,
      'discount': discount,
      'stock_quantity': stockQuantity,
      'min_stock_alert': minStockAlert,
      'status': status,
    });
    await _adminDataSource.createAdminProduct(payload);
    await fetchProducts(isRefresh: true);
  }

  /// Only fields the caller actually supplies are sent — the backend's
  /// `AdminProductUpdateSchema` only touches fields present in the payload
  /// (`exclude_unset=True`), so omitted fields are left as-is server-side.
  Future<void> updateProduct(
    int productId, {
    int? companyId,
    String? name,
    String? sku,
    int? globalCategoryId,
    String? description,
    double? retailPrice,
    double? wholesalePrice,
    double? discount,
    int? stockQuantity,
    int? minStockAlert,
    String? status,
  }) async {
    final payload = <String, dynamic>{};
    if (companyId != null) payload['company_id'] = companyId;
    if (name != null) payload['name'] = name;
    if (sku != null) payload['sku'] = sku;
    if (globalCategoryId != null) payload['global_category_id'] = globalCategoryId;
    if (description != null) payload['description'] = description;
    if (retailPrice != null) payload['retail_price'] = retailPrice;
    if (wholesalePrice != null) payload['wholesale_price'] = wholesalePrice;
    if (discount != null) payload['discount'] = discount;
    if (stockQuantity != null) payload['stock_quantity'] = stockQuantity;
    if (minStockAlert != null) payload['min_stock_alert'] = minStockAlert;
    if (status != null) payload['status'] = status;

    await _adminDataSource.updateAdminProduct(productId, jsonEncode(payload));
    await fetchProducts(isRefresh: true);
  }

  Future<void> deleteProduct(int productId) async {
    await _adminDataSource.deleteAdminProduct(productId);
    state = state.copyWith(products: state.products.where((p) => p.id != productId).toList());
  }
}

final adminProductsProvider =
    NotifierProvider<AdminProductsController, AdminProductsState>(() {
  return AdminProductsController();
});
