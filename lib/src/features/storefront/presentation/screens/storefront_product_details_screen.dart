import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_cart_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_page_route.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_cart_button.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontProductDetailsScreen extends StatefulWidget {
  final StorefrontProduct product;
  final StorefrontAudience audience;

  const StorefrontProductDetailsScreen({
    super.key,
    required this.product,
    required this.audience,
  });

  @override
  State<StorefrontProductDetailsScreen> createState() =>
      _StorefrontProductDetailsScreenState();
}

class _StorefrontProductDetailsScreenState
    extends State<StorefrontProductDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.decimalPattern();
    final heroTag =
        '${widget.audience.name}_${widget.product.company.id}_${widget.product.id}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.product_details),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12.w),
            child: StorefrontCartButton(
              audience: widget.audience,
              onPressed: () {
                Navigator.of(context).push(
                  buildStorefrontRoute(
                    context: context,
                    page: StorefrontCartScreen(audience: widget.audience),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                height: 260.h,
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                child: widget.product.primaryImage == null
                    ? const Icon(Icons.image_outlined, size: 48)
                    : CachedNetworkImage(
                        imageUrl: widget.product.primaryImage!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            widget.product.name,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.product.company.name,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _InfoChip(
                label: widget.product.isAvailable
                    ? l10n.available
                    : l10n.unavailable,
              ),
              if (widget.product.categoryLabel.isNotEmpty)
                _InfoChip(label: widget.product.categoryLabel),
              _InfoChip(label: l10n.stock_count(widget.product.stockQuantity)),
            ],
          ),
          SizedBox(height: 20.h),
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
                  l10n.price_overview,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12.h),
                _DetailRow(
                  label: l10n.display_price,
                  value: l10n.iqd_price(
                    money.format(widget.product.displayPrice),
                  ),
                ),
                _DetailRow(
                  label: l10n.retail_price,
                  value: l10n.iqd_price(
                    money.format(widget.product.retailPrice),
                  ),
                ),
                _DetailRow(
                  label: l10n.wholesale_price,
                  value: l10n.iqd_price(
                    money.format(widget.product.wholesalePrice),
                  ),
                ),
                if ((widget.product.sku ?? '').isNotEmpty)
                  _DetailRow(label: l10n.sku, value: widget.product.sku!),
              ],
            ),
          ),
          if ((widget.product.description ?? '').trim().isNotEmpty) ...[
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
                    l10n.description,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    widget.product.description!,
                    style: TextStyle(height: 1.6, fontSize: 13.sp),
                  ),
                ],
              ),
            ),
          ],
          if (widget.product.pricingTiers.isNotEmpty) ...[
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
                    l10n.pricing_tiers,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...widget.product.pricingTiers.map(
                    (tier) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        l10n.pricing_tier_line(
                          tier.quantity,
                          money.format(tier.unitPrice),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Text(
                  l10n.quantity,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.sp,
                  ),
                ),
                const Spacer(),
                _QtyControl(
                  icon: Icons.remove,
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity -= 1);
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Text(
                    '$_quantity',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                _QtyControl(
                  icon: Icons.add,
                  onTap: () => setState(() => _quantity += 1),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.all(16.r),
        child: ElevatedButton.icon(
          onPressed: () async {
            await storefrontCart.addProduct(
              widget.product,
              audience: widget.audience,
              quantity: _quantity,
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.added_to_cart)));
          },
          icon: const Icon(Icons.add_shopping_cart_rounded),
          label: Text(l10n.add_to_cart),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

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

class _QtyControl extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyControl({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 18.sp),
      ),
    );
  }
}
