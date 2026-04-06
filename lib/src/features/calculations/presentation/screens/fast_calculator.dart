import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/solar_request_form.dart';
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
  bool _isGuideExpanded = true;

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
        clickBack: () => Navigator.of(context).maybePop(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.97, end: 1),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Opacity(opacity: value, child: child),
              ),
              child: _buildGuideCard(context),
            ),
            SizedBox(height: 18.h),
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

  Widget _buildGuideCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF2CC), Color(0xFFFFFFFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFFFDF8B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18.r),
            onTap: () => setState(() => _isGuideExpanded = !_isGuideExpanded),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16.r)),
                    child: const Icon(Iconsax.info_circle_bold, color: AppTheme.primaryColor),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _tr(context, 'Guide and hints', 'الدليل والتنبيهات'),
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isGuideExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: IconButton(
                      onPressed: () => setState(() => _isGuideExpanded = !_isGuideExpanded),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      color: Colors.grey[800],
                      tooltip: _tr(context, 'Toggle guide', 'إظهار أو إخفاء الدليل'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOutCubic,
            crossFadeState: _isGuideExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: EdgeInsets.only(top: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHintLine(
                    context,
                    'Current I is the home AC load you want to support, for example 10 ampere.',
                    'التيار I هو حمل المنزل المتناوب الذي تريد تشغيله، مثل 10 أمبير.',
                  ),
                  _buildHintLine(
                    context,
                    'Battery time bt is the backup duration you want from the batteries.',
                    'زمن البطارية bt هو مدة التشغيل الاحتياطي المطلوبة من البطاريات.',
                  ),
                  _buildHintLine(
                    context,
                    'Battery ampere ba starts with the same value as current and can be adjusted if needed.',
                    'تيار البطارية ba يبدأ بنفس قيمة التيار ويمكن تعديله عند الحاجة.',
                  ),
                  _buildHintLine(
                    context,
                    'Keep about 20% battery reserve to reduce damage and extend battery life.',
                    'احتفظ بحوالي 20% احتياطي في البطارية لتقليل الضرر وإطالة عمر البطارية.',
                  ),
                  _buildHintLine(
                    context,
                    'Panel size pw is the power of one module, and the default value is 620 watt.',
                    'قدرة اللوح pw هي قدرة اللوح الواحد، والقيمة الافتراضية هي 620 واط.',
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    _tr(
                      context,
                      'Formulas: panels = (I × 230 × 1.35) ÷ pw, inverter = (I × 230 × 1.3) ÷ 1000, battery = (bt × ba × 230) ÷ 1000.',
                      'المعادلات: الألواح = (I × 230 × 1.35) ÷ pw، العاكس = (I × 230 × 1.3) ÷ 1000، البطارية = (bt × ba × 230) ÷ 1000.',
                    ),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[800], height: 1.5),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputsCard(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  context: context,
                  label: _tr(context, 'Current I', 'التيار I'),
                  hint: _tr(context, 'Example: 10 ampere', 'مثال: 10 أمبير'),
                  controller: _currentController,
                  onChanged: (value) {
                    _handleCurrentChanged(value);
                    setState(() {});
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildNumberField(
                  context: context,
                  label: _tr(context, 'Battery time bt', 'زمن البطارية bt'),
                  hint: _tr(context, 'Example: 4 hours', 'مثال: 4 ساعات'),
                  controller: _batteryTimeController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  context: context,
                  label: _tr(context, 'Battery current ba', 'تيار البطارية ba'),
                  hint: _tr(context, 'Defaults to the current value', 'يأخذ قيمة التيار افتراضيًا'),
                  controller: _batteryAmpController,
                  onChanged: (value) {
                    _batteryAmpEdited = value.trim().isNotEmpty && value.trim() != _currentController.text.trim();
                    setState(() {});
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildNumberField(
                  context: context,
                  label: _tr(context, 'Panel size pw', 'قدرة اللوح pw'),
                  hint: _tr(context, 'Default: 620 watt', 'الافتراضي: 620 واط'),
                  controller: _panelWattController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
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

  Widget _buildPrimaryMetric(BuildContext context, {required String label, required String value, required String unit, required Color accent}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.grey[700]),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: accent, height: 1),
          ),
          SizedBox(height: 4.h),
          Text(
            unit,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryHighlight(BuildContext context, _FastCalculation result) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryColor.withValues(alpha: 0.14), AppTheme.primaryLightColor.withValues(alpha: 0.12)]),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Battery recommendation', 'توصية البطارية'),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.grey[800]),
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
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportRow(BuildContext context, {required String title, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.grey[900]),
        ),
      ],
    );
  }

  Widget _buildSurface(BuildContext context, {required Widget child, Key? key}) {
    return Container(
      key: key,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }

  Widget _buildHintLine(BuildContext context, String en, String ar) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        _tr(context, en, ar),
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[800], height: 1.45),
      ),
    );
  }

  Widget _buildNumberField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      onChanged: onChanged,
      decoration: AppTheme.inputDecoration(label, hint).copyWith(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.18)),
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
