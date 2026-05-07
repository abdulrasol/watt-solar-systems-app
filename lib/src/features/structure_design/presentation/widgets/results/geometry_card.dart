import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';

/// A card displaying detailed geometry dimensions
class GeometryCard extends StatelessWidget {
  const GeometryCard({
    super.key,
    required this.result,
    required this.title,
    required this.frameWidthLabel,
    required this.frameDepthLabel,
    required this.rowSpacingLabel,
    required this.frontLegHeightLabel,
    required this.rearLegHeightLabel,
    required this.slopeLengthLabel,
    required this.projectedDepthLabel,
    required this.supportSpacingLabel,
    required this.braceLengthLabel,
  });

  final FrameResult result;
  final String title;
  final String frameWidthLabel;
  final String frameDepthLabel;
  final String rowSpacingLabel;
  final String frontLegHeightLabel;
  final String rearLegHeightLabel;
  final String slopeLengthLabel;
  final String projectedDepthLabel;
  final String supportSpacingLabel;
  final String braceLengthLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Iconsax.rulerpen_bold,
                  color: theme.colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Overall dimensions section
            _SectionTitle('Overall Dimensions'),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _DimensionTile(
                    label: frameWidthLabel,
                    value: '${result.frameWidthMeters.toStringAsFixed(2)} m',
                    icon: Iconsax.arrow_right_bold,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _DimensionTile(
                    label: frameDepthLabel,
                    value: '${result.totalFootprintDepthMeters.toStringAsFixed(2)} m',
                    icon: Iconsax.arrow_down_bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Leg heights section
            _SectionTitle('Leg Heights'),
            SizedBox(height: 8.h),
            if (result.isUniformLegDesign) ...[
              Row(
                children: [
                  Expanded(
                    child: _DimensionTile(
                      label: frontLegHeightLabel,
                      value: '${result.frontLegHeightMeters.toStringAsFixed(2)} m',
                      icon: Iconsax.arrow_up_bold,
                      iconColor: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _DimensionTile(
                      label: rearLegHeightLabel,
                      value: '${result.rearLegHeightMeters.toStringAsFixed(2)} m',
                      icon: Iconsax.arrow_up_1_bold,
                      iconColor: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildHeightRangeTile(
                context,
                frontLegHeightLabel,
                result.minFrontLegHeightMeters,
                result.maxFrontLegHeightMeters,
                Colors.blue,
              ),
              SizedBox(height: 8.h),
              _buildHeightRangeTile(
                context,
                rearLegHeightLabel,
                result.minRearLegHeightMeters,
                result.maxRearLegHeightMeters,
                Colors.indigo,
              ),
            ],
            SizedBox(height: 16.h),

            // Frame geometry section
            _SectionTitle('Frame Geometry'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                _SmallDimensionChip(
                  label: slopeLengthLabel,
                  value: '${result.frameSlopeLengthMeters.toStringAsFixed(2)} m',
                ),
                _SmallDimensionChip(
                  label: projectedDepthLabel,
                  value: '${result.projectedRowDepthMeters.toStringAsFixed(2)} m',
                ),
                _SmallDimensionChip(
                  label: rowSpacingLabel,
                  value: '${result.rowSpacingMeters.toStringAsFixed(2)} m',
                ),
                _SmallDimensionChip(
                  label: supportSpacingLabel,
                  value: '${result.supportSpacingMeters.toStringAsFixed(2)} m',
                ),
                _SmallDimensionChip(
                  label: braceLengthLabel,
                  value: '${result.braceLengthMeters.toStringAsFixed(2)} m',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightRangeTile(
    BuildContext context,
    String label,
    double min,
    double max,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.arrow_up_bold,
            color: color,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)} m',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _DimensionTile extends StatelessWidget {
  const _DimensionTile({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18.sp,
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallDimensionChip extends StatelessWidget {
  const _SmallDimensionChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
