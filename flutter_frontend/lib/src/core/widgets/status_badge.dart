import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/theme/app_colors.dart';

/// Resolves the semantic [AppColors] for the current theme brightness.
///
/// Mirrors the brightness-check pattern already used by `SectionCard`
/// (orders_core/presentation/widgets/order_widgets.dart) instead of reading
/// `appColorsProvider`, so this widget works from both `StatelessWidget` and
/// `ConsumerWidget` call sites without forcing a Riverpod dependency here.
AppColors _resolveAppColors(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.dark() : AppColors.light();
}

/// Small colored pill used to visualize an order's lifecycle stage.
///
/// Accepts the raw backend status string (e.g. `pending`, `processing`,
/// `shipped`, `delivered`, `cancelled`, `completed`) and maps it to both a
/// localized label and a semantic color, so every screen that lists orders
/// (buyer orders, company orders, order detail) renders the same visual
/// language instead of a plain text pill.
class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const OrderStatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = _resolveAppColors(context);
    final styleKey = status.toLowerCase();
    final Color color = switch (styleKey) {
      'pending' => colors.orderPending,
      'processing' => colors.orderProcessing,
      'shipped' => colors.orderShipped,
      'delivered' => colors.orderDelivered,
      'cancelled' => colors.orderCancelled,
      'completed' => colors.orderCompleted,
      _ => colors.orderPending,
    };
    final label = switch (styleKey) {
      'pending' => l10n.status_pending,
      'processing' => l10n.status_processing,
      'shipped' => l10n.status_shipped,
      'delivered' => l10n.status_delivered,
      'cancelled' => l10n.status_cancelled,
      'completed' => l10n.status_completed,
      _ => status,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8.w : 10.w, vertical: compact ? 4.h : 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11.sp : 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small colored pill used to visualize product stock availability.
class StockStatusBadge extends StatelessWidget {
  final int stockQuantity;
  final int minStockAlert;
  final bool compact;

  const StockStatusBadge({
    super.key,
    required this.stockQuantity,
    this.minStockAlert = 0,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = _resolveAppColors(context);

    final Color color;
    final String label;
    if (stockQuantity <= 0) {
      color = colors.stockOutOfStock;
      label = l10n.stock_out_of_stock;
    } else if (minStockAlert > 0 && stockQuantity <= minStockAlert) {
      color = colors.stockLowStock;
      label = l10n.low_stock;
    } else {
      color = colors.stockInStock;
      label = l10n.stock_in_stock;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8.w : 10.w, vertical: compact ? 4.h : 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 11.sp : 12.sp,
        ),
      ),
    );
  }
}

/// Small pill used to distinguish a B2B cart/order from a B2C one wherever
/// both can appear side by side (company-member buyer flows).
class AudienceBadge extends StatelessWidget {
  final bool isB2b;
  final bool compact;

  const AudienceBadge({super.key, required this.isB2b, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = _resolveAppColors(context);
    final color = isB2b ? colors.audienceB2b : colors.audienceB2c;
    final label = isB2b ? l10n.b2b_cart : l10n.b2c_cart;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8.w : 10.w, vertical: compact ? 4.h : 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isB2b ? Icons.store_mall_directory_rounded : Icons.storefront_rounded,
            size: compact ? 12.sp : 14.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: compact ? 11.sp : 12.sp),
          ),
        ],
      ),
    );
  }
}
