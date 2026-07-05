import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_public_service_form_model.dart';
import 'package:solar_hub/src/shared/domain/company/company_public_service.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:validatorless/validatorless.dart';

/// Bottom sheet form for adding or editing a public service.
class PublicServiceFormSheet extends ConsumerStatefulWidget {
  final CompanyPublicService? initialValue;
  final Future<void> Function(CompanyPublicServiceFormModel payload) onSubmit;

  const PublicServiceFormSheet({super.key, required this.onSubmit, this.initialValue});

  @override
  ConsumerState<PublicServiceFormSheet> createState() => _PublicServiceFormSheetState();
}

class _PublicServiceFormSheetState extends ConsumerState<PublicServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialValue?.title ?? '');
    _priceController = TextEditingController(text: widget.initialValue?.price?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.initialValue?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
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
                  widget.initialValue == null ? l10n.company_public_services_add : l10n.company_public_services_edit,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _titleController,
                  label: l10n.company_public_services_title,
                  validator: Validatorless.required(l10n.company_public_services_title_required),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _priceController,
                  label: l10n.company_public_services_price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descriptionController,
                  label: l10n.company_public_services_description,
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                AppButton(
                  text: _isSubmitting ? l10n.loading : l10n.company_public_services_save,
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
        CompanyPublicServiceFormModel(
          title: _titleController.text.trim(),
          price: _priceController.text.trim().isEmpty ? null : num.tryParse(_priceController.text.trim()),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
