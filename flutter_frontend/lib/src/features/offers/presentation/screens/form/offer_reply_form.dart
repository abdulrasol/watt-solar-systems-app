import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/widgets/pre_scaffold.dart';
import 'package:watt/src/features/offers/domain/entities/involve.dart';
import 'package:watt/src/features/offers/domain/entities/solar_offer.dart';
import 'package:watt/src/features/offers/domain/entities/solar_request.dart';
import 'package:watt/src/features/offers/presentation/providers/involves_provider.dart';
import 'package:watt/src/features/offers/presentation/providers/offers_provider.dart';
import 'package:watt/src/features/offers/presentation/screens/form/models/selected_involve.dart';
import 'package:watt/src/features/offers/presentation/screens/form/widgets/equipment_section.dart';
import 'package:watt/src/features/offers/presentation/screens/form/widgets/form_cards.dart';
import 'package:watt/src/features/offers/presentation/screens/form/widgets/form_sections.dart';
import 'package:watt/src/features/offers/presentation/screens/form/widgets/involve_item_card.dart';
import 'package:watt/src/features/offers/presentation/screens/involves_catalog_screen.dart';
import 'package:watt/src/utils/app_enums.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/services/toast_service.dart';

class OfferReplyForm extends ConsumerStatefulWidget {
  final SolarRequest? request;
  final SolarOffer? offer;

  const OfferReplyForm({super.key, this.request, this.offer}) : assert(request != null || offer != null);

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
  late final AppLocalizations l10n;

  @override
  void initState() {
    super.initState();
    l10n = AppLocalizations.of(context)!;
    final sourceRequest = _request;
    final sourceOffer = _offer;
    final panelPower = sourceOffer?.panelPower ?? sourceRequest?.panelPower ?? 0;
    final panelCount = sourceOffer?.panelCount ?? sourceRequest?.panelCount ?? 0;
    final batterySize = sourceOffer?.batterySize ?? sourceRequest?.batterySize ?? 0;
    final batteryCount = sourceOffer?.batteryCount ?? sourceRequest?.batteryCount ?? 0;
    final inverterSize = sourceOffer?.inverterSize ?? sourceRequest?.inverterSize ?? 0;
    final inverterCount = sourceOffer?.inverterCount ?? sourceRequest?.inverterCount ?? 0;
    final involvesCost = (sourceOffer?.involves ?? const <Involve>[]).fold<double>(
      0,
      (sum, item) => sum + ((item.totalCost ?? (item.cost * (item.quantity ?? 1))).toDouble()),
    );
    final equipmentBudget = ((sourceOffer?.price ?? 0) - involvesCost).clamp(0, double.infinity);
    final totalUnits = panelCount + batteryCount + inverterCount;
    final averageUnitPrice = totalUnits > 0 ? equipmentBudget / totalUnits : 0.0;

    _panelPowerController = TextEditingController(text: panelPower.toString());
    _panelCountController = TextEditingController(text: panelCount.toString());
    _panelUnitPriceController = TextEditingController(text: panelCount > 0 ? _formatNumber(averageUnitPrice) : '');
    _panelNoteController = TextEditingController(text: sourceOffer?.panelNote ?? sourceRequest?.panelNote ?? '');
    _batterySizeController = TextEditingController(text: _formatNumber(batterySize));
    _batteryCountController = TextEditingController(text: batteryCount.toString());
    _batteryUnitPriceController = TextEditingController(text: batteryCount > 0 ? _formatNumber(averageUnitPrice) : '');
    _batteryNoteController = TextEditingController(text: sourceOffer?.batteryNote ?? sourceRequest?.batteryNote ?? '');
    _inverterSizeController = TextEditingController(text: _formatNumber(inverterSize));
    _inverterCountController = TextEditingController(text: inverterCount.toString());
    _inverterUnitPriceController = TextEditingController(text: inverterCount > 0 ? _formatNumber(averageUnitPrice) : '');
    _inverterNoteController = TextEditingController(text: sourceOffer?.inverterNote ?? sourceRequest?.inverterNote ?? '');
    _noteController = TextEditingController(text: sourceOffer?.note ?? sourceRequest?.note ?? '');

    _batteryType = sourceOffer?.batteryType ?? sourceRequest?.batteryType ?? BatteryType.lithium;
    _inverterType = sourceOffer?.inverterType ?? sourceRequest?.inverterType ?? InverterType.hybrid;

    for (final involve in sourceOffer?.involves ?? const <Involve>[]) {
      _selectedInvolves.add(SelectedTemplateInvolve(templateId: involve.id, quantity: involve.quantity ?? 1));
    }

    _recalculateTotals();
    Future.microtask(() => ref.read(involvesProvider.notifier).getInvolves(force: true));
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

  int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

  double _parseDouble(String value) => double.tryParse(value.trim()) ?? 0;

  String _formatNumber(num value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _syncTotals() {
    _totalPanelPower = _parseInt(_panelPowerController.text) * _parseInt(_panelCountController.text);
    _panelSectionTotal = _parseInt(_panelCountController.text) * _parseDouble(_panelUnitPriceController.text);
    _batterySectionTotal = _parseInt(_batteryCountController.text) * _parseDouble(_batteryUnitPriceController.text);
    _inverterSectionTotal = _parseInt(_inverterCountController.text) * _parseDouble(_inverterUnitPriceController.text);
    _estimatedInvolvesCost = _calculateInvolvesCost();
    _grandTotal = _panelSectionTotal + _batterySectionTotal + _inverterSectionTotal + _estimatedInvolvesCost;
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
    final offersState = ref.watch(offersProvider);
    final involvesState = ref.watch(involvesProvider);
    final catalogItems = involvesState.items.where((item) => item.isActive).toList();

    return PreScaffold(
      title: _isEditMode ? l10n.edit_offer : l10n.new_offer_proposal,
      clickBack: () => Navigator.of(context).maybePop(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          children: [
            HeroCard(
              title: l10n.build_quotation,
              subtitle: l10n.build_quotation_subtitle,
              chips: [
                _buildInfoChip(context, Iconsax.money_send, l10n.auto_totals_label),
                _buildInfoChip(context, Iconsax.verify, _isEditMode ? l10n.editing_existing_offer : l10n.uses_request_defaults),
              ],
            ),
            SizedBox(height: 20.h),
            EquipmentSection(
              title: l10n.panel_offer,
              subtitle: l10n.panel_offer_subtitle,
              icon: Iconsax.sun_1,
              accent: const Color(0xFFFFA726),
              fields: [
                _buildNumberField(context: context, label: l10n.panel_power_watts, controller: _panelPowerController, onChanged: _recalculateTotals),
                _buildNumberField(context: context, label: l10n.panel_count, controller: _panelCountController, onChanged: _recalculateTotals),
                _buildDecimalField(context: context, label: l10n.panel_unit_price, controller: _panelUnitPriceController, onChanged: _recalculateTotals),
              ],
              fieldsPerRow: 3,
              totalTile: Column(
                children: [
                  TotalTile(label: l10n.total_panel_power_label, value: '${_formatNumber(_totalPanelPower)} W'),
                  SizedBox(height: 12.h),
                  TotalTile(label: l10n.panels_total_price, value: '\$${_panelSectionTotal.toStringAsFixed(2)}'),
                ],
              ),
              noteField: _buildTextField(context: context, label: l10n.panel_note_label, controller: _panelNoteController, hintText: l10n.panel_note_hint),
            ),

            SizedBox(height: 20.h),
            EquipmentSection(
              title: l10n.battery_offer,
              subtitle: l10n.battery_offer_subtitle,
              icon: Iconsax.flash_1,
              accent: const Color(0xFF42A5F5),
              topChild: FormDropdown<BatteryType>(
                label: l10n.battery_type,
                value: _batteryType,
                items: BatteryType.values,
                onChanged: (value) => setState(() => _batteryType = value ?? BatteryType.lithium),
                itemLabelBuilder: (item) => item.localizedLabel(AppLocalizations.of(context)!),
              ),
              fields: [
                _buildDecimalField(context: context, label: l10n.battery_size, controller: _batterySizeController),
                _buildNumberField(context: context, label: l10n.battery_count, controller: _batteryCountController, onChanged: _recalculateTotals),
                _buildDecimalField(context: context, label: l10n.battery_unit_price, controller: _batteryUnitPriceController, onChanged: _recalculateTotals),
              ],
              fieldsPerRow: 3,
              totalTile: TotalTile(label: l10n.batteries_total_price, value: '\$${_batterySectionTotal.toStringAsFixed(2)}'),
              noteField: _buildTextField(
                context: context,
                label: l10n.battery_note_label,
                controller: _batteryNoteController,
                hintText: l10n.battery_note_hint,
              ),
            ),

            SizedBox(height: 20.h),
            EquipmentSection(
              title: l10n.inverter_offer,
              subtitle: l10n.inverter_offer_subtitle,
              icon: Iconsax.setting_2,
              accent: const Color(0xFF8E24AA),
              topChild: FormDropdown<InverterType>(
                label: l10n.inverter_type,
                value: _inverterType,
                items: InverterType.values,
                onChanged: (value) => setState(() => _inverterType = value ?? InverterType.hybrid),
                itemLabelBuilder: (item) => item.localizedLabel(AppLocalizations.of(context)!),
              ),
              fields: [
                _buildDecimalField(context: context, label: l10n.inverter_size, controller: _inverterSizeController),
                _buildNumberField(context: context, label: l10n.inverter_count, controller: _inverterCountController, onChanged: _recalculateTotals),
                _buildDecimalField(context: context, label: l10n.inverter_unit_price, controller: _inverterUnitPriceController, onChanged: _recalculateTotals),
              ],
              fieldsPerRow: 3,
              totalTile: TotalTile(label: l10n.inverters_total_price, value: '\$${_inverterSectionTotal.toStringAsFixed(2)}'),
              noteField: _buildTextField(
                context: context,
                label: l10n.inverter_note_label,
                controller: _inverterNoteController,
                hintText: l10n.inverter_note_hint,
              ),
            ),
            SizedBox(height: 20.h),
            NotesCard(
              title: l10n.offer_note_title,
              description: l10n.offer_note_description,
              field: _buildTextField(context: context, label: l10n.note_optional, controller: _noteController, hintText: l10n.note_hint, maxLines: 4),
            ),
            SizedBox(height: 20.h),
            FormSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormSectionTitle(
                    title: l10n.template_involves,
                    subtitle: l10n.template_involves_subtitle,
                    icon: Iconsax.receipt_item,
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
                        decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16.r)),
                        child: Text(
                          l10n.no_extra_services,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                        ),
                      )
                    else
                      ..._selectedInvolves.asMap().entries.map((entry) {
                        final index = entry.key;
                        final selected = entry.value;
                        final selectedIds = _selectedInvolves
                            .where((item) => item != selected && item.templateId != null)
                            .map((item) => item.templateId!)
                            .toSet();
                        final options = catalogItems.where((item) => !selectedIds.contains(item.id) || item.id == selected.templateId).toList();

                        return InvolveItemCard(
                          index: index,
                          selected: selected,
                          options: options,
                          catalogItems: catalogItems,
                          onRemove: () => _removeInvolveRow(index),
                          onChanged: _recalculateTotals,
                          tr: (en, ar) => l10n.localeName == 'ar' ? ar : en,
                        );
                      }),
                    SizedBox(height: 12.h),
                    TotalTile(label: l10n.estimated_extra_fees_label, value: '\$${_estimatedInvolvesCost.toStringAsFixed(2)}'),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: [
                        OutlinedButton.icon(
                          onPressed: catalogItems.isEmpty ? null : _addInvolveRow,
                          icon: const Icon(Iconsax.add_circle),
                          label: Text(l10n.add_from_catalog),
                        ),
                        OutlinedButton.icon(onPressed: _createInvolveFromForm, icon: const Icon(Iconsax.edit), label: Text(l10n.create_new_item)),
                        TextButton.icon(onPressed: _openCatalogScreen, icon: const Icon(Iconsax.setting_2), label: Text(l10n.manage_catalog)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20.h),
            TotalTile(label: l10n.quotation_total, value: '\$${_grandTotal.toStringAsFixed(2)}'),
            SizedBox(height: 28.h),
            SizedBox(
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: offersState.isLoading ? null : _submit,
                icon: offersState.isLoading
                    ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Iconsax.send_2),
                label: Text(_isEditMode ? l10n.save_offer_changes : l10n.submit_quotation),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({required BuildContext context, required String label, required TextEditingController controller, VoidCallback? onChanged}) {
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
          return AppLocalizations.of(context)!.form_required;
        }
        return null;
      },
    );
  }

  Widget _buildDecimalField({required BuildContext context, required String label, required TextEditingController controller, VoidCallback? onChanged}) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      validator: (value) {
        final parsed = double.tryParse(value?.trim() ?? '');
        if (parsed == null || parsed <= 0) {
          return AppLocalizations.of(context)!.form_required;
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
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: onSurface.withValues(alpha: 0.82)),
          ),
        ],
      ),
    );
  }

  void _addInvolveRow() {
    final items = ref.read(involvesProvider).items.where((item) => item.isActive).toList();
    final selectedIds = _selectedInvolves.where((item) => item.templateId != null).map((item) => item.templateId!).toSet();
    final available = items.where((item) => !selectedIds.contains(item.id)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.no_more_catalog_items)));
      return;
    }
    setState(() {
      _selectedInvolves.add(SelectedTemplateInvolve(templateId: available.first.id));
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
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16.h),
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
                      l10n.create_item_title,
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.create_item_subtitle,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.name_label,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? l10n.form_required : null,
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.cost_label,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value?.trim() ?? '');
                        if (parsed == null || parsed < 0) {
                          return l10n.form_required;
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
                            ToastService.error(context, l10n.form_required, l10n.name_label);
                            return;
                          }
                          final cost = int.tryParse(costController.text.trim());
                          if (cost == null) {
                            ToastService.error(context, l10n.form_required, l10n.cost_label);
                            return;
                          }

                          if (!formKey.currentState!.validate()) return;
                          final created = await ref.read(involvesProvider.notifier).createInvolve(name: nameController.text.trim(), cost: cost);
                          if (!sheetContext.mounted) return;
                          if (created != null) {
                            Navigator.of(sheetContext).pop();
                            if (!mounted) return;
                            setState(() {
                              _selectedInvolves.add(SelectedTemplateInvolve(templateId: created.id));
                              _syncTotals();
                            });
                          }
                        },
                        child: Text(l10n.create_item_button),
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
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InvolvesCatalogScreen()));
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
        ToastService.error(context, l10n.extra_fees_missing_title, l10n.extra_fees_missing_msg);
        return false;
      }
    }
    return true;
  }

  Future<void> _submit() async {
    if (_totalPanelPower <= 0) {
      ToastService.error(context, l10n.invalid_panel_offer_title, l10n.invalid_panel_offer_msg);
      return;
    }

    if (_parseDouble(_batterySizeController.text) <= 0 || _parseInt(_batteryCountController.text) <= 0) {
      ToastService.error(context, l10n.invalid_battery_offer_title, l10n.invalid_battery_offer_msg);
      return;
    }

    if (_parseDouble(_inverterSizeController.text) <= 0 || _parseInt(_inverterCountController.text) <= 0) {
      ToastService.error(context, l10n.invalid_inverter_offer_title, l10n.invalid_inverter_offer_msg);
      return;
    }

    if (_panelSectionTotal <= 0 || _batterySectionTotal <= 0 || _inverterSectionTotal <= 0 || _grandTotal <= 0) {
      ToastService.error(context, l10n.invalid_pricing_title, l10n.invalid_pricing_msg);
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (!_validateTemplateInvolves()) {
      ToastService.error(context, l10n.extra_fees_missing_title, l10n.extra_fees_missing_msg);
      return;
    }

    final data = {
      'price': _grandTotal,
      'template_involves': _selectedInvolves
          .where((item) => item.templateId != null)
          .map((item) => {'template_id': item.templateId, 'quantity': item.quantity})
          .toList(),
      'total_panel_power': _totalPanelPower == 0 ? (_request?.totalPanelPower ?? _offer?.totalPanelPower ?? 0) : _totalPanelPower,
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
        : await ref.read(offersProvider.notifier).replyToRequest(_request!.id!, data);
    if (mounted && success) Navigator.of(context).pop(true);
  }
}
