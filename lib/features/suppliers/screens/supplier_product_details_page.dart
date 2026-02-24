import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/models/company_model.dart';

import 'package:solar_hub/features/store/controllers/cart_controller.dart';
import 'package:solar_hub/features/store/screens/cart_page.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';
import 'package:solar_hub/utils/toast_service.dart';
import 'package:solar_hub/controllers/currency_controller.dart';
import 'package:solar_hub/models/currency_model.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class SupplierProductDetailsPage extends StatefulWidget {
  final ProductModel product;
  final CompanyModel supplier;

  const SupplierProductDetailsPage({super.key, required this.product, required this.supplier});

  @override
  State<SupplierProductDetailsPage> createState() => _SupplierProductDetailsPageState();
}

class _SupplierProductDetailsPageState extends State<SupplierProductDetailsPage> {
  final CartController cartController = Get.put(CartController());
  final quantity = 1.obs;

  double get currentPrice {
    // Logic for tiered pricing
    // Find the tier with the highest minQuantity that is <= chosen quantity
    if (widget.product.pricingTiers.isEmpty) {
      return widget.product.wholesalePrice;
    }

    ProductPricingTier? applicableTier;
    for (var tier in widget.product.pricingTiers) {
      if (quantity.value >= tier.minQuantity) {
        if (applicableTier == null || tier.minQuantity > applicableTier.minQuantity) {
          applicableTier = tier;
        }
      }
    }

    return applicableTier?.unitPrice ?? widget.product.wholesalePrice;
  }

  CurrencyModel get currency {
    if (widget.product.currency != null) return widget.product.currency!;
    final currencyController = Get.find<CurrencyController>();
    return currencyController.getCurrencyById(widget.supplier.currencyId) ??
        currencyController.defaultCurrency ??
        CurrencyModel(id: 'manual', name: 'US Dollar', code: 'USD', symbol: '\$');
  }

  void _addToCart() {
    // Add to cart with B2B flow
    cartController.addToCart(
      widget.product.copyWith(companyName: widget.supplier.name),
      quantity: quantity.value,
      customUnitPrice: currentPrice, // Ensure cart uses the tiered price
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'added_to_cart'.tr}: ${widget.product.name} x${quantity.value}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      floatingActionButton: Obx(() {
        // Calculate count for this specific supplier
        final count = cartController.cartItems.where((i) => i.product.companyId == widget.supplier.id).fold(0, (sum, item) => sum + item.quantity);

        if (count == 0) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => Get.to(() => CartPage(filterCompanyId: widget.supplier.id)),
          icon: const Icon(Icons.shopping_cart),
          label: Text('${'view_cart'.tr} ($count)'),
          backgroundColor: Theme.of(context).primaryColor,
        );
      }),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header (Image + Basic Info)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: StoreImage(
                          url: widget.product.imageUrl,
                          width: 150, // Approximate width for consistency or fit
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 32),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('SKU: ${widget.product.sku ?? "N/A"}', style: TextStyle(color: Theme.of(context).disabledColor)),
                            const SizedBox(height: 16),
                            Text(widget.product.description ?? "No description available.", style: const TextStyle(fontSize: 16, height: 1.5)),
                            const SizedBox(height: 24),

                            // Current Price Display
                            Obx(() {
                              final price = currentPrice;
                              final isTiered = price != widget.product.wholesalePrice;
                              final isOutOfStock = widget.product.stockQuantity <= 0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isOutOfStock)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        'out_of_stock'.tr,
                                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ),
                                  Text(
                                    price.toPriceWithCurrency(currency.symbol),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: isOutOfStock ? Colors.grey : Theme.of(context).colorScheme.primary,
                                      decoration: isOutOfStock ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  Text('${'per_unit'.tr} (${quantity.value} items)', style: const TextStyle(color: Colors.grey)),
                                  if (isTiered)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                        child: Text(
                                          'volume_discount_applied'.tr,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${'in_stock'.tr}: ${widget.product.stockQuantity}',
                                    style: TextStyle(
                                      color: widget.product.stockQuantity < 5 ? Colors.orange : Colors.grey,
                                      fontSize: 13,
                                      fontWeight: widget.product.stockQuantity < 5 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Pricing Tiers Table
                if (widget.product.pricingTiers.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('quantity_discounts'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('min_qty'.tr)),
                              DataColumn(label: Text('unit_price'.tr)),
                            ],
                            rows: [
                              // Default Tier
                              DataRow(cells: [const DataCell(Text('1+')), DataCell(Text(widget.product.wholesalePrice.toPriceWithCurrency(currency.symbol)))]),
                              // Defined Tiers
                              ...widget.product.pricingTiers.map((tier) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text('${tier.minQuantity}+')),
                                    DataCell(
                                      Text(
                                        tier.unitPrice.toPriceWithCurrency(currency.symbol),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Add to Order Action
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: widget.product.stockQuantity <= 0
                                  ? null
                                  : () {
                                      if (quantity.value > 1) quantity.value--;
                                    },
                              icon: const Icon(Icons.remove),
                            ),
                            Obx(
                              () => Text(
                                '${quantity.value}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: widget.product.stockQuantity <= 0 ? Colors.grey : null),
                              ),
                            ),
                            IconButton(
                              onPressed: widget.product.stockQuantity <= 0
                                  ? null
                                  : () {
                                      if (quantity.value < widget.product.stockQuantity) {
                                        quantity.value++;
                                      } else {
                                        ToastService.warning('limited_stock'.tr, 'max_stock_reached'.tr);
                                      }
                                    },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Obx(
                          () => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: widget.product.stockQuantity <= 0 ? Colors.grey : Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: widget.product.stockQuantity <= 0 ? null : _addToCart,
                            child: Text(
                              widget.product.stockQuantity <= 0
                                  ? 'out_of_stock'.tr
                                  : '${'add_to_order'.tr} - ${(currentPrice * quantity.value).toPriceWithCurrency(currency.symbol)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
