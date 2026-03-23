import 'package:solar_hub/src/utils/app_ints.dart';

class ProductsFilter {
  final String? status;
  final int? minStock;
  final int? maxStock;
  final double? minPrice;
  final double? maxPrice;
  final int? categoryId;
  final String? search;
  final String? sortBy;
  final int page;
  final int pageSize;

  ProductsFilter({
    this.status,
    this.minStock,
    this.maxStock,
    this.minPrice,
    this.maxPrice,
    this.categoryId,
    this.search,
    this.sortBy,
    this.page = 1,
    this.pageSize = AppInts.perPage,
  });

  ProductsFilter copyWith({
    String? status,
    int? minStock,
    int? maxStock,
    double? minPrice,
    double? maxPrice,
    int? categoryId,
    String? search,
    String? sortBy,
    int? page,
  }) {
    return ProductsFilter(
      status: status ?? this.status,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      categoryId: categoryId ?? this.categoryId,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
    );
  }

  Map<String, dynamic> query() {
    final Map<String, dynamic> query = {'page': page, 'page_size': pageSize};
    if (status != null) query['status'] = status;
    if (minStock != null) query['min_stock'] = minStock;
    if (maxStock != null) query['max_stock'] = maxStock;
    if (minPrice != null) query['min_price'] = minPrice;
    if (maxPrice != null) query['max_price'] = maxPrice;
    if (categoryId != null) query['category_id'] = categoryId;
    if (search != null) query['search'] = search;
    if (sortBy != null) query['sort_by'] = sortBy;

    return query;
  }
}
