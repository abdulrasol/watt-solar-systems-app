class Product {
  final int id;
  final ProductCompany company;
  final String name;
  final String? sku;
  final ProductCategory? category; // Legacy or company-specific category
  final String? description;
  final double costPrice;
  final double retailPrice;
  final double wholesalePrice;
  final double displayPrice;
  final double discount;
  final int stockQuantity;
  final int minStockAlert;
  final bool isAvailable;
  final Map<String, dynamic> specs;
  final String status;
  final List<ProductOption> options;
  final List<ProductPricingTier> pricingTiers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final ProductCategory? globalCategory;
  final List<ProductCategory> internalCategories;

  const Product({
    required this.id,
    required this.company,
    required this.name,
    this.sku,
    this.category,
    this.description,
    required this.costPrice,
    required this.retailPrice,
    required this.wholesalePrice,
    required this.displayPrice,
    required this.discount,
    required this.stockQuantity,
    this.minStockAlert = 5,
    this.isAvailable = true,
    this.specs = const {},
    required this.status,
    this.options = const [],
    this.pricingTiers = const [],
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.globalCategory,
    this.internalCategories = const [],
  });
}

class ProductCompany {
  final int id;
  final String name;
  final bool allowsB2B;
  final bool allowsB2C;
  final List<ProductCategory> companyCategories;

  const ProductCompany({
    required this.id,
    required this.name,
    required this.allowsB2B,
    required this.allowsB2C,
    this.companyCategories = const [],
  });
}

class ProductCategory {
  final int id;
  final String name;
  final String? description;
  final int? companyId; // For internal categories

  const ProductCategory({required this.id, required this.name, this.description, this.companyId});
}

class ProductOption {
  final int? id;
  final String name;
  final double retailPrice;
  final double cost;
  final double? wholesalePrice;
  final bool isRequired;

  const ProductOption({this.id, required this.name, this.retailPrice = 0, this.cost = 0, this.wholesalePrice, this.isRequired = false});
}

class ProductPricingTier {
  final int? id;
  final int quantity;
  final double unitPrice;

  const ProductPricingTier({this.id, required this.quantity, required this.unitPrice});
}
