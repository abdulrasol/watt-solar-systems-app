import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/src/core/widgets/status_badge.dart';

class StorefrontProductInfoSection extends StatelessWidget {
  final String companyName;
  final String? categoryLabel;
  final int stockQuantity;
  final int minStockAlert;

  const StorefrontProductInfoSection({
    super.key,
    required this.companyName,
    required this.categoryLabel,
    required this.stockQuantity,
    required this.minStockAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _InfoChip(label: companyName),
        // Replaces the old plain available/unavailable boolean chip with the
        // shared stock-status badge, so buyers see in-stock/low-stock/out-of-
        // stock instead of a flat available/unavailable label.
        StockStatusBadge(stockQuantity: stockQuantity, minStockAlert: minStockAlert),
        if ((categoryLabel ?? '').isNotEmpty) _InfoChip(label: categoryLabel!),
      ],
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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp),
      ),
    );
  }
}
