import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_cart.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:watt/src/features/storefront/presentation/screens/storefront_checkout_screen.dart';
import 'package:watt/src/utils/app_theme.dart';

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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StorefrontCheckoutScreen(
                      companyId: cart.companyId,
                      audience: cart.audience,
                    ),
                  ),
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

  void _remove() {
    storefrontCart.removeItem(
      audience: item.audience,
      companyId: item.companyId,
      productId: item.productId,
      selectedOptionIds: item.selectedOptionIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.decimalPattern();

    // Dismissible (swipe-to-remove) wraps the tile so removing an item is
    // discoverable both by swiping and via the explicit trash icon below —
    // the old UI only had a small "Remove" text link easy to miss.
    return Dismissible(
      key: ValueKey('${item.audience.name}_${item.companyId}_${item.productId}_${item.selectedOptionIds.join('-')}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: EdgeInsetsDirectional.only(end: 20.w),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
      ),
      onDismissed: (_) => _remove(),
      child: Padding(
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
              IconButton(
                onPressed: _remove,
                tooltip: l10n.remove,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
      ),
    );
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
