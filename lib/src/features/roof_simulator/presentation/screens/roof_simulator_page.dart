import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/features/roof_simulator/domain/models/roof_simulator_state.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/controllers/roof_simulator_controller.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/widgets/visual_grid_canvas.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/widgets/simulation_time_slider.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/widgets/parameter_inputs_card.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/widgets/boundary_walls_card.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/widgets/metrics_panel.dart';

class RoofSimulatorPage extends ConsumerStatefulWidget {
  const RoofSimulatorPage({super.key});

  @override
  ConsumerState<RoofSimulatorPage> createState() => _RoofSimulatorPageState();
}

class _RoofSimulatorPageState extends ConsumerState<RoofSimulatorPage> {
  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr(context, 'Reset Layout Canvas', 'إعادة تعيين اللوحة'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          _tr(
            context,
            'Are you sure you want to clear all placed panels, obstacles, and custom outlines from the canvas?',
            'هل أنت متأكد من رغبتك في مسح جميع الألواح والعوائق والخطوط المخصصة من اللوحة؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr(context, 'Cancel', 'إلغاء')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ref.read(roofSimulatorProvider.notifier).clearGrid();
              ToastService.info(
                context,
                _tr(context, 'Canvas Reset', 'تمت إعادة تعيين اللوحة'),
                _tr(context, 'All elements successfully cleared.', 'تم مسح جميع العناصر بنجاح.'),
              );
            },
            child: Text(_tr(context, 'Clear Canvas', 'مسح اللوحة')),
          ),
        ],
      ),
    );
  }

  void _autofillRoof() {
    ref.read(roofSimulatorProvider.notifier).autofillRoof(avoidShade: true);
    ToastService.success(
      context,
      _tr(context, 'Autofill Complete', 'اكتمل الملء التلقائي'),
      _tr(context, 'Successfully populated available safe space with panels.', 'تم ملء المساحات المتاحة بالألواح بنجاح.'),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: AppTheme.primaryColor),
            SizedBox(width: 8.w),
            Text(
              _tr(context, 'How to Use Simulator', 'كيفية استخدام المحاكي'),
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpRow('1', _tr(context, 'Set Dimensions:', 'تحديد الأبعاد:'), _tr(context, 'Enter your roof length, width, and desired safety setback margin.', 'أدخل طول وعرض السقف وهامش ارتداد السلامة المطلوب.')),
              _buildHelpRow('2', _tr(context, 'Select Active Tool:', 'اختيار الأداة:'), _tr(context, 'Tap a tool below (Panel, Obstacle, Tree, Excluded) to start drawing on cells.', 'اختر أداة من شريط الأدوات (لوح، عائق، شجرة، مستبعد) للبدء في الرسم على الشبكة.')),
              _buildHelpRow('3', _tr(context, 'Draw Custom Outlines:', 'رسم حدود مخصصة:'), _tr(context, 'Tap "Sketch Perimeter" to plot any custom polygon roof shapes or angles.', 'انقر على "رسم حدود السقف" لتحديد أي زوايا أو أشكال مضلعة غير منتظمة.')),
              _buildHelpRow('4', _tr(context, 'Time Shadow Sweeper:', 'محاكي حركة الظل:'), _tr(context, 'Slide the daytime hour slider to watch shadow Sweeps from chimneys/walls.', 'اسحب منزلق الساعات لمشاهدة امتداد الظلال من جدران السطح والعوائق.')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr(context, 'Got it', 'فهمت')),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpRow(String index, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 9.r,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
            child: Text(index, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5.sp)),
                SizedBox(height: 2.h),
                Text(description, style: TextStyle(fontSize: 10.5.sp, height: 1.4, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.read(roofSimulatorProvider);
    final controller = ref.read(roofSimulatorProvider.notifier);

    final panelsCount = controller.panelsCount;
    final peakPower = controller.peakPower;
    final totalArea = controller.totalArea;
    final totalWeight = panelsCount * state.panelWeightKg;
    final obstaclesCount = controller.obstaclesCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: isDark ? const Color(0xFF161E1C) : Colors.white,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12.r)),
              child: const Icon(Iconsax.document_text_bold, color: AppTheme.primaryColor),
            ),
            SizedBox(width: 10.w),
            Text(
              _tr(context, 'Roof Proposal Summary', 'ملخص مقترح السطح'),
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tr(
                  context,
                  'Here is the complete layout plan for your roof installation. You can save this design or share it directly with companies to request custom quotes.',
                  'إليك مخطط توزيع الألواح الخاص بسطحك. يمكنك حفظ هذا التصميم أو مشاركته مباشرة مع الشركات لطلب عروض أسعار مخصصة.',
                ),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp, color: isDark ? Colors.white70 : Colors.grey[700], height: 1.45),
              ),
              SizedBox(height: 18.h),
              _buildDialogStatRow(
                context,
                label: _tr(context, 'Total Solar Panels', 'إجمالي الألواح الشمسية'),
                value: '$panelsCount ${_tr(context, 'Panels', 'لوح')}',
                icon: Iconsax.sun_1_bold,
                iconColor: Colors.amber,
              ),
              const Divider(),
              _buildDialogStatRow(
                context,
                label: _tr(context, 'Peak Output (kWp)', 'قدرة الإنتاج القصوى (ك.و)'),
                value: '${peakPower.toStringAsFixed(2)} kWp',
                icon: Iconsax.flash_1_bold,
                iconColor: Colors.redAccent,
              ),
              const Divider(),
              _buildDialogStatRow(
                context,
                label: _tr(context, 'Roof Area Occupied', 'المساحة المشغولة'),
                value: '${totalArea.toStringAsFixed(1)} m²',
                icon: Iconsax.grid_5_bold,
                iconColor: Colors.blueAccent,
              ),
              const Divider(),
              _buildDialogStatRow(
                context,
                label: _tr(context, 'Structural Weight Load', 'الوزن الهيكلي الإضافي'),
                value: '${totalWeight.toStringAsFixed(0)} kg',
                icon: Icons.fitness_center,
                iconColor: Colors.teal,
              ),
              const Divider(),
              _buildDialogStatRow(
                context,
                label: _tr(context, 'Total Obstacles & Shadows', 'إجمالي العوائق والظلال'),
                value: '$obstaclesCount ${_tr(context, 'Cells', 'خلايا')}',
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.amber[800]!,
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ToastService.success(
                      context,
                      _tr(context, 'Saved Successfully', 'تم الحفظ بنجاح'),
                      _tr(context, 'Solar layout has been saved to your offline designs list.', 'تم حفظ مخطط الألواح بنجاح في قائمة تصاميمك المحلية.'),
                    );
                  },
                  child: Text(_tr(context, 'Save Design', 'حفظ التصميم')),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ToastService.success(
                      context,
                      _tr(context, 'Proposal Submitted', 'تم إرسال المقترح'),
                      _tr(
                        context,
                        'Your roof visual proposal has been sent to partner suppliers.',
                        'تمت مشاركة مقترح السطح البصري الخاص بك مع الشركات المزودة للخدمة.',
                      ),
                    );
                  },
                  child: Text(_tr(context, 'Share & Quote', 'طلب عروض')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogStatRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem({
    required BuildContext context,
    required ToolMode tool,
    required String titleEn,
    required String titleAr,
    required IconData icon,
    required Color color,
    required ToolMode activeTool,
    required Function(ToolMode) onSelect,
  }) {
    final bool isSelected = activeTool == tool;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onSelect(tool),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF1E2624) : const Color(0xFFF7F9F8)),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? color
                : Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 14.sp),
            SizedBox(width: 6.w),
            Text(
              _tr(context, titleEn, titleAr),
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final simulator = ref.watch(roofSimulatorProvider);
    final notifier = ref.read(roofSimulatorProvider.notifier);

    final panelsCount = notifier.panelsCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tr(context, 'Roof Visual Simulator', 'محاكي الأسطح البصري'),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Interactive dashboard metrics row
          const MetricsPanel(),

          // 2. Main Scrollable canvas content area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Visual drawing canvas
                  const VisualGridCanvas(),
                  SizedBox(height: 16.h),

                  // Elegant Tool Selection Strip
                  Text(
                    _tr(context, 'Interactive Tools Palette', 'لوحة الأدوات التفاعلية'),
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, color: AppTheme.primaryColor),
                  ),
                  SizedBox(height: 8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildToolItem(
                          context: context,
                          tool: ToolMode.placePanel,
                          titleEn: 'PV Panel',
                          titleAr: 'لوح شمسي',
                          icon: Iconsax.sun_1_bold,
                          color: Colors.amber,
                          activeTool: simulator.activeTool,
                          onSelect: (t) => notifier.selectTool(t),
                        ),
                        SizedBox(width: 8.w),
                        _buildToolItem(
                          context: context,
                          tool: ToolMode.placeObstacle,
                          titleEn: 'Obstacle',
                          titleAr: 'عائق / بناء',
                          icon: Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          activeTool: simulator.activeTool,
                          onSelect: (t) => notifier.selectTool(t),
                        ),
                        SizedBox(width: 8.w),
                        _buildToolItem(
                          context: context,
                          tool: ToolMode.placeTree,
                          titleEn: 'Tree',
                          titleAr: 'شجرة',
                          icon: Icons.park_rounded,
                          color: Colors.green,
                          activeTool: simulator.activeTool,
                          onSelect: (t) => notifier.selectTool(t),
                        ),
                        SizedBox(width: 8.w),
                        _buildToolItem(
                          context: context,
                          tool: ToolMode.excludeRoof,
                          titleEn: 'Exclude',
                          titleAr: 'منطقة محظورة',
                          icon: Icons.close_rounded,
                          color: Colors.blueGrey,
                          activeTool: simulator.activeTool,
                          onSelect: (t) => notifier.selectTool(t),
                        ),
                        SizedBox(width: 8.w),
                        _buildToolItem(
                          context: context,
                          tool: ToolMode.erase,
                          titleEn: 'Eraser',
                          titleAr: 'ممحاة',
                          icon: Icons.auto_fix_normal_rounded,
                          color: Colors.orange,
                          activeTool: simulator.activeTool,
                          onSelect: (t) => notifier.selectTool(t),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Daytime Simulation Shadow Slider
                  const SimulationTimeSlider(),
                  SizedBox(height: 16.h),

                  // Dimensions & Specs parameters card
                  const ParameterInputsCard(),
                  SizedBox(height: 16.h),

                  // Roof boundary walls config card
                  const BoundaryWallsCard(),
                  SizedBox(height: 20.h),

                  // Main CTA action triggers
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            side: const BorderSide(color: Colors.redAccent, width: 1.2),
                            foregroundColor: Colors.redAccent,
                          ),
                          onPressed: _clearAll,
                          icon: const Icon(Icons.refresh),
                          label: Text(_tr(context, 'Reset Canvas', 'إعادة تعيين')),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                            foregroundColor: AppTheme.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            elevation: 0,
                          ),
                          onPressed: _autofillRoof,
                          icon: const Icon(Iconsax.magic_star_bold),
                          label: Text(_tr(context, 'Smart Autofill', 'ملء تلقائي ذكي')),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                        elevation: 4,
                        shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                      onPressed: panelsCount > 0
                          ? _showExportDialog
                          : () {
                              ToastService.warning(
                                context,
                                _tr(context, 'No Panels', 'لا توجد ألواح'),
                                _tr(context, 'Please place at least one panel first!', 'يرجى وضع لوح شمسي واحد على الأقل أولًا!'),
                              );
                            },
                      icon: const Icon(Iconsax.export_bold),
                      label: Text(
                        _tr(context, 'Export Proposal Mockup', 'تصدير ملخص المقترح البصري'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
