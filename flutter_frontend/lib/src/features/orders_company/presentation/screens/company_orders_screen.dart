import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/layout/app_breakpoints.dart';
import 'package:watt/src/core/widgets/status_badge.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:watt/src/features/orders_buyer/presentation/providers/orders_providers.dart';
import 'package:watt/src/features/orders_core/domain/entities/order_queries.dart';
import 'package:watt/src/features/orders_core/presentation/widgets/order_widgets.dart';

class CompanyOrdersScreen extends ConsumerWidget {
  final bool embedded;
  const CompanyOrdersScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(authProvider).company?.id;
    final l10n = AppLocalizations.of(context)!;
    if (companyId == null) {
      if (embedded) return Center(child: Text(l10n.no_company_workspace));
      return CompanyPageScaffold(
        child: Center(child: Text(l10n.no_company_workspace)),
      );
    }
    final state = ref.watch(companyOrdersProvider(companyId));

    final content = RefreshIndicator(
      onRefresh: () =>
          ref.read(companyOrdersProvider(companyId).notifier).fetchOrders(),
      child: ListView(
        padding: AppBreakpoints.pagePadding(context),
        children: [
          ResponsiveContent(
            child: state.isLoading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.items.isEmpty
                ? AdminErrorState(
                    error: state.error!,
                    onRetry: () => ref
                        .read(companyOrdersProvider(companyId).notifier)
                        .fetchOrders(),
                  )
                : state.items.isEmpty
                ? AdminEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.no_orders_found,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orders,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      // Quick status shortcuts, color-coded to match the
                      // OrderStatusBadge used everywhere else. A true
                      // "N pending / N processing" stats header would need
                      // a backend aggregate-count endpoint that doesn't
                      // exist yet, so this gives fast one-tap filtering
                      // instead of a (potentially misleading, page-scoped)
                      // count.
                      _QuickStatusFilterRow(
                        selected: state.query.status,
                        onSelected: (status) => ref
                            .read(companyOrdersProvider(companyId).notifier)
                            .updateFilters(state.query.copyWith(
                              page: 1,
                              status: status,
                              clearStatus: status == null,
                            )),
                      ),
                      const SizedBox(height: 12),
                      _CompanyOrderFilters(
                        state: state,
                        onChanged: (query) => ref
                            .read(companyOrdersProvider(companyId).notifier)
                            .updateFilters(query),
                      ),
                      const SizedBox(height: 16),
                      ...state.items.map(
                        (order) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrderListTile(
                            order: order,
                            onTap: () => context.push(
                              '/companies/dashboard/orders/${order.id}',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );

    if (embedded) {
      return content;
    }

    return CompanyPageScaffold(
      child: content,
    );
  }
}

class _QuickStatusFilterRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _QuickStatusFilterRow({required this.selected, required this.onSelected});

  static const _statuses = <String>['pending', 'processing', 'shipped', 'delivered', 'cancelled', 'completed'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _statuses.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: Text(l10n.all),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            );
          }
          final status = _statuses[index - 1];
          final isSelected = selected == status;
          return GestureDetector(
            onTap: () => onSelected(status),
            child: Opacity(
              opacity: isSelected ? 1 : 0.55,
              child: OrderStatusBadge(status: status, compact: true),
            ),
          );
        },
      ),
    );
  }
}

class _CompanyOrderFilters extends StatefulWidget {
  final OrdersListState state;
  final ValueChanged<OrderListQuery> onChanged;

  const _CompanyOrderFilters({required this.state, required this.onChanged});

  @override
  State<_CompanyOrderFilters> createState() => _CompanyOrderFiltersState();
}

class _CompanyOrderFiltersState extends State<_CompanyOrderFilters> {
  late final TextEditingController _searchController;
  late String? _status;
  late String? _paymentStatus;
  late String? _paymentMethod;

  static const _statuses = <String>[
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'completed',
  ];

  static const _paymentStatuses = <String>[
    'paid',
    'unpaid',
    'partial',
    'refunded',
  ];
  static const _paymentMethods = <String>[
    'cash',
    'credit',
    'payment_upon_receipt',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.state.query.search ?? '',
    );
    _status = widget.state.query.status;
    _paymentStatus = widget.state.query.paymentStatus;
    _paymentMethod = widget.state.query.paymentMethod;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SectionCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final children = [
            _dropdownField(
              context,
              label: l10n.status,
              value: _status,
              items: _statuses,
              onChanged: (value) {
                setState(() => _status = value);
                _emit();
              },
            ),
            _dropdownField(
              context,
              label: l10n.payment_status,
              value: _paymentStatus,
              items: _paymentStatuses,
              onChanged: (value) {
                setState(() => _paymentStatus = value);
                _emit();
              },
            ),
            _dropdownField(
              context,
              label: l10n.payment_method,
              value: _paymentMethod,
              items: _paymentMethods,
              onChanged: (value) {
                setState(() => _paymentMethod = value);
                _emit();
              },
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.search_products,
                prefixIcon: const Icon(Icons.search),
              ),
              onSubmitted: (_) => _emit(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _status = null;
                    _paymentStatus = null;
                    _paymentMethod = null;
                    _searchController.clear();
                  });
                  widget.onChanged(const OrderListQuery());
                },
                child: Text(l10n.clear_filters),
              ),
            ),
          ];

          if (isWide) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: children
                  .map((child) => SizedBox(width: 220, child: child))
                  .toList(),
            );
          }

          return Column(
            children: [
              for (final child in children) ...[
                child,
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _dropdownField(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(AppLocalizations.of(context)!.all),
        ),
        ...items.map(
          (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
        ),
      ],
      onChanged: onChanged,
    );
  }

  void _emit() {
    widget.onChanged(
      widget.state.query.copyWith(
        page: 1,
        status: _status,
        paymentStatus: _paymentStatus,
        paymentMethod: _paymentMethod,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        clearStatus: _status == null,
        clearPaymentStatus: _paymentStatus == null,
        clearPaymentMethod: _paymentMethod == null,
        clearSearch: _searchController.text.trim().isEmpty,
      ),
    );
  }
}
