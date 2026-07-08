import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_cart_button.dart';

class StorefrontHeader extends StatelessWidget {
  final StorefrontAudience audience;
  final int totalItems;
  final bool embedded;
  final VoidCallback onCartTap;

  const StorefrontHeader({
    super.key,
    required this.audience,
    required this.totalItems,
    required this.embedded,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isB2b = audience == StorefrontAudience.b2b;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isB2b
              ? [const Color(0xFF123A52), const Color(0xFF1C6E8C)]
              : [const Color(0xFFFFB703), const Color(0xFFFB8500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isB2b ? l10n.b2b_storefront : l10n.b2c_storefront,
                  style: TextStyle(
                    fontSize: embedded ? 22.sp : 24.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              StorefrontCartButton(
                audience: audience,
                onPressed: onCartTap,
                filled: true,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            isB2b ? l10n.storefront_b2b_subtitle : l10n.storefront_b2c_subtitle,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.45,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              l10n.storefront_products_available(totalItems),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
