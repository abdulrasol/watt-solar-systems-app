import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';

/// A card displaying key summary metrics for the structure design
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.result,
    required this.panelPowerWatts,
    required this.totalPowerLabel,
    required this.panelCountLabel,
    required this.footprintLabel,
    required this.dimensionsLabel,
    required this.tiltLabel,
    required this.azimuthLabel,
  });

  final FrameResult result;
  final double panelPowerWatts;
  final String totalPowerLabel;
  final String panelCountLabel;
  final String footprintLabel;
  final String dimensionsLabel;
  final String tiltLabel;
  final String azimuthLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPowerKw = (result.panelCount * panelPowerWatts) / 1000;

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
                Icon(
                  Iconsax.chart_2_bold,
                  color: theme.colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Design Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Key metrics grid
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Iconsax.sun_1_bold,
                    iconColor: Colors.orange,
                    value: '${result.panelCount}',
                    label: panelCountLabel,
                    subtitle: '${result.rows} x ${result.columns}',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _MetricTile(
                    icon: Iconsax.flash_bold,
                    iconColor: Colors.amber,
                    value: totalPowerKw.toStringAsFixed(2),
                    label: totalPowerLabel,
                    subtitle: 'kW',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Iconsax.map_1_bold,
                    iconColor: Colors.green,
                    value:
                        '${result.frameWidthMeters.toStringAsFixed(1)} x ${result.totalFootprintDepthMeters.toStringAsFixed(1)}',
                    label: footprintLabel,
                    subtitle: 'm',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _MetricTile(
                    icon: Iconsax.rotate_left_bold,
                    iconColor: Colors.blue,
                    value: '${result.appliedTiltDegrees.toStringAsFixed(1)}°',
                    label: tiltLabel,
                    subtitle:
                        'ideal: ${result.idealTiltDegrees.toStringAsFixed(1)}°',
                  ),
                ),
              ],
            ),

            // Constraint warning if applicable
            if (result.isOrientationConstrained) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.warning_2_bold,
                      color: Colors.orange,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Layout constrained by site dimensions. Consider adjusting site size or panel orientation.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Icon(icon, color: iconColor, size: 20.sp),
              const Spacer(),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
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
