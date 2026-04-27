import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/core/services/network_status_service.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/domain/repositories/storefront_repository.dart';

class StorefrontScope {
  final StorefrontAudience audience;
  final int? companyId;
  final StorefrontQuery initialQuery;

  const StorefrontScope({
    required this.audience,
    this.companyId,
    this.initialQuery = const StorefrontQuery(),
  });

  @override
  bool operator ==(Object other) {
    return other is StorefrontScope &&
        other.audience == audience &&
        other.companyId == companyId &&
        other.initialQuery == initialQuery;
  }

  @override
  int get hashCode => Object.hash(audience, companyId, initialQuery);
}

class StorefrontFilterSheetState {
  final bool isLoadingCompanies;
  final bool isLoadingMoreCompanies;
  final bool hasLoadedCompanies;
  final String? companiesError;
  final List<StorefrontCompanyListItem> companies;
  final PaginationMeta companiesPagination;
  final String companySearch;

  const StorefrontFilterSheetState({
    this.isLoadingCompanies = false,
    this.isLoadingMoreCompanies = false,
    this.hasLoadedCompanies = false,
    this.companiesError,
    this.companies = const [],
    this.companiesPagination = PaginationMeta.empty,
    this.companySearch = '',
  });

  StorefrontFilterSheetState copyWith({
    bool? isLoadingCompanies,
    bool? isLoadingMoreCompanies,
    bool? hasLoadedCompanies,
    String? companiesError,
    bool clearCompaniesError = false,
    List<StorefrontCompanyListItem>? companies,
    PaginationMeta? companiesPagination,
    String? companySearch,
  }) {
    return StorefrontFilterSheetState(
      isLoadingCompanies: isLoadingCompanies ?? this.isLoadingCompanies,
      isLoadingMoreCompanies:
          isLoadingMoreCompanies ?? this.isLoadingMoreCompanies,
      hasLoadedCompanies: hasLoadedCompanies ?? this.hasLoadedCompanies,
      companiesError: clearCompaniesError
          ? null
          : (companiesError ?? this.companiesError),
      companies: companies ?? this.companies,
      companiesPagination: companiesPagination ?? this.companiesPagination,
      companySearch: companySearch ?? this.companySearch,
    );
  }
}

class StorefrontState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final StorefrontMeta meta;
  final List<StorefrontProduct> products;
  final PaginationMeta pagination;
  final StorefrontQuery query;
  final StorefrontFilterSheetState filterSheet;
  final List<StorefrontCompanyCategory> companyCategories;
  final bool isLoadingCompanyCategories;
  final String? companyCategoriesError;
  final int? loadedCompanyCategoriesForCompanyId;

  const StorefrontState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.meta = StorefrontMeta.empty,
    this.products = const [],
    this.pagination = PaginationMeta.empty,
    this.query = const StorefrontQuery(),
    this.filterSheet = const StorefrontFilterSheetState(),
    this.companyCategories = const [],
    this.isLoadingCompanyCategories = false,
    this.companyCategoriesError,
    this.loadedCompanyCategoriesForCompanyId,
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
    StorefrontFilterSheetState? filterSheet,
    List<StorefrontCompanyCategory>? companyCategories,
    bool? isLoadingCompanyCategories,
    String? companyCategoriesError,
    bool clearCompanyCategoriesError = false,
    int? loadedCompanyCategoriesForCompanyId,
    bool clearLoadedCompanyCategoriesForCompanyId = false,
  }) {
    return StorefrontState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      meta: meta ?? this.meta,
      products: products ?? this.products,
      pagination: pagination ?? this.pagination,
      query: query ?? this.query,
      filterSheet: filterSheet ?? this.filterSheet,
      companyCategories: companyCategories ?? this.companyCategories,
      isLoadingCompanyCategories:
          isLoadingCompanyCategories ?? this.isLoadingCompanyCategories,
      companyCategoriesError: clearCompanyCategoriesError
          ? null
          : (companyCategoriesError ?? this.companyCategoriesError),
      loadedCompanyCategoriesForCompanyId:
          clearLoadedCompanyCategoriesForCompanyId
          ? null
          : (loadedCompanyCategoriesForCompanyId ??
                this.loadedCompanyCategoriesForCompanyId),
    );
  }
}

class StorefrontNotifier extends Notifier<StorefrontState> {
  final StorefrontScope arg;

  StorefrontNotifier(this.arg);

  late final StorefrontRepository _repository;
  late final NetworkStatusService _networkStatus;
  Timer? _productSearchDebounce;
  Timer? _companySearchDebounce;

  String get _salesChannel =>
      arg.audience == StorefrontAudience.b2b ? 'b2b' : 'b2c';

  int? get effectiveCompanyId => arg.companyId ?? state.query.companyId;

  @override
  StorefrontState build() {
    _repository = getIt<StorefrontRepository>();
    _networkStatus = getIt<NetworkStatusService>();
    ref.onDispose(() {
      _productSearchDebounce?.cancel();
      _companySearchDebounce?.cancel();
    });
    Future.microtask(initialize);
    return StorefrontState(query: arg.initialQuery);
  }

  Future<void> initialize() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final meta = await _repository.getMeta();
      state = state.copyWith(meta: meta);
      if (arg.companyId != null) {
        unawaited(ensureCompanyCategoriesLoaded(arg.companyId!));
      }
      await _fetchProducts();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _networkStatus.userMessageFor(
          e,
          fallback: 'Could not load storefront data.',
        ),
        products: const [],
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(query: state.query.resetPage());
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
        pagination: response.pagination,
        query: state.query.copyWith(page: response.pagination.page),
        products: [...state.products, ...response.items],
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: _networkStatus.userMessageFor(
          e,
          fallback: 'Could not load more products.',
        ),
      );
    }
  }

  void updateSearch(String value) {
    _productSearchDebounce?.cancel();
    _productSearchDebounce = Timer(const Duration(milliseconds: 350), () {
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

  Future<void> updateGlobalCategory(int? categoryId) async {
    state = state.copyWith(
      query: state.query.copyWith(
        globalCategoryId: categoryId,
        clearGlobalCategoryId: categoryId == null,
        page: 1,
      ),
    );
    await _fetchProducts();
  }

  Future<void> updateCompanyCategory(int? categoryId) async {
    state = state.copyWith(
      query: state.query.copyWith(
        companyCategoryId: categoryId,
        clearCompanyCategoryId: categoryId == null,
        page: 1,
      ),
    );
    await _fetchProducts();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(
      query: arg.initialQuery.copyWith(page: 1),
      companyCategories: arg.companyId == null
          ? const []
          : state.companyCategories,
      clearCompanyCategoriesError: true,
      clearLoadedCompanyCategoriesForCompanyId: arg.companyId == null,
    );

    if (arg.companyId != null) {
      await ensureCompanyCategoriesLoaded(arg.companyId!);
    }

    await _fetchProducts();
  }

  Future<void> ensureCompaniesLoaded({bool forceRefresh = false}) async {
    final filterSheet = state.filterSheet;
    if (!forceRefresh &&
        (filterSheet.hasLoadedCompanies || filterSheet.isLoadingCompanies)) {
      return;
    }

    await _fetchCompanies(reset: true);
  }

  void updateCompanySearch(String value) {
    state = state.copyWith(
      filterSheet: state.filterSheet.copyWith(companySearch: value),
    );

    _companySearchDebounce?.cancel();
    _companySearchDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_fetchCompanies(reset: true));
    });
  }

  Future<void> loadMoreCompanies() async {
    if (state.filterSheet.isLoadingMoreCompanies ||
        !state.filterSheet.companiesPagination.hasNext) {
      return;
    }

    await _fetchCompanies(
      reset: false,
      page: state.filterSheet.companiesPagination.page + 1,
    );
  }

  Future<void> ensureCompanyCategoriesLoaded(
    int companyId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.loadedCompanyCategoriesForCompanyId == companyId &&
        state.companyCategories.isNotEmpty) {
      return;
    }

    state = state.copyWith(
      isLoadingCompanyCategories: true,
      clearCompanyCategoriesError: true,
      loadedCompanyCategoriesForCompanyId: companyId,
    );

    try {
      final categories = await _repository.getCompanyCategories(companyId);
      state = state.copyWith(
        isLoadingCompanyCategories: false,
        companyCategories: categories,
        loadedCompanyCategoriesForCompanyId: companyId,
      );

      if (state.query.companyCategoryId != null &&
          !categories.any((item) => item.id == state.query.companyCategoryId)) {
        state = state.copyWith(
          query: state.query.copyWith(
            companyCategoryId: null,
            clearCompanyCategoryId: true,
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingCompanyCategories: false,
        companyCategoriesError: _networkStatus.userMessageFor(
          e,
          fallback: 'Could not load company categories.',
        ),
        companyCategories: const [],
      );
    }
  }

  void clearDraftCompanyCategories() {
    state = state.copyWith(
      companyCategories: const [],
      clearCompanyCategoriesError: true,
      clearLoadedCompanyCategoriesForCompanyId: true,
      isLoadingCompanyCategories: false,
    );
  }

  Future<void> applyFilters({
    int? companyId,
    bool clearCompanyId = false,
    int? globalCategoryId,
    bool clearGlobalCategoryId = false,
    int? companyCategoryId,
    bool clearCompanyCategoryId = false,
    bool? isAvailable,
    bool clearAvailability = false,
    double? minPrice,
    bool clearMinPrice = false,
    double? maxPrice,
    bool clearMaxPrice = false,
    String? ordering,
  }) async {
    final previousEffectiveCompanyId = effectiveCompanyId;
    final nextQuery = state.query.copyWith(
      companyId: companyId,
      clearCompanyId: arg.companyId != null ? true : clearCompanyId,
      globalCategoryId: globalCategoryId,
      clearGlobalCategoryId: clearGlobalCategoryId,
      companyCategoryId: companyCategoryId,
      clearCompanyCategoryId: clearCompanyCategoryId,
      isAvailable: isAvailable,
      clearAvailability: clearAvailability,
      minPrice: minPrice,
      clearMinPrice: clearMinPrice,
      maxPrice: maxPrice,
      clearMaxPrice: clearMaxPrice,
      ordering: ordering,
      page: 1,
    );

    state = state.copyWith(query: nextQuery);

    final nextEffectiveCompanyId = effectiveCompanyId;

    if (nextEffectiveCompanyId == null) {
      clearDraftCompanyCategories();
    } else if (previousEffectiveCompanyId != nextEffectiveCompanyId ||
        state.loadedCompanyCategoriesForCompanyId != nextEffectiveCompanyId) {
      await ensureCompanyCategoriesLoaded(
        nextEffectiveCompanyId,
        forceRefresh: true,
      );
    }

    await _fetchProducts();
  }

  Future<void> _fetchCompanies({required bool reset, int? page}) async {
    final nextPage = reset
        ? 1
        : (page ?? state.filterSheet.companiesPagination.page);
    state = state.copyWith(
      filterSheet: state.filterSheet.copyWith(
        isLoadingCompanies: reset,
        isLoadingMoreCompanies: !reset,
        clearCompaniesError: true,
        companies: reset ? const [] : null,
      ),
    );

    try {
      final response = await _repository.getCompanies(
        audience: arg.audience,
        query: StorefrontCompanyQuery(
          page: nextPage,
          pageSize: state.filterSheet.companiesPagination.pageSize == 0
              ? 12
              : state.filterSheet.companiesPagination.pageSize,
          search: state.filterSheet.companySearch,
          salesChannel: _salesChannel,
          ordering: 'name',
        ),
      );

      state = state.copyWith(
        filterSheet: state.filterSheet.copyWith(
          isLoadingCompanies: false,
          isLoadingMoreCompanies: false,
          hasLoadedCompanies: true,
          companiesPagination: response.pagination,
          companies: reset
              ? response.items
              : [...state.filterSheet.companies, ...response.items],
        ),
      );
    } catch (e) {
      state = state.copyWith(
        filterSheet: state.filterSheet.copyWith(
          isLoadingCompanies: false,
          isLoadingMoreCompanies: false,
          companiesError: _networkStatus.userMessageFor(
            e,
            fallback: 'Could not load companies.',
          ),
        ),
      );
    }
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
        error: _networkStatus.userMessageFor(
          e,
          fallback: 'Could not load storefront data.',
        ),
        products: const [],
      );
    }
  }
}

final storefrontNotifierProvider =
    NotifierProvider.family<
      StorefrontNotifier,
      StorefrontState,
      StorefrontScope
    >(StorefrontNotifier.new);
