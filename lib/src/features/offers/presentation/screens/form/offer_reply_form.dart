import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/offers/domain/entities/involve.dart';
import 'package:solar_hub/src/features/offers/domain/entities/solar_offer.dart';
import 'package:solar_hub/src/features/offers/domain/entities/solar_request.dart';
import 'package:solar_hub/src/features/offers/presentation/providers/involves_provider.dart';
import 'package:solar_hub/src/features/offers/presentation/providers/offers_provider.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/models/selected_involve.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/widgets/equipment_section.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/widgets/form_cards.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/widgets/form_sections.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/widgets/involve_item_card.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/involves_catalog_screen.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/services/toast_service.dart';

class OfferReplyForm extends ConsumerStatefulWidget {
  final SolarRequest? request;
  final SolarOffer? offer;

  const OfferReplyForm({super.key, this.request, this.offer})
    : assert(request != null || offer != null);

  @override
  ConsumerState<OfferReplyForm> createState() => _OfferReplyFormState();
}

class _OfferReplyFormState extends ConsumerState<OfferReplyForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _panelPowerController;
  late final TextEditingController _panelCountController;
  late final TextEditingController _panelUnitPriceController;
  late final TextEditingController _panelNoteController;
  late final TextEditingController _batterySizeController;
  late final TextEditingController _batteryCountController;
  late final TextEditingController _batteryUnitPriceController;
  late final TextEditingController _batteryNoteController;
  late final TextEditingController _inverterSizeController;
  late final TextEditingController _inverterCountController;
  late final TextEditingController _inverterUnitPriceController;
  late final TextEditingController _inverterNoteController;
  late final TextEditingController _noteController;

  late BatteryType _batteryType;
  late InverterType _inverterType;

  final List<SelectedTemplateInvolve> _selectedInvolves = [];

  int _totalPanelPower = 0;
  double _panelSectionTotal = 0;
  double _batterySectionTotal = 0;
  double _inverterSectionTotal = 0;
  double _estimatedInvolvesCost = 0;
  double _grandTotal = 0;

  bool get _isEditMode => widget.offer != null;
  SolarRequest? get _request => widget.request;
  SolarOffer? get _offer => widget.offer;

  @override
  void initState() {
    super.initState();
    final sourceRequest = _request;
    final sourceOffer = _offer;
    final panelPower =
        sourceOffer?.panelPower ?? sourceRequest?.panelPower ?? 0;
    final panelCount =
        sourceOffer?.panelCount ?? sourceRequest?.panelCount ?? 0;
    final batterySize =
        sourceOffer?.batterySize ?? sourceRequest?.batterySize ?? 0;
    final batteryCount =
        sourceOffer?.batteryCount ?? sourceRequest?.batteryCount ?? 0;
    final inverterSize =
        sourceOffer?.inverterSize ?? sourceRequest?.inverterSize ?? 0;
    final inverterCount =
        sourceOffer?.inverterCount ?? sourceRequest?.inverterCount ?? 0;
    final involvesCost = (sourceOffer?.involves ?? const <Involve>[])
        .fold<double>(
          0,
          (sum, item) =>
              sum +
              ((item.totalCost ?? (item.cost * (item.quantity ?? 1)))
                  .toDouble()),
        );
    final equipmentBudget = ((sourceOffer?.price ?? 0) - involvesCost).clamp(
      0,
      double.infinity,
    );
    final totalUnits = panelCount + batteryCount + inverterCount;
    final averageUnitPrice = totalUnits > 0
        ? equipmentBudget / totalUnits
        : 0.0;

    _panelPowerController = TextEditingController(text: panelPower.toString());
    _panelCountController = TextEditingController(text: panelCount.toString());
    _panelUnitPriceController = TextEditingController(
      text: panelCount > 0 ? _formatNumber(averageUnitPrice) : '',
    );
    _panelNoteController = TextEditingController(
      text: sourceOffer?.panelNote ?? sourceRequest?.panelNote ?? '',
    );
    _batterySizeController = TextEditingController(
      text: _formatNumber(batterySize),
    );
    _batteryCountController = TextEditingController(
      text: batteryCount.toString(),
    );
    _batteryUnitPriceController = TextEditingController(
      text: batteryCount > 0 ? _formatNumber(averageUnitPrice) : '',
    );
    _batteryNoteController = TextEditingController(
      text: sourceOffer?.batteryNote ?? sourceRequest?.batteryNote ?? '',
    );
    _inverterSizeController = TextEditingController(
      text: _formatNumber(inverterSize),
    );
    _inverterCountController = TextEditingController(
      text: inverterCount.toString(),
    );
    _inverterUnitPriceController = TextEditingController(
      text: inverterCount > 0 ? _formatNumber(averageUnitPrice) : '',
    );
    _inverterNoteController = TextEditingController(
      text: sourceOffer?.inverterNote ?? sourceRequest?.inverterNote ?? '',
    );
    _noteController = TextEditingController(
      text: sourceOffer?.note ?? sourceRequest?.note ?? '',
    );

    _batteryType =
        sourceOffer?.batteryType ??
        sourceRequest?.batteryType ??
        BatteryType.lithium;
    _inverterType =
        sourceOffer?.inverterType ??
        sourceRequest?.inverterType ??
        InverterType.hybrid;

    for (final involve in sourceOffer?.involves ?? const <Involve>[]) {
      _selectedInvolves.add(
        SelectedTemplateInvolve(
          templateId: involve.id,
          quantity: involve.quantity ?? 1,
        ),
      );
    }

    _recalculateTotals();
    Future.microtask(
      () => ref.read(involvesProvider.notifier).getInvolves(force: true),
    );
  }

  @override
  void dispose() {
    _panelPowerController.dispose();
    _panelCountController.dispose();
    _panelUnitPriceController.dispose();
    _panelNoteController.dispose();
    _batterySizeController.dispose();
    _batteryCountController.dispose();
    _batteryUnitPriceController.dispose();
    _batteryNoteController.dispose();
    _inverterSizeController.dispose();
    _inverterCountController.dispose();
    _inverterUnitPriceController.dispose();
    _inverterNoteController.dispose();
    _noteController.dispose();
    for (final item in _selectedInvolves) {
      item.dispose();
    }
    super.dispose();
  }

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

  double _parseDouble(String value) => double.tryParse(value.trim()) ?? 0;

  String _formatNumber(num value) {
    return value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _syncTotals() {
    _totalPanelPower =
        _parseInt(_panelPowerController.text) *
        _parseInt(_panelCountController.text);
    _panelSectionTotal =
        _parseInt(_panelCountController.text) *
        _parseDouble(_panelUnitPriceController.text);
    _batterySectionTotal =
        _parseInt(_batteryCountController.text) *
        _parseDouble(_batteryUnitPriceController.text);
    _inverterSectionTotal =
        _parseInt(_inverterCountController.text) *
        _parseDouble(_inverterUnitPriceController.text);
    _estimatedInvolvesCost = _calculateInvolvesCost();
    _grandTotal =
        _panelSectionTotal +
        _batterySectionTotal +
        _inverterSectionTotal +
        _estimatedInvolvesCost;
  }

  void _recalculateTotals() {
    setState(() {
      _syncTotals();
    });
  }

  double _calculateInvolvesCost() {
    final items = ref.read(involvesProvider).items;
    double total = 0;
    for (final selected in _selectedInvolves) {
      Involve? template;
      for (final item in items) {
        if (item.id == selected.templateId) {
          template = item;
          break;
        }
      }
      if (template != null) {
        total += template.cost.toDouble() * selected.quantity;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final offersState = ref.watch(offersProvider);
    final involvesState = ref.watch(involvesProvider);
    final catalogItems = involvesState.items
        .where((item) => item.isActive)
        .toList();

    return PreScaffold(
      title: _isEditMode
          ? _tr(context, 'Edit offer', 'تعديل العرض')
          : l10n.new_offer_proposal,
      clickBack: () => Navigator.of(context).maybePop(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          children: [
            HeroCard(
              title: _tr(context, 'Build your quotation', 'أنشئ عرض السعر'),
              subtitle: _tr(
                context,
                'Start from the customer request, adjust your technical offer, then add extra services if needed.',
                'ابدأ من طلب العميل ثم عدّل العرض الفني وأضف الخدمات الإضافية عند الحاجة.',
              ),
              chips: [
                _buildInfoChip(
                  context,
                  Iconsax.money_send_bold,
                  _tr(
                    context,
                    'Auto totals from unit prices',
                    'إجماليات تلقائية من أسعار الوحدة',
                  ),
                ),
                _buildInfoChip(
                  context,
                  Iconsax.verify_bold,
                  _tr(
                    context,
                    _isEditMode
                        ? 'Editing existing offer'
                        : 'Uses request defaults',
                    _isEditMode
                        ? 'تعديل عرض موجود'
                        : 'يعتمد على القيم الافتراضية للطلب',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            EquipmentSection(
              title: _tr(context, 'Panel offer', 'عرض الألواح'),
              subtitle: _tr(
                context,
                'These values start from the customer request and can be adjusted before sending your quote.',
                'هذه القيم تبدأ من طلب العميل ويمكن تعديلها قبل إرسال عرض السعر.',
              ),
              icon: Iconsax.sun_1_bold,
              accent: const Color(0xFFFFA726),
              fields: [
                _buildNumberField(
                  context: context,
                  label: _tr(context, 'Panel power (W)', 'قدرة اللوح (واط)'),
                  controller: _panelPowerController,
                  onChanged: _recalculateTotals,
                ),
                _buildNumberField(
                  context: context,
                  label: _tr(context, 'Panel count', 'عدد الألواح'),
                  controller: _panelCountController,
                  onChanged: _recalculateTotals,
                ),
                _buildDecimalField(
                  context: context,
                  label: _tr(context, 'Panel unit price', 'سعر اللوح'),
                  controller: _panelUnitPriceController,
                  onChanged: _recalculateTotals,
                ),
              ],
              fieldsPerRow: 3,
              totalTile: Column(
                children: [
                  TotalTile(
                    label: _tr(
                      context,
                      'Total panel power',
                      'إجمالي قدرة الألواح',
                    ),
                    value: '${_formatNumber(_totalPanelPower)} W',
                  ),
                  SizedBox(height: 12.h),
                  TotalTile(
                    label: _tr(
                      context,
                      'Panels total price',
                      'إجمالي سعر الألواح',
                    ),
                    value: '\$${_panelSectionTotal.toStringAsFixed(2)}',
                  ),
                ],
              ),
              noteField: _buildTextField(
                context: context,
                label: _tr(
                  context,
                  'Panel note (optional)',
                  'ملاحظة الألواح (اختياري)',
                ),
                controller: _panelNoteController,
                hintText: _tr(
                  context,
                  'Brand, mono, warranty, mounting notes...',
                  'العلامة التجارية، مونو، الضمان، ملاحظات التركيب...',
                ),
              ),
            ),

            SizedBox(height: 20.h),
            EquipmentSection(
              title: _tr(context, 'Battery offer', 'عرض البطاريات'),
              subtitle: _tr(
                context,
                'Use battery type and size details to explain your backup recommendation clearly.',
                'استخدم نوع البطارية وسعتها لتوضيح توصيتك الخاصة بالنسخ الاحتياطي بشكل واضح.',
              ),
              icon: Iconsax.flash_1_bold,
              accent: const Color(0xFF42A5F5),
              topChild: FormDropdown<BatteryType>(
                label: _tr(context, 'Battery type', 'نوع البطارية'),
                value: _batteryType,
                items: BatteryType.values,
                onChanged: (value) =>
                    setState(() => _batteryType = value ?? BatteryType.lithium),
                itemLabelBuilder: (item) =>
                    item.localizedLabel(AppLocalizations.of(context)!),
              ),
              fields: [
                _buildDecimalField(
                  context: context,
                  label: _tr(context, 'Battery size', 'سعة البطارية'),
                  controller: _batterySizeController,
                ),
                _buildNumberField(
                  context: context,
                  label: _tr(context, 'Battery count', 'عدد البطاريات'),
                  controller: _batteryCountController,
                  onChanged: _recalculateTotals,
                ),
                _buildDecimalField(
                  context: context,
                  label: _tr(context, 'Battery unit price', 'سعر البطارية'),
                  controller: _batteryUnitPriceController,
                  onChanged: _recalculateTotals,
                ),
              ],
              fieldsPerRow: 3,
              totalTile: TotalTile(
                label: _tr(
                  context,
                  'Batteries total price',
                  'إجمالي سعر البطاريات',
                ),
                value: '\$${_batterySectionTotal.toStringAsFixed(2)}',
              ),
              noteField: _buildTextField(
                context: context,
                label: _tr(
                  context,
                  'Battery note (optional)',
                  'ملاحظة البطارية (اختياري)',
                ),
                controller: _batteryNoteController,
                hintText: _tr(
                  context,
                  'Rack setup, backup hours, preferred brand...',
                  'إعداد الرف، ساعات التشغيل، العلامة المفضلة...',
                ),
              ),
            ),

            SizedBox(height: 20.h),
            EquipmentSection(
              title: _tr(context, 'Inverter offer', 'عرض العاكس'),
              subtitle: _tr(
                context,
                'Keep inverter details aligned with the real installation setup and grid requirements.',
                'اجعل تفاصيل العاكس متوافقة مع إعداد التركيب الفعلي ومتطلبات الشبكة.',
              ),
              icon: Iconsax.setting_2_bold,
              accent: const Color(0xFF8E24AA),
              topChild: FormDropdown<InverterType>(
                label: _tr(context, 'Inverter type', 'نوع العاكس'),
                value: _inverterType,
                items: InverterType.values,
                onChanged: (value) => setState(
                  () => _inverterType = value ?? InverterType.hybrid,
                ),
                itemLabelBuilder: (item) =>
                    item.localizedLabel(AppLocalizations.of(context)!),
              ),
              fields: [
                _buildDecimalField(
                  context: context,
                  label: _tr(context, 'Inverter size', 'قدرة العاكس'),
                  controller: _inverterSizeController,
                ),
                _buildNumberField(
                  context: context,
                  label: _tr(context, 'Inverter count', 'عدد العواكس'),
                  controller: _inverterCountController,
                  onChanged: _recalculateTotals,
                ),
                _buildDecimalField(
                  context: context,
                  label: _tr(context, 'Inverter unit price', 'سعر العاكس'),
                  controller: _inverterUnitPriceController,
                  onChanged: _recalculateTotals,
                ),
              ],
              fieldsPerRow: 3,
              totalTile: TotalTile(
                label: _tr(
                  context,
                  'Inverters total price',
                  'إجمالي سعر العواكس',
                ),
                value: '\$${_inverterSectionTotal.toStringAsFixed(2)}',
              ),
              noteField: _buildTextField(
                context: context,
                label: _tr(
                  context,
                  'Inverter note (optional)',
                  'ملاحظة العاكس (اختياري)',
                ),
                controller: _inverterNoteController,
                hintText: _tr(
                  context,
                  'Single phase, MPPT count, protection notes...',
                  'أحادي الطور، عدد MPPT، ملاحظات الحماية...',
                ),
              ),
            ),
            SizedBox(height: 20.h),
            NotesCard(
              title: _tr(context, 'Offer note', 'ملاحظات العرض'),
              description: _tr(
                context,
                'Use this area for delivery time, warranty, execution notes, or exclusions.',
                'استخدم هذا الحقل لوقت التسليم أو الضمان أو ملاحظات التنفيذ أو الاستثناءات.',
              ),
              field: _buildTextField(
                context: context,
                label: _tr(context, 'Note (optional)', 'ملاحظة (اختياري)'),
                controller: _noteController,
                hintText: _tr(
                  context,
                  'Delivery time, payment terms, warranty...',
                  'مدة التسليم، شروط الدفع، الضمان...',
                ),
                maxLines: 4,
              ),
            ),
            SizedBox(height: 20.h),
            FormSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormSectionTitle(
                    title: _tr(
                      context,
                      'Template involves',
                      'الخدمات أو الرسوم الإضافية',
                    ),
                    subtitle: _tr(
                      context,
                      'Use this for installation fee, delivery, mounting, cables, or any extra service linked to this quotation.',
                      'استخدم هذا القسم لرسوم التركيب أو التوصيل أو الهياكل أو الكابلات أو أي خدمة إضافية مرتبطة بهذا العرض.',
                    ),
                    icon: Iconsax.receipt_item_bold,
                    accent: const Color(0xFF00A884),
                  ),
                  SizedBox(height: 16.h),
                  if (involvesState.isLoading && involvesState.items.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    if (_selectedInvolves.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          _tr(
                            context,
                            'No extra services added yet.',
                            'لم تتم إضافة خدمات أو رسوم إضافية بعد.',
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      )
                    else
                      ..._selectedInvolves.asMap().entries.map((entry) {
                        final index = entry.key;
                        final selected = entry.value;
                        final selectedIds = _selectedInvolves
                            .where(
                              (item) =>
                                  item != selected && item.templateId != null,
                            )
                            .map((item) => item.templateId!)
                            .toSet();
                        final options = catalogItems
                            .where(
                              (item) =>
                                  !selectedIds.contains(item.id) ||
                                  item.id == selected.templateId,
                            )
                            .toList();

                        return InvolveItemCard(
                          index: index,
                          selected: selected,
                          options: options,
                          catalogItems: catalogItems,
                          onRemove: () => _removeInvolveRow(index),
                          onChanged: _recalculateTotals,
                          tr: (en, ar) => _tr(context, en, ar),
                        );
                      }),
                    SizedBox(height: 12.h),
                    TotalTile(
                      label: _tr(
                        context,
                        'Estimated extra fees',
                        'إجمالي الرسوم الإضافية التقديري',
                      ),
                      value: '\$${_estimatedInvolvesCost.toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: [
                        OutlinedButton.icon(
                          onPressed: catalogItems.isEmpty
                              ? null
                              : _addInvolveRow,
                          icon: const Icon(Iconsax.add_circle_bold),
                          label: Text(
                            _tr(
                              context,
                              'Add from catalog',
                              'إضافة من الكتالوج',
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _createInvolveFromForm,
                          icon: const Icon(Iconsax.edit_bold),
                          label: Text(
                            _tr(context, 'Create new item', 'إنشاء عنصر جديد'),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openCatalogScreen,
                          icon: const Icon(Iconsax.setting_2_bold),
                          label: Text(
                            _tr(context, 'Manage catalog', 'إدارة الكتالوج'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20.h),
            TotalTile(
              label: _tr(context, 'Quotation total', 'إجمالي عرض السعر'),
              value: '\$${_grandTotal.toStringAsFixed(2)}',
            ),
            SizedBox(height: 28.h),
            SizedBox(
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: offersState.isLoading ? null : _submit,
                icon: offersState.isLoading
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Iconsax.send_2_bold),
                label: Text(
                  _tr(
                    context,
                    _isEditMode ? 'Save offer changes' : 'Submit quotation',
                    _isEditMode ? 'حفظ تعديلات العرض' : 'إرسال عرض السعر',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged?.call(),
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
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (_) => onChanged?.call(),
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
    required BuildContext context,
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

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

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

  void _addInvolveRow() {
    final items = ref
        .read(involvesProvider)
        .items
        .where((item) => item.isActive)
        .toList();
    final selectedIds = _selectedInvolves
        .where((item) => item.templateId != null)
        .map((item) => item.templateId!)
        .toSet();
    final available = items
        .where((item) => !selectedIds.contains(item.id))
        .toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              context,
              'No more active catalog items are available. Create a new one first.',
              'لا توجد عناصر نشطة أخرى متاحة في الكتالوج. أنشئ عنصرًا جديدًا أولًا.',
            ),
          ),
        ),
      );
      return;
    }
    setState(() {
      _selectedInvolves.add(
        SelectedTemplateInvolve(templateId: available.first.id),
      );
      _syncTotals();
    });
  }

  void _removeInvolveRow(int index) {
    setState(() {
      _selectedInvolves[index].dispose();
      _selectedInvolves.removeAt(index);
      _syncTotals();
    });
  }

  Future<void> _createInvolveFromForm() async {
    final nameController = TextEditingController();
    final costController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16.h,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr(
                        context,
                        'Create extra fee item',
                        'إنشاء عنصر رسوم إضافية',
                      ),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _tr(
                        context,
                        'Examples: installation, delivery, cable run, steel structure.',
                        'أمثلة: التركيب، التوصيل، تمديد الكابلات، الهيكل المعدني.',
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: _tr(context, 'Name', 'الاسم'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? _tr(context, 'Required', 'مطلوب')
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: _tr(context, 'Cost', 'السعر'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value?.trim() ?? '');
                        if (parsed == null || parsed < 0) {
                          return _tr(context, 'Required', 'مطلوب');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 18.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            ToastService.error(
                              context,
                              _tr(context, 'Required', 'مطلوب'),
                              _tr(
                                context,
                                'Please enter name',
                                'يرجى إدخال الاسم',
                              ),
                            );
                            return;
                          }
                          final cost = int.tryParse(costController.text.trim());
                          if (cost == null) {
                            ToastService.error(
                              context,
                              _tr(context, 'Required', 'مطلوب'),
                              _tr(
                                context,
                                'Please enter a valid cost',
                                'يرجى إدخال تكلفة صالحة',
                              ),
                            );
                            return;
                          }

                          if (!formKey.currentState!.validate()) return;
                          final created = await ref
                              .read(involvesProvider.notifier)
                              .createInvolve(
                                name: nameController.text.trim(),
                                cost: cost,
                              );
                          if (!sheetContext.mounted) return;
                          if (created != null) {
                            Navigator.of(sheetContext).pop();
                            if (!mounted) return;
                            setState(() {
                              _selectedInvolves.add(
                                SelectedTemplateInvolve(templateId: created.id),
                              );
                              _syncTotals();
                            });
                          }
                        },
                        child: Text(
                          _tr(context, 'Create item', 'إنشاء العنصر'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCatalogScreen() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const InvolvesCatalogScreen()));
    if (!mounted) return;
    await ref.read(involvesProvider.notifier).getInvolves(force: true);
    _recalculateTotals();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _validateTemplateInvolves() {
    for (final item in _selectedInvolves) {
      if (item.templateId == null || item.quantity <= 0) {
        ToastService.error(
          context,
          _tr(context, 'Extra fees missing', 'رسوم إضافية مفقودة'),
          _tr(
            context,
            'Each selected extra fee must have a catalog item and quantity.',
            'يجب أن يحتوي كل رسم إضافي مختار على عنصر من الكتالوج وكمية.',
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _submit() async {
    if (_totalPanelPower <= 0) {
      ToastService.error(
        context,
        _tr(context, 'Invalid panel offer', 'عرض ألواح غير صالح'),
        _tr(
          context,
          'Please enter valid panel power and count',
          'يرجى إدخال قدرة وعدد ألواح صالحين',
        ),
      );
      return;
    }

    if (_parseDouble(_batterySizeController.text) <= 0 ||
        _parseInt(_batteryCountController.text) <= 0) {
      ToastService.error(
        context,
        _tr(context, 'Invalid battery offer', 'عرض بطاريات غير صالح'),
        _tr(
          context,
          'Please enter valid battery details',
          'يرجى إدخال تفاصيل بطارية صالحة',
        ),
      );
      return;
    }

    if (_parseDouble(_inverterSizeController.text) <= 0 ||
        _parseInt(_inverterCountController.text) <= 0) {
      ToastService.error(
        context,
        _tr(context, 'Invalid inverter offer', 'عرض عاكس غير صالح'),
        _tr(
          context,
          'Please enter valid inverter details',
          'يرجى إدخال تفاصيل عاكس صالحة',
        ),
      );
      return;
    }

    if (_panelSectionTotal <= 0 ||
        _batterySectionTotal <= 0 ||
        _inverterSectionTotal <= 0 ||
        _grandTotal <= 0) {
      ToastService.error(
        context,
        _tr(context, 'Invalid pricing', 'تسعير غير صالح'),
        _tr(
          context,
          'Please enter valid unit prices for panels, batteries, and inverters',
          'يرجى إدخال أسعار وحدة صالحة للألواح والبطاريات والعواكس',
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (!_validateTemplateInvolves()) {
      ToastService.error(
        context,
        _tr(context, 'Extra fees missing', 'رسوم إضافية مفقودة'),
        _tr(
          context,
          'Please fill all selected extra fee details',
          'يرجى ملء تفاصيل الرسوم الإضافية المختارة',
        ),
      );
      return;
    }

    final data = {
      'price': _grandTotal,
      'template_involves': _selectedInvolves
          .where((item) => item.templateId != null)
          .map(
            (item) => {
              'template_id': item.templateId,
              'quantity': item.quantity,
            },
          )
          .toList(),
      'total_panel_power': _totalPanelPower == 0
          ? (_request?.totalPanelPower ?? _offer?.totalPanelPower ?? 0)
          : _totalPanelPower,
      'panel_power': _parseInt(_panelPowerController.text),
      'panel_count': _parseInt(_panelCountController.text),
      'panel_note': _emptyToNull(_panelNoteController.text),
      'battery_size': _parseDouble(_batterySizeController.text),
      'battery_count': _parseInt(_batteryCountController.text),
      'battery_note': _emptyToNull(_batteryNoteController.text),
      'battery_type': _batteryType.name,
      'inverter_size': _parseDouble(_inverterSizeController.text),
      'inverter_count': _parseInt(_inverterCountController.text),
      'inverter_note': _emptyToNull(_inverterNoteController.text),
      'inverter_type': _inverterType.name,
      'note': _emptyToNull(_noteController.text),
    };

    final success = _isEditMode
        ? await ref.read(offersProvider.notifier).updateOffer(_offer!.id!, data)
        : await ref
              .read(offersProvider.notifier)
              .replyToRequest(_request!.id!, data);
    if (mounted && success) Navigator.of(context).pop(true);
  }
}
