import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontProductCard extends StatelessWidget {
  final StorefrontProduct product;
  final StorefrontAudience audience;
  final VoidCallback onTap;

  const StorefrontProductCard({
    super.key,
    required this.product,
    required this.audience,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final priceFormat = NumberFormat.decimalPattern();
    final isB2b = audience == StorefrontAudience.b2b;
    final color = isB2b ? const Color(0xFF1C6E8C) : AppTheme.primaryColor;
    final heroTag = '${audience.name}_${product.company.id}_${product.id}';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: heroTag,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                  ),
                  child: product.primaryImage == null
                      ? Icon(Icons.image_outlined, size: 36.sp, color: color)
                      : ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: product.primaryImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: product.isAvailable
                          ? AppTheme.successColor.withValues(alpha: 0.12)
                          : AppTheme.errorColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      product.isAvailable ? l10n.available : l10n.unavailable,
                      style: TextStyle(
                        color: product.isAvailable
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    product.company.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (product.categoryLabel.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      product.categoryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, color: color),
                    ),
                  ],
                  SizedBox(height: 10.h),
                  Text(
                    l10n.iqd_price(priceFormat.format(product.displayPrice)),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isB2b
                              ? l10n.wholesale_price_label(
                                  priceFormat.format(product.wholesalePrice),
                                )
                              : l10n.retail_price_label(
                                  priceFormat.format(product.retailPrice),
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Text(
                        l10n.stock_count(product.stockQuantity),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
