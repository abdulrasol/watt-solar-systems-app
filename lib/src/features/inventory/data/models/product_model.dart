import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.sku,
    super.category,
    super.description,
    required super.costPrice,
    required super.retailPrice,
    required super.wholesalePrice,
    required super.discount,
    required super.stockQuantity,
    required super.minStockAlert,
    required super.specs,
    required super.status,
    required super.options,
    required super.pricingTiers,
    required super.createdAt,
    required super.updatedAt,
    required super.productImages,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      category: json['category'] != null ? ProductCategoryModel.fromJson(json['category']) : null,
      description: json['description'] as String?,
      costPrice: (json['cost_price'] as num).toDouble(),
      retailPrice: (json['retail_price'] as num).toDouble(),
      wholesalePrice: (json['wholesale_price'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      minStockAlert: json['min_stock_alert'] as int? ?? 5,
      specs: json['specs'] != null ? Map<String, dynamic>.from(json['specs']) : {},
      status: json['status'] as String,
      options: json['options'] != null ? (json['options'] as List).map((e) => ProductOptionModel.fromJson(e)).toList() : [],
      pricingTiers: json['pricing_tiers'] != null ? (json['pricing_tiers'] as List).map((e) => ProductPricingTierModel.fromJson(e)).toList() : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      productImages: json['product_images'] != null ? List<String>.from(json['product_images']) : [],
    );
  }
}

class ProductCategoryModel extends ProductCategory {
  const ProductCategoryModel({required super.id, required super.name, super.description});

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(id: json['id'] as int, name: json['name'] as String, description: json['description'] as String?);
  }
}

class ProductOptionModel extends ProductOption {
  const ProductOptionModel({required super.name, super.retailPrice = 0, super.cost = 0, super.wholesalePrice, super.isRequired = false});

  factory ProductOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductOptionModel(
      name: json['name'] as String,
      retailPrice: (json['retail_price'] as num?)?.toDouble() ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      wholesalePrice: (json['wholesale_price'] as num?)?.toDouble(),
      isRequired: json['is_required'] as bool? ?? false,
    );
  }
}

class ProductPricingTierModel extends ProductPricingTier {
  const ProductPricingTierModel({super.id, required super.quantity, required super.unitPrice});

  factory ProductPricingTierModel.fromJson(Map<String, dynamic> json) {
    return ProductPricingTierModel(id: json['id'] as int?, quantity: json['quantity'] as int, unitPrice: (json['unit_price'] as num).toDouble());
  }
}
