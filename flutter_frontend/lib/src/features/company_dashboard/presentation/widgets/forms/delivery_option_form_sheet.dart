import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/features/company_dashboard/domain/models/delivery_option_form_model.dart';
import 'package:watt/src/shared/widgets/shared_widgets.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:validatorless/validatorless.dart';

/// Bottom sheet form for adding a new delivery option.
class DeliveryOptionFormSheet extends ConsumerStatefulWidget {
  final Future<void> Function(DeliveryOptionFormModel payload) onSubmit;

  const DeliveryOptionFormSheet({super.key, required this.onSubmit});

  @override
  ConsumerState<DeliveryOptionFormSheet> createState() => _DeliveryOptionFormSheetState();
}

class _DeliveryOptionFormSheetState extends ConsumerState<DeliveryOptionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _minDaysController = TextEditingController();
  final _maxDaysController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _minDaysController.dispose();
    _maxDaysController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.add} ${l10n.delivery}',
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  label: l10n.name,
                  validator: Validatorless.required(l10n.required_field),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _costController,
                  label: l10n.cost,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: Validatorless.multiple([Validatorless.required(l10n.required_field), Validatorless.number(l10n.required_field)]),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _minDaysController,
                        label: l10n.company_delivery_estimated_days_min,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _maxDaysController,
                        label: l10n.company_delivery_estimated_days_max,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descriptionController,
                  label: l10n.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                AppButton(
                  text: _isSubmitting ? l10n.loading : l10n.save,
                  onPressed: _isSubmitting ? null : _submit,
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        DeliveryOptionFormModel(
          name: _nameController.text.trim(),
          cost: double.tryParse(_costController.text.trim()) ?? 0,
          estimatedDaysMin: int.tryParse(_minDaysController.text.trim()),
          estimatedDaysMax: int.tryParse(_maxDaysController.text.trim()),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
