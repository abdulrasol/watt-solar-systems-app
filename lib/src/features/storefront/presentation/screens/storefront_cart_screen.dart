import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/orders_buyer/domain/repositories/orders_repository.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/features/services/domain/repositories/public_services_repository.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_cart.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontCartScreen extends StatelessWidget {
  final StorefrontAudience audience;

  const StorefrontCartScreen({super.key, required this.audience});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cart)),
      body: ListenableBuilder(
        listenable: storefrontCart,
        builder: (context, _) {
          final carts = storefrontCart.allCarts();

          if (carts.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 56.sp),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.cart_empty,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(l10n.cart_empty_subtitle, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          final totalAmount = storefrontCart.totalAmountAll();
          final totalItems = storefrontCart.totalItemsAll();
          final money = NumberFormat.decimalPattern();

          return ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              ...carts.map((cart) => _CompanyCartCard(cart: cart)),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cart_summary,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _SummaryRow(label: l10n.total_items, value: '$totalItems'),
                    _SummaryRow(
                      label: l10n.total_amount,
                      value: l10n.iqd_price(money.format(totalAmount)),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () =>
                          context.push('/storefront/${audience.name}/orders'),
                      child: Text(l10n.my_orders),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompanyCartCard extends StatelessWidget {
  final StorefrontCompanyCart cart;

  const _CompanyCartCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.decimalPattern();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cart.companyName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${cart.audience == StorefrontAudience.b2b ? l10n.b2b_cart : l10n.b2c_cart} • ${l10n.cart_items_count(cart.totalItems)}',
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  storefrontCart.clearCompanyCart(
                    audience: cart.audience,
                    companyId: cart.companyId,
                  );
                },
                child: Text(l10n.clear_cart),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...cart.items.map((item) => _CartItemTile(item: item)),
          Divider(height: 24.h),
          _SummaryRow(
            label: l10n.subtotal,
            value: l10n.iqd_price(money.format(cart.subtotal)),
          ),
          if (cart.deliveryMethod != null)
            _SummaryRow(
              label: l10n.shipping_method,
              value: cart.deliveryMethod!,
            ),
          if (cart.deliveryCost > 0)
            _SummaryRow(
              label: l10n.delivery,
              value: l10n.iqd_price(money.format(cart.deliveryCost)),
            ),
          _SummaryRow(
            label: l10n.total_amount,
            value: l10n.iqd_price(money.format(cart.totalAmount)),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => _CheckoutSheet(cart: cart),
                );
              },
              child: Text(l10n.place_order),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final StorefrontCartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.decimalPattern();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              width: 70.r,
              height: 70.r,
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              child: item.imageUrl == null
                  ? const Icon(Icons.image_outlined)
                  : CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.selectedOptions.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item.selectedOptions
                        .map((option) => option.name)
                        .join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
                Text(
                  l10n.iqd_price(money.format(item.effectiveUnitPrice)),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (item.appliedTier != null)
                  Text(
                    l10n.pricing_tier_line(
                      item.appliedTier!.quantity,
                      money.format(item.appliedTier!.unitPrice),
                    ),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () {
                      storefrontCart.updateQuantity(
                        audience: item.audience,
                        companyId: item.companyId,
                        productId: item.productId,
                        quantity: item.quantity - 1,
                        selectedOptionIds: item.selectedOptionIds,
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () {
                      storefrontCart.updateQuantity(
                        audience: item.audience,
                        companyId: item.companyId,
                        productId: item.productId,
                        quantity: item.quantity + 1,
                        selectedOptionIds: item.selectedOptionIds,
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.iqd_price(money.format(item.lineTotal)),
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4.h),
              TextButton(
                onPressed: () {
                  storefrontCart.removeItem(
                    audience: item.audience,
                    companyId: item.companyId,
                    productId: item.productId,
                    selectedOptionIds: item.selectedOptionIds,
                  );
                },
                child: Text(l10n.remove),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  final StorefrontCompanyCart cart;

  const _CheckoutSheet({required this.cart});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  late String _paymentMethod;
  String? _deliveryMethod;
  int? _deliveryOptionId;
  double _deliveryCost = 0;
  bool _submitting = false;

  static const _paymentMethods = <String>[
    'cash',
    'credit',
    'payment_upon_receipt',
  ];

  @override
  void initState() {
    super.initState();
    _paymentMethod = widget.cart.paymentMethod;
    _deliveryMethod = widget.cart.deliveryMethod;
    _deliveryOptionId = widget.cart.deliveryOptionId;
    _deliveryCost = widget.cart.deliveryCost;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          20.h + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FutureBuilder<Company>(
          future: getIt<PublicServicesRepository>().getCompanyDetails(
            widget.cart.companyId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Text(
                snapshot.error?.toString() ?? l10n.error_loading_data,
              );
            }

            final company = snapshot.data!;
            final deliveryOptions = company.deliveryOptions
                .where((option) => option.isActive)
                .toList();
            final money = NumberFormat.decimalPattern();

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cart.companyName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.cart.audience == StorefrontAudience.b2b
                        ? l10n.b2b_cart
                        : l10n.b2c_cart,
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    decoration: InputDecoration(labelText: l10n.payment_method),
                    items: _paymentMethods
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(_paymentLabel(l10n, method)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _paymentMethod = value);
                    },
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String?>(
                    initialValue: _deliveryMethod,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.shipping_method,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.no_delivery_selected),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'pickup',
                        child: Text(l10n.pickup_from_company),
                      ),
                      ...deliveryOptions.map(
                        (option) => DropdownMenuItem<String?>(
                          value: option.name,
                          child: Text(
                            option.cost == null
                                ? option.name
                                : '${option.name} • ${money.format(option.cost)}',
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _deliveryMethod = value;
                        if (value == null) {
                          _deliveryOptionId = null;
                          _deliveryCost = 0;
                        } else if (value == 'pickup') {
                          _deliveryOptionId = null;
                          _deliveryCost = 0;
                        } else {
                          final selected = deliveryOptions.firstWhere(
                            (option) => option.name == value,
                          );
                          _deliveryOptionId = selected.id;
                          _deliveryCost = selected.cost?.toDouble() ?? 0;
                        }
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  _SummaryRow(
                    label: l10n.subtotal,
                    value: l10n.iqd_price(money.format(widget.cart.subtotal)),
                  ),
                  _SummaryRow(
                    label: l10n.delivery,
                    value: l10n.iqd_price(money.format(_deliveryCost)),
                  ),
                  _SummaryRow(
                    label: l10n.total_amount,
                    value: l10n.iqd_price(
                      money.format(widget.cart.subtotal + _deliveryCost),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : () async {
                              final navigator = Navigator.of(context);
                              final router = GoRouter.of(context);
                              setState(() => _submitting = true);
                              await storefrontCart.updateCompanyCartConfig(
                                audience: widget.cart.audience,
                                companyId: widget.cart.companyId,
                                paymentMethod: _paymentMethod,
                                deliveryMethod: _deliveryMethod,
                                clearDeliveryMethod: _deliveryMethod == null,
                                deliveryOptionId: _deliveryOptionId,
                                clearDeliveryOptionId:
                                    _deliveryOptionId == null,
                                deliveryCost: _deliveryCost,
                              );

                              final latestCart = storefrontCart.cartForCompany(
                                audience: widget.cart.audience,
                                companyId: widget.cart.companyId,
                              );
                              if (latestCart == null) {
                                if (!mounted) return;
                                navigator.pop();
                                return;
                              }

                              try {
                                final repository = getIt<OrdersRepository>();
                                final order =
                                    widget.cart.audience ==
                                        StorefrontAudience.b2b
                                    ? await repository.createB2bOrder(
                                        B2bOrderCreateRequest.fromCompanyCart(
                                          latestCart,
                                        ),
                                      )
                                    : await repository.createB2cOrder(
                                        B2cOrderCreateRequest.fromCompanyCart(
                                          latestCart,
                                        ),
                                      );

                                await storefrontCart.clearCompanyCart(
                                  audience: widget.cart.audience,
                                  companyId: widget.cart.companyId,
                                );

                                if (!context.mounted) return;
                                navigator.pop();
                                router.push(
                                  '/storefront/order-result',
                                  extra: order,
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _submitting = false);
                                }
                              }
                            },
                      child: Text(l10n.place_order),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _paymentLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'cash':
        return l10n.payment_cash;
      case 'credit':
        return l10n.payment_credit;
      case 'payment_upon_receipt':
        return l10n.payment_upon_receipt;
      default:
        return value;
    }
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 16.sp),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
