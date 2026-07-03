import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ResultSummaryCard extends StatelessWidget {
  const ResultSummaryCard({
    super.key,
    required this.result,
    required this.l10n,
  });

  final FrameResult result;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.structure_results_title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(
                label:
                    '${l10n.structure_ideal_tilt}: ${result.idealTiltDegrees.toStringAsFixed(1)} deg',
              ),
              _MiniChip(
                label:
                    '${l10n.structure_applied_tilt}: ${result.appliedTiltDegrees.toStringAsFixed(1)} deg',
              ),
              _MiniChip(
                label:
                    '${l10n.structure_applied_azimuth}: ${result.appliedAzimuthDegrees.toStringAsFixed(0)} deg',
              ),
              _MiniChip(
                label: result.rowMode == RowMode.independent
                    ? l10n.structure_row_mode_independent
                    : l10n.structure_row_mode_stepped,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            result.isUniformLegDesign
                ? l10n.structure_equal_legs_explanation
                : l10n.structure_stepped_legs_explanation,
            key: result.isUniformLegDesign
                ? const Key('uniform_leg_explanation')
                : const Key('stepped_leg_explanation'),
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
