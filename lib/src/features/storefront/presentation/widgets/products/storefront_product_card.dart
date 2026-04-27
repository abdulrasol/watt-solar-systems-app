import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontProductCard extends StatelessWidget {
  final StorefrontProduct product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;

  const StorefrontProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final priceFormat = NumberFormat.decimalPattern();
    final requiredOptionIds = product.options
        .where((option) => option.isRequired)
        .map((e) => e.id)
        .toList();

    return ListenableBuilder(
      listenable: storefrontCart,
      builder: (context, _) {
        final isInCart = storefrontCart.containsProduct(
          product,
          selectedOptionIds: requiredOptionIds,
        );

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24.r),
            child: Ink(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24.r),
                            ),
                            child: product.primaryImage == null
                                ? Container(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.08,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 38.sp,
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: product.primaryImage!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        PositionedDirectional(
                          top: 12,
                          start: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? AppTheme.successColor.withValues(
                                      alpha: 0.88,
                                    )
                                  : Colors.black.withValues(alpha: 0.62),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              product.isAvailable
                                  ? l10n.available
                                  : l10n.unavailable,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        if (product.images.length > 1)
                          PositionedDirectional(
                            bottom: 12,
                            end: 12,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                '1/${product.images.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(14.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _CompanyAvatar(company: product.company),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                product.company.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.62),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                        if (product.categoryLabel.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              product.categoryLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 12.h),
                        Text(
                          l10n.iqd_price(
                            priceFormat.format(product.displayPrice),
                          ),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          child: isInCart
                              ? OutlinedButton.icon(
                                  onPressed: onRemoveFromCart,
                                  icon: const Icon(
                                    Icons.remove_shopping_cart_rounded,
                                  ),
                                  label: Text(l10n.remove_from_cart),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: onAddToCart,
                                  icon: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                  ),
                                  label: Text(l10n.add_to_cart),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  final StorefrontCompany company;

  const _CompanyAvatar({required this.company});

  @override
  Widget build(BuildContext context) {
    if ((company.logo ?? '').isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl: company.logo!,
          width: 28.r,
          height: 28.r,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 28.r,
      height: 28.r,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Text(
        company.name.isEmpty ? '?' : company.name.substring(0, 1),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
