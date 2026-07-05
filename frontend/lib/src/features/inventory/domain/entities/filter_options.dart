import 'product.dart';

class ProductFilterOptions {
  final List<ProductCategory> globalCategories;
  final List<ProductCategory> internalCategories;
  final List<ProductCategory> companyCategories;

  const ProductFilterOptions({
    this.globalCategories = const [],
    this.internalCategories = const [],
    this.companyCategories = const [],
  });
}
