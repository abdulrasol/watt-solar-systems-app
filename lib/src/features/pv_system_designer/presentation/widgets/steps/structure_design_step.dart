import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/wizard/wizard_intro_card.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/inputs/section_card.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/inputs/pv_number_field.dart';

class StructureDesignStep extends ConsumerStatefulWidget {
  const StructureDesignStep({super.key});

  @override
  ConsumerState<StructureDesignStep> createState() => _StructureDesignStepState();
}

class _StructureDesignStepState extends ConsumerState<StructureDesignStep> {
  late final TextEditingController _frontCtrl;
  late final TextEditingController _rearCtrl;
  late final TextEditingController _sideCtrl;
  late final TextEditingController _legCtrl;
  late final TextEditingController _interRowCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(pvSystemDesignerProvider);
    _frontCtrl = TextEditingController(text: s.frontClearanceM.toStringAsFixed(2));
    _rearCtrl = TextEditingController(text: s.rearClearanceM.toStringAsFixed(2));
    _sideCtrl = TextEditingController(text: s.sideClearanceM.toStringAsFixed(2));
    _legCtrl = TextEditingController(text: s.frontLegClearanceM.toStringAsFixed(2));
    _interRowCtrl = TextEditingController(text: s.interRowGapM.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _frontCtrl.dispose();
    _rearCtrl.dispose();
    _sideCtrl.dispose();
    _legCtrl.dispose();
    _interRowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pvSystemDesignerProvider);
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    final isAr = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final result = controller.frameResult;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardIntroCard(
            icon: Iconsax.buildings_2_bold,
            titleEn: 'Structure Design',
            titleAr: 'تصميم الهيكل',
            descriptionEn: 'Configure clearances and row mode. The calculator will auto-optimize the frame layout.',
            descriptionAr: 'اضبط المسافات الفاصلة ووضع الصفوف. سيحسب المحرك تلقائياً تخطيط الهيكل الأمثل.',
          ),
          SizedBox(height: 16.h),
          SectionCard(
            titleEn: 'Clearances',
            titleAr: 'المسافات الفاصلة',
            icon: Iconsax.maximize_circle_bold,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: PvNumberField(label: isAr ? 'أمامي' : 'Front', controller: _frontCtrl, suffix: 'm', min: 0, max: 10, onChanged: (v) => controller.updateFrontClearance(v))),
                    SizedBox(width: 12.w),
                    Expanded(child: PvNumberField(label: isAr ? 'خلفي' : 'Rear', controller: _rearCtrl, suffix: 'm', min: 0, max: 10, onChanged: (v) => controller.updateRearClearance(v))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: PvNumberField(label: isAr ? 'جانبي' : 'Side', controller: _sideCtrl, suffix: 'm', min: 0, max: 5, onChanged: (v) => controller.updateSideClearance(v))),
                    SizedBox(width: 12.w),
                    Expanded(child: PvNumberField(label: isAr ? 'ارتفاع الساق' : 'Leg Height', controller: _legCtrl, suffix: 'm', min: 0, max: 5, onChanged: (v) => controller.updateFrontLegClearance(v))),
                  ],
                ),
                PvNumberField(label: isAr ? 'فجوة بين الصفوف' : 'Inter-Row Gap', controller: _interRowCtrl, suffix: 'm', min: 0, max: 5, onChanged: (v) => controller.updateInterRowGap(v)),
              ],
            ),
          ),
          SectionCard(
            titleEn: 'Row Mode',
            titleAr: 'وضع الصفوف',
            icon: Iconsax.row_vertical_bold,
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(isAr ? 'مستقل' : 'Independent'),
                    selected: state.rowMode == RowMode.independent,
                    onSelected: (_) => controller.updateRowMode(RowMode.independent),
                    selectedColor: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ChoiceChip(
                    label: Text(isAr ? 'متدرج' : 'Stepped'),
                    selected: state.rowMode == RowMode.stepped,
                    onSelected: (_) => controller.updateRowMode(RowMode.stepped),
                    selectedColor: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
          if (result != null) ...[
            SizedBox(height: 16.h),
            SectionCard(
              titleEn: 'Layout Result',
              titleAr: 'نتيجة التخطيط',
              icon: Iconsax.chart_bold,
              child: Column(
                children: [
                  _buildMetricRow(isAr, 'Rows / Columns', 'الصفوف / الأعمدة', '${result.rows} / ${result.columns}'),
                  _buildMetricRow(isAr, 'Panel Count', 'عدد الألواح', '${result.panelCount}'),
                  _buildMetricRow(isAr, 'Frame Width', 'عرض الهيكل', '${result.frameWidthMeters.toStringAsFixed(2)} m'),
                  _buildMetricRow(isAr, 'Tilt Angle', 'زاوية الميل', '${result.appliedTiltDegrees.toStringAsFixed(1)}°'),
                  _buildMetricRow(isAr, 'Azimuth', 'الاتجاه', '${result.appliedAzimuthDegrees.toStringAsFixed(0)}°'),
                  _buildMetricRow(isAr, 'Total Steel', 'إجمالي الحديد', '${result.totalSteelLengthMeters.toStringAsFixed(1)} m'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(bool isAr, String en, String ar, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(child: Text(isAr ? ar : en, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]))),
          Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
