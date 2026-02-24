import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/layouts/company/add_product_page.dart';
import 'package:solar_hub/layouts/shared/widgets/responsive_row_column.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class ProductDetailsPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsPage({super.key, required this.product});

  bool get _canEdit {
    final role = Get.find<CompanyController>().currentRole.value;
    return ['owner', 'manager', 'inventory_manager'].contains(role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          if (_canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Get.to(() => AddProductPage(product: product));
                if (result == true) {
                  Get.back(result: true); // Cascade update back to inventory list
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        image: (product.imageUrl?.isNotEmpty ?? false)
                            ? DecorationImage(image: CachedNetworkImageProvider(product.imageUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: (product.imageUrl?.isEmpty ?? true) ? const Icon(Icons.image, size: 40) : null,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("${'sku'.tr}: ${product.sku ?? 'N/A'}", style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(label: Text(product.category ?? "global_category".tr)), // Using Global Category as fallback label or Uncategorized
                              if (product.stockQuantity <= (product.minStockAlert))
                                Chip(
                                  label: Text("low_stock".tr),
                                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                                  labelStyle: const TextStyle(color: Colors.red),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics / Inventory
            ResponsiveRowColumn(
              children: [
                _buildInfoCard(context, title: "in_stock".tr, value: product.stockQuantity.toString(), icon: Icons.inventory_2, iconColor: Colors.blue),
                _buildInfoCard(
                  context,
                  title: "retail_price".tr,
                  value: product.retailPrice.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                  icon: Icons.attach_money,
                  iconColor: AppTheme.primaryColor,
                  isPrice: true,
                  discountPrice: product.hasDiscount
                      ? product.effectivePrice.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol)
                      : null,
                ),
                _buildInfoCard(
                  context,
                  title: "wholesale".tr,
                  value: product.wholesalePrice.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                  icon: Icons.store,
                  iconColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details
            Text("description".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(product.description?.isNotEmpty == true ? product.description! : "no_description".tr),
            const SizedBox(height: 24),

            if (product.options.isNotEmpty) ...[
              Text("product_options".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: product.options.map((opt) {
                  return Chip(label: Text("${opt.name}: ${opt.values.map((v) => v.value).join(', ')}"));
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            if (product.pricingTiers.isNotEmpty) ...[
              Text("pricing_tiers".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.grey.withValues(alpha: 0.2)),
                columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("min_qty".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("unit_price".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...product.pricingTiers.map((tier) {
                    return TableRow(
                      children: [
                        Padding(padding: const EdgeInsets.all(8.0), child: Text(tier.minQuantity.toString())),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(tier.unitPrice.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
    bool isPrice = false,
    String? discountPrice,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? Colors.blue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (discountPrice != null) ...[
            Text(
              discountPrice,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough, color: Colors.grey),
            ),
          ] else
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
