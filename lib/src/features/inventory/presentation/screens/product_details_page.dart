import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:solar_hub/src/utils/app_strings.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/dashboard_data_provider.dart';
import '../../domain/entities/product.dart';
import '../providers/inventory_provider.dart';

class ProductDetailsPage extends ConsumerWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  bool _canEdit(String role, Map<String, String> permissions) {
    if (role == AppStrings.owner || role == 'admin') return true;
    return permissions[AppStrings.inventoryPermission] == AppStrings.writePremeission;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final role = dashboardAsync.value?.role ?? '';
    final permissions = dashboardAsync.value?.permissions ?? {};
    final canEdit = _canEdit(role, permissions);

    return Scaffold(
      backgroundColor: Colors.grey[50], // sleek background
      appBar: AppBar(
        title: Text(product.name),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Product',
              onPressed: () {
                context.push('/company-dashboard/inventory/edit/${product.id}', extra: product);
              },
            ),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete Product',
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(context),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo(context),
                    const SizedBox(height: 32),
                    _buildStatsRow(context),
                    const SizedBox(height: 32),
                    _buildDescriptionSection(context),
                    if (product.options.isNotEmpty) ...[const SizedBox(height: 32), _buildOptionsSection(context)],
                    if (product.pricingTiers.isNotEmpty) ...[const SizedBox(height: 32), _buildPricingTiersSection(context)],
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        image: product.productImages.isNotEmpty ? DecorationImage(image: CachedNetworkImageProvider(product.productImages.first), fit: BoxFit.cover) : null,
      ),
      child: product.productImages.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text("No Image Available", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              ],
            )
          : null,
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(product.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text("SKU: ${product.sku?.isNotEmpty == true ? product.sku : 'N/A'}", style: TextStyle(fontSize: 15, color: Colors.grey[600])),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(product.category?.name ?? "Uncategorized", style: const TextStyle(fontWeight: FontWeight.w600)),
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            if (product.stockQuantity <= product.minStockAlert)
              Chip(
                label: const Text("Low Stock", style: TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                labelStyle: const TextStyle(color: Colors.redAccent),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              )
            else
              Chip(
                label: const Text("In Stock", style: TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                labelStyle: const TextStyle(color: Colors.green),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard(context, title: "In Stock", value: "${product.stockQuantity}", icon: Icons.inventory_2, iconColor: Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallStatCard(
            context,
            title: "Retail",
            value: "\$${product.retailPrice.toStringAsFixed(2)}",
            icon: Icons.sell_outlined,
            iconColor: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallStatCard(
            context,
            title: "Wholesale",
            value: "\$${product.wholesalePrice.toStringAsFixed(2)}",
            icon: Icons.storefront,
            iconColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Description"),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Text(
            product.description?.isNotEmpty == true ? product.description! : "No description provided",
            style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Product Options"),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: product.options.map((opt) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(opt.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      "+\$${opt.retailPrice}",
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPricingTiersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Quantity Discounts"),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Table(
              border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
              columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05)),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Text(
                        "Min Quantity",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Text(
                        "Unit Price",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                ...product.pricingTiers.map((tier) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Text("${tier.quantity} units", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Text(
                          "\$${tier.unitPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Product", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this product? This action cannot be undone.", style: TextStyle(height: 1.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop(); // close dialog
              final success = await ref.read(inventoryNotifierProvider.notifier).deleteProduct(product.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product successfully deleted")));
                context.pop(); // go back to inventory list
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
