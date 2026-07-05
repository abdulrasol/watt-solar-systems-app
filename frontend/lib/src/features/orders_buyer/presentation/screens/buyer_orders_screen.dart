import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/orders_buyer/presentation/providers/orders_providers.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/features/orders_core/presentation/widgets/order_widgets.dart';

class BuyerOrdersScreen extends ConsumerWidget {
  final OrderAudience audience;

  const BuyerOrdersScreen({super.key, required this.audience});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(buyerOrdersProvider(audience));
    final notifier = ref.read(buyerOrdersProvider(audience).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          audience == OrderAudience.b2b ? l10n.b2b_orders : l10n.b2c_orders,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.fetchOrders,
        child: state.isLoading && state.items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null && state.items.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: 160),
                  AdminErrorState(
                    error: state.error!,
                    onRetry: notifier.fetchOrders,
                  ),
                ],
              )
            : state.items.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: 160),
                  AdminEmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: l10n.no_orders_found,
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = state.items[index];
                  return OrderListTile(
                    order: order,
                    onTap: () => context.push(
                      '/storefront/${audience.name}/orders/${order.id}',
                    ),
                  );
                },
              ),
      ),
    );
  }
}
