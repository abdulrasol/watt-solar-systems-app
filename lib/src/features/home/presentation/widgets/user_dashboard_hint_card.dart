import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';

class UserDashboardHintCard extends StatelessWidget {
  const UserDashboardHintCard({super.key, required this.hint});

  final ExplanationItem hint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14.r)),
            child: Icon(Iconsax.info_circle, color: AppTheme.primaryColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hint.title,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6.h),
                Text(
                  hint.description,
                  style: TextStyle(fontSize: 12.sp, height: 1.55, color: isDark ? Colors.white70 : Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
