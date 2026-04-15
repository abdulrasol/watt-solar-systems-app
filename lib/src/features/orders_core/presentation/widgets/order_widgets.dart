import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ResponsiveContent extends StatelessWidget {
  final Widget child;

  const ResponsiveContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppBreakpoints.contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: child,
    );
  }
}

class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderListTile extends StatelessWidget {
  final OrderRecord order;
  final VoidCallback? onTap;

  const OrderListTile({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.decimalPattern();
    final amount = order.currencySymbol?.isNotEmpty == true
        ? '${order.currencySymbol} ${money.format(order.totalAmount)}'
        : l10n.iqd_price(money.format(order.totalAmount));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: SectionCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.orderNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.sp,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${order.sellerParty.name} • ${order.buyerParty.name}',
                    style: TextStyle(color: Theme.of(context).hintColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _pill(context, order.orderType.toUpperCase()),
                      _pill(context, order.status),
                      _pill(context, order.paymentMethod),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  DateFormat(
                    'yyyy-MM-dd',
                  ).format(order.createdAt ?? DateTime.now()),
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;

  const KeyValueRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
