import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/accounting/domain/entities/accounting_models.dart';
import 'package:solar_hub/src/features/accounting/presentation/providers/accounting_providers.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/features/orders_core/presentation/widgets/order_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AccountingScreen extends ConsumerWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(authProvider).company?.id;
    final l10n = AppLocalizations.of(context)!;
    if (companyId == null) {
      return CompanyPageScaffold(
        child: Center(child: Text(l10n.no_company_workspace)),
      );
    }

    final dashboard = ref.watch(accountingDashboardProvider(companyId));
    final accounts = ref.watch(accountsProvider(companyId));
    final invoices = ref.watch(invoicesProvider(companyId));
    final bills = ref.watch(billsProvider(companyId));
    final payments = ref.watch(paymentsProvider(companyId));
    final journal = ref.watch(journalEntriesProvider(companyId));
    final receivables = ref.watch(receivablesProvider(companyId));
    final payables = ref.watch(payablesProvider(companyId));
    final transactions = ref.watch(transactionsProvider(companyId));

    return CompanyPageScaffold(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountingDashboardProvider(companyId));
          ref.invalidate(accountsProvider(companyId));
          ref.invalidate(invoicesProvider(companyId));
          ref.invalidate(billsProvider(companyId));
          ref.invalidate(paymentsProvider(companyId));
          ref.invalidate(journalEntriesProvider(companyId));
          ref.invalidate(receivablesProvider(companyId));
          ref.invalidate(payablesProvider(companyId));
          ref.invalidate(transactionsProvider(companyId));
        },
        child: ListView(
          padding: AppBreakpoints.pagePadding(context),
          children: [
            ResponsiveContent(
              child: dashboard.isLoading && dashboard.overview == null
                  ? const Center(child: CircularProgressIndicator())
                  : dashboard.error != null
                  ? AdminErrorState(
                      error: dashboard.error!,
                      onRetry: () => ref
                          .read(accountingDashboardProvider(companyId).notifier)
                          .fetch(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.accounting,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: 220,
                              child: MetricTile(
                                label: l10n.invoices,
                                value:
                                    '${dashboard.overview?.invoicesTotal ?? 0}',
                                icon: Iconsax.receipt_1_bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: MetricTile(
                                label: l10n.bills,
                                value: '${dashboard.overview?.billsTotal ?? 0}',
                                icon: Iconsax.receipt_text_bold,
                                color: AppTheme.accentColor,
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: MetricTile(
                                label: l10n.payments,
                                value:
                                    '${dashboard.overview?.paymentsTotal ?? 0}',
                                icon: Iconsax.money_recive_bold,
                                color: AppTheme.successColor,
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: MetricTile(
                                label: l10n.net_income,
                                value:
                                    dashboard.ledger?.netIncome.toStringAsFixed(
                                      2,
                                    ) ??
                                    '0.00',
                                icon: Iconsax.chart_2_bold,
                                color: AppTheme.warningColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _DataSection<AccountRecord>(
                          title: l10n.accounts,
                          asyncValue: accounts,
                          itemBuilder: (item) => '${item.code} • ${item.name}',
                        ),
                        _DataSection<InvoiceRecord>(
                          title: l10n.invoices,
                          asyncValue: invoices,
                          itemBuilder: (item) =>
                              '${item.invoiceNumber} • ${item.customer.name}',
                        ),
                        _DataSection<BillRecord>(
                          title: l10n.bills,
                          asyncValue: bills,
                          itemBuilder: (item) =>
                              '${item.billNumber} • ${item.supplier.name}',
                        ),
                        _DataSection<PaymentRecord>(
                          title: l10n.payments,
                          asyncValue: payments,
                          itemBuilder: (item) =>
                              '${item.paymentType} • ${item.amount.toStringAsFixed(2)}',
                        ),
                        _DataSection<JournalEntryRecord>(
                          title: l10n.journal_entries,
                          asyncValue: journal,
                          itemBuilder: (item) => item.description,
                        ),
                        _DataSection<ReceivableRecord>(
                          title: l10n.receivables,
                          asyncValue: receivables,
                          itemBuilder: (item) =>
                              '${item.customerName} • ${item.balanceDue.toStringAsFixed(2)}',
                        ),
                        _DataSection<PayableRecord>(
                          title: l10n.payables,
                          asyncValue: payables,
                          itemBuilder: (item) =>
                              '${item.supplierName} • ${item.balanceDue.toStringAsFixed(2)}',
                        ),
                        _DataSection<TransactionRecord>(
                          title: l10n.transactions,
                          asyncValue: transactions,
                          itemBuilder: (item) =>
                              '${item.type} • ${item.number}',
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataSection<T> extends StatelessWidget {
  final String title;
  final AsyncValue<dynamic> asyncValue;
  final String Function(T item) itemBuilder;

  const _DataSection({
    required this.title,
    required this.asyncValue,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: asyncValue.when(
        data: (data) {
          final items = (data.items as List).cast<T>();
          return SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Text(AppLocalizations.of(context)!.no_data_available)
                else
                  ...items
                      .take(4)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(itemBuilder(item)),
                        ),
                      ),
              ],
            ),
          );
        },
        error: (error, _) => SectionCard(child: Text(error.toString())),
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
