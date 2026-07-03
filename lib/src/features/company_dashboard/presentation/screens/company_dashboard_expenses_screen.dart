import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/shared/domain/company/company_expense.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_expense_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_expenses_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:validatorless/validatorless.dart';

class CompanyDashboardExpensesScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const CompanyDashboardExpensesScreen({super.key, this.embedded = false});

  @override
  ConsumerState<CompanyDashboardExpensesScreen> createState() => _CompanyDashboardExpensesScreenState();
}

class _CompanyDashboardExpensesScreenState extends ConsumerState<CompanyDashboardExpensesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      final companyId = ref.read(authProvider).company?.id;
      if (companyId != null) {
        ref.read(companyExpensesProvider.notifier).fetchNextPage(companyId);
      }
    }
  }

  Future<void> _load() async {
    final companyId = ref.read(authProvider).company?.id;
    if (companyId != null) {
      await ref.read(companyExpensesProvider.notifier).fetchFirstPage(companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(companyExpensesProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final canManage = company?.canManageWorkspace ?? false;

    final content = companyId == null
        ? AdminEmptyState(icon: Iconsax.money_2, title: l10n.expenses, subtitle: l10n.company_workspace_no_company)
        : state.isLoading && state.items.isEmpty
        ? AdminLoadingState(icon: Iconsax.money_2, message: l10n.loading)
        : state.error != null && state.items.isEmpty
        ? AdminErrorState(error: state.error!, onRetry: _load)
        : SingleChildScrollView(
            controller: _scrollController,
            padding: AppBreakpoints.pagePadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: AppBreakpoints.contentMaxWidth(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CompanySectionIntro(
                      title: l10n.expenses,
                      subtitle: l10n.section_label(l10n.expenses),
                      action: FilledButton.icon(
                        onPressed: canManage ? () => _openExpenseSheet(context, companyId) : null,
                        icon: const Icon(Iconsax.add_circle),
                        label: Text('${l10n.add} ${l10n.expenses}'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.items.isNotEmpty) _TotalCard(total: state.totalAmount),
                    const SizedBox(height: 16),
                    if (state.items.isEmpty)
                      AdminEmptyState(icon: Iconsax.money_2, title: l10n.expenses, subtitle: l10n.no_data_available)
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final expense = state.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _ExpenseCard(expense: expense, onDelete: canManage ? () => _deleteExpense(context, companyId, expense) : null),
                          );
                        },
                      ),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                  ],
                ),
              ),
            ),
          );

    if (widget.embedded) {
      return content;
    }

    return CompanyPageScaffold(child: content);
  }

  Future<void> _deleteExpense(BuildContext context, int companyId, CompanyExpense expense) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCompanyDeleteDialog(context: context, title: l10n.delete, message: l10n.company_expense_delete_message(expense.category));
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(companyExpensesProvider.notifier).deleteExpense(companyId, expense.id);
      if (!context.mounted) return;
      ToastService.success(context, l10n.success, l10n.delete);
    } catch (e) {
      if (!context.mounted) return;
      ToastService.error(context, l10n.error, e.toString());
    }
  }

  Future<void> _openExpenseSheet(BuildContext context, int companyId) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExpenseFormSheet(
        onSubmit: (payload) async {
          await ref.read(companyExpensesProvider.notifier).createExpense(companyId, payload);
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Text(
            l10n.amount,
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            total.toStringAsFixed(2),
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense, required this.onDelete});

  final CompanyExpense expense;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Iconsax.money_2, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  expense.category,
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                expense.amount.toStringAsFixed(2),
                style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Iconsax.trash, color: Colors.redAccent),
              ),
            ],
          ),
          if (expense.date != null) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.date}: ${expense.date!.year}-${expense.date!.month.toString().padLeft(2, '0')}-${expense.date!.day.toString().padLeft(2, '0')}',
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: Theme.of(context).hintColor),
            ),
          ],
          if ((expense.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              expense.description!,
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: Theme.of(context).hintColor),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseFormSheet extends StatefulWidget {
  const _ExpenseFormSheet({required this.onSubmit});

  final Future<void> Function(CompanyExpenseFormModel payload) onSubmit;

  @override
  State<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<_ExpenseFormSheet> {
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.amount),
                  validator: Validatorless.multiple([Validatorless.required(l10n.required_field), Validatorless.number(l10n.required_field)]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: l10n.category),
                  validator: Validatorless.required(l10n.required_field),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(_date.year - 5),
                      lastDate: DateTime(_date.year + 1),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: l10n.date),
                    child: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.description),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
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
                              Navigator.of(this.context).pop();
                            } finally {
                              if (mounted) setState(() => _isSubmitting = false);
                            }
                          },
                    child: Text(_isSubmitting ? l10n.loading : l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
