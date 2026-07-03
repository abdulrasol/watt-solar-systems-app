import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/wizard/wizard_bottom_bar.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/wizard/step_indicator.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/site_setup_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/roof_config_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/panel_placement_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/shadows_obstacles_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/structure_design_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/results_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/export_step.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/services/toast_service.dart';

class PvSystemDesignerScreen extends ConsumerStatefulWidget {
  const PvSystemDesignerScreen({super.key});

  @override
  ConsumerState<PvSystemDesignerScreen> createState() => _PvSystemDesignerScreenState();
}

class _PvSystemDesignerScreenState extends ConsumerState<PvSystemDesignerScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  static const int _totalSteps = 7;

  static const _stepTitlesEn = [
    'Site Setup',
    'Roof Config',
    'Panel Specs',
    'Layout & Shadows',
    'Structure',
    'Results',
    'Export',
  ];

  static const _stepTitlesAr = [
    'إعداد الموقع',
    'إعداد السقف',
    'مواصفات الألواح',
    'التوزيع والظلال',
    'الهيكل',
    'النتائج',
    'التصدير',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _totalSteps, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(pvSystemDesignerProvider.notifier);
      controller.recalculate();
      // Kick off a real irradiance/temperature fetch for the default (or
      // last-used) site so the energy estimate reflects real climate data
      // as soon as possible, rather than only the synthetic fallback.
      controller.refreshIrradianceData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    ref.read(pvSystemDesignerProvider.notifier).setStep(_tabController.index);
  }

  void _goToStep(int step) {
    _tabController.animateTo(step);
  }

  bool _isArabic(BuildContext context) => Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  void _showHelpDialog(BuildContext context) {
    final isAr = _isArabic(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: AppTheme.primaryColor),
            SizedBox(width: 8.w),
            Text(isAr ? 'دليل المصمم' : 'Designer Guide', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpRow('1', isAr ? 'الموقع' : 'Site', isAr ? 'حدد موقعك الجغرافي واتجاه الألواح.' : 'Set your GPS location and panel facing direction.'),
              _buildHelpRow('2', isAr ? 'السقف' : 'Roof', isAr ? 'أدخل أبعاد السقف والجدران المحيطة.' : 'Enter roof dimensions and boundary walls.'),
              _buildHelpRow('3', isAr ? 'الألواح' : 'Panels', isAr ? 'اضبط مواصفات الألواح الشمسية.' : 'Configure solar panel specifications.'),
              _buildHelpRow('4', isAr ? 'التوزيع' : 'Layout', isAr ? 'ضع الألواح على الشبكة وحدد الظلال والعوائق.' : 'Place panels on the grid and mark shadows/obstacles.'),
              _buildHelpRow('5', isAr ? 'الهيكل' : 'Structure', isAr ? 'اضبط المسافات واترك المحرك يحسب الهيكل.' : 'Set clearances and let the engine calculate the frame.'),
              _buildHelpRow('6', isAr ? 'النتائج' : 'Results', isAr ? 'راجع إنتاج الطاقة وقائمة المواد.' : 'Review energy production and bill of materials.'),
              _buildHelpRow('7', isAr ? 'التصدير' : 'Export', isAr ? 'احفظ أو شارك تصميمك النهائي.' : 'Save or share your final design.'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(isAr ? 'فهمت' : 'Got it'))],
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pvSystemDesignerProvider);
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    final isAr = _isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAr ? 'مصمم النظام الشمسي' : 'PV System Designer',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline_rounded), onPressed: () => _showHelpDialog(context)),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: StepIndicator(
            currentStep: state.currentStep,
            totalSteps: _totalSteps,
            stepLabels: isAr ? _stepTitlesAr : _stepTitlesEn,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 36.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              itemCount: _totalSteps,
              itemBuilder: (context, index) {
                final isActive = index == state.currentStep;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                  child: GestureDetector(
                    onTap: () => _goToStep(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primaryColor.withValues(alpha: 0.15) : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.withValues(alpha: 0.06)),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: isActive ? AppTheme.primaryColor : Colors.transparent),
                      ),
                      child: Center(
                        child: Text(
                          isAr ? _stepTitlesAr[index] : _stepTitlesEn[index],
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive ? AppTheme.primaryColor : (isDark ? Colors.white60 : Colors.grey[600]),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                SiteSetupStep(),
                RoofConfigStep(),
                PanelPlacementStep(),
                ShadowsObstaclesStep(),
                StructureDesignStep(),
                ResultsStep(),
                ExportStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: WizardBottomBar(
        currentStep: state.currentStep,
        totalSteps: _totalSteps,
        onBack: () => _goToStep(state.currentStep - 1),
        onNext: () => _goToStep(state.currentStep + 1),
        onSave: () async {
          // Previously this dialog had no text field and its Save button
          // never called controller.saveDesign() — it silently did
          // nothing. Now mirrors the working implementation on the Export
          // step's Save button.
          final nameCtrl = TextEditingController();
          final name = await showDialog<String>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              title: Text(isAr ? 'حفظ التصميم' : 'Save Design'),
              content: TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: isAr ? 'اسم التصميم' : 'Design Name',
                  hintText: isAr ? 'أدخل اسماً' : 'Enter a name',
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(isAr ? 'إلغاء' : 'Cancel')),
                ElevatedButton(onPressed: () => Navigator.pop(dialogContext, nameCtrl.text), child: Text(isAr ? 'حفظ' : 'Save')),
              ],
            ),
          );
          nameCtrl.dispose();
          if (name != null && name.trim().isNotEmpty) {
            await controller.saveDesign(name.trim());
            if (context.mounted) {
              ToastService.success(
                context,
                isAr ? 'تم الحفظ بنجاح' : 'Saved Successfully',
                isAr ? 'تم حفظ التصميم' : 'Design has been saved',
              );
            }
          }
        },
      ),
    );
  }
}
