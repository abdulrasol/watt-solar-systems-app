import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/features/company_dashboard/domain/models/company_contact_form_model.dart';
import 'package:watt/src/shared/widgets/shared_widgets.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:validatorless/validatorless.dart';

/// Bottom sheet form for adding a new company contact.
class ContactFormSheet extends ConsumerStatefulWidget {
  final Future<void> Function(CompanyContactFormModel payload) onSubmit;

  const ContactFormSheet({super.key, required this.onSubmit});

  @override
  ConsumerState<ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends ConsumerState<ContactFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
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
                  l10n.company_contacts_add,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  label: l10n.company_contacts_name,
                  validator: Validatorless.required(l10n.company_contacts_name_required),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _emailController,
                  label: l10n.company_contacts_email,
                  validator: Validatorless.multiple([
                    Validatorless.required(l10n.company_contacts_email_required),
                    Validatorless.email(l10n.company_contacts_email_invalid),
                  ]),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _phoneController,
                  label: l10n.company_contacts_phone,
                  validator: Validatorless.required(l10n.company_contacts_phone_required),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _notesController,
                  label: l10n.company_contacts_notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                AppButton(
                  text: _isSubmitting ? l10n.loading : l10n.company_contacts_save,
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
        CompanyContactFormModel(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
