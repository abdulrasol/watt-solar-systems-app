import 'package:solar_hub/features/store/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  final List<Map<String, dynamic>> selectedOptions;
  final double? customUnitPrice; // For B2B/Tiered pricing

  CartItemModel({required this.product, this.quantity = 1, this.selectedOptions = const [], this.customUnitPrice});

  double get totalPrice {
    double basePrice = customUnitPrice ?? product.effectivePrice;
    double optionsCost = selectedOptions.fold(0.0, (sum, item) => sum + (item['extra_cost'] as num? ?? 0.0).toDouble());
    return (basePrice + optionsCost) * quantity;
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
      selectedOptions: (json['selected_options'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      customUnitPrice: (json['custom_unit_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity, 'selected_options': selectedOptions, 'custom_unit_price': customUnitPrice};
  }
}
