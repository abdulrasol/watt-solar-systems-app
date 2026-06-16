import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/wizard/wizard_intro_card.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/inputs/section_card.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/sketch/combined_sketch_preview.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/sketch/technical_sketch_page.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ResultsStep extends ConsumerWidget {
  const ResultsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    final isAr = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final frameResult = controller.frameResult;
    final energy = controller.energyEstimate;
    final panelsCount = controller.panelsCount;
    final peakPower = controller.peakPower;
    final totalArea = controller.totalArea;
    final totalWeight = controller.totalWeight;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardIntroCard(
            icon: Iconsax.chart_2_bold,
            titleEn: 'System Results & Energy',
            titleAr: 'نتائج النظام والطاقة',
            descriptionEn: 'Complete overview of your PV system: panel layout, structural design, energy production, and bill of materials.',
            descriptionAr: 'نظرة شاملة على نظامك الشمسي: توزيع الألواح، التصميم الهيكلي، إنتاج الطاقة، وقائمة المواد.',
          ),
          SizedBox(height: 16.h),
          _buildMetricsGrid(context, isAr, isDark, panelsCount, peakPower, totalArea, totalWeight),
          SizedBox(height: 20.h),
          _buildSketchSection(context, isAr, isDark),
          SizedBox(height: 20.h),
          if (energy != null) _buildEnergyCard(context, isAr, isDark, energy),
          SizedBox(height: 16.h),
          if (frameResult != null) ...[
            _buildStructureCard(context, isAr, isDark, frameResult),
            SizedBox(height: 16.h),
            _buildBomCard(context, isAr, isDark, frameResult),
          ],
        ],
      ),
    );
  }

  Widget _buildSketchSection(BuildContext context, bool isAr, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.diagram_bold, color: AppTheme.primaryColor, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              isAr ? 'الرسومات التقنية' : 'Technical Drawings',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TechnicalSketchPage()),
                );
              },
              icon: Icon(Icons.fullscreen_rounded, size: 16.sp),
              label: Text(isAr ? 'عرض كامل' : 'Full View', style: TextStyle(fontSize: 11.sp)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const CombinedSketchPreview(height: 400),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendDot(Colors.amber.shade700, isAr ? 'ألواح' : 'Panels'),
            SizedBox(width: 16.w),
            _buildLegendDot(Colors.redAccent, isAr ? 'عوائق' : 'Obstacles'),
            SizedBox(width: 16.w),
            _buildLegendDot(Colors.green, isAr ? 'أشجار' : 'Trees'),
            SizedBox(width: 16.w),
            _buildLegendDot(Colors.grey, isAr ? 'ظلال' : 'Shadows'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, bool isAr, bool isDark, int panelsCount, double peakPower, double totalArea, double totalWeight) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryColor.withValues(alpha: 0.1), AppTheme.primaryColor.withValues(alpha: 0.03)]),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isAr ? 'ملخص النظام' : 'System Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildStatTile(isAr, 'الألواح', 'Panels', '$panelsCount', Iconsax.sun_1_bold, Colors.amber),
              SizedBox(width: 8.w),
              _buildStatTile(isAr, 'القدرة', 'Peak Power', '${peakPower.toStringAsFixed(2)} kWp', Iconsax.flash_1_bold, Colors.redAccent),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildStatTile(isAr, 'المساحة', 'Area', '${totalArea.toStringAsFixed(1)} m²', Iconsax.grid_5_bold, Colors.blueAccent),
              SizedBox(width: 8.w),
              _buildStatTile(isAr, 'الوزن', 'Weight', '${totalWeight.toStringAsFixed(0)} kg', Icons.fitness_center, Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(bool isAr, String arLabel, String enLabel, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 4.h),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
            SizedBox(height: 2.h),
            Text(isAr ? arLabel : enLabel, style: TextStyle(fontSize: 9.sp, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyCard(BuildContext context, bool isAr, bool isDark, dynamic energy) {
    return SectionCard(
      titleEn: 'Energy Production Estimate',
      titleAr: 'تقدير إنتاج الطاقة',
      icon: Iconsax.flash_bold,
      explanationEn: 'Estimated based on your location, peak power output, and typical system losses (14%).',
      explanationAr: 'محسوب بناءً على موقعك وقدرة الإنتاج القصوى وفقدان النظام النموذجي (14%).',
      child: Column(
        children: [
          _buildEnergyRow(isAr, 'Daily Production', 'الإنتاج اليومي', '${energy.dailyKwh.toStringAsFixed(1)} kWh/day'),
          _buildEnergyRow(isAr, 'Monthly Production', 'الإنتاج الشهري', '${energy.monthlyKwh.toStringAsFixed(0)} kWh/month'),
          _buildEnergyRow(isAr, 'Annual Production', 'الإنتاج السنوي', '${energy.yearlyKwh.toStringAsFixed(0)} kWh/year'),
          _buildEnergyRow(isAr, 'Peak Sun Hours', 'ساعات الذروة', '${energy.peakSunHours.toStringAsFixed(1)} h/day'),
          _buildEnergyRow(isAr, 'Capacity Factor', 'معامل السعة', '${(energy.capacityFactor * 100).toStringAsFixed(1)}%'),
          _buildEnergyRow(isAr, 'CO₂ Offset', 'توفير الكربون', '${energy.annualCo2OffsetKg.toStringAsFixed(0)} kg/year'),
        ],
      ),
    );
  }

  Widget _buildEnergyRow(bool isAr, String en, String ar, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(width: 6.w, height: 6.w, decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2.r))),
          SizedBox(width: 8.w),
          Expanded(child: Text(isAr ? ar : en, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]))),
          Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStructureCard(BuildContext context, bool isAr, bool isDark, dynamic result) {
    return SectionCard(
      titleEn: 'Structural Design',
      titleAr: 'التصميم الهيكلي',
      icon: Iconsax.buildings_2_bold,
      child: Column(
        children: [
          _buildEnergyRow(isAr, 'Rows × Columns', 'الصفوف × الأعمدة', '${result.rows} × ${result.columns}'),
          _buildEnergyRow(isAr, 'Frame Width', 'عرض الهيكل', '${result.frameWidthMeters.toStringAsFixed(2)} m'),
          _buildEnergyRow(isAr, 'Tilt / Azimuth', 'الميل / الاتجاه', '${result.appliedTiltDegrees.toStringAsFixed(1)}° / ${result.appliedAzimuthDegrees.toStringAsFixed(0)}°'),
          _buildEnergyRow(isAr, 'Row Spacing', 'تباعد الصفوف', '${result.rowSpacingMeters.toStringAsFixed(2)} m'),
          _buildEnergyRow(isAr, 'Front Leg', 'الساق الأمامي', '${result.frontLegHeightMeters.toStringAsFixed(2)} m'),
          _buildEnergyRow(isAr, 'Rear Leg', 'الساق الخلفي', '${result.rearLegHeightMeters.toStringAsFixed(2)} m'),
          _buildEnergyRow(isAr, 'Total Steel', 'إجمالي الحديد', '${result.totalSteelLengthMeters.toStringAsFixed(1)} m'),
          _buildEnergyRow(isAr, 'Support Stations', 'محطات الدعم', '${result.supportStationCount}'),
        ],
      ),
    );
  }

  Widget _buildBomCard(BuildContext context, bool isAr, bool isDark, dynamic result) {
    return SectionCard(
      titleEn: 'Bill of Materials',
      titleAr: 'قائمة المواد',
      icon: Iconsax.document_text_bold,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              children: [
                Expanded(child: Text(isAr ? 'العنصر' : 'Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp))),
                Expanded(child: Text(isAr ? 'الكمية' : 'Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp), textAlign: TextAlign.end)),
                SizedBox(width: 40.w),
              ],
            ),
          ),
          ...result.bomItems.asMap().entries.map((entry) {
            final item = entry.value;
            final isEven = entry.key % 2 == 0;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              color: isEven ? Colors.transparent : Colors.grey.withValues(alpha: isDark ? 0.03 : 0.04),
              child: Row(
                children: [
                  Expanded(child: Text(item.name, style: TextStyle(fontSize: 11.sp))),
                  Expanded(child: Text('${item.quantity.toStringAsFixed(1)} ${item.unit}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
                  SizedBox(width: 40.w),
                ],
              ),
            );
          }),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              children: [
                Expanded(child: Text(isAr ? 'الإجمالي' : 'Total Steel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp))),
                Expanded(child: Text('${result.totalSteelLengthMeters.toStringAsFixed(1)} m', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, color: AppTheme.primaryColor), textAlign: TextAlign.end)),
                SizedBox(width: 40.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
