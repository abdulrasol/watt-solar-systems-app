import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class SolarProductionCard extends ConsumerWidget {
  const SolarProductionCard({super.key});

  double _estimatePeakSunHours() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 6.5;
    if (month >= 6 && month <= 8) return 7.2;
    if (month >= 9 && month <= 11) return 5.8;
    return 4.5;
  }

  double _estimateDailyProduction() {
    final sunHours = _estimatePeakSunHours();
    return (sunHours * 1.5 * 0.75 * 100).roundToDouble() / 100;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sunHours = _estimatePeakSunHours();
    final dailyProduction = _estimateDailyProduction();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF8E1), Color(0xFFFFF3CD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFFFE082)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(color: const Color(0xFFFFCC02).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14.r)),
                child: Icon(Iconsax.sun_1, color: const Color(0xFFE6A800), size: 24.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.solar_tips,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF8B6914)),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.seasonal_solar_estimate,
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFFA0852B)),
                    ),
                  ],
                ),
              ),
              Icon(Iconsax.sun_1, color: const Color(0xFFE6A800), size: 32.sp),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  context,
                  icon: Iconsax.timer_1,
                  label: l10n.peak_sun_hours,
                  value: '${sunHours.toStringAsFixed(1)}h',
                  color: const Color(0xFFE6A800),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetric(
                  context,
                  icon: Iconsax.flash_1,
                  label: l10n.est_daily_kw,
                  value: '${dailyProduction.toStringAsFixed(1)} kWh',
                  color: const Color(0xFFE6A800),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: const Color(0xFFFFCC02).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10.r)),
            child: Text(
              l10n.formatSolarAdvice(_tiltAdvice()),
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8B6914), fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: const Color(0xFF8B6914), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFF5C4A0A), fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }

  String _tiltAdvice() {
    final month = DateTime.now().month;
    if (month >= 4 && month <= 9) return '15-25 degrees';
    return '30-45 degrees';
  }
}
