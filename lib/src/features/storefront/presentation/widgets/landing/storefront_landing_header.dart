import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_cart_button.dart';

class StorefrontLandingHeader extends StatelessWidget {
  final StorefrontAudience audience;
  final int totalItems;
  final bool embedded;
  final VoidCallback onCartTap;

  const StorefrontLandingHeader({
    super.key,
    required this.audience,
    required this.totalItems,
    required this.embedded,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFF7A800), Color(0xFFF36B1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.store,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: embedded ? 22.sp : 26.sp,
                    fontWeight: FontWeight.w900,
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
            l10n.storefront_unified_subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.45,
              fontSize: 13.sp,
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
