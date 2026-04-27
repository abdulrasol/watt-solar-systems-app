import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontCartButton extends StatelessWidget {
  final StorefrontAudience audience;
  final VoidCallback onPressed;
  final bool filled;

  const StorefrontCartButton({
    super.key,
    required this.audience,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: storefrontCart,
      builder: (context, _) {
        final count = storefrontCart.totalItemsAll();
        final background = filled
            ? AppTheme.primaryColor
            : Theme.of(context).cardColor;

        return Material(
          color: background,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: filled
                      ? Colors.transparent
                      : AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        FontAwesome.cart_shopping_solid,
                        size: 18.sp,
                        color: filled ? Colors.white : AppTheme.primaryColor,
                      ),
                      if (count > 0)
                        PositionedDirectional(
                          top: -8,
                          end: -10,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
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
