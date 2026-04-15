import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/orders_buyer/presentation/providers/orders_providers.dart';
import 'package:solar_hub/src/features/orders_company/presentation/utils/company_order_permissions.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/features/orders_core/presentation/widgets/order_widgets.dart';

class OrderDetailScreen extends ConsumerWidget {
  final OrderAudience? audience;
  final int orderId;
  final int? companyId;
  final bool sellerView;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.audience,
    this.companyId,
    this.sellerView = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncValue = sellerView
        ? ref.watch(
            companyOrderDetailProvider((
              companyId: companyId!,
              orderId: orderId,
            )),
          )
        : ref.watch(
            buyerOrderDetailProvider((audience: audience!, orderId: orderId)),
          );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.order_details)),
      body: asyncValue.when(
        data: (order) => _OrderDetailBody(
          order: order,
          audience: audience,
          sellerView: sellerView,
        ),
        error: (error, _) => Center(
          child: AdminErrorState(
            error: error.toString(),
            onRetry: () => ref.invalidate(
              sellerView
                  ? companyOrderDetailProvider((
                      companyId: companyId!,
                      orderId: orderId,
                    ))
                  : buyerOrderDetailProvider((
                      audience: audience!,
                      orderId: orderId,
                    )),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  final OrderRecord order;
  final OrderAudience? audience;
  final bool sellerView;

  const _OrderDetailBody({
    required this.order,
    required this.audience,
    required this.sellerView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final amount = NumberFormat.decimalPattern().format(order.totalAmount);
    final company = ref.watch(authProvider).company;
    final permissions = CompanyOrderPermissions.fromCompany(company);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ResponsiveContent(
          child: Column(
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '#${order.orderNumber}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (sellerView && permissions.canChangeOrderStatus)
                          _StatusUpdateMenu(
                            order: order,
                            canEditOrderDetails:
                                permissions.canEditOrderDetails,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    KeyValueRow(label: l10n.status, value: order.status),
                    KeyValueRow(
                      label: l10n.payment_status,
                      value: order.paymentStatus,
                    ),
                    KeyValueRow(
                      label: l10n.payment_method,
                      value: order.paymentMethod,
                    ),
                    KeyValueRow(
                      label: l10n.total_amount,
                      value: l10n.iqd_price(amount),
                    ),
                    if (order.fulfilledAt != null)
                      KeyValueRow(
                        label: l10n.fulfilled_at,
                        value: DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).format(order.fulfilledAt!),
                      ),
                  ],
                ),
              ),
              if (sellerView && permissions.canEditOrderDetails) ...[
                const SizedBox(height: 16),
                _SellerEditCard(order: order),
              ],
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.items,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.productName)),
                            Text(
                              '${item.quantity} × ${item.unitPrice.toStringAsFixed(0)}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.parties,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    KeyValueRow(
                      label: l10n.seller,
                      value: order.sellerParty.name,
                    ),
                    KeyValueRow(
                      label: l10n.buyer,
                      value: order.buyerParty.name,
                    ),
                    if (order.customer != null)
                      KeyValueRow(
                        label: l10n.customer,
                        value: order.customer!.fullName,
                      ),
                    if (order.supplier != null)
                      KeyValueRow(
                        label: l10n.supplier,
                        value: order.supplier!.fullName,
                      ),
                  ],
                ),
              ),
              if (!sellerView &&
                  order.canConfirmReceipt &&
                  audience == OrderAudience.b2b) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final updated = await ref
                          .read(buyerOrdersProvider(OrderAudience.b2b).notifier)
                          .confirmReceipt(order.id);
                      if (updated != null && context.mounted) {
                        ref.invalidate(
                          buyerOrderDetailProvider((
                            audience: OrderAudience.b2b,
                            orderId: order.id,
                          )),
                        );
                      }
                    },
                    child: Text(l10n.confirm_receipt),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusUpdateMenu extends ConsumerWidget {
  final OrderRecord order;
  final bool canEditOrderDetails;

  const _StatusUpdateMenu({
    required this.order,
    required this.canEditOrderDetails,
  });

  static const _statuses = <String>[
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'completed',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(authProvider).company?.id;
    if (companyId == null) return const SizedBox.shrink();

    return DropdownButton<String>(
      value: order.status,
      items: _statuses
          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
          .toList(),
      onChanged: (value) async {
        if (value == null || value == order.status) return;
        final request = SellerOrderUpdateRequest(status: value);
        final updated = await ref
            .read(companyOrdersProvider(companyId).notifier)
            .updateOrder(order.id, request);
        if (updated != null) {
          ref.invalidate(
            companyOrderDetailProvider((
              companyId: companyId,
              orderId: order.id,
            )),
          );
        }
      },
    );
  }
}

class _SellerEditCard extends ConsumerStatefulWidget {
  final OrderRecord order;

  const _SellerEditCard({required this.order});

  @override
  ConsumerState<_SellerEditCard> createState() => _SellerEditCardState();
}

class _SellerEditCardState extends ConsumerState<_SellerEditCard> {
  late final TextEditingController _shippingCostController;
  late final TextEditingController _shippingMethodController;
  late final TextEditingController _paidAmountController;
  late final TextEditingController _cancellationReasonController;

  @override
  void initState() {
    super.initState();
    _shippingCostController = TextEditingController(
      text: widget.order.shippingCost.toString(),
    );
    _shippingMethodController = TextEditingController(
      text: widget.order.shippingMethod ?? '',
    );
    _paidAmountController = TextEditingController(
      text: widget.order.paidAmount.toString(),
    );
    _cancellationReasonController = TextEditingController(
      text: widget.order.cancellationReason ?? '',
    );
  }

  @override
  void dispose() {
    _shippingCostController.dispose();
    _shippingMethodController.dispose();
    _paidAmountController.dispose();
    _cancellationReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final companyId = ref.watch(authProvider).company?.id;
    if (companyId == null) return const SizedBox.shrink();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.edit_order_details,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _shippingCostController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.shipping_cost),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _shippingMethodController,
            decoration: InputDecoration(labelText: l10n.shipping_method),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _paidAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.paid_amount),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cancellationReasonController,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.cancellation_reason),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final updated = await ref
                    .read(companyOrdersProvider(companyId).notifier)
                    .updateOrder(
                      widget.order.id,
                      SellerOrderUpdateRequest(
                        status: widget.order.status,
                        shippingCost: double.tryParse(
                          _shippingCostController.text.trim(),
                        ),
                        shippingMethod:
                            _shippingMethodController.text.trim().isEmpty
                            ? null
                            : _shippingMethodController.text.trim(),
                        paidAmount: double.tryParse(
                          _paidAmountController.text.trim(),
                        ),
                        cancellationReason:
                            _cancellationReasonController.text.trim().isEmpty
                            ? null
                            : _cancellationReasonController.text.trim(),
                        shippingAddress: widget.order.shippingAddress,
                      ),
                    );
                if (updated != null) {
                  ref.invalidate(
                    companyOrderDetailProvider((
                      companyId: companyId,
                      orderId: widget.order.id,
                    )),
                  );
                }
              },
              child: Text(l10n.save_changes),
            ),
          ),
        ],
      ),
    );
  }
}
