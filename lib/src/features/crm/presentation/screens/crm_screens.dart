import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/features/crm/presentation/providers/crm_providers.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/features/orders_core/presentation/widgets/order_widgets.dart';

class CompanyCustomersScreen extends ConsumerWidget {
  const CompanyCustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(authProvider).company?.id;
    final l10n = AppLocalizations.of(context)!;
    if (companyId == null) {
      return CompanyPageScaffold(
        child: Center(child: Text(l10n.no_company_workspace)),
      );
    }
    final state = ref.watch(customersProvider(companyId));
    return _CrmListPage<CustomerRecord>(
      title: l10n.customers,
      state: state,
      emptyTitle: l10n.no_customers_found,
      itemBuilder: (item) =>
          _personTile(context, item.fullName, item.phoneNumber, item.balance),
    );
  }
}

class CompanySuppliersScreen extends ConsumerWidget {
  const CompanySuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(authProvider).company?.id;
    final l10n = AppLocalizations.of(context)!;
    if (companyId == null) {
      return CompanyPageScaffold(
        child: Center(child: Text(l10n.no_company_workspace)),
      );
    }
    final state = ref.watch(suppliersProvider(companyId));
    return _CrmListPage<SupplierRecord>(
      title: l10n.suppliers,
      state: state,
      emptyTitle: l10n.no_suppliers_found,
      itemBuilder: (item) =>
          _personTile(context, item.fullName, item.phoneNumber, item.balance),
    );
  }
}

class _CrmListPage<T> extends StatelessWidget {
  final String title;
  final CrmState<T> state;
  final String emptyTitle;
  final Widget Function(T item) itemBuilder;

  const _CrmListPage({
    required this.title,
    required this.state,
    required this.emptyTitle,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CompanyPageScaffold(
      child: ListView(
        padding: AppBreakpoints.pagePadding(context),
        children: [
          ResponsiveContent(
            child: state.isLoading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.items.isEmpty
                ? AdminErrorState(error: state.error!, onRetry: () {})
                : state.items.isEmpty
                ? AdminEmptyState(icon: Icons.people_outline, title: emptyTitle)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ...state.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: itemBuilder(item),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _personTile(
  BuildContext context,
  String title,
  String? phone,
  double balance,
) {
  return SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        if (phone != null) ...[
          const SizedBox(height: 6),
          Text(phone, style: TextStyle(color: Theme.of(context).hintColor)),
        ],
        const SizedBox(height: 8),
        Text(
          'Balance: ${balance.toStringAsFixed(2)}',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      ],
    ),
  );
}
