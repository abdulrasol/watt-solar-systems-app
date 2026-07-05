import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontProductsEmptyState extends StatelessWidget {
  final String message;
  final bool showErrorStyle;

  const StorefrontProductsEmptyState({
    super.key,
    required this.message,
    this.showErrorStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Icon(
            showErrorStyle
                ? Icons.error_outline_rounded
                : Icons.storefront_outlined,
            size: 42.sp,
            color: showErrorStyle ? AppTheme.errorColor : Colors.grey.shade500,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp),
          ),
        ],
      ),
    );
  }
}
