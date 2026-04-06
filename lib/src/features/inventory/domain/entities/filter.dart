import 'package:solar_hub/src/utils/app_ints.dart';

class ProductsFilter {
  final String? status;
  final int? globalCategoryId;
  final int? internalCategoryId;
  final int? companyCategoryId;
  final int? categoryId; // Legacy
  final double? minPrice;
  final double? maxPrice;
  final bool? isAvailable;
  final String? search;
  final String? ordering;
  final int page;
  final int pageSize;

  ProductsFilter({
    this.status,
    this.globalCategoryId,
    this.internalCategoryId,
    this.companyCategoryId,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.isAvailable,
    this.search,
    this.ordering = '-created_at',
    this.page = 1,
    this.pageSize = AppInts.perPage,
  });

  ProductsFilter copyWith({
    String? status,
    int? globalCategoryId,
    int? internalCategoryId,
    int? companyCategoryId,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? isAvailable,
    String? search,
    String? ordering,
    int? page,
    bool clearGlobalCategoryId = false,
    bool clearInternalCategoryId = false,
    bool clearCompanyCategoryId = false,
    bool clearCategoryId = false,
    bool clearIsAvailable = false,
  }) {
    return ProductsFilter(
      status: status ?? this.status,
      globalCategoryId: clearGlobalCategoryId ? null : (globalCategoryId ?? this.globalCategoryId),
      internalCategoryId: clearInternalCategoryId ? null : (internalCategoryId ?? this.internalCategoryId),
      companyCategoryId: clearCompanyCategoryId ? null : (companyCategoryId ?? this.companyCategoryId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isAvailable: clearIsAvailable ? null : (isAvailable ?? this.isAvailable),
      search: search ?? this.search,
      ordering: ordering ?? this.ordering,
      page: page ?? this.page,
    );
  }

  Map<String, dynamic> query() {
    final Map<String, dynamic> query = {'page': page, 'page_size': pageSize};
    if (status != null) query['status'] = status;
    if (globalCategoryId != null) query['global_category_id'] = globalCategoryId;
    if (internalCategoryId != null) query['internal_category_id'] = internalCategoryId;
    if (companyCategoryId != null) query['company_category_id'] = companyCategoryId;
    if (categoryId != null) query['category_id'] = categoryId;
    if (minPrice != null) query['min_price'] = minPrice;
    if (maxPrice != null) query['max_price'] = maxPrice;
    if (isAvailable != null) query['is_available'] = isAvailable;
    if (search != null) query['search'] = search;
    if (ordering != null) query['ordering'] = ordering;

    return query;
  }
}
