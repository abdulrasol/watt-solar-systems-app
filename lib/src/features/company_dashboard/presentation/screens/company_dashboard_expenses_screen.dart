import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_expenses_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/expenses/expense_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/expenses/expense_total_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/forms/expense_form_sheet.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/shared/domain/company/company_expense.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

/// Company expenses management screen.
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
    final colors = ref.watch(appColorsProvider);
    final state = ref.watch(companyExpensesProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final canManage = company?.canManageWorkspace ?? false;

    if (companyId == null) {
      return AdminEmptyState(icon: Iconsax.money_2, title: l10n.expenses, subtitle: l10n.company_workspace_no_company);
    }

    if (state.isLoading && state.items.isEmpty) {
      return AdminLoadingState(icon: Iconsax.money_2, message: l10n.loading);
    }

    if (state.error != null && state.items.isEmpty) {
      if (isServiceUnavailableForCompanyType(state.error)) {
        return AppServiceUnavailableState(
          serviceName: l10n.expenses,
        );
      }
      return AdminErrorState(error: state.error!, onRetry: _load);
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: _load,
      notificationPredicate: (notification) => notification.depth == 0,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppBreakpoints.pagePadding(context).copyWith(bottom: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppBreakpoints.contentMaxWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompanySectionIntro(
                  title: l10n.expenses,
                  subtitle: l10n.section_label(l10n.expenses),
                  action: AppButton(
                    text: '${l10n.add} ${l10n.expenses}',
                    icon: Iconsax.add_circle,
                    onPressed: canManage ? () => _openExpenseSheet(context, companyId) : null,
                    width: null,
                  ),
                ),
                const SizedBox(height: 16),
                if (state.items.isNotEmpty) ExpenseTotalCard(total: state.totalAmount),
                const SizedBox(height: 16),
                if (state.items.isEmpty)
                  AppEmptyState(
                    icon: Iconsax.money_2,
                    title: l10n.expenses,
                    subtitle: l10n.no_data_available,
                    actionTitle: canManage ? '${l10n.add} ${l10n.expenses}' : null,
                    onActionPressed: canManage ? () => _openExpenseSheet(context, companyId) : null,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final expense = state.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ExpenseCard(
                          expense: expense,
                          onDelete: canManage ? () => _deleteExpense(context, companyId, expense) : null,
                        ),
                      );
                    },
                  ),
                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: AppLoadingIndicator(size: 24)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteExpense(BuildContext context, int companyId, CompanyExpense expense) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCompanyDeleteDialog(
      context: context,
      title: l10n.delete,
      message: l10n.company_expense_delete_message(expense.category),
    );
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
      builder: (context) => ExpenseFormSheet(
        onSubmit: (payload) async {
          await ref.read(companyExpensesProvider.notifier).createExpense(companyId, payload);
        },
      ),
    );
  }
}
