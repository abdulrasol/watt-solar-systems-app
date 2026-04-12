import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_dialog.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/solar_request_form.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class FastCalculator extends ConsumerStatefulWidget {
  const FastCalculator({super.key});

  @override
  ConsumerState<FastCalculator> createState() => _FastCalculatorState();
}

class _FastCalculatorState extends ConsumerState<FastCalculator> {
  static const List<int> _standardBatterySizes = [5, 8, 10, 15, 16];

  final _currentController = TextEditingController(text: '10');
  final _batteryTimeController = TextEditingController(text: '4');
  final _batteryAmpController = TextEditingController(text: '10');
  final _panelWattController = TextEditingController(text: '620');

  bool _batteryAmpEdited = false;

  @override
  void dispose() {
    _currentController.dispose();
    _batteryTimeController.dispose();
    _batteryAmpController.dispose();
    _panelWattController.dispose();
    super.dispose();
  }

  bool _isArabic(BuildContext context) => Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  String _kwLabel(BuildContext context) => _tr(context, 'kW', 'كيلو واط');

  String _wattLabel(BuildContext context) => _tr(context, 'watt', 'واط');

  String _hourLabel(BuildContext context, num value) => _tr(context, value == 1 ? 'hour' : 'hours', value == 1 ? 'ساعة' : 'ساعات');

  String _ampLabel(BuildContext context) => _tr(context, 'ampere', 'أمبير');

  List<ExplanationItem> _fieldExplanations(BuildContext context) {
    return [
      ExplanationItem(
        title: _tr(context, 'AC load current', 'تيار الحمل المتناوب'),
        description: _tr(
          context,
          'Enter the AC current you want the solar system to support continuously. This value is used to estimate panel count and inverter size.',
          'أدخل تيار الحمل المتناوب الذي تريد أن تدعمه المنظومة الشمسية بشكل مستمر. تستخدم هذه القيمة لتقدير عدد الألواح وحجم العاكس.',
        ),
      ),
      ExplanationItem(
        title: _tr(context, 'Battery running time', 'مدة تشغيل البطارية'),
        description: _tr(
          context,
          'Enter the backup duration you want from the battery bank when there is no charging source available.',
          'أدخل مدة التشغيل الاحتياطي المطلوبة من بنك البطاريات عند غياب مصدر الشحن.',
        ),
      ),
      ExplanationItem(
        title: _tr(context, 'Battery running current', 'تيار تشغيل البطارية'),
        description: _tr(
          context,
          'Enter the current the battery bank should support during backup operation. It starts with the same value as the AC load current and can be adjusted.',
          'أدخل التيار الذي يجب أن يدعمه بنك البطاريات أثناء التشغيل الاحتياطي. يبدأ بنفس قيمة تيار الحمل المتناوب ويمكن تعديله.',
        ),
      ),
      ExplanationItem(
        title: _tr(context, 'Solar panel wattage', 'قدرة اللوح الشمسي'),
        description: _tr(
          context,
          'Enter the wattage of one solar panel module. The default value is 620 watt.',
          'أدخل قدرة اللوح الشمسي الواحد بالواط. القيمة الافتراضية هي 620 واط.',
        ),
      ),
    ];
  }

  List<ExplanationItem> _guideExplanations(BuildContext context) {
    return [
      ExplanationItem(
        title: _tr(context, 'Fast calculator guide', 'دليل الحاسبة السريعة'),
        description: _tr(
          context,
          'Use this calculator for a quick home estimate based on AC load current, battery backup time, battery running current, and solar panel wattage.',
          'استخدم هذه الحاسبة للحصول على تقدير سريع منزلي اعتماداً على تيار الحمل المتناوب ومدة تشغيل البطارية وتيار تشغيل البطارية وقدرة اللوح الشمسي.',
        ),
      ),
      ExplanationItem(
        title: _tr(context, 'Battery reserve', 'احتياطي البطارية'),
        description: _tr(
          context,
          'Keep about 20% battery reserve to reduce damage and extend battery life.',
          'احتفظ بحوالي 20% احتياطي في البطارية لتقليل الضرر وإطالة عمر البطارية.',
        ),
      ),
      ExplanationItem(
        title: _tr(context, 'Calculation formulas', 'معادلات الحساب'),
        description: _tr(
          context,
          'Panels = (AC load current × 230 × 1.35) ÷ solar panel wattage. Inverter = (AC load current × 230 × 1.3) ÷ 1000. Battery = (battery running time × battery running current × 230) ÷ 1000.',
          'الألواح = (تيار الحمل المتناوب × 230 × 1.35) ÷ قدرة اللوح الشمسي. العاكس = (تيار الحمل المتناوب × 230 × 1.3) ÷ 1000. البطارية = (مدة تشغيل البطارية × تيار تشغيل البطارية × 230) ÷ 1000.',
        ),
      ),
    ];
  }

  double? _parsePositive(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  String _formatNum(num value, {int fraction = 2}) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(fraction).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _handleCurrentChanged(String value) {
    if (_batteryAmpEdited) return;
    if (_batteryAmpController.text == value) return;
    _batteryAmpController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  _FastCalculation? _calculate() {
    final current = _parsePositive(_currentController.text);
    final batteryTime = _parsePositive(_batteryTimeController.text);
    final batteryAmp = _parsePositive(_batteryAmpController.text);
    final panelWatt = _parsePositive(_panelWattController.text);

    if (current == null || batteryTime == null || batteryAmp == null || panelWatt == null) {
      return null;
    }

    final panelCount = math.max(1, ((current * 230 * 1.35) / panelWatt).round());
    final totalPanelPower = panelCount * panelWatt.toInt();
    final inverterSizeKw = math.max(1, ((current * 230 * 1.3) / 1000).ceil());
    final exactBatteryKwh = (batteryTime * batteryAmp * 230) / 1000;
    final suggestedBatterySize = _standardBatterySizes.firstWhere((size) => exactBatteryKwh <= size, orElse: () => _standardBatterySizes.last);
    final batteryCount = math.max(1, (exactBatteryKwh / suggestedBatterySize).ceil());
    final totalBatteryPower = suggestedBatterySize * batteryCount;

    return _FastCalculation(
      currentAmp: current,
      batteryTimeHours: batteryTime,
      batteryAmp: batteryAmp,
      panelWatt: panelWatt.toInt(),
      panelCount: panelCount,
      totalPanelPower: totalPanelPower,
      inverterSizeKw: inverterSizeKw.toDouble(),
      exactBatteryKwh: exactBatteryKwh,
      suggestedBatterySize: suggestedBatterySize.toDouble(),
      batteryCount: batteryCount,
      totalBatteryPower: totalBatteryPower.toDouble(),
    );
  }

  void _openRequestForm(_FastCalculation result) {
    context.push(
      '/user-requests/new',
      extra: SolarRequestFormPrefill(
        panelPower: result.panelWatt,
        panelCount: result.panelCount,
        totalPanelPower: result.totalPanelPower,
        batterySize: result.suggestedBatterySize,
        batteryCount: result.batteryCount,
        totalBatteryPower: result.totalBatteryPower,
        inverterSize: result.inverterSizeKw,
        totalInvertersPower: result.inverterSizeKw,
        panelNote: _tr(context, 'Prepared from fast PV calculator', 'تم التحضير من الحاسبة السريعة للطاقة الشمسية'),
        batteryNote: _tr(
          context,
          'Exact need ${_formatNum(result.exactBatteryKwh)} ${_kwLabel(context)}',
          'الاحتياج الفعلي ${_formatNum(result.exactBatteryKwh)} ${_kwLabel(context)}',
        ),
        inverterNote: _tr(
          context,
          'Derived from AC load ${_formatNum(result.currentAmp)} ${_ampLabel(context)}',
          'تم الحساب من حمل متناوب ${_formatNum(result.currentAmp)} ${_ampLabel(context)}',
        ),
        note: _tr(
          context,
          'Inputs: current ${_formatNum(result.currentAmp)} ${_ampLabel(context)}, battery time ${_formatNum(result.batteryTimeHours)} ${_hourLabel(context, result.batteryTimeHours)}, battery current ${_formatNum(result.batteryAmp)} ${_ampLabel(context)}, panel size ${result.panelWatt} ${_wattLabel(context)}. Battery recommendation ${result.batteryCount} x ${_formatNum(result.suggestedBatterySize)} ${_kwLabel(context)}.',
          'المدخلات: التيار ${_formatNum(result.currentAmp)} ${_ampLabel(context)}، زمن البطارية ${_formatNum(result.batteryTimeHours)} ${_hourLabel(context, result.batteryTimeHours)}، تيار البطارية ${_formatNum(result.batteryAmp)} ${_ampLabel(context)}، قدرة اللوح ${result.panelWatt} ${_wattLabel(context)}. التوصية للبطاريات ${result.batteryCount} × ${_formatNum(result.suggestedBatterySize)} ${_kwLabel(context)}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _calculate();
    final offersEnabled = isEnabled(ref, 'offers');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PreScaffold(
        title: _tr(context, 'Fast PV Calculator', 'حاسبة سريعة للطاقة الشمسية'),
        actions: [
          IconButton(
            onPressed: () {
              ExplanationDialog.show(context, explanations: _guideExplanations(context));
            },
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: _tr(context, 'Guide', 'الدليل'),
          ),
        ],
        clickBack: () => Navigator.of(context).maybePop(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          children: [
            _buildInputsCard(context),
            SizedBox(height: 18.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: result == null ? _buildInvalidState(context, theme) : _buildResultCard(context, result, offersEnabled),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputsCard(BuildContext context) {
    final explanations = _fieldExplanations(context);
    return _buildSurface(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Inputs', 'المدخلات'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14.h),
          _buildFieldSection(
            context: context,
            title: _tr(context, 'AC load current', 'تيار الحمل المتناوب'),
            helper: _tr(
              context,
              'Enter the current you want the solar system to support, for example 10 ampere.',
              'أدخل التيار الذي تريد أن تدعمه المنظومة الشمسية، مثل 10 أمبير.',
            ),
            explanation: explanations[0],
            field: _buildNumberField(
              context: context,
              label: _tr(context, 'AC load current', 'تيار الحمل المتناوب'),
              hint: _tr(context, 'Example: 10 ampere', 'مثال: 10 أمبير'),
              controller: _currentController,
              onChanged: (value) {
                _handleCurrentChanged(value);
                setState(() {});
              },
            ),
          ),
          SizedBox(height: 12.h),
          _buildFieldSection(
            context: context,
            title: _tr(context, 'Battery running time', 'مدة تشغيل البطارية'),
            helper: _tr(context, 'Enter the backup duration you want from the batteries.', 'أدخل مدة التشغيل الاحتياطي المطلوبة من البطاريات.'),
            explanation: explanations[1],
            field: _buildNumberField(
              context: context,
              label: _tr(context, 'Battery running time', 'مدة تشغيل البطارية'),
              hint: _tr(context, 'Example: 4 hours', 'مثال: 4 ساعات'),
              controller: _batteryTimeController,
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(height: 12.h),
          _buildFieldSection(
            context: context,
            title: _tr(context, 'Battery running current', 'تيار تشغيل البطارية'),
            helper: _tr(
              context,
              'This starts with the same value as the AC load current and can be adjusted if needed.',
              'يبدأ بنفس قيمة تيار الحمل المتناوب ويمكن تعديله عند الحاجة.',
            ),
            explanation: explanations[2],
            field: _buildNumberField(
              context: context,
              label: _tr(context, 'Battery running current', 'تيار تشغيل البطارية'),
              hint: _tr(context, 'Defaults to the AC load current', 'يأخذ قيمة تيار الحمل افتراضيًا'),
              controller: _batteryAmpController,
              onChanged: (value) {
                _batteryAmpEdited = value.trim().isNotEmpty && value.trim() != _currentController.text.trim();
                setState(() {});
              },
            ),
          ),
          SizedBox(height: 12.h),
          _buildFieldSection(
            context: context,
            title: _tr(context, 'Solar panel wattage', 'قدرة اللوح الشمسي'),
            helper: _tr(
              context,
              'Enter the wattage of one solar panel module. The default value is 620 watt.',
              'أدخل قدرة اللوح الشمسي الواحد. القيمة الافتراضية هي 620 واط.',
            ),
            explanation: explanations[3],
            field: _buildNumberField(
              context: context,
              label: _tr(context, 'Solar panel wattage', 'قدرة اللوح الشمسي'),
              hint: _tr(context, 'Default: 620 watt', 'الافتراضي: 620 واط'),
              controller: _panelWattController,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidState(BuildContext context, ThemeData theme) {
    return _buildSurface(
      context,
      key: const ValueKey('invalid_state'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.warning_2_bold, color: theme.colorScheme.error),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              _tr(
                context,
                'Enter valid values greater than zero in all fields to calculate the system.',
                'أدخل قيمًا صحيحة أكبر من الصفر في جميع الحقول لحساب النظام.',
              ),
              style: TextStyle(fontSize: 13.sp, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, _FastCalculation result, bool offersEnabled) {
    return _buildSurface(
      context,
      key: const ValueKey('result_state'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Calculation result', 'نتيجة الحساب'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _buildPrimaryMetric(
                  context,
                  label: _tr(context, 'Panels', 'الألواح'),
                  value: '${result.panelCount}',
                  unit: _tr(context, 'panel', 'لوح'),
                  accent: const Color(0xFFFFA726),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildPrimaryMetric(
                  context,
                  label: _tr(context, 'Inverter', 'العاكس'),
                  value: _formatNum(result.inverterSizeKw),
                  unit: _kwLabel(context),
                  accent: const Color(0xFFEF5350),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildBatteryHighlight(context, result),
          SizedBox(height: 14.h),
          _buildSupportRow(context, title: _tr(context, 'Total PV power', 'إجمالي قدرة الألواح'), value: '${result.totalPanelPower} ${_wattLabel(context)}'),
          SizedBox(height: 8.h),
          _buildSupportRow(
            context,
            title: _tr(context, 'Exact battery need', 'الاحتياج الفعلي للبطارية'),
            value: '${_formatNum(result.exactBatteryKwh)} ${_kwLabel(context)}',
          ),
          SizedBox(height: 8.h),
          _buildSupportRow(
            context,
            title: _tr(context, 'Suggested battery bank', 'البنك المقترح للبطاريات'),
            value: '${_formatNum(result.totalBatteryPower)} ${_kwLabel(context)}',
          ),
          if (offersEnabled) ...[
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: () => _openRequestForm(result),
                icon: const Icon(Iconsax.document_text_bold),
                label: Text(_tr(context, 'Request offer', 'اطلب عرض سعر')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldSection({
    required BuildContext context,
    required String title,
    required String helper,
    required ExplanationItem explanation,
    required Widget field,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      helper,
                      style: TextStyle(fontSize: 12.sp, height: 1.45, color: isDark ? Colors.white70 : Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: () {
                  ExplanationDialog.show(context, explanations: [explanation]);
                },
                icon: const Icon(Icons.help_outline_rounded),
                color: AppTheme.primaryColor,
                tooltip: _tr(context, 'More info', 'معلومات أكثر'),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          field,
        ],
      ),
    );
  }

  Widget _buildPrimaryMetric(BuildContext context, {required String label, required String value, required String unit, required Color accent}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? accent.withValues(alpha: 0.14) : accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accent.withValues(alpha: isDark ? 0.22 : 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.grey[700]),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: accent, height: 1),
          ),
          SizedBox(height: 4.h),
          Text(
            unit,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryHighlight(BuildContext context, _FastCalculation result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.primaryDarkColor.withValues(alpha: 0.35), AppTheme.primaryColor.withValues(alpha: 0.16)]
              : [AppTheme.primaryColor.withValues(alpha: 0.14), AppTheme.primaryLightColor.withValues(alpha: 0.12)],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.22 : 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Battery recommendation', 'توصية البطارية'),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.grey[800]),
          ),
          SizedBox(height: 8.h),
          Text(
            '${result.batteryCount} × ${_formatNum(result.suggestedBatterySize)} ${_kwLabel(context)}',
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryDarkColor, height: 1.05),
          ),
          SizedBox(height: 6.h),
          Text(
            _tr(
              context,
              'For ${_formatNum(result.batteryAmp)} ${_ampLabel(context)} during about ${_formatNum(result.batteryTimeHours)} ${_hourLabel(context, result.batteryTimeHours)}',
              'لتشغيل ${_formatNum(result.batteryAmp)} ${_ampLabel(context)} لمدة تقارب ${_formatNum(result.batteryTimeHours)} ${_hourLabel(context, result.batteryTimeHours)}',
            ),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportRow(BuildContext context, {required String title, required String value}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.grey[900]),
        ),
      ],
    );
  }

  Widget _buildSurface(BuildContext context, {required Widget child, Key? key}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      key: key,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildNumberField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: AppTheme.inputDecoration(label, hint).copyWith(
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontFamily: AppTheme.fontFamily),
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontFamily: AppTheme.fontFamily),
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.grey.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}

class _FastCalculation {
  const _FastCalculation({
    required this.currentAmp,
    required this.batteryTimeHours,
    required this.batteryAmp,
    required this.panelWatt,
    required this.panelCount,
    required this.totalPanelPower,
    required this.inverterSizeKw,
    required this.exactBatteryKwh,
    required this.suggestedBatterySize,
    required this.batteryCount,
    required this.totalBatteryPower,
  });

  final double currentAmp;
  final double batteryTimeHours;
  final double batteryAmp;
  final int panelWatt;
  final int panelCount;
  final int totalPanelPower;
  final double inverterSizeKw;
  final double exactBatteryKwh;
  final double suggestedBatterySize;
  final int batteryCount;
  final double totalBatteryPower;
}
