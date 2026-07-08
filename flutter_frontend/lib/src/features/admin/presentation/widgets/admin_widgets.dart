import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/core/widgets/loading_widgets.dart';
import 'package:watt/src/utils/app_theme.dart';

import 'package:watt/src/core/widgets/branded_empty_state.dart';

class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({super.key, required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return BrandedEmptyState(icon: icon, title: title, subtitle: subtitle);
  }
}

class AdminErrorState extends StatelessWidget {
  const AdminErrorState({super.key, required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(color: AppTheme.errorColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Iconsax.warning_2, size: 48.sp, color: AppTheme.errorColor),
            ),
            SizedBox(height: 24.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
            ),
            SizedBox(height: 12.h),
            Text(
              error,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLoadingState extends StatelessWidget {
  const AdminLoadingState({super.key, this.message = 'Loading...', this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, size: 40.sp, color: AppTheme.primaryColor),
                ),
                SizedBox(height: 24.h),
              ] else
                LoadingWidget(size: 80.sp),
              Text(
                message,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({super.key, required this.title, required this.value, required this.icon, required this.color, this.onTap});

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: Offset(0, 8.h))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14.r)),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 12.h),
            Flexible(
              child: Text(
                value,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4.h),
            Flexible(
              child: Text(
                title,
                style: TextStyle(fontSize: 11.sp, color: isDark ? Colors.grey[400] : Colors.grey[600], fontFamily: AppTheme.fontFamily),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminActionTile extends StatelessWidget {
  const AdminActionTile({super.key, required this.title, required this.subtitle, required this.icon, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14.r)),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, fontFamily: AppTheme.fontFamily),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13.sp, color: isDark ? Colors.grey[400] : Colors.grey[600], fontFamily: AppTheme.fontFamily),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20.sp),
          ],
        ),
      ),
    );
  }
}
