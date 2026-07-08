import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/features/company_dashboard/domain/models/company_expense_form_model.dart';
import 'package:watt/src/shared/widgets/shared_widgets.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:validatorless/validatorless.dart';

/// Bottom sheet form for adding a new company expense.
class ExpenseFormSheet extends ConsumerStatefulWidget {
  final Future<void> Function(CompanyExpenseFormModel payload) onSubmit;

  const ExpenseFormSheet({super.key, required this.onSubmit});

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
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
                  '${l10n.add} ${l10n.expenses}',
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _amountController,
                  label: l10n.amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: Validatorless.multiple([Validatorless.required(l10n.required_field), Validatorless.number(l10n.required_field)]),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _categoryController,
                  label: l10n.category,
                  validator: Validatorless.required(l10n.required_field),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.date,
                      labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, color: colors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                    ),
                    child: Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, color: colors.textPrimary),
                    ),
                  ),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 5),
      lastDate: DateTime(_date.year + 1),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        CompanyExpenseFormModel(
          amount: double.tryParse(_amountController.text.trim()) ?? 0,
          category: _categoryController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          date: _date,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
