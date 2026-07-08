import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/wizard/wizard_intro_card.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/inputs/section_card.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/inputs/pv_number_field.dart';

class RoofConfigStep extends ConsumerStatefulWidget {
  const RoofConfigStep({super.key});

  @override
  ConsumerState<RoofConfigStep> createState() => _RoofConfigStepState();
}

class _RoofConfigStepState extends ConsumerState<RoofConfigStep> {
  late final TextEditingController _roofWidthCtrl;
  late final TextEditingController _roofLengthCtrl;
  late final TextEditingController _setbackCtrl;
  late final TextEditingController _northWallCtrl;
  late final TextEditingController _southWallCtrl;
  late final TextEditingController _eastWallCtrl;
  late final TextEditingController _westWallCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(pvSystemDesignerProvider);
    _roofWidthCtrl = TextEditingController(text: s.roofWidthM.toStringAsFixed(1));
    _roofLengthCtrl = TextEditingController(text: s.roofLengthM.toStringAsFixed(1));
    _setbackCtrl = TextEditingController(text: s.wallSetbackM.toStringAsFixed(2));
    _northWallCtrl = TextEditingController(text: s.northWallHeight.toStringAsFixed(1));
    _southWallCtrl = TextEditingController(text: s.southWallHeight.toStringAsFixed(1));
    _eastWallCtrl = TextEditingController(text: s.eastWallHeight.toStringAsFixed(1));
    _westWallCtrl = TextEditingController(text: s.westWallHeight.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _roofWidthCtrl.dispose();
    _roofLengthCtrl.dispose();
    _setbackCtrl.dispose();
    _northWallCtrl.dispose();
    _southWallCtrl.dispose();
    _eastWallCtrl.dispose();
    _westWallCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pvSystemDesignerProvider);
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    final isAr = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardIntroCard(
            icon: Iconsax.buildings,
            titleEn: 'Roof Configuration',
            titleAr: 'إعدادات السقف',
            descriptionEn: 'Define your roof dimensions, safety setback, and boundary walls for shading analysis.',
            descriptionAr: 'حدد أبعاد السقف وهامش الأمان والجدران المحيطة لتحليل الظلال.',
          ),
          SizedBox(height: 16.h),
          SectionCard(
            titleEn: 'Roof Dimensions',
            titleAr: 'أبعاد السقف',
            icon: Iconsax.maximize,
            explanationEn: 'Enter the total usable width and length of your roof area for panel placement.',
            explanationAr: 'أدخل العرض والطول الإجماليين لمنطقة السقف القابلة للاستخدام لوضع الألواح.',
            child: Row(
              children: [
                Expanded(
                  child: PvNumberField(
                    label: isAr ? 'العرض' : 'Width',
                    controller: _roofWidthCtrl,
                    suffix: 'm',
                    min: 2,
                    max: 150,
                    onChanged: (v) => controller.updateRoofDimensions(v, state.roofLengthM),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PvNumberField(
                    label: isAr ? 'الطول' : 'Length',
                    controller: _roofLengthCtrl,
                    suffix: 'm',
                    min: 2,
                    max: 150,
                    onChanged: (v) => controller.updateRoofDimensions(state.roofWidthM, v),
                  ),
                ),
              ],
            ),
          ),
          SectionCard(
            titleEn: 'Safety Setback',
            titleAr: 'هامش الأمان',
            icon: Icons.warning_amber_rounded,
            explanationEn: 'Minimum distance from roof edges where panels cannot be placed for safety.',
            explanationAr: 'الحد الأدنى للمسافة من حواف السقف حيث لا يمكن وضع الألواح للسلامة.',
            child: PvNumberField(
              label: isAr ? 'هامش الارتداد' : 'Setback Distance',
              controller: _setbackCtrl,
              suffix: 'm',
              min: 0,
              max: 5,
              onChanged: (v) => controller.updateWallSetback(v),
            ),
          ),
          SectionCard(
            titleEn: 'Boundary Walls',
            titleAr: 'الجدران المحيطة',
            icon: Iconsax.building,
            explanationEn: 'Configure boundary walls that may cast shadows on your panels throughout the day.',
            explanationAr: 'اضبط الجدران المحيطة التي قد تلقي ظلالاً على الألواح خلال اليوم.',
            child: Column(
              children: [
                _buildWallToggle(
                  context,
                  isAr,
                  'North',
                  'شمال',
                  state.hasNorthWall,
                  (v) => controller.updateWallToggles(north: v),
                  _northWallCtrl,
                  (v) => controller.updateWallHeights(north: v),
                ),
                _buildWallToggle(
                  context,
                  isAr,
                  'South',
                  'جنوب',
                  state.hasSouthWall,
                  (v) => controller.updateWallToggles(south: v),
                  _southWallCtrl,
                  (v) => controller.updateWallHeights(south: v),
                ),
                _buildWallToggle(
                  context,
                  isAr,
                  'East',
                  'شرق',
                  state.hasEastWall,
                  (v) => controller.updateWallToggles(east: v),
                  _eastWallCtrl,
                  (v) => controller.updateWallHeights(east: v),
                ),
                _buildWallToggle(
                  context,
                  isAr,
                  'West',
                  'غرب',
                  state.hasWestWall,
                  (v) => controller.updateWallToggles(west: v),
                  _westWallCtrl,
                  (v) => controller.updateWallHeights(west: v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallToggle(
    BuildContext context,
    bool isAr,
    String en,
    String ar,
    bool enabled,
    ValueChanged<bool> onToggle,
    TextEditingController ctrl,
    ValueChanged<double> onHeight,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Flexible(
            flex: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: Checkbox(
                    value: enabled,
                    onChanged: (v) => onToggle(v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  isAr ? ar : en,
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 8.w),
              ],
            ),
          ),
          if (enabled)
            Expanded(
              child: PvNumberField(label: isAr ? 'الارتفاع' : 'Height', controller: ctrl, suffix: 'm', min: 0, max: 10, onChanged: onHeight),
            )
          else
            Expanded(
              child: Text(
                isAr ? 'غير مفعل' : 'Disabled',
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              ),
            ),
        ],
      ),
    );
  }
}
