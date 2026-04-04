import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
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
      appBar: AppBar(
        title: Text(
          audience == StorefrontAudience.b2b ? l10n.b2b_cart : l10n.b2c_cart,
        ),
      ),
      body: ListenableBuilder(
        listenable: storefrontCart,
        builder: (context, _) {
          final carts = storefrontCart.cartsForAudience(audience);

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

          final totalAmount = storefrontCart.totalAmount(audience);
          final totalItems = storefrontCart.totalItems(audience);
          final money = NumberFormat.decimalPattern();

          return ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              ...carts.map(
                (cart) => _CompanyCartCard(cart: cart, audience: audience),
              ),
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
  final StorefrontAudience audience;

  const _CompanyCartCard({required this.cart, required this.audience});

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
                    Text(l10n.cart_items_count(cart.totalItems)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  storefrontCart.clearCompanyCart(
                    audience: audience,
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
            value: l10n.iqd_price(money.format(cart.totalAmount)),
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
                SizedBox(height: 4.h),
                Text(
                  l10n.iqd_price(money.format(item.unitPrice)),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w800,
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
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () {
                  storefrontCart.removeItem(
                    audience: item.audience,
                    companyId: item.companyId,
                    productId: item.productId,
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
