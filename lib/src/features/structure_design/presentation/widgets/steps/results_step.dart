import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/section_card.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/presentation/providers/structure_design_controller.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/results/metric_row.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/results/offset_field.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/results/result_summary_card.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/results/stepper_tile.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/sketch/structure_sketch_painter.dart';

import 'package:solar_hub/src/utils/app_explanations.dart';

class ResultsStep extends ConsumerWidget {
  const ResultsStep({
    super.key,
    required this.controller,
    required this.l10n,
    required this.explanations,
    required this.onSaveWattDrawing,
    required this.onViewTechnicalDrawings,
    required this.onViewFullSketch,
  });

  final StructureDesignController controller;
  final AppLocalizations l10n;
  final List<ExplanationItem> explanations;
  final Future<void> Function() onSaveWattDrawing;
  final VoidCallback onViewTechnicalDrawings;
  final VoidCallback onViewFullSketch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = controller.result;
    if (result == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 28.h),
      child: Column(
        children: [
          SectionCard(
            icon: Iconsax.grid_1_bold,
            title: l10n.structure_layout_editor,
            explanation: explanations[7],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StepperTile(
                        title: l10n.structure_rows,
                        value: '${result.rows}',
                        onAdd: controller.incrementRows,
                        onRemove: controller.decrementRows,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: StepperTile(
                        title: l10n.structure_columns,
                        value: '${result.columns}',
                        onAdd: controller.incrementColumns,
                        onRemove: controller.decrementColumns,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    onPressed: controller.resetAutoLayout,
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.structure_reset_auto_layout),
                  ),
                ),
                if (controller.input.rowMode == RowMode.stepped) ...[
                  SizedBox(height: 16.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.structure_row_offsets,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  for (var index = 0; index < result.rows; index++)
                    OffsetField(
                      key: Key('row_offset_$index'),
                      label: l10n.structure_row_offset_value(index + 1),
                      initialValue: index < controller.rowBaseOffsetsMeters.length
                          ? controller.rowBaseOffsetsMeters[index]
                          : 0.0,
                      onChanged: (value) =>
                          controller.updateRowBaseOffset(index, value),
                    ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ResultSummaryCard(result: result, l10n: l10n),
          SizedBox(height: 16.h),
          SectionCard(
            icon: Icons.straighten,
            title: l10n.structure_geometry_results,
            explanation: explanations[8],
            child: Column(
              children: [
                MetricRow(
                  label: l10n.structure_panel_count,
                  value: '${result.panelCount}',
                ),
                MetricRow(
                  label: l10n.structure_frame_width,
                  value: _meters(result.frameWidthMeters),
                ),
                MetricRow(
                  label: l10n.structure_frame_length,
                  value: _meters(result.frameSlopeLengthMeters),
                ),
                MetricRow(
                  label: l10n.structure_row_spacing,
                  value: _meters(result.rowSpacingMeters),
                ),
                MetricRow(
                  label: l10n.structure_total_footprint_depth,
                  value: _meters(result.totalFootprintDepthMeters),
                ),
                MetricRow(
                  label: l10n.structure_front_leg_height,
                  value: _meters(result.frontLegHeightMeters),
                ),
                MetricRow(
                  label: l10n.structure_rear_leg_height,
                  value: _meters(result.rearLegHeightMeters),
                ),
                if (result.rowMode == RowMode.stepped) ...[
                  Column(
                    key: const Key('stepped_row_results'),
                    children: [
                      MetricRow(
                        label: l10n.structure_min_front_leg,
                        value: _meters(result.minFrontLegHeightMeters),
                      ),
                      MetricRow(
                        label: l10n.structure_max_front_leg,
                        value: _meters(result.maxFrontLegHeightMeters),
                      ),
                      MetricRow(
                        label: l10n.structure_min_rear_leg,
                        value: _meters(result.minRearLegHeightMeters),
                      ),
                      MetricRow(
                        label: l10n.structure_max_rear_leg,
                        value: _meters(result.maxRearLegHeightMeters),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SectionCard(
            icon: Icons.assignment_outlined,
            title: l10n.structure_bom_title,
            explanation: explanations[8],
            child: Column(
              children: [
                MetricRow(
                  label: l10n.structure_rail_length,
                  value: _meters(result.railLengthMeters),
                ),
                MetricRow(
                  label: l10n.structure_brace_length,
                  value: _meters(result.braceLengthMeters),
                ),
                MetricRow(
                  label: l10n.structure_total_steel_length,
                  value: _meters(result.totalSteelLengthMeters),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.structure_total_steel_breakdown(
                    _meters(result.railLengthMeters),
                    _meters(result.totalFrontLegLengthMeters),
                    _meters(result.totalRearLegLengthMeters),
                    _meters(result.totalBraceLengthMeters),
                  ),
                  key: const Key('main_total_steel_breakdown'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SectionCard(
            icon: Iconsax.gallery_bold,
            title: l10n.structure_sketch_title,
            explanation: explanations[8],
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    FilledButton.tonalIcon(
                      key: const Key('save_watt_drawing_button'),
                      onPressed: onSaveWattDrawing,
                      icon: const Icon(Icons.save_alt_rounded),
                      label: Text(l10n.structure_save_watt_drawing),
                    ),
                    FilledButton.tonalIcon(
                      key: const Key('view_technical_drawings_button'),
                      onPressed: onViewTechnicalDrawings,
                      icon: const Icon(Icons.architecture),
                      label: const Text('Technical Drawings'),
                    ),
                    FilledButton.tonalIcon(
                      key: const Key('view_full_sketch_button'),
                      onPressed: onViewFullSketch,
                      icon: const Icon(Icons.open_in_full_rounded),
                      label: Text(l10n.view),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                AspectRatio(
                  aspectRatio: 1.7,
                  child: CustomPaint(
                    key: const Key('structure_sketch'),
                    painter: StructureSketchPainter(
                      result: result,
                      siteWidthMeters: controller.input.siteWidthMeters,
                      siteDepthMeters: controller.input.siteDepthMeters,
                      topViewLabel: l10n.structure_top_view,
                      sideViewLabel: l10n.structure_side_view,
                      frontViewLabel: l10n.structure_front_view,
                      isometricViewLabel: l10n.structure_isometric_view,
                      frontLabel: l10n.structure_front_label,
                      rearLabel: l10n.structure_rear_label,
                      braceLabel: l10n.structure_brace_label,
                      viewMode: StructureSketchView.top,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.structure_sketch_hint,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _meters(double value) => '${value.toStringAsFixed(2)} m';
}
