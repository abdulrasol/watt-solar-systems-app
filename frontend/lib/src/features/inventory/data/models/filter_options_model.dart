import '../../domain/entities/filter_options.dart';
import 'product_model.dart';

class ProductFilterOptionsModel extends ProductFilterOptions {
  const ProductFilterOptionsModel({
    super.globalCategories,
    super.internalCategories,
    super.companyCategories,
  });

  factory ProductFilterOptionsModel.fromJson(Map<String, dynamic> json) {
    return ProductFilterOptionsModel(
      globalCategories: json['global_categories'] != null
          ? (json['global_categories'] as List).map((e) => ProductCategoryModel.fromJson(e)).toList()
          : [],
      internalCategories: json['internal_categories'] != null
          ? (json['internal_categories'] as List).map((e) => ProductCategoryModel.fromJson(e)).toList()
          : [],
      companyCategories: json['company_categories'] != null
          ? (json['company_categories'] as List).map((e) => ProductCategoryModel.fromJson(e)).toList()
          : [],
    );
  }
}
