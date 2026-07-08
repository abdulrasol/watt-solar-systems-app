import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/structure_design/domain/entities/frame_result.dart';

/// A card displaying per-row details for non-uniform designs
class RowDetailsCard extends StatelessWidget {
  const RowDetailsCard({
    super.key,
    required this.result,
    required this.title,
    required this.rowLabel,
    required this.frontHeightLabel,
    required this.rearHeightLabel,
    required this.offsetLabel,
  });

  final FrameResult result;
  final String title;
  final String rowLabel;
  final String frontHeightLabel;
  final String rearHeightLabel;
  final String offsetLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = result.rowResults;

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
                Icon(Iconsax.row_horizontal, color: theme.colorScheme.primary, size: 24.sp),
                SizedBox(width: 12.w),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20.r)),
                  child: Text(
                    '${rows.length} $rowLabel',
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
                    flex: 1,
                    child: Text(
                      '#',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      frontHeightLabel,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      rearHeightLabel,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      offsetLabel,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),

            // Table rows
            ...rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              final isEven = index % 2 == 0;
              final isLast = index == rows.length - 1;

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isEven ? theme.colorScheme.surface : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: isLast ? BorderRadius.vertical(bottom: Radius.circular(8.r)) : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${row.rowIndex + 1}',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('${row.frontLegHeightMeters.toStringAsFixed(2)} m', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('${row.rearLegHeightMeters.toStringAsFixed(2)} m', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${row.baseOffsetMeters.toStringAsFixed(2)} m',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
