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
}

final adminProductsProvider =
    NotifierProvider<AdminProductsController, AdminProductsState>(() {
  return AdminProductsController();
});
