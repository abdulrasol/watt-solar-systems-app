import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/controllers/roof_simulator_controller.dart';

class MetricsPanel extends ConsumerWidget {
  const MetricsPanel({super.key});

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  Widget _buildStatChip({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2523) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4))
        ],
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.15 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14.sp),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 8.sp,
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulator = ref.watch(roofSimulatorProvider);
    final controller = ref.read(roofSimulatorProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final panelsCount = controller.panelsCount;
    final peakPower = controller.peakPower;
    final totalArea = controller.totalArea;
    final totalWeight = panelsCount * simulator.panelWeightKg;
    final obstaclesCount = controller.obstaclesCount;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A18) : const Color(0xFFF4FAF7),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF1B2523).withValues(alpha: 0.1),
            width: 1.5,
          ),
          top: BorderSide(
            color: const Color(0xFF1B2523).withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildStatChip(
              context: context,
              label: _tr(context, 'Panels', 'الألواح'),
              value: '$panelsCount',
              icon: Iconsax.sun_1_bold,
              color: Colors.amber,
              isDark: isDark,
            ),
            SizedBox(width: 8.w),
            _buildStatChip(
              context: context,
              label: _tr(context, 'Output', 'القدرة'),
              value: '${peakPower.toStringAsFixed(2)} kWp',
              icon: Iconsax.flash_1_bold,
              color: Colors.redAccent,
              isDark: isDark,
            ),
            SizedBox(width: 8.w),
            _buildStatChip(
              context: context,
              label: _tr(context, 'Area', 'المساحة'),
              value: '${totalArea.toStringAsFixed(1)} m²',
              icon: Iconsax.grid_5_bold,
              color: Colors.blueAccent,
              isDark: isDark,
            ),
            SizedBox(width: 8.w),
            _buildStatChip(
              context: context,
              label: _tr(context, 'Weight', 'الوزن'),
              value: '${totalWeight.toStringAsFixed(0)} kg',
              icon: Icons.fitness_center,
              color: Colors.teal,
              isDark: isDark,
            ),
            SizedBox(width: 8.w),
            _buildStatChip(
              context: context,
              label: _tr(context, 'Obstacles', 'العوائق'),
              value: '$obstaclesCount',
              icon: Icons.warning_amber_rounded,
              color: Colors.orangeAccent,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}
