import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/offers/presentation/providers/offers_provider.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class SolarRequestFormPrefill {
  const SolarRequestFormPrefill({
    required this.panelPower,
    required this.panelCount,
    required this.totalPanelPower,
    required this.batterySize,
    required this.batteryCount,
    required this.totalBatteryPower,
    required this.inverterSize,
    this.inverterCount = 1,
    required this.totalInvertersPower,
    this.batteryType = BatteryType.lithium,
    this.inverterType = InverterType.hybrid,
    this.panelNote,
    this.batteryNote,
    this.inverterNote,
    this.note,
  });

  final int panelPower;
  final int panelCount;
  final int totalPanelPower;
  final double batterySize;
  final int batteryCount;
  final double totalBatteryPower;
  final double inverterSize;
  final int inverterCount;
  final double totalInvertersPower;
  final BatteryType batteryType;
  final InverterType inverterType;
  final String? panelNote;
  final String? batteryNote;
  final String? inverterNote;
  final String? note;
}

class SolarRequestForm extends ConsumerStatefulWidget {
  const SolarRequestForm({super.key, this.prefill});

  final SolarRequestFormPrefill? prefill;

  @override
  ConsumerState<SolarRequestForm> createState() => _SolarRequestFormState();
}

class _SolarRequestFormState extends ConsumerState<SolarRequestForm> {
  final _formKey = GlobalKey<FormState>();

  final _panelPowerController = TextEditingController();
  final _panelCountController = TextEditingController(text: '1');
  final _panelNoteController = TextEditingController();

  final _batterySizeController = TextEditingController();
  final _batteryCountController = TextEditingController(text: '1');
  final _batteryNoteController = TextEditingController();

  final _inverterSizeController = TextEditingController();
  final _inverterCountController = TextEditingController(text: '1');
  final _inverterNoteController = TextEditingController();

  final _noteController = TextEditingController();

  BatteryType _batteryType = BatteryType.lithium;
  InverterType _inverterType = InverterType.hybrid;
  bool _allCities = false;

  int _totalPanelPower = 0;
  double _totalBatteryPower = 0;
  double _totalInvertersPower = 0;

  @override
  void initState() {
    super.initState();
    _applyPrefill();
    _recalculateTotals();
  }

  @override
  void dispose() {
    _panelPowerController.dispose();
    _panelCountController.dispose();
    _panelNoteController.dispose();
    _batterySizeController.dispose();
    _batteryCountController.dispose();
    _batteryNoteController.dispose();
    _inverterSizeController.dispose();
    _inverterCountController.dispose();
    _inverterNoteController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _recalculateTotals() {
    setState(() {
      _totalPanelPower =
          _parseInt(_panelPowerController.text) *
          _parseInt(_panelCountController.text);
      _totalBatteryPower =
          _parseDouble(_batterySizeController.text) *
          _parseInt(_batteryCountController.text);
      _totalInvertersPower =
          _parseDouble(_inverterSizeController.text) *
          _parseInt(_inverterCountController.text);
    });
  }

  void _applyPrefill() {
    final prefill = widget.prefill;
    if (prefill == null) return;

    _panelPowerController.text = prefill.panelPower.toString();
    _panelCountController.text = prefill.panelCount.toString();
    _panelNoteController.text = prefill.panelNote ?? '';

    _batterySizeController.text = _formatNumber(prefill.batterySize);
    _batteryCountController.text = prefill.batteryCount.toString();
    _batteryNoteController.text = prefill.batteryNote ?? '';

    _inverterSizeController.text = _formatNumber(prefill.inverterSize);
    _inverterCountController.text = prefill.inverterCount.toString();
    _inverterNoteController.text = prefill.inverterNote ?? '';

    _noteController.text = prefill.note ?? '';

    _batteryType = prefill.batteryType;
    _inverterType = prefill.inverterType;
    _totalPanelPower = prefill.totalPanelPower;
    _totalBatteryPower = prefill.totalBatteryPower;
    _totalInvertersPower = prefill.totalInvertersPower;
  }

  int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

  double _parseDouble(String value) => double.tryParse(value.trim()) ?? 0;

  String _formatNumber(num value) {
    return value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final userCity = authState.user?.city;
    final isLoading = ref.watch(offersProvider).isLoading;

    return PreScaffold(
      title: l10n.create_solar_request,
      clickBack: () => Navigator.of(context).maybePop(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          children: [
            _buildHeroCard(
              context,
              l10n,
              userCity?.name ??
                  _tr(context, 'No city selected', 'لم يتم اختيار مدينة'),
            ),
            SizedBox(height: 20.h),
            _buildLocationCard(context, l10n, userCity?.name ?? '-'),
            SizedBox(height: 20.h),
            _buildEquipmentSection(
              context: context,
              title: _tr(context, 'Panel', 'الألواح'),
              icon: Iconsax.sun_1_bold,
              accent: const Color(0xFFFFA726),
              recommendation: _tr(
                context,
                'Recommended: keep the same wattage for all panels for better matching and easier offers.',
                'مقترح: استخدم نفس القدرة لكل الألواح لتحصل على توافق أفضل وعروض أدق.',
              ),
              specs: [
                _buildNumberField(
                  label: _tr(context, 'Panel power (W)', 'قدرة اللوح (واط)'),
                  controller: _panelPowerController,
                  onChanged: _recalculateTotals,
                ),
                _buildNumberField(
                  label: _tr(context, 'Panel count', 'عدد الألواح'),
                  controller: _panelCountController,
                  onChanged: _recalculateTotals,
                ),
              ],
              noteField: _buildTextField(
                label: _tr(
                  context,
                  'Panel note (optional)',
                  'ملاحظة الألواح (اختياري)',
                ),
                controller: _panelNoteController,
                hintText: _tr(
                  context,
                  'Brand, half-cut, mono, roof limits...',
                  'العلامة التجارية، نصف خلية، مونو، قيود السطح...',
                ),
              ),
              totalLabel: _tr(
                context,
                'Total panel power',
                'إجمالي قدرة الألواح',
              ),
              totalValue: '${_formatNumber(_totalPanelPower)} W',
            ),
            SizedBox(height: 20.h),
            _buildEquipmentSection(
              context: context,
              title: _tr(context, 'Battery', 'البطارية'),
              icon: Iconsax.flash_1_bold,
              accent: const Color(0xFF42A5F5),
              recommendation: _tr(
                context,
                'Best performance: lithium is the default for longer cycle life and faster charging.',
                'أفضل أداء: الليثيوم هو الخيار الافتراضي لعمر أطول وشحن أسرع.',
              ),
              topChild: _buildDropdown<BatteryType>(
                label: _tr(context, 'Battery type', 'نوع البطارية'),
                value: _batteryType,
                items: BatteryType.values,
                onChanged: (value) =>
                    setState(() => _batteryType = value ?? BatteryType.lithium),
              ),
              specs: [
                _buildDecimalField(
                  label: _tr(context, 'Battery size', 'سعة البطارية'),
                  controller: _batterySizeController,
                  onChanged: _recalculateTotals,
                ),
                _buildNumberField(
                  label: _tr(context, 'Battery count', 'عدد البطاريات'),
                  controller: _batteryCountController,
                  onChanged: _recalculateTotals,
                ),
              ],
              noteField: _buildTextField(
                label: _tr(
                  context,
                  'Battery note (optional)',
                  'ملاحظة البطارية (اختياري)',
                ),
                controller: _batteryNoteController,
                hintText: _tr(
                  context,
                  'Rack style, backup hours, preferred brand...',
                  'نوع الرف، ساعات النسخ الاحتياطي، العلامة المفضلة...',
                ),
              ),
              totalLabel: _tr(
                context,
                'Total battery power',
                'إجمالي سعة البطاريات',
              ),
              totalValue: _formatNumber(_totalBatteryPower),
            ),
            SizedBox(height: 20.h),
            _buildEquipmentSection(
              context: context,
              title: _tr(context, 'Inverter', 'العاكس'),
              icon: Iconsax.setting_2_bold,
              accent: const Color(0xFF8E24AA),
              recommendation: _tr(
                context,
                'Best performance: hybrid works well when you want grid support and future battery expansion.',
                'أفضل أداء: الهايبرد مناسب عند الحاجة لدعم الشبكة وإضافة بطاريات مستقبلًا.',
              ),
              topChild: _buildDropdown<InverterType>(
                label: _tr(context, 'Inverter type', 'نوع العاكس'),
                value: _inverterType,
                items: InverterType.values,
                onChanged: (value) => setState(
                  () => _inverterType = value ?? InverterType.hybrid,
                ),
              ),
              specs: [
                _buildDecimalField(
                  label: _tr(context, 'Inverter size', 'قدرة العاكس'),
                  controller: _inverterSizeController,
                  onChanged: _recalculateTotals,
                ),
                _buildNumberField(
                  label: _tr(context, 'Inverter count', 'عدد العواكس'),
                  controller: _inverterCountController,
                  onChanged: _recalculateTotals,
                ),
              ],
              noteField: _buildTextField(
                label: _tr(
                  context,
                  'Inverter note (optional)',
                  'ملاحظة العاكس (اختياري)',
                ),
                controller: _inverterNoteController,
                hintText: _tr(
                  context,
                  'Single phase, MPPT count, brand...',
                  'أحادي الطور، عدد MPPT، العلامة التجارية...',
                ),
              ),
              totalLabel: _tr(
                context,
                'Total inverters power',
                'إجمالي قدرة العواكس',
              ),
              totalValue: _formatNumber(_totalInvertersPower),
            ),
            SizedBox(height: 20.h),
            _buildNotesCard(),
            SizedBox(height: 28.h),
            SizedBox(
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : () => _submit(userCity?.id),
                icon: isLoading
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Iconsax.document_upload_bold),
                label: Text(l10n.post_solar_request),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(int? cityId) async {
    if (!_formKey.currentState!.validate()) return;
    if (cityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              context,
              'Your profile must have a city before creating a request.',
              'يجب تحديد مدينة في ملفك الشخصي قبل إنشاء الطلب.',
            ),
          ),
        ),
      );
      return;
    }

    final data = {
      'city_id': cityId,
      'all_cities': _allCities,
      'total_panel_power': _totalPanelPower == 0 ? null : _totalPanelPower,
      'panel_power': _parseInt(_panelPowerController.text),
      'panel_count': _parseInt(_panelCountController.text),
      'panel_note': _emptyToNull(_panelNoteController.text),
      'total_battery_power': _totalBatteryPower,
      'battery_size': _parseDouble(_batterySizeController.text),
      'battery_count': _parseInt(_batteryCountController.text),
      'battery_note': _emptyToNull(_batteryNoteController.text),
      'battery_type': _batteryType.name,
      'total_inverters_power': _totalInvertersPower,
      'inverter_size': _parseDouble(_inverterSizeController.text),
      'inverter_count': _parseInt(_inverterCountController.text),
      'inverter_note': _emptyToNull(_inverterNoteController.text),
      'inverter_type': _inverterType.name,
      'note': _emptyToNull(_noteController.text),
    };

    await ref.read(offersProvider.notifier).createRequest(data);
    if (mounted) Navigator.of(context).pop();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Widget _buildHeroCard(
    BuildContext context,
    AppLocalizations l10n,
    String cityName,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2A2212), const Color(0xFF171310)]
              : [const Color(0xFFFFF6DD), const Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? onSurface.withValues(alpha: 0.08)
              : const Color(0xFFFFE0A3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: const Icon(
                  Iconsax.document_text_bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.create_solar_request,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: AppTheme.fontFamily,
                        color: onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _tr(
                        context,
                        'Share clear sizes and notes so companies can send more accurate offers.',
                        'أضف المقاسات والملاحظات بوضوح لتصلك عروض أدق من الشركات.',
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildInfoChip(Iconsax.location_bold, cityName),
              _buildInfoChip(
                Iconsax.flash_1_bold,
                _tr(
                  context,
                  'Defaults tuned for fast entry',
                  'إعدادات افتراضية لإدخال أسرع',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    AppLocalizations l10n,
    String cityName,
  ) {
    return _buildSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.global_bold, color: AppTheme.primaryColor),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  _tr(context, 'Location & reach', 'الموقع ونطاق الإرسال'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.location_bold, color: AppTheme.primaryColor),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr(context, 'Request city', 'مدينة الطلب'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        cityName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SwitchListTile.adaptive(
            value: _allCities,
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppTheme.primaryColor,
            title: Text(
              _tr(context, 'Send to all cities', 'الإرسال إلى جميع المدن'),
            ),
            subtitle: Text(
              _tr(
                context,
                'Turn on to let companies outside your city respond as well.',
                'فعّل هذا الخيار للسماح للشركات خارج مدينتك بالرد أيضًا.',
              ),
            ),
            onChanged: (value) => setState(() => _allCities = value),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color accent,
    required String recommendation,
    required List<Widget> specs,
    required Widget noteField,
    required String totalLabel,
    required String totalValue,
    Widget? topChild,
  }) {
    return _buildSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: accent),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.72),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (topChild != null) ...[SizedBox(height: 16.h), topChild],
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: specs[0]),
              SizedBox(width: 12.w),
              Expanded(child: specs[1]),
            ],
          ),
          SizedBox(height: 12.h),
          _buildTotalTile(totalLabel, totalValue),
          SizedBox(height: 12.h),
          noteField,
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return _buildSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'General note', 'ملاحظات عامة'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8.h),
          Text(
            _tr(
              context,
              'Add any site details, installation limits, or preferred brands.',
              'أضف تفاصيل الموقع أو قيود التركيب أو العلامات التجارية المفضلة.',
            ),
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          SizedBox(height: 14.h),
          _buildTextField(
            label: _tr(context, 'Note (optional)', 'ملاحظة (اختياري)'),
            controller: _noteController,
            hintText: _tr(
              context,
              'Roof type, backup target, timeline...',
              'نوع السطح، هدف النسخ الاحتياطي، الجدول الزمني...',
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSurface({required Widget child}) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: onSurface.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppTheme.primaryColor),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: onSurface.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTile(String label, String value) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      validator: (value) {
        final parsed = int.tryParse(value?.trim() ?? '');
        if (parsed == null || parsed <= 0) {
          return _tr(context, 'Required', 'مطلوب');
        }
        return null;
      },
    );
  }

  Widget _buildDecimalField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      validator: (value) {
        final parsed = double.tryParse(value?.trim() ?? '');
        if (parsed == null || parsed <= 0) {
          return _tr(context, 'Required', 'مطلوب');
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }

  Widget _buildDropdown<T extends Object>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                _localizedDropdownLabel(AppLocalizations.of(context)!, item),
              ),
            ),
          )
          .toList(),
    );
  }

  String _localizedDropdownLabel(AppLocalizations l10n, Object item) {
    if (item is BatteryType) return item.localizedLabel(l10n);
    if (item is InverterType) return item.localizedLabel(l10n);
    return item.toString();
  }
}
