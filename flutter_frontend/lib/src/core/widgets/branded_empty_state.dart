import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/src/utils/app_theme.dart';

class BrandedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double? iconSize;

  const BrandedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.3),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: iconSize ?? 64.sp,
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTheme.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      fontFamily: AppTheme.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (action != null) ...[
                  SizedBox(height: 24.h),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
