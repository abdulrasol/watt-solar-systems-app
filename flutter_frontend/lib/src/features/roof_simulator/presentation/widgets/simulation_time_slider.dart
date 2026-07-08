import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/src/features/roof_simulator/presentation/controllers/roof_simulator_controller.dart';

class SimulationTimeSlider extends ConsumerWidget {
  const SimulationTimeSlider({super.key});

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  String _formatHour(double hour) {
    final int h = hour.floor();
    final int m = ((hour - h) * 60).round();
    final String minutesStr = m < 10 ? '0$m' : '$m';

    if (h == 12) {
      return '12:$minutesStr PM';
    } else if (h > 12) {
      return '${h - 12}:$minutesStr PM';
    } else {
      return '$h:$minutesStr AM';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulator = ref.watch(roofSimulatorProvider);
    final controller = ref.read(roofSimulatorProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E1C) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.amber,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _tr(context, 'Sun Altitude & Shadows', 'ارتفاع الشمس والظلال'),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  _formatHour(simulator.simulationTime),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.amber,
              inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[200],
              thumbColor: Colors.amber[700],
              overlayColor: Colors.amber.withValues(alpha: 0.2),
              valueIndicatorColor: Colors.amber[800],
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
            ),
            child: Slider(
              value: simulator.simulationTime,
              min: 8.0,
              max: 17.0,
              divisions: 18, // 30-minute intervals
              onChanged: (val) {
                controller.updateSimulationTime(val);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _tr(context, 'Sunrise (8 AM)', 'الشروق (8 ص)'),
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _tr(context, 'Noon (12 PM)', 'الظهيرة (12 م)'),
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _tr(context, 'Sunset (5 PM)', 'الغروب (5 م)'),
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
