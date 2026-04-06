import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';
import 'package:solar_hub/src/utils/app_strings.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import '../../domain/entities/product.dart';
import '../providers/inventory_provider.dart';

class ProductDetailsPage extends ConsumerWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final companySummery = ref.watch(companySummeryProvider);
    final hasInventoryPermission = companySummery.isPermisseon(AppStrings.inventoryPermission);

    return PreScaffold(
      title: l10n.product_details,
      actions: [
        if (hasInventoryPermission) ...[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/inventory/edit/${product.id}', extra: product),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(context),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainInfo(context, l10n),
                  SizedBox(height: 24.h),
                  _buildPriceSection(context, l10n),
                  SizedBox(height: 24.h),
                  _buildInventoryStats(context, l10n),
                  SizedBox(height: 24.h),
                  _buildCategoriesSection(context, l10n),
                  SizedBox(height: 24.h),
                  _buildDescriptionSection(context, l10n),
                  if (product.options.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _buildOptionsSection(context, l10n),
                  ],
                  if (product.pricingTiers.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _buildPricingTiersSection(context, l10n),
                  ],
                  SizedBox(height: 60.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    if (product.images.isEmpty) {
      return Container(
        height: 250.h,
        width: double.infinity,
        color: Colors.grey.withValues(alpha: 0.1),
        child: Icon(Icons.inventory_2_outlined, size: 80.r, color: Colors.grey.withValues(alpha: 0.3)),
      );
    }

    return SizedBox(
      height: 300.h,
      child: PageView.builder(
        itemCount: product.images.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: product.images[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        },
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
            ),
            _buildStatusBadge(l10n),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          '${l10n.sku}: ${product.sku ?? "---"}',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(AppLocalizations l10n) {
    final isActive = product.status == 'active';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.2)),
      ),
      child: Text(
        isActive ? l10n.active : l10n.inactive,
        style: TextStyle(fontSize: 12.sp, color: isActive ? Colors.green : Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.price_overview),
        SizedBox(height: 12.h),
        Row(
          children: [
            _buildPriceItem(l10n.display_price, l10n.iqd_price(product.displayPrice), AppTheme.primaryDarkColor, isMain: true),
            SizedBox(width: 16.w),
            _buildPriceItem(l10n.costPrice, l10n.iqd_price(product.costPrice), Colors.orange),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _buildPriceItem(l10n.retail_price, l10n.iqd_price(product.retailPrice), Colors.green),
            SizedBox(width: 16.w),
            _buildPriceItem(l10n.wholesale_price, l10n.iqd_price(product.wholesalePrice), Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceItem(String label, String value, Color color, {bool isMain = false}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(fontSize: isMain ? 16.sp : 14.sp, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStats(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.inventory),
        SizedBox(height: 12.h),
        Row(
          children: [
            _buildStatCard(l10n.stockQuantity, product.stockQuantity.toString(), Icons.inventory_2, Colors.blue),
            SizedBox(width: 12.w),
            _buildStatCard(l10n.minStockAlert, product.minStockAlert.toString(), Icons.notification_important_outlined, Colors.orange),
            SizedBox(width: 12.w),
            _buildStatCard(l10n.availability, product.isAvailable ? l10n.available : l10n.unavailable, Icons.check_circle_outline, product.isAvailable ? Colors.green : Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.r),
            SizedBox(height: 8.h),
            Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.all_categories),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            if (product.globalCategory != null) _buildCategoryChip(product.globalCategory!.name, Colors.purple, l10n.global_category),
            ...product.internalCategories.map((c) => _buildCategoryChip(c.name, Colors.blue, l10n.internal_category)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String name, Color color, String type) {
    return Chip(
      avatar: CircleAvatar(backgroundColor: color.withValues(alpha: 0.2), child: Text(type[0], style: TextStyle(fontSize: 10.sp, color: color))),
      label: Text(name),
      backgroundColor: color.withValues(alpha: 0.05),
      side: BorderSide(color: color.withValues(alpha: 0.1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.description),
        SizedBox(height: 8.h),
        Text(
          product.description ?? "---",
          style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.addOption),
        SizedBox(height: 12.h),
        ...product.options.map((opt) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        if (opt.isRequired)
                          Text(l10n.isRequired, style: TextStyle(fontSize: 10.sp, color: Colors.red, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Text(
                    '+${l10n.iqd_price(opt.retailPrice)}',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildPricingTiersSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.pricing_tiers),
        SizedBox(height: 12.h),
        ...product.pricingTiers.map((tier) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppTheme.primaryDarkColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.primaryDarkColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${tier.quantity}+ units',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    l10n.iqd_price(tier.unitPrice),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkColor),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteProduct),
        content: Text(l10n.confirmDeleteProduct),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(inventoryNotifierProvider.notifier).deleteProduct(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.productDeleted)));
                context.pop();
              }
            },
            child: Text(l10n.remove, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
