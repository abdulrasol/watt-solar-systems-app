import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/widgets/wd_image_preview.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:watt/src/utils/app_theme.dart';

class StorefrontProductCard extends StatefulWidget {
  final StorefrontProduct product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;

  const StorefrontProductCard({super.key, required this.product, required this.onTap, required this.onAddToCart, required this.onRemoveFromCart});

  @override
  State<StorefrontProductCard> createState() => _StorefrontProductCardState();
}

class _StorefrontProductCardState extends State<StorefrontProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _animationController.forward();
  void _onTapUp(TapUpDetails details) => _animationController.reverse();
  void _onTapCancel() => _animationController.reverse();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final priceFormat = NumberFormat.decimalPattern();
    final requiredOptionIds = widget.product.options.where((option) => option.isRequired).map((e) => e.id).toList();

    return ListenableBuilder(
      listenable: storefrontCart,
      builder: (context, _) {
        final isInCart = storefrontCart.containsProduct(widget.product, selectedOptionIds: requiredOptionIds);

        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: () {
            _animationController.forward().then((_) {
              _animationController.reverse();
              widget.onTap();
            });
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10), spreadRadius: -5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                            child: widget.product.primaryImage == null
                                ? Container(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.inventory_2_outlined, size: 42.sp, color: AppTheme.primaryColor.withValues(alpha: 0.4)),
                                  )
                                : RepaintBoundary(
                                    child: CachedNetworkImage(
                                      imageUrl: widget.product.primaryImage!,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 500,
                                      memCacheHeight: 500,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.withValues(alpha: 0.1),
                                        child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                                        child: Icon(Icons.broken_image_outlined, size: 38.sp, color: AppTheme.primaryColor.withValues(alpha: 0.4)),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        PositionedDirectional(
                          top: 12,
                          start: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: widget.product.isAvailable ? AppTheme.successColor : Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(999.r),
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.product.isAvailable ? AppTheme.successColor : Theme.of(context).colorScheme.error).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.product.isAvailable ? l10n.available : l10n.unavailable,
                              style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                            ),
                          ),
                        ),
                        if (widget.product.images.length > 1)
                          PositionedDirectional(
                            bottom: 12,
                            end: 12,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(999.r),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.photo_library_rounded, size: 12.sp, color: Colors.white),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '1/${widget.product.images.length}',
                                    style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _CompanyAvatar(company: widget.product.company),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                widget.product.company.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, height: 1.3, letterSpacing: -0.3),
                        ),
                        if (widget.product.categoryLabel.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8.r)),
                            child: Text(
                              widget.product.categoryLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                            ),
                          ),
                        ],
                        SizedBox(height: 16.h),
                        Text(
                          l10n.iqd_price(priceFormat.format(widget.product.displayPrice)),
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          child: isInCart
                              ? OutlinedButton.icon(
                                  onPressed: widget.onRemoveFromCart,
                                  icon: Icon(Icons.remove_shopping_cart_rounded, size: 20.sp),
                                  label: Text(
                                    l10n.remove_from_cart,
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    foregroundColor: Theme.of(context).colorScheme.error,
                                    side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                    elevation: 0,
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: widget.onAddToCart,
                                  icon: Icon(Icons.add_shopping_cart_rounded, size: 20.sp),
                                  label: Text(
                                    l10n.add_to_cart,
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                    elevation: 0,
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
        child: RepaintBoundary(
          child: WdImagePreview(imageUrl: company.logo!, fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      width: 28.r,
      height: 28.r,
      decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12.r)),
      alignment: Alignment.center,
      child: Text(
        company.name.isEmpty ? '?' : company.name.substring(0, 1),
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
      ),
    );
  }
}
