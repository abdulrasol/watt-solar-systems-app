import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/filter.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/filter_options.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';
import 'package:solar_hub/src/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryState {
  final List<Product> products;
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final ProductsFilter filter;
  final ProductFilterOptions? filterOptions;

  const InventoryState({
    this.products = const [],
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
    required this.filter,
    this.filterOptions,
  });

  InventoryState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    ProductsFilter? filter,
    ProductFilterOptions? filterOptions,
  }) {
    return InventoryState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      filter: filter ?? this.filter,
      filterOptions: filterOptions ?? this.filterOptions,
    );
  }
}

class InventoryProviderNotifier extends Notifier<InventoryState> {
  final InventoryRepository _repository = getIt<InventoryRepository>();

  @override
  InventoryState build() {
    Future.microtask(() {
      fetchFilterOptions();
      fetchProducts(isRefresh: true);
    });
    return InventoryState(filter: ProductsFilter(), isLoading: true);
  }

  Future<void> fetchFilterOptions() async {
    try {
      final user = getIt<CasheInterface>().user();
      if (user?.company?.id == null) return;
      final options = await _repository.getFilterOptions(user!.company!.id);
      state = state.copyWith(filterOptions: options);
    } catch (e) {
      // Log error but don't break the UI
    }
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isLoading: true, hasMore: true);
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true);
    }

    try {
      final user = getIt<CasheInterface>().user();
      if (user?.company?.id == null) {
        state = state.copyWith(isLoading: false, isMoreLoading: false, error: "No company selected");
        return;
      }

      final filter = isRefresh ? state.filter.copyWith(page: 1) : state.filter;
      final products = await _repository.getProducts(user!.company!.id, filter: filter);

      state = state.copyWith(
        products: isRefresh ? products : [...state.products, ...products],
        isLoading: false,
        isMoreLoading: false,
        hasMore: products.length >= filter.pageSize,
        filter: filter.copyWith(page: filter.page),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isMoreLoading: false, error: e.toString());
    }
  }

  Future<void> nextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;

    state = state.copyWith(filter: state.filter.copyWith(page: state.filter.page + 1));
    await fetchProducts();
  }

  void addProduct(Product product, {bool isUpdate = false}) {
    if (isUpdate) {
      state = state.copyWith(products: state.products.map((e) => e.id == product.id ? product : e).toList());
    } else {
      state = state.copyWith(products: [product, ...state.products]);
    }
  }

  Future updateFilters(ProductsFilter filter) async {
    state = state.copyWith(filter: filter);
    await fetchProducts(isRefresh: true);
  }

  Future search(String query) async {
    state = state.copyWith(filter: state.filter.copyWith(search: query));
    await fetchProducts(isRefresh: true);
  }

  Future deleteProduct(int productId) async {
    try {
      final user = getIt<CasheInterface>().user();
      if (user?.company?.id == null) return;
      await _repository.deleteProduct(user!.company!.id, productId);
      state = state.copyWith(products: state.products.where((e) => e.id != productId).toList());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final inventoryNotifierProvider = NotifierProvider<InventoryProviderNotifier, InventoryState>(InventoryProviderNotifier.new);
