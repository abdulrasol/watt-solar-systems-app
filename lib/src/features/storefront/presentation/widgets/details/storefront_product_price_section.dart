import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_cart.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

class StorefrontProductPriceSection extends StatelessWidget {
  final StorefrontProduct product;
  final int quantity;
  final double baseUnitPrice;
  final double optionsUnitPrice;
  final double effectiveUnitPrice;
  final double lineTotal;
  final bool canViewB2bDetails;
  final StorefrontCartItemPricingTier? appliedTier;

  const StorefrontProductPriceSection({
    super.key,
    required this.product,
    required this.quantity,
    required this.baseUnitPrice,
    required this.optionsUnitPrice,
    required this.effectiveUnitPrice,
    required this.lineTotal,
    required this.canViewB2bDetails,
    required this.appliedTier,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.decimalPattern();

    return _CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.price_overview,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12.h),
          if (canViewB2bDetails) ...[
            _DetailRow(
              label: l10n.base_unit_price,
              value: l10n.iqd_price(money.format(baseUnitPrice)),
            ),
            _DetailRow(
              label: l10n.options_total,
              value: l10n.iqd_price(money.format(optionsUnitPrice)),
            ),
            _DetailRow(
              label: l10n.effective_unit_price,
              value: l10n.iqd_price(money.format(effectiveUnitPrice)),
            ),
            if (appliedTier != null)
              _DetailRow(
                label: l10n.applied_pricing_tier,
                value: l10n.pricing_tier_line(
                  appliedTier!.quantity,
                  money.format(appliedTier!.unitPrice),
                ),
              ),
          ] else ...[
            _DetailRow(
              label: l10n.unit_price,
              value: l10n.iqd_price(money.format(effectiveUnitPrice)),
            ),
          ],
          _DetailRow(
            label: l10n.line_total,
            value: l10n.iqd_price(money.format(lineTotal)),
          ),
          if ((product.sku ?? '').isNotEmpty)
            _DetailRow(label: l10n.sku, value: product.sku!),
          _DetailRow(label: l10n.quantity, value: '$quantity'),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final Widget child;

  const _CardSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: child,
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
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
