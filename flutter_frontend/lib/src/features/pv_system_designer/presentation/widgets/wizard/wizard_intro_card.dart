import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/src/utils/app_theme.dart';

class WizardIntroCard extends StatelessWidget {
  const WizardIntroCard({super.key, required this.icon, required this.titleEn, required this.titleAr, required this.descriptionEn, required this.descriptionAr});

  final IconData icon;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withValues(alpha: 0.12), AppTheme.primaryColor.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAr ? titleAr : titleEn, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.sp)),
                SizedBox(height: 4.h),
                Text(
                  isAr ? descriptionAr : descriptionEn,
                  style: TextStyle(fontSize: 11.sp, color: isDark ? Colors.white70 : Colors.grey[600], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
