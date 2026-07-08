import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/energy_estimate.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/frame_result.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/inverter_spec.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/financial_estimate.dart';
import 'package:watt/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/wizard/wizard_intro_card.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/inputs/section_card.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/inputs/pv_number_field.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/sketch/combined_sketch_preview.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/sketch/technical_sketch_page.dart';
import 'package:watt/src/utils/app_theme.dart';

class ResultsStep extends ConsumerStatefulWidget {
  const ResultsStep({super.key});

  @override
  ConsumerState<ResultsStep> createState() => _ResultsStepState();
}

class _ResultsStepState extends ConsumerState<ResultsStep> {
  late final TextEditingController _costCtrl;
  late final TextEditingController _rateCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(pvSystemDesignerProvider);
    _costCtrl = TextEditingController(text: s.installedCostPerWatt.toStringAsFixed(2));
    _rateCtrl = TextEditingController(text: s.electricityRatePerKwh.toStringAsFixed(3));
  }

  @override
  void dispose() {
    _costCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    // Watch so this step rebuilds when background weather fetches / any
    // recalculation lands (controller getters below always read the
    // latest cached results off the same provider instance).
    ref.watch(pvSystemDesignerProvider);
    final isAr = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final frameResult = controller.frameResult;
    final energy = controller.energyEstimate;
    final panelsCount = controller.panelsCount;
    final peakPower = controller.peakPower;
    final totalArea = controller.totalArea;
    final totalWeight = controller.totalWeight;
    final stringSizing = controller.stringSizingResult;
    final financial = controller.financialEstimate;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardIntroCard(
            icon: Iconsax.chart_2,
            titleEn: 'System Results & Energy',
            titleAr: 'نتائج النظام والطاقة',
            descriptionEn: 'Complete overview of your PV system: panel layout, structural design, energy production, and bill of materials.',
            descriptionAr: 'نظرة شاملة على نظامك الشمسي: توزيع الألواح، التصميم الهيكلي، إنتاج الطاقة، وقائمة المواد.',
          ),
          SizedBox(height: 12.h),
          _buildWeatherDataBanner(context, isAr, isDark, controller, energy),
          SizedBox(height: 12.h),
          _buildMetricsGrid(context, isAr, isDark, panelsCount, peakPower, totalArea, totalWeight),
          SizedBox(height: 20.h),
          _buildSketchSection(context, isAr, isDark),
          SizedBox(height: 20.h),
          if (energy != null) _buildEnergyCard(context, isAr, isDark, energy),
          SizedBox(height: 16.h),
          if (energy != null) _buildMonthlyChartCard(context, isAr, isDark, energy),
          SizedBox(height: 16.h),
          if (energy != null) _buildLossDiagramCard(context, isAr, isDark, energy),
          SizedBox(height: 16.h),
          if (stringSizing != null) _buildInverterSizingCard(context, isAr, isDark, stringSizing),
          SizedBox(height: 16.h),
          _buildFinancialCard(context, isAr, isDark, financial, controller),
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

  Widget _buildWeatherDataBanner(BuildContext context, bool isAr, bool isDark, PvSystemDesignerController controller, EnergyEstimate? energy) {
    final isFetching = controller.isFetchingWeather;
    final isReal = energy?.isRealWeatherData ?? controller.isUsingRealWeatherData;
    final color = isFetching ? Colors.blueGrey : (isReal ? Colors.green : Colors.amber);
    final text = isFetching
        ? (isAr ? 'جاري تحميل بيانات الطقس الحقيقية...' : 'Fetching real weather data...')
        : (isReal
              ? (isAr ? 'الحسابات مبنية على بيانات طقس تاريخية حقيقية لهذا الموقع' : 'Calculations use real historical weather data for this site')
              : (isAr ? 'تعذر الوصول لبيانات الطقس — يتم استخدام تقدير مبني على خط العرض فقط' : 'Weather data unavailable — using a latitude-only estimate'));
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          if (isFetching)
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(isReal ? Icons.cloud_done_outlined : Icons.info_outline, size: 16.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 10.5.sp, color: color, fontWeight: FontWeight.w600),
            ),
          ),
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
            Icon(Iconsax.diagram, color: AppTheme.primaryColor, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              isAr ? 'الرسومات التقنية' : 'Technical Drawings',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicalSketchPage()));
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
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
        ),
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
          Text(
            isAr ? 'ملخص النظام' : 'System Summary',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildStatTile(isAr, 'الألواح', 'Panels', '$panelsCount', Iconsax.sun_1, Colors.amber),
              SizedBox(width: 8.w),
              _buildStatTile(isAr, 'القدرة', 'Peak Power', '${peakPower.toStringAsFixed(2)} kWp', Iconsax.flash_1, Colors.redAccent),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildStatTile(isAr, 'المساحة', 'Area', '${totalArea.toStringAsFixed(1)} m²', Iconsax.grid_5, Colors.blueAccent),
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
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              isAr ? arLabel : enLabel,
              style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyCard(BuildContext context, bool isAr, bool isDark, EnergyEstimate energy) {
    return SectionCard(
      titleEn: 'Energy Production Estimate',
      titleAr: 'تقدير إنتاج الطاقة',
      icon: Iconsax.flash,
      explanationEn: 'Based on your location\'s real irradiance/temperature data, array tilt & azimuth, and the loss diagram below.',
      explanationAr: 'محسوب بناءً على بيانات الإشعاع والحرارة الحقيقية لموقعك، وميل واتجاه المصفوفة، ومخطط الفقد أدناه.',
      child: Column(
        children: [
          _buildEnergyRow(isAr, 'Daily Production', 'الإنتاج اليومي', '${energy.dailyKwh.toStringAsFixed(1)} kWh/day'),
          _buildEnergyRow(isAr, 'Monthly Production', 'الإنتاج الشهري', '${energy.monthlyKwh.toStringAsFixed(0)} kWh/month'),
          _buildEnergyRow(isAr, 'Annual Production', 'الإنتاج السنوي', '${energy.yearlyKwh.toStringAsFixed(0)} kWh/year'),
          _buildEnergyRow(isAr, 'Peak Sun Hours', 'ساعات الذروة', '${energy.peakSunHours.toStringAsFixed(1)} h/day'),
          _buildEnergyRow(isAr, 'Performance Ratio', 'نسبة الأداء', '${(energy.performanceRatio * 100).toStringAsFixed(1)}%'),
          _buildEnergyRow(isAr, 'Capacity Factor', 'معامل السعة', '${(energy.capacityFactor * 100).toStringAsFixed(1)}%'),
          _buildEnergyRow(isAr, 'CO₂ Offset', 'توفير الكربون', '${energy.annualCo2OffsetKg.toStringAsFixed(0)} kg/year'),
        ],
      ),
    );
  }

  Widget _buildMonthlyChartCard(BuildContext context, bool isAr, bool isDark, EnergyEstimate energy) {
    const monthLabels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final values = energy.monthlyProductionKwh;
    final maxY = values.isEmpty ? 100.0 : (values.reduce((a, b) => a > b ? a : b) * 1.2).clamp(10.0, double.infinity).toDouble();

    return SectionCard(
      titleEn: 'Monthly Production',
      titleAr: 'الإنتاج الشهري',
      icon: Iconsax.chart,
      explanationEn: 'Real seasonal variation from your site\'s irradiance and temperature data — not a flat yearly average.',
      explanationAr: 'التباين الموسمي الحقيقي بناءً على بيانات الإشعاع والحرارة لموقعك — وليس متوسطاً سنوياً ثابتاً.',
      child: SizedBox(
        height: 180.h,
        child: values.every((v) => v == 0)
            ? Center(
                child: Text(
                  isAr ? 'لا توجد بيانات كافية بعد' : 'Not enough data yet',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              )
            : BarChart(
                BarChartData(
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= monthLabels.length) return const SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              monthLabels[i],
                              style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    values.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [BarChartRodData(toY: values[i], color: AppTheme.primaryColor, width: 12.w, borderRadius: BorderRadius.circular(3.r))],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLossDiagramCard(BuildContext context, bool isAr, bool isDark, EnergyEstimate energy) {
    final losses = energy.losses;
    return SectionCard(
      titleEn: 'Loss Diagram',
      titleAr: 'مخطط الفقد',
      icon: Icons.trending_down_rounded,
      explanationEn: 'Itemized system losses, replacing a single opaque "system losses %" figure.',
      explanationAr: 'تفصيل فقد النظام بدلاً من رقم واحد غير واضح.',
      child: Column(
        children: [
          _buildEnergyRow(isAr, 'Soiling', 'التربة والغبار', '${losses.soilingLossPercent.toStringAsFixed(1)}%'),
          _buildEnergyRow(isAr, 'Mismatch', 'عدم التطابق', '${losses.mismatchLossPercent.toStringAsFixed(1)}%'),
          _buildEnergyRow(isAr, 'DC Wiring', 'أسلاك التيار المستمر', '${losses.dcWiringLossPercent.toStringAsFixed(1)}%'),
          _buildEnergyRow(isAr, 'AC Wiring', 'أسلاك التيار المتردد', '${losses.acWiringLossPercent.toStringAsFixed(1)}%'),
          _buildEnergyRow(isAr, 'Inverter Efficiency', 'كفاءة الإنفرتر', '${losses.inverterEfficiencyPercent.toStringAsFixed(1)}%'),
          _buildEnergyRow(isAr, 'Availability', 'التوفر', '${(100 - losses.availabilityLossPercent).toStringAsFixed(1)}%'),
          _buildEnergyRow(isAr, 'Annual Degradation', 'التدهور السنوي', '${losses.annualDegradationPercent.toStringAsFixed(2)}%/yr'),
          _buildEnergyRow(isAr, 'Avg. Temperature Loss', 'فقد الحرارة المتوسط', '${(energy.avgTemperatureLossFraction * 100).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildInverterSizingCard(BuildContext context, bool isAr, bool isDark, StringSizingResult sizing) {
    final color = sizing.isFullyCompliant ? Colors.green : Colors.redAccent;
    return SectionCard(
      titleEn: 'Inverter & String Sizing',
      titleAr: 'توافق الإنفرتر والسلاسل',
      icon: Iconsax.cpu,
      explanationEn: 'Checks your array against ${sizing.inverter.name}\'s MPPT voltage window and current limits.',
      explanationAr: 'يتحقق من توافق مصفوفتك مع نافذة جهد وتيار الإنفرتر ${sizing.inverter.name}.',
      child: Column(
        children: [
          _buildEnergyRow(isAr, 'Suggested Inverter', 'الإنفرتر المقترح', sizing.inverter.name),
          _buildEnergyRow(isAr, 'String Configuration', 'إعداد السلسلة', '${sizing.panelsPerString} × ${sizing.parallelStrings} strings'),
          _buildEnergyRow(isAr, 'DC:AC Ratio', 'نسبة التيار المستمر/المتردد', sizing.dcAcRatio.toStringAsFixed(2)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              children: [
                Icon(sizing.isFullyCompliant ? Icons.check_circle_outline : Icons.warning_amber_rounded, color: color, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    sizing.isFullyCompliant
                        ? (isAr ? 'التصميم متوافق كهربائياً' : 'Design is electrically compliant')
                        : (isAr ? 'يوجد تحذيرات — راجع أدناه' : 'Warnings found — see below'),
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color),
                  ),
                ),
              ],
            ),
          ),
          if (sizing.warnings.isNotEmpty)
            ...sizing.warnings.map(
              (w) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  '• $w',
                  style: TextStyle(fontSize: 10.sp, color: Colors.redAccent, height: 1.3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(BuildContext context, bool isAr, bool isDark, FinancialEstimate? financial, PvSystemDesignerController controller) {
    return SectionCard(
      titleEn: 'Financial Estimate',
      titleAr: 'التقدير المالي',
      icon: Icons.payments_outlined,
      explanationEn: 'Adjust the installed cost and local electricity rate to estimate payback.',
      explanationAr: 'عدّل تكلفة التركيب وسعر الكهرباء المحلي لتقدير فترة الاسترداد.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PvNumberField(
                  label: isAr ? 'التكلفة لكل واط' : 'Cost per Watt',
                  controller: _costCtrl,
                  suffix: '/W',
                  min: 0,
                  max: 10,
                  onChanged: (v) => controller.updateFinancialInputs(costPerWatt: v),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PvNumberField(
                  label: isAr ? 'سعر الكهرباء' : 'Electricity Rate',
                  controller: _rateCtrl,
                  suffix: '/kWh',
                  min: 0,
                  max: 5,
                  onChanged: (v) => controller.updateFinancialInputs(electricityRate: v),
                ),
              ),
            ],
          ),
          if (financial != null && financial.systemCost > 0) ...[
            _buildEnergyRow(isAr, 'Estimated System Cost', 'تكلفة النظام التقديرية', financial.systemCost.toStringAsFixed(0)),
            _buildEnergyRow(isAr, 'Est. Annual Savings', 'التوفير السنوي التقديري', financial.annualSavings.toStringAsFixed(0)),
            _buildEnergyRow(
              isAr,
              'Simple Payback',
              'فترة الاسترداد',
              financial.paybackYears != null ? '${financial.paybackYears!.toStringAsFixed(1)} yrs' : (isAr ? 'غير محدد' : 'N/A'),
            ),
            _buildEnergyRow(
              isAr,
              '${financial.lifetimeYears}-Year Net Savings',
              'صافي التوفير على ${financial.lifetimeYears} سنة',
              financial.lifetimeSavings.toStringAsFixed(0),
            ),
          ] else
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                isAr ? 'أدخل التكلفة وسعر الكهرباء لعرض تقدير الاسترداد' : 'Enter cost and electricity rate to see a payback estimate',
                style: TextStyle(fontSize: 10.5.sp, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnergyRow(bool isAr, String en, String ar, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isAr ? ar : en,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStructureCard(BuildContext context, bool isAr, bool isDark, FrameResult result) {
    return SectionCard(
      titleEn: 'Structural Design',
      titleAr: 'التصميم الهيكلي',
      icon: Iconsax.buildings_2,
      child: Column(
        children: [
          _buildEnergyRow(isAr, 'Rows × Columns', 'الصفوف × الأعمدة', '${result.rows} × ${result.columns}'),
          _buildEnergyRow(isAr, 'Frame Width', 'عرض الهيكل', '${result.frameWidthMeters.toStringAsFixed(2)} m'),
          _buildEnergyRow(
            isAr,
            'Tilt / Azimuth',
            'الميل / الاتجاه',
            '${result.appliedTiltDegrees.toStringAsFixed(1)}° / ${result.appliedAzimuthDegrees.toStringAsFixed(0)}°',
          ),
          _buildEnergyRow(isAr, 'Row Spacing', 'تباعد الصفوف', '${result.rowSpacingMeters.toStringAsFixed(2)} m'),
          _buildEnergyRow(isAr, 'Front Leg', 'الساق الأمامي', '${result.frontLegHeightMeters.toStringAsFixed(2)} m'),
          _buildEnergyRow(isAr, 'Rear Leg', 'الساق الخلفي', '${result.rearLegHeightMeters.toStringAsFixed(2)} m'),
          _buildEnergyRow(isAr, 'Total Steel', 'إجمالي الحديد', '${result.totalSteelLengthMeters.toStringAsFixed(1)} m'),
          _buildEnergyRow(isAr, 'Support Stations', 'محطات الدعم', '${result.supportStationCount}'),
        ],
      ),
    );
  }

  Widget _buildBomCard(BuildContext context, bool isAr, bool isDark, FrameResult result) {
    return SectionCard(
      titleEn: 'Bill of Materials',
      titleAr: 'قائمة المواد',
      icon: Iconsax.document_text,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isAr ? 'العنصر' : 'Item',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp),
                  ),
                ),
                Expanded(
                  child: Text(
                    isAr ? 'الكمية' : 'Qty',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp),
                    textAlign: TextAlign.end,
                  ),
                ),
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
                  Expanded(
                    child: Text(item.name, style: TextStyle(fontSize: 11.sp)),
                  ),
                  Expanded(
                    child: Text(
                      '${item.quantity.toStringAsFixed(1)} ${item.unit}',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.end,
                    ),
                  ),
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
                Expanded(
                  child: Text(
                    isAr ? 'الإجمالي' : 'Total Steel',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${result.totalSteelLengthMeters.toStringAsFixed(1)} m',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, color: AppTheme.primaryColor),
                    textAlign: TextAlign.end,
                  ),
                ),
                SizedBox(width: 40.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
