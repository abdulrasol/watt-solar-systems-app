import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isOutOfStock = product.stockQuantity == 0;
    final bool isLowStock = product.stockQuantity <= product.minStockAlert && product.stockQuantity > 0;

    Color statusColor = Colors.green;
    String statusText = l10n.available;
    if (isOutOfStock) {
      statusColor = Colors.red;
      statusText = l10n.unavailable;
    } else if (isLowStock) {
      statusColor = Colors.orange;
      statusText = l10n.low_stock;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/inventory/product/${product.id}', extra: product);
        },
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with premium feel
              Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: product.images.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (context, url, error) => Icon(Icons.image_outlined, color: Colors.grey, size: 30.r),
                        ),
                      )
                    : Icon(Icons.inventory_2_outlined, color: Colors.grey.withValues(alpha: 0.5), size: 40.r),
              ),
              SizedBox(width: 16.w),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${l10n.sku}: ${product.sku ?? "---"}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          l10n.iqd_price(product.displayPrice),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDarkColor,
                          ),
                        ),
                        const Spacer(),
                        _buildStatusBadge(statusText, statusColor),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.inventory_2, size: 14.r, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          '${l10n.stock_count(product.stockQuantity)}',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        if (product.globalCategory != null)
                          _buildCategoryBadge(product.globalCategory!.name, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategoryBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10.sp, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
      ),
    );
  }
}
