import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/domain/repositories/storefront_repository.dart';

class StorefrontScope {
  final StorefrontAudience audience;
  final int? companyId;

  const StorefrontScope({required this.audience, this.companyId});

  @override
  bool operator ==(Object other) {
    return other is StorefrontScope &&
        other.audience == audience &&
        other.companyId == companyId;
  }

  @override
  int get hashCode => Object.hash(audience, companyId);
}

class StorefrontState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final StorefrontMeta meta;
  final List<StorefrontProduct> products;
  final PaginationMeta pagination;
  final StorefrontQuery query;
  final StorefrontCategoryType? activeCategoryType;
  final int? selectedCategoryId;

  const StorefrontState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.meta = StorefrontMeta.empty,
    this.products = const [],
    this.pagination = PaginationMeta.empty,
    this.query = const StorefrontQuery(),
    this.activeCategoryType,
    this.selectedCategoryId,
  });

  StorefrontState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    StorefrontMeta? meta,
    List<StorefrontProduct>? products,
    PaginationMeta? pagination,
    StorefrontQuery? query,
    StorefrontCategoryType? activeCategoryType,
    bool clearCategoryType = false,
    int? selectedCategoryId,
    bool clearSelectedCategoryId = false,
  }) {
    return StorefrontState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      meta: meta ?? this.meta,
      products: products ?? this.products,
      pagination: pagination ?? this.pagination,
      query: query ?? this.query,
      activeCategoryType: clearCategoryType
          ? null
          : (activeCategoryType ?? this.activeCategoryType),
      selectedCategoryId: clearSelectedCategoryId
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }
}

class StorefrontNotifier extends Notifier<StorefrontState> {
  final StorefrontScope arg;
  StorefrontNotifier(this.arg);

  late StorefrontRepository _repository;
  Timer? _debounce;

  @override
  StorefrontState build() {
    _repository = getIt<StorefrontRepository>();
    
    ref.onDispose(() => _debounce?.cancel());
    
    // Initialize after build to avoid state modification error
    Future.microtask(() => initialize());
    
    return StorefrontState(
      query: StorefrontQuery(companyId: arg.companyId),
    );
  }

  Future<void> initialize() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final meta = await _repository.getMeta();
      state = state.copyWith(meta: meta);
      await _fetchProducts();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        products: const [],
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(query: state.query.resetPage(), products: const []);
    await _fetchProducts();
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.pagination.hasNext) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final response = await _repository.getProducts(
        audience: arg.audience,
        companyId: arg.companyId,
        query: state.query.copyWith(page: state.pagination.page + 1),
      );

      state = state.copyWith(
        isLoadingMore: false,
        query: state.query.copyWith(page: response.pagination.page),
        pagination: response.pagination,
        products: [...state.products, ...response.items],
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void updateSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      state = state.copyWith(
        query: state.query.copyWith(search: value, page: 1),
      );
      unawaited(_fetchProducts());
    });
  }

  Future<void> updateOrdering(String ordering) async {
    state = state.copyWith(
      query: state.query.copyWith(ordering: ordering, page: 1),
    );
    await _fetchProducts();
  }

  Future<void> applyFilters({
    int? companyId,
    bool clearCompanyId = false,
    bool? isAvailable,
    bool clearAvailability = false,
    double? minPrice,
    bool clearMinPrice = false,
    double? maxPrice,
    bool clearMaxPrice = false,
    String? ordering,
  }) async {
    state = state.copyWith(
      query: state.query.copyWith(
        companyId: companyId,
        clearCompanyId: clearCompanyId,
        isAvailable: isAvailable,
        clearAvailability: clearAvailability,
        minPrice: minPrice,
        clearMinPrice: clearMinPrice,
        maxPrice: maxPrice,
        clearMaxPrice: clearMaxPrice,
        ordering: ordering,
        page: 1,
      ),
    );
    await _fetchProducts();
  }

  Future<void> updateCategoryType(StorefrontCategoryType? type) async {
    if (type == state.activeCategoryType) {
      state = state.copyWith(
        clearCategoryType: true,
        clearSelectedCategoryId: true,
        query: _clearCategoryFilters(state.query).copyWith(page: 1),
      );
    } else {
      state = state.copyWith(
        activeCategoryType: type,
        clearSelectedCategoryId: true,
        query: _clearCategoryFilters(state.query).copyWith(page: 1),
      );
    }
    await _fetchProducts();
  }

  Future<void> updateCategory(int? categoryId) async {
    final currentType = state.activeCategoryType;
    var nextQuery = _clearCategoryFilters(state.query).copyWith(page: 1);

    if (categoryId != null && currentType != null) {
      switch (currentType) {
        case StorefrontCategoryType.global:
          nextQuery = nextQuery.copyWith(globalCategoryId: categoryId);
        case StorefrontCategoryType.internal:
          nextQuery = nextQuery.copyWith(internalCategoryId: categoryId);
        case StorefrontCategoryType.company:
          nextQuery = nextQuery.copyWith(companyCategoryId: categoryId);
      }
    }

    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearSelectedCategoryId: categoryId == null,
      query: nextQuery,
    );
    await _fetchProducts();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(
      query: StorefrontQuery(companyId: arg.companyId),
      clearError: true,
      clearCategoryType: true,
      clearSelectedCategoryId: true,
    );
    await _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.getProducts(
        audience: arg.audience,
        companyId: arg.companyId,
        query: state.query,
      );
      state = state.copyWith(
        isLoading: false,
        products: response.items,
        pagination: response.pagination,
        query: state.query.copyWith(page: response.pagination.page),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        products: const [],
      );
    }
  }

  StorefrontQuery _clearCategoryFilters(StorefrontQuery query) {
    return query.copyWith(
      clearCategoryId: true,
      clearGlobalCategoryId: true,
      clearInternalCategoryId: true,
      clearCompanyCategoryId: true,
    );
  }
}

final storefrontNotifierProvider = NotifierProvider.family<StorefrontNotifier, StorefrontState, StorefrontScope>(StorefrontNotifier.new);
