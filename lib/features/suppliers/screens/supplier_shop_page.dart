import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/suppliers/controllers/suppliers_controller.dart';
import 'package:solar_hub/features/suppliers/screens/supplier_product_details_page.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/features/store/controllers/cart_controller.dart';
import 'package:solar_hub/features/store/screens/cart_page.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';
import 'package:solar_hub/controllers/currency_controller.dart';
import 'package:solar_hub/models/currency_model.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class SupplierShopPage extends StatefulWidget {
  final CompanyModel wholesaler;

  const SupplierShopPage({super.key, required this.wholesaler});

  @override
  State<SupplierShopPage> createState() => _SupplierShopPageState();
}

class _SupplierShopPageState extends State<SupplierShopPage> {
  final SuppliersController controller = Get.find(); // Already in memory

  @override
  void initState() {
    super.initState();
    // Fetch products for this specific wholesaler when viewing their shop
    // Using simple Future.microtask to avoid build errors if called immediately
    Future.microtask(() => controller.fetchSupplierProducts(widget.wholesaler.id));
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wholesaler.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Theme.of(context).dividerColor, height: 1.0),
        ),
      ),
      floatingActionButton: Obx(() {
        final count = filterCartCount(cartController, widget.wholesaler.id);
        if (count == 0) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => Get.to(() => CartPage(filterCompanyId: widget.wholesaler.id)), // Ensure CartPage is imported
          icon: const Icon(Icons.shopping_cart),
          label: Text('${'view_cart'.tr} ($count)'),
          backgroundColor: Theme.of(context).primaryColor,
        );
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.wholesaler.status != 'active') {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                Text('store_inactive_msg'.tr, style: TextStyle(fontSize: 18, color: Theme.of(context).disabledColor)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'store_verification_pending'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.supplierProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.box_search_bold, size: 64, color: Theme.of(context).disabledColor),
                const SizedBox(height: 16),
                Text('no_wholesale_products'.tr, style: TextStyle(fontSize: 18, color: Theme.of(context).disabledColor)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.supplierProducts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = controller.supplierProducts[index];
            return _buildProductRow(context, product);
          },
        );
      }),
    );
  }

  Widget _buildProductRow(BuildContext context, ProductModel product) {
    final wholesalePrice = product.wholesalePrice;
    // final retailPrice = product.retailPrice;
    final hasTiers = product.pricingTiers.isNotEmpty;

    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.to(() => SupplierProductDetailsPage(product: product, supplier: widget.wholesaler)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              StoreImage(url: product.imageUrl, width: 80, height: 80, fit: BoxFit.cover, borderRadius: 8),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('SKU: ${product.sku ?? '-'}', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            '${'wholesale'.tr}: ${wholesalePrice.toPriceWithCurrency(_getCurrency(product).symbol)}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        if (hasTiers)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.discount, size: 12, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  'quantity_discounts'.tr,
                                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action
              IconButton(
                onPressed: () => Get.to(() => SupplierProductDetailsPage(product: product, supplier: widget.wholesaler)),
                icon: Icon(Iconsax.arrow_right_3_outline, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int filterCartCount(CartController controller, String? companyId) {
    if (companyId == null) return controller.itemCount;
    return controller.cartItems.where((i) => i.product.companyId == companyId).fold(0, (sum, item) => sum + item.quantity);
  }

  CurrencyModel _getCurrency(ProductModel product) {
    if (product.currency != null) return product.currency!;
    final currencyController = Get.find<CurrencyController>();
    return currencyController.getCurrencyById(widget.wholesaler.currencyId) ??
        currencyController.defaultCurrency ??
        CurrencyModel(id: 'manual', name: 'US Dollar', code: 'USD', symbol: '\$');
  }
}
