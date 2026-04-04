import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

class StorefrontCartItem {
  final int productId;
  final int companyId;
  final String companyName;
  final StorefrontAudience audience;
  final String name;
  final String? sku;
  final String? imageUrl;
  final String categoryName;
  final double unitPrice;
  final int quantity;

  const StorefrontCartItem({
    required this.productId,
    required this.companyId,
    required this.companyName,
    required this.audience,
    required this.name,
    this.sku,
    this.imageUrl,
    required this.categoryName,
    required this.unitPrice,
    required this.quantity,
  });

  factory StorefrontCartItem.fromProduct(
    StorefrontProduct product, {
    required StorefrontAudience audience,
    int quantity = 1,
  }) {
    return StorefrontCartItem(
      productId: product.id,
      companyId: product.company.id,
      companyName: product.company.name,
      audience: audience,
      name: product.name,
      sku: product.sku,
      imageUrl: product.primaryImage,
      categoryName: product.categoryLabel,
      unitPrice: product.displayPrice,
      quantity: quantity,
    );
  }

  factory StorefrontCartItem.fromJson(Map<String, dynamic> json) {
    return StorefrontCartItem(
      productId: json['product_id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      companyName: json['company_name'] ?? '',
      audience: (json['audience'] ?? 'b2c') == 'b2b'
          ? StorefrontAudience.b2b
          : StorefrontAudience.b2c,
      name: json['name'] ?? '',
      sku: json['sku'],
      imageUrl: json['image_url'],
      categoryName: json['category_name'] ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'company_id': companyId,
      'company_name': companyName,
      'audience': audience.name,
      'name': name,
      'sku': sku,
      'image_url': imageUrl,
      'category_name': categoryName,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }

  double get lineTotal => unitPrice * quantity;

  StorefrontCartItem copyWith({int? quantity}) {
    return StorefrontCartItem(
      productId: productId,
      companyId: companyId,
      companyName: companyName,
      audience: audience,
      name: name,
      sku: sku,
      imageUrl: imageUrl,
      categoryName: categoryName,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

class StorefrontCompanyCart {
  final int companyId;
  final String companyName;
  final StorefrontAudience audience;
  final List<StorefrontCartItem> items;

  const StorefrontCompanyCart({
    required this.companyId,
    required this.companyName,
    required this.audience,
    required this.items,
  });

  double get totalAmount =>
      items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.quantity);
}
