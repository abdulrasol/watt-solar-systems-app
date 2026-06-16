import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/wizard/wizard_intro_card.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/canvas/roof_grid_canvas.dart';

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
            icon: Iconsax.sun_bold,
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
                Text(isAr ? 'الأدوات' : 'Tools', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildToolChip(context, isAr, ToolMode.placePanel, isAr ? 'لوح' : 'Panel', Iconsax.sun_1_bold, Colors.amber, state.activeTool, (t) => controller.selectTool(t)),
                    _buildToolChip(context, isAr, ToolMode.placeObstacle, isAr ? 'عائق' : 'Obstacle', Icons.warning_amber_rounded, Colors.redAccent, state.activeTool, (t) => controller.selectTool(t)),
                    _buildToolChip(context, isAr, ToolMode.placeTree, isAr ? 'شجرة' : 'Tree', Icons.park_rounded, Colors.green, state.activeTool, (t) => controller.selectTool(t)),
                    _buildToolChip(context, isAr, ToolMode.excludeRoof, isAr ? 'مستبعد' : 'Exclude', Icons.close_rounded, Colors.blueGrey, state.activeTool, (t) => controller.selectTool(t)),
                    _buildToolChip(context, isAr, ToolMode.erase, isAr ? 'ممحاة' : 'Eraser', Icons.auto_fix_normal_rounded, Colors.orange, state.activeTool, (t) => controller.selectTool(t)),
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
                Text(isAr ? 'وقت المحاكي' : 'Simulation Time', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp)),
                SizedBox(height: 8.h),
                Slider(
                  value: state.simulationTime,
                  min: 8.0,
                  max: 17.0,
                  divisions: 18,
                  label: _formatHour(state.simulationTime, isAr),
                  onChanged: (v) => controller.updateSimulationTime(v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isAr ? 'شروق' : 'Sunrise', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                    Text(isAr ? 'ظهر' : 'Noon', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                    Text(isAr ? 'غروب' : 'Sunset', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                  ],
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
                  icon: Icon(state.isSafeOverlayActive ? Iconsax.eye_bold : Iconsax.eye_slash_bold, size: 16.sp),
                  label: Text(isAr ? 'طبقة الأمان' : 'Safety Overlay', style: TextStyle(fontSize: 10.sp)),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10.h)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.autofillRoof(avoidShade: true),
                  icon: Icon(Iconsax.magic_star_bold, size: 16.sp),
                  label: Text(isAr ? 'ملء تلقائي' : 'Autofill', style: TextStyle(fontSize: 10.sp)),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10.h)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.rotateGrid90Clockwise(),
                  icon: Icon(Iconsax.refresh_bold, size: 16.sp),
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
                  icon: Icon(Iconsax.undo_bold, size: 16.sp),
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
                          ElevatedButton(onPressed: () { controller.clearGrid(); Navigator.pop(context); }, child: Text(isAr ? 'مسح' : 'Clear')),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.refresh_rounded, size: 16.sp),
                  label: Text(isAr ? 'مسح' : 'Clear', style: TextStyle(fontSize: 10.sp)),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10.h), foregroundColor: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatHour(double hour, bool isAr) {
    final h = hour.floor();
    final m = ((hour - h) * 60).round();
    final period = h >= 12 ? (isAr ? 'م' : 'PM') : (isAr ? 'ص' : 'AM');
    final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$displayH:${m.toString().padLeft(2, '0')} $period';
  }

  Widget _buildToolChip(BuildContext context, bool isAr, ToolMode tool, String label, IconData icon, Color color, ToolMode activeTool, ValueChanged<ToolMode> onSelect) {
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
            Text(label, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: isSelected ? color : (isDark ? Colors.white70 : Colors.black87))),
          ],
        ),
      ),
    );
  }
}
