import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

class StorefrontCartSelectedOption {
  final int id;
  final String name;
  final double retailPrice;
  final double wholesalePrice;
  final bool isRequired;

  const StorefrontCartSelectedOption({
    required this.id,
    required this.name,
    required this.retailPrice,
    required this.wholesalePrice,
    required this.isRequired,
  });

  factory StorefrontCartSelectedOption.fromProductOption(
    StorefrontProductOption option,
  ) {
    return StorefrontCartSelectedOption(
      id: option.id,
      name: option.name,
      retailPrice: option.retailPrice,
      wholesalePrice: option.wholesalePrice,
      isRequired: option.isRequired,
    );
  }

  factory StorefrontCartSelectedOption.fromJson(Map<String, dynamic> json) {
    return StorefrontCartSelectedOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      retailPrice: (json['retail_price'] as num?)?.toDouble() ?? 0,
      wholesalePrice: (json['wholesale_price'] as num?)?.toDouble() ?? 0,
      isRequired: json['is_required'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'retail_price': retailPrice,
      'wholesale_price': wholesalePrice,
      'is_required': isRequired,
    };
  }

  double priceForAudience(StorefrontAudience audience) {
    return audience == StorefrontAudience.b2b ? wholesalePrice : retailPrice;
  }
}

class StorefrontCartItemPricingTier {
  final int id;
  final int quantity;
  final double unitPrice;

  const StorefrontCartItemPricingTier({
    required this.id,
    required this.quantity,
    required this.unitPrice,
  });

  factory StorefrontCartItemPricingTier.fromStorefrontPricingTier(
    StorefrontPricingTier tier,
  ) {
    return StorefrontCartItemPricingTier(
      id: tier.id,
      quantity: tier.quantity,
      unitPrice: tier.unitPrice,
    );
  }

  factory StorefrontCartItemPricingTier.fromJson(Map<String, dynamic> json) {
    return StorefrontCartItemPricingTier(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'quantity': quantity, 'unit_price': unitPrice};
  }
}

class StorefrontCartItem {
  final int productId;
  final int companyId;
  final String companyName;
  final StorefrontAudience audience;
  final String name;
  final String? sku;
  final String? imageUrl;
  final String categoryName;
  final double retailPrice;
  final double wholesalePrice;
  final int quantity;
  final List<StorefrontCartSelectedOption> selectedOptions;
  final List<StorefrontCartItemPricingTier> pricingTiers;

  const StorefrontCartItem({
    required this.productId,
    required this.companyId,
    required this.companyName,
    required this.audience,
    required this.name,
    this.sku,
    this.imageUrl,
    required this.categoryName,
    required this.retailPrice,
    required this.wholesalePrice,
    required this.quantity,
    this.selectedOptions = const [],
    this.pricingTiers = const [],
  });

  factory StorefrontCartItem.fromProduct(
    StorefrontProduct product, {
    required StorefrontAudience audience,
    required int quantity,
    required List<StorefrontProductOption> selectedOptions,
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
      retailPrice: product.retailPrice,
      wholesalePrice: product.wholesalePrice,
      quantity: quantity,
      selectedOptions: selectedOptions
          .map(StorefrontCartSelectedOption.fromProductOption)
          .toList(),
      pricingTiers: product.pricingTiers
          .map(StorefrontCartItemPricingTier.fromStorefrontPricingTier)
          .toList(),
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
      retailPrice: (json['retail_price'] as num?)?.toDouble() ?? 0,
      wholesalePrice: (json['wholesale_price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] ?? 1,
      selectedOptions: (json['selected_options'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => StorefrontCartSelectedOption.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      pricingTiers: (json['pricing_tiers'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => StorefrontCartItemPricingTier.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
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
      'retail_price': retailPrice,
      'wholesale_price': wholesalePrice,
      'quantity': quantity,
      'selected_options': selectedOptions.map((item) => item.toJson()).toList(),
      'pricing_tiers': pricingTiers.map((tier) => tier.toJson()).toList(),
    };
  }

  StorefrontCartItemPricingTier? get appliedTier {
    final eligible = pricingTiers.where((tier) => quantity >= tier.quantity);
    if (eligible.isEmpty) return null;

    StorefrontCartItemPricingTier? best;
    for (final tier in eligible) {
      if (best == null || tier.unitPrice < best.unitPrice) {
        best = tier;
      }
    }
    return best;
  }

  List<int> get selectedOptionIds =>
      selectedOptions.map((item) => item.id).toList();

  double get baseUnitPrice {
    final tier = appliedTier;
    if (tier != null) return tier.unitPrice;
    return audience == StorefrontAudience.b2b ? wholesalePrice : retailPrice;
  }

  double get optionsUnitPrice {
    return selectedOptions.fold<double>(
      0,
      (sum, item) => sum + item.priceForAudience(audience),
    );
  }

  double get effectiveUnitPrice => baseUnitPrice + optionsUnitPrice;

  double get lineTotal => effectiveUnitPrice * quantity;

  StorefrontCartItem copyWith({
    StorefrontAudience? audience,
    int? quantity,
    List<StorefrontCartSelectedOption>? selectedOptions,
    List<StorefrontCartItemPricingTier>? pricingTiers,
  }) {
    return StorefrontCartItem(
      productId: productId,
      companyId: companyId,
      companyName: companyName,
      audience: audience ?? this.audience,
      name: name,
      sku: sku,
      imageUrl: imageUrl,
      categoryName: categoryName,
      retailPrice: retailPrice,
      wholesalePrice: wholesalePrice,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      pricingTiers: pricingTiers ?? this.pricingTiers,
    );
  }
}

class StorefrontCompanyCartConfig {
  final int companyId;
  final StorefrontAudience audience;
  final String paymentMethod;
  final String? deliveryMethod;
  final int? deliveryOptionId;
  final double deliveryCost;
  final Map<String, dynamic>? shippingAddress;

  const StorefrontCompanyCartConfig({
    required this.companyId,
    required this.audience,
    required this.paymentMethod,
    this.deliveryMethod,
    this.deliveryOptionId,
    this.deliveryCost = 0,
    this.shippingAddress,
  });

  factory StorefrontCompanyCartConfig.fromJson(Map<String, dynamic> json) {
    return StorefrontCompanyCartConfig(
      companyId: json['company_id'] ?? 0,
      audience: (json['audience'] ?? 'b2c') == 'b2b'
          ? StorefrontAudience.b2b
          : StorefrontAudience.b2c,
      paymentMethod: json['payment_method'] ?? 'cash',
      deliveryMethod: json['delivery_method'],
      deliveryOptionId: json['delivery_option_id'],
      deliveryCost: (json['delivery_cost'] as num?)?.toDouble() ?? 0,
      shippingAddress: json['shipping_address'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['shipping_address'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'audience': audience.name,
      'payment_method': paymentMethod,
      'delivery_method': deliveryMethod,
      'delivery_option_id': deliveryOptionId,
      'delivery_cost': deliveryCost,
      'shipping_address': shippingAddress,
    };
  }

  StorefrontCompanyCartConfig copyWith({
    String? paymentMethod,
    String? deliveryMethod,
    bool clearDeliveryMethod = false,
    int? deliveryOptionId,
    bool clearDeliveryOptionId = false,
    double? deliveryCost,
    Map<String, dynamic>? shippingAddress,
    bool clearShippingAddress = false,
  }) {
    return StorefrontCompanyCartConfig(
      companyId: companyId,
      audience: audience,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryMethod: clearDeliveryMethod
          ? null
          : (deliveryMethod ?? this.deliveryMethod),
      deliveryOptionId: clearDeliveryOptionId
          ? null
          : (deliveryOptionId ?? this.deliveryOptionId),
      deliveryCost: deliveryCost ?? this.deliveryCost,
      shippingAddress: clearShippingAddress
          ? null
          : (shippingAddress ?? this.shippingAddress),
    );
  }
}

class StorefrontCompanyCart {
  final int companyId;
  final String companyName;
  final StorefrontAudience audience;
  final List<StorefrontCartItem> items;
  final String paymentMethod;
  final String? deliveryMethod;
  final int? deliveryOptionId;
  final double deliveryCost;
  final Map<String, dynamic>? shippingAddress;

  const StorefrontCompanyCart({
    required this.companyId,
    required this.companyName,
    required this.audience,
    required this.items,
    required this.paymentMethod,
    this.deliveryMethod,
    this.deliveryOptionId,
    this.deliveryCost = 0,
    this.shippingAddress,
  });

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  double get totalAmount => subtotal + deliveryCost;

  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.quantity);

  StorefrontCompanyCartConfig get config => StorefrontCompanyCartConfig(
    companyId: companyId,
    audience: audience,
    paymentMethod: paymentMethod,
    deliveryMethod: deliveryMethod,
    deliveryOptionId: deliveryOptionId,
    deliveryCost: deliveryCost,
    shippingAddress: shippingAddress,
  );
}
