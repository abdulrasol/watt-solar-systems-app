import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/wizard/wizard_intro_card.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/inputs/section_card.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/inputs/pv_number_field.dart';

class PanelPlacementStep extends ConsumerStatefulWidget {
  const PanelPlacementStep({super.key});

  @override
  ConsumerState<PanelPlacementStep> createState() => _PanelPlacementStepState();
}

class _PanelPlacementStepState extends ConsumerState<PanelPlacementStep> {
  late final TextEditingController _powerCtrl;
  late final TextEditingController _lengthCtrl;
  late final TextEditingController _widthCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _thicknessCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(pvSystemDesignerProvider);
    _powerCtrl = TextEditingController(text: s.panelPowerW.toStringAsFixed(0));
    _lengthCtrl = TextEditingController(text: s.panelLengthM.toStringAsFixed(2));
    _widthCtrl = TextEditingController(text: s.panelWidthM.toStringAsFixed(2));
    _weightCtrl = TextEditingController(text: s.panelWeightKg.toStringAsFixed(1));
    _thicknessCtrl = TextEditingController(text: s.panelThicknessM.toStringAsFixed(3));
  }

  @override
  void dispose() {
    _powerCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _weightCtrl.dispose();
    _thicknessCtrl.dispose();
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
            icon: Iconsax.sun_1_bold,
            titleEn: 'Panel Specifications',
            titleAr: 'مواصفات الألواح',
            descriptionEn: 'Configure your solar panel dimensions, power rating, and orientation.',
            descriptionAr: 'اضبط أبعاد الألواح الشمسية وقدرتها الكهربائية واتجاهها.',
          ),
          SizedBox(height: 16.h),
          SectionCard(
            titleEn: 'Panel Dimensions & Power',
            titleAr: 'أبعاد وقوة اللوح',
            icon: Iconsax.sun_1_bold,
            child: Column(
              children: [
                PvNumberField(
                  label: isAr ? 'القوة المقننة' : 'Rated Power',
                  controller: _powerCtrl,
                  suffix: 'W',
                  min: 10,
                  max: 2000,
                  onChanged: (v) => controller.updatePanelSpec(powerW: v),
                ),
                Row(
                  children: [
                    Expanded(child: PvNumberField(label: isAr ? 'الطول' : 'Length', controller: _lengthCtrl, suffix: 'm', min: 0.2, max: 5, onChanged: (v) => controller.updatePanelSpec(lengthM: v))),
                    SizedBox(width: 12.w),
                    Expanded(child: PvNumberField(label: isAr ? 'العرض' : 'Width', controller: _widthCtrl, suffix: 'm', min: 0.2, max: 5, onChanged: (v) => controller.updatePanelSpec(widthM: v))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: PvNumberField(label: isAr ? 'الوزن' : 'Weight', controller: _weightCtrl, suffix: 'kg', min: 1, max: 100, onChanged: (v) => controller.updatePanelSpec(weightKg: v))),
                    SizedBox(width: 12.w),
                    Expanded(child: PvNumberField(label: isAr ? 'السماكة' : 'Thickness', controller: _thicknessCtrl, suffix: 'm', min: 0.01, max: 0.1, onChanged: (v) => controller.updatePanelSpec(thicknessM: v))),
                  ],
                ),
              ],
            ),
          ),
          SectionCard(
            titleEn: 'Panel Orientation',
            titleAr: 'اتجاه اللوح',
            icon: Iconsax.rotate_left_bold,
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(isAr ? 'طولي' : 'Portrait'),
                    selected: state.isPortrait,
                    onSelected: (_) => controller.updatePortrait(true),
                    selectedColor: Colors.teal.withValues(alpha: 0.2),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ChoiceChip(
                    label: Text(isAr ? 'عرضي' : 'Landscape'),
                    selected: !state.isPortrait,
                    onSelected: (_) => controller.updatePortrait(false),
                    selectedColor: Colors.teal.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
          SectionCard(
            titleEn: 'Panel Gaps',
            titleAr: 'فجوات الألواح',
            icon: Iconsax.row_vertical_bold,
            child: Row(
              children: [
                Expanded(
                  child: PvNumberField(
                    label: isAr ? 'أفقي' : 'Horizontal Gap',
                    controller: TextEditingController(text: state.horizontalGapM.toStringAsFixed(3)),
                    suffix: 'm',
                    min: 0,
                    max: 0.5,
                    onChanged: (v) => controller.updateHorizontalGap(v),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PvNumberField(
                    label: isAr ? 'عمودي' : 'Vertical Gap',
                    controller: TextEditingController(text: state.verticalGapM.toStringAsFixed(3)),
                    suffix: 'm',
                    min: 0,
                    max: 0.5,
                    onChanged: (v) => controller.updateVerticalGap(v),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[800], size: 24.sp),
                SizedBox(height: 8.h),
                Text(
                  isAr
                      ? 'في الخطوة التالية، ستتمكن من وضع الألواح على السقف بصرياً وتحديد العوائق والظلال.'
                      : 'In the next step, you will be able to visually place panels on the roof and mark obstacles and shadows.',
                  style: TextStyle(fontSize: 11.sp, color: Colors.amber[900], height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
