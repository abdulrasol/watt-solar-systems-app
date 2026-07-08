import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:watt/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/wizard/wizard_intro_card.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/canvas/roof_grid_canvas.dart';
import 'package:watt/src/utils/app_theme.dart';

class ShadowsObstaclesStep extends ConsumerWidget {
  const ShadowsObstaclesStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pvSystemDesignerProvider);
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    final isAr = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardIntroCard(
            icon: Iconsax.sun,
            titleEn: 'Panel Layout & Shadows',
            titleAr: 'توزيع الألواح والظلال',
            descriptionEn: 'Place panels on the roof grid. Mark obstacles, trees, and shadow zones. Use the time slider to simulate sun movement.',
            descriptionAr: 'ضع الألواح على شبكة السقف. حدد العوائق والأشجار ومناطق الظل. استخدم منزلق الوقت لمحاكاة حركة الشمس.',
          ),
          SizedBox(height: 16.h),
          const RoofGridCanvas(),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2624) : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'الأدوات' : 'Tools',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildToolChip(
                      context,
                      isAr,
                      ToolMode.placePanel,
                      isAr ? 'لوح' : 'Panel',
                      Iconsax.sun_1,
                      Colors.amber,
                      state.activeTool,
                      (t) => controller.selectTool(t),
                    ),
                    _buildToolChip(
                      context,
                      isAr,
                      ToolMode.placeObstacle,
                      isAr ? 'عائق' : 'Obstacle',
                      Icons.warning_amber_rounded,
                      Colors.redAccent,
                      state.activeTool,
                      (t) => controller.selectTool(t),
                    ),
                    _buildToolChip(
                      context,
                      isAr,
                      ToolMode.placeTree,
                      isAr ? 'شجرة' : 'Tree',
                      Icons.park_rounded,
                      Colors.green,
                      state.activeTool,
                      (t) => controller.selectTool(t),
                    ),
                    _buildToolChip(
                      context,
                      isAr,
                      ToolMode.excludeRoof,
                      isAr ? 'مستبعد' : 'Exclude',
                      Icons.close_rounded,
                      Colors.blueGrey,
                      state.activeTool,
                      (t) => controller.selectTool(t),
                    ),
                    _buildToolChip(
                      context,
                      isAr,
                      ToolMode.erase,
                      isAr ? 'ممحاة' : 'Eraser',
                      Icons.auto_fix_normal_rounded,
                      Colors.orange,
                      state.activeTool,
                      (t) => controller.selectTool(t),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2624) : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isAr ? 'تاريخ المحاكاة' : 'Simulation Date',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: state.simulationDate,
                          firstDate: DateTime(state.simulationDate.year - 1),
                          lastDate: DateTime(state.simulationDate.year + 1),
                        );
                        if (picked != null) controller.updateSimulationDate(picked);
                      },
                      icon: Icon(Icons.calendar_month_rounded, size: 14.sp),
                      label: Text(
                        '${state.simulationDate.year}-${state.simulationDate.month.toString().padLeft(2, '0')}-${state.simulationDate.day.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6.w,
                  children: [
                    _buildDatePreset(context, isAr ? 'الانقلاب الشتوي' : 'Winter Solstice', DateTime(state.simulationDate.year, 12, 21), controller),
                    _buildDatePreset(context, isAr ? 'الاعتدال' : 'Equinox', DateTime(state.simulationDate.year, 3, 20), controller),
                    _buildDatePreset(context, isAr ? 'الانقلاب الصيفي' : 'Summer Solstice', DateTime(state.simulationDate.year, 6, 21), controller),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  isAr ? 'وقت المحاكي' : 'Simulation Time',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                Builder(
                  builder: (context) {
                    final sunTimes = controller.sunriseSunset;
                    final double min = sunTimes.sunrise.clamp(0.0, 23.5).toDouble();
                    final double max = sunTimes.sunset.clamp(min + 0.5, 24.0).toDouble();
                    final double clampedValue = state.simulationTime.clamp(min, max).toDouble();
                    final sun = controller.sunPosition;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: clampedValue,
                          min: min,
                          max: max,
                          divisions: ((max - min) * 4).round().clamp(1, 200).toInt(),
                          label: _formatHour(clampedValue, isAr),
                          onChanged: (v) => controller.updateSimulationTime(v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${isAr ? 'شروق' : 'Sunrise'} ${_formatHour(min, isAr)}',
                              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                            ),
                            Text(
                              '${isAr ? 'غروب' : 'Sunset'} ${_formatHour(max, isAr)}',
                              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          sun.isDaylight
                              ? (isAr
                                    ? 'ارتفاع الشمس ${sun.elevationDeg.toStringAsFixed(0)}° · الاتجاه ${sun.azimuthDeg.toStringAsFixed(0)}°'
                                    : 'Sun elevation ${sun.elevationDeg.toStringAsFixed(0)}° · azimuth ${sun.azimuthDeg.toStringAsFixed(0)}°')
                              : (isAr ? 'الشمس تحت الأفق في هذا الوقت' : 'Sun is below the horizon at this time'),
                          style: TextStyle(fontSize: 10.sp, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.toggleSafeOverlay(),
                  icon: Icon(state.isSafeOverlayActive ? Iconsax.eye : Iconsax.eye_slash, size: 16.sp),
                  label: Text(isAr ? 'طبقة الأمان' : 'Safety Overlay', style: TextStyle(fontSize: 10.sp)),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10.h)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.autofillRoof(avoidShade: true),
                  icon: Icon(Iconsax.magic_star, size: 16.sp),
                  label: Text(isAr ? 'ملء تلقائي' : 'Autofill', style: TextStyle(fontSize: 10.sp)),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10.h)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.rotateGrid90Clockwise(),
                  icon: Icon(Iconsax.refresh, size: 16.sp),
                  label: Text(isAr ? 'تدوير' : 'Rotate', style: TextStyle(fontSize: 10.sp)),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10.h)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.undo,
                  icon: Icon(Iconsax.undo, size: 16.sp),
                  label: Text(isAr ? 'تراجع' : 'Undo', style: TextStyle(fontSize: 10.sp)),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10.h)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.redo,
                  icon: Icon(Icons.refresh, size: 16.sp),
                  label: Text(isAr ? 'إعادة' : 'Redo', style: TextStyle(fontSize: 10.sp)),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10.h)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(isAr ? 'إعادة تعيين' : 'Reset Canvas'),
                        content: Text(isAr ? 'هل أنت متأكد؟' : 'Clear all placed items?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text(isAr ? 'إلغاء' : 'Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              controller.clearGrid();
                              Navigator.pop(context);
                            },
                            child: Text(isAr ? 'مسح' : 'Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.refresh_rounded, size: 16.sp),
                  label: Text(isAr ? 'مسح' : 'Clear', style: TextStyle(fontSize: 10.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePreset(BuildContext context, String label, DateTime date, PvSystemDesignerController controller) {
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 9.5.sp)),
      onPressed: () => controller.updateSimulationDate(date),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatHour(double hour, bool isAr) {
    final h = hour.floor();
    final m = ((hour - h) * 60).round();
    final period = h >= 12 ? (isAr ? 'م' : 'PM') : (isAr ? 'ص' : 'AM');
    final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$displayH:${m.toString().padLeft(2, '0')} $period';
  }

  Widget _buildToolChip(
    BuildContext context,
    bool isAr,
    ToolMode tool,
    String label,
    IconData icon,
    Color color,
    ToolMode activeTool,
    ValueChanged<ToolMode> onSelect,
  ) {
    final isSelected = activeTool == tool;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onSelect(tool),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : (isDark ? const Color(0xFF1E2624) : const Color(0xFFF7F9F8)),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? color : Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 14.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: isSelected ? color : (isDark ? Colors.white70 : Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
}
