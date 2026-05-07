import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';

/// A data table displaying the Bill of Materials
class BomTable extends StatelessWidget {
  const BomTable({
    super.key,
    required this.result,
    required this.title,
    required this.itemLabel,
    required this.quantityLabel,
    required this.unitLabel,
    required this.totalLabel,
  });

  final FrameResult result;
  final String title;
  final String itemLabel;
  final String quantityLabel;
  final String unitLabel;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = result.bomItems;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Iconsax.box_bold, color: theme.colorScheme.primary, size: 24.sp),
                SizedBox(width: 12.w),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20.r)),
                  child: Text(
                    '${items.length} $itemLabel',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Table header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      itemLabel,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      quantityLabel,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      unitLabel,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),

            // Table rows
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isEven = index % 2 == 0;

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isEven ? theme.colorScheme.surface : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: index == items.length - 1 ? BorderRadius.vertical(bottom: Radius.circular(8.r)) : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Icon(_getIconForItem(item.name), size: 18.sp, color: theme.colorScheme.primary),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(item.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatQuantity(item.quantity),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        item.unit,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Total row
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8.r)),
              child: Row(
                children: [
                  Icon(Iconsax.weight_bold, size: 20.sp, color: theme.colorScheme.primary),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(totalLabel, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    '${result.totalSteelLengthMeters.toStringAsFixed(1)} m',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(2);
  }

  IconData _getIconForItem(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('leg') || lowerName.contains('post')) {
      return IonIcons.cloud_offline; // .colum  column_bold;
    } else if (lowerName.contains('rail') || lowerName.contains('beam')) {
      return Iconsax.ruler_bold;
    } else if (lowerName.contains('brace') || lowerName.contains('diagonal')) {
      return Iconsax.activity_bold;
    } else if (lowerName.contains('anchor') || lowerName.contains('bolt')) {
      return Iconsax.link_bold;
    } else if (lowerName.contains('clamp') || lowerName.contains('clip')) {
      return Iconsax.attach_circle_bold;
    } else if (lowerName.contains('panel') || lowerName.contains('module')) {
      return Iconsax.sun_1_bold;
    }
    return Iconsax.box_bold;
  }
}
