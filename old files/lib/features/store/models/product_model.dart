import 'package:solar_hub/models/enums.dart';
import 'package:solar_hub/models/currency_model.dart';

class ProductPricingTier {
  final String? id;
  final String? productId;
  final int minQuantity;
  final double unitPrice;

  ProductPricingTier({this.id, this.productId, required this.minQuantity, required this.unitPrice});

  factory ProductPricingTier.fromJson(Map<String, dynamic> json) {
    return ProductPricingTier(
      id: json['id'] as String?,
      productId: json['product_id'] as String?,
      minQuantity: json['min_quantity'] as int? ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'min_quantity': minQuantity, 'unit_price': unitPrice};
  }
}

class ProductOption {
  final String? id;
  final String name;
  final bool isRequired;
  final List<ProductOptionValue> values;

  ProductOption({this.id, required this.name, this.isRequired = false, this.values = const []});

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id'],
      name: json['name'] ?? '',
      isRequired: json['is_required'] ?? false,
      values: (json['product_option_values'] as List?)?.map((e) => ProductOptionValue.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'is_required': isRequired, 'values': values.map((e) => e.toJson()).toList()};
}

class ProductOptionValue {
  final String? id;
  final String value;
  final double extraCost;

  ProductOptionValue({this.id, required this.value, this.extraCost = 0.0});

  factory ProductOptionValue.fromJson(Map<String, dynamic> json) {
    return ProductOptionValue(id: json['id'], value: json['value'] ?? '', extraCost: (json['extra_cost'] as num?)?.toDouble() ?? 0.0);
  }

  Map<String, dynamic> toJson() => {'value': value, 'extra_cost': extraCost};
}

class ProductModel {
  final String? id;
  final String? companyId;
  final String name;
  final String? sku;
  final String? category; // Legacy simple category or Global Category ID
  final String? companyName; // Fetched via join
  final String? description;
  final String? imageUrl;
  final double costPrice;
  final double retailPrice;
  final double wholesalePrice;
  final int stockQuantity;
  final int minStockAlert;
  final Map<String, dynamic> specs;
  final ProductStatus status;
  final DateTime? createdAt;

  // New Fields
  final List<ProductPricingTier> pricingTiers;
  final List<ProductOption> options;
  final List<String> companyCategoryIds;
  final List<Map<String, dynamic>> companyCategories; // Full objects for display
  final double discount; // Fixed discount amount
  final CurrencyModel? currency;

  ProductModel({
    this.id,
    this.companyId,
    required this.name,
    this.sku,
    this.category,
    this.companyName,
    this.description,
    this.imageUrl,
    this.costPrice = 0.0,
    required this.retailPrice,
    this.wholesalePrice = 0.0,
    this.stockQuantity = 0,
    this.minStockAlert = 5,
    this.specs = const {},
    this.status = ProductStatus.active,
    this.createdAt,
    this.pricingTiers = const [],
    this.options = const [],
    this.companyCategoryIds = const [],
    this.companyCategories = const [],
    this.discount = 0.0,
    this.currency,
  });

  // Helper getters for discount logic
  double get effectivePrice => (retailPrice - discount).clamp(0.0, double.infinity);
  bool get hasDiscount => discount > 0;
  double get discountPercentage => retailPrice > 0 ? (discount / retailPrice) * 100 : 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var tiersList = <ProductPricingTier>[];
    if (json['product_pricing_tiers'] != null) {
      tiersList = (json['product_pricing_tiers'] as List).map((e) => ProductPricingTier.fromJson(e as Map<String, dynamic>)).toList();
    }

    var optionsList = <ProductOption>[];
    if (json['product_options'] != null) {
      optionsList = (json['product_options'] as List).map((e) => ProductOption.fromJson(e as Map<String, dynamic>)).toList();
    }

    // Parsing nested company categories if joined
    var catsList = <Map<String, dynamic>>[];
    var catIds = <String>[];

    if (json['product_company_categories'] != null) {
      // Supabase join often returns { "company_categories": { "id": "...", "name": "..." } } inside list
      // Or just the junction table rows depending on query
      // Let's assume standard select(..., product_company_categories(company_categories(*)))
      for (var item in (json['product_company_categories'] as List)) {
        if (item['company_categories'] != null) {
          catsList.add(item['company_categories']);
          catIds.add(item['company_categories']['id']);
        }
      }
    }

    return ProductModel(
      id: json['id'] as String?,
      companyId: json['company_id'] as String?,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      category: json['category'] as String?,
      companyName: (json['companies'] is Map ? json['companies']['name'] : json['company_name']) as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0.0,
      retailPrice: (json['retail_price'] as num?)?.toDouble() ?? 0.0,
      wholesalePrice: (json['wholesale_price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      minStockAlert: json['min_stock_alert'] as int? ?? 5,
      specs: json['specs'] as Map<String, dynamic>? ?? {},
      status: ProductStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] as String? ?? 'active'),
        orElse: () => ProductStatus.active,
      ),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      pricingTiers: tiersList,
      options: optionsList,
      companyCategories: catsList,
      companyCategoryIds: catIds,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      currency: (json['companies'] != null && json['companies']['currencies'] != null) ? CurrencyModel.fromJson(json['companies']['currencies']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'company_id': companyId,
      'name': name,
      'sku': sku,
      'category': category,
      'description': description,
      'image_url': imageUrl,
      'cost_price': costPrice,
      'retail_price': retailPrice,
      'wholesale_price': wholesalePrice,
      'stock_quantity': stockQuantity,
      'min_stock_alert': minStockAlert,
      'specs': specs,
      'status': status.toString().split('.').last,
      'discount': discount,
      'company_name': companyName, // Persist for local storage
    };
  }

  ProductModel copyWith({
    String? id,
    String? companyId,
    String? name,
    String? sku,
    String? category,
    String? description,
    String? imageUrl,
    double? costPrice,
    double? retailPrice,
    double? wholesalePrice,
    int? stockQuantity,
    int? minStockAlert,
    Map<String, dynamic>? specs,
    ProductStatus? status,
    DateTime? createdAt,
    List<ProductPricingTier>? pricingTiers,
    List<ProductOption>? options,
    List<String>? companyCategoryIds,
    List<Map<String, dynamic>>? companyCategories,
    double? discount,
    String? companyName,
    CurrencyModel? currency,
  }) {
    return ProductModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      companyName: companyName ?? this.companyName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      costPrice: costPrice ?? this.costPrice,
      retailPrice: retailPrice ?? this.retailPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      specs: specs ?? this.specs,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pricingTiers: pricingTiers ?? this.pricingTiers,
      options: options ?? this.options,
      companyCategoryIds: companyCategoryIds ?? this.companyCategoryIds,
      companyCategories: companyCategories ?? this.companyCategories,
      discount: discount ?? this.discount,
      currency: currency ?? this.currency,
    );
  }
}
