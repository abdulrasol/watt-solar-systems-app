import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontFilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const StorefrontFilterButton({
    super.key,
    required this.activeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = activeCount > 0;

    return Material(
      color: hasActiveFilters
          ? AppTheme.primaryColor.withValues(alpha: 0.12)
          : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: hasActiveFilters
                  ? AppTheme.primaryColor
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.tune_rounded,
                color: hasActiveFilters
                    ? AppTheme.primaryColor
                    : Theme.of(context).colorScheme.onSurface,
              ),
              if (hasActiveFilters)
                PositionedDirectional(
                  top: 7,
                  end: 7,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      '$activeCount',
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
        ),
      ),
    );
  }
}
