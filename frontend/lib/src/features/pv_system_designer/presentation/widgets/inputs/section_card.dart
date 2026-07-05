import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.titleEn, required this.titleAr, required this.child, this.icon, this.explanationEn, this.explanationAr});

  final String titleEn;
  final String titleAr;
  final Widget child;
  final IconData? icon;
  final String? explanationEn;
  final String? explanationAr;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2624) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18.sp, color: Colors.amber),
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: Text(
                  isAr ? titleAr : titleEn,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                ),
              ),
              if (explanationEn != null)
                IconButton(
                  onPressed: () => _showExplanation(context, isAr),
                  icon: Icon(Icons.info_outline_rounded, size: 16.sp, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  void _showExplanation(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(isAr ? titleAr : titleEn, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(isAr ? (explanationAr ?? '') : (explanationEn ?? ''), style: TextStyle(fontSize: 13.sp, height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(isAr ? 'فهمت' : 'Got it'))],
      ),
    );
  }
}
