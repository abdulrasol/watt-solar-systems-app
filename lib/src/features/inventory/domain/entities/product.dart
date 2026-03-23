class Product {
  final int id;
  final String name;
  final String? sku;
  final ProductCategory? category;
  final String? description;
  final double costPrice;
  final double retailPrice;
  final double wholesalePrice;
  final double discount;
  final int stockQuantity;
  final int minStockAlert;
  final Map<String, dynamic> specs;
  final String status;
  final List<ProductOption> options;
  final List<ProductPricingTier> pricingTiers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> productImages;

  const Product({
    required this.id,
    required this.name,
    this.sku,
    this.category,
    this.description,
    required this.costPrice,
    required this.retailPrice,
    required this.wholesalePrice,
    required this.discount,
    required this.stockQuantity,
    this.minStockAlert = 5,
    this.specs = const {},
    required this.status,
    this.options = const [],
    this.pricingTiers = const [],
    required this.createdAt,
    required this.updatedAt,
    this.productImages = const [],
  });
}

class ProductCategory {
  final int id;
  final String name;
  final String? description;

  const ProductCategory({required this.id, required this.name, this.description});
}

class ProductOption {
  final String name;
  final double retailPrice;
  final double cost;
  final double? wholesalePrice;
  final bool isRequired;

  const ProductOption({required this.name, this.retailPrice = 0, this.cost = 0, this.wholesalePrice, this.isRequired = false});
}

class ProductPricingTier {
  final int? id;
  final int quantity;
  final double unitPrice;

  const ProductPricingTier({this.id, required this.quantity, required this.unitPrice});
}
