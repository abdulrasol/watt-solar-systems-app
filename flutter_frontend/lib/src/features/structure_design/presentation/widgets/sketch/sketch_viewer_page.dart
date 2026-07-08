import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:watt/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/results/metric_row.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/sketch/structure_sketch_painter.dart';

class StructureSketchViewerPage extends StatelessWidget {
  const StructureSketchViewerPage({
    super.key,
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    // Responsive breakpoints: >=900 → desktop wide-layout, >=600 → tablet, <600 → mobile
    final screenWidth = media.size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final useWideLayout = isDesktop;
    // On tablet/desktop we give more vertical space to each sketch card
    final sketchHeightFactor = isDesktop ? 0.45 : (isTablet ? 0.38 : 0.32);
    final sideHeightFactor = isDesktop ? 0.50 : (isTablet ? 0.42 : 0.36);
    final smallHeightFactor = isDesktop ? 0.35 : (isTablet ? 0.30 : 0.26);

    final sketchColumn = Column(
      children: [
        _SketchViewCard(
          key: const Key('full_structure_sketch'),
          title: l10n.structure_top_view,
          height: math.min(media.size.height * sketchHeightFactor, 400.0),
          painter: StructureSketchPainter(
            result: result,
            siteWidthMeters: siteWidthMeters,
            siteDepthMeters: siteDepthMeters,
            topViewLabel: l10n.structure_top_view,
            sideViewLabel: l10n.structure_side_view,
            frontViewLabel: l10n.structure_front_view,
            isometricViewLabel: l10n.structure_isometric_view,
            frontLabel: l10n.structure_front_label,
            rearLabel: l10n.structure_rear_label,
            braceLabel: l10n.structure_brace_label,
            viewMode: StructureSketchView.top,
            detailLevel: SketchDetailLevel.detailed,
          ),
        ),
        SizedBox(height: 14.h),
        _SketchViewCard(
          title: l10n.structure_side_view,
          height: math.min(media.size.height * sideHeightFactor, 420.0),
          painter: StructureSketchPainter(
            result: result,
            siteWidthMeters: siteWidthMeters,
            siteDepthMeters: siteDepthMeters,
            topViewLabel: l10n.structure_top_view,
            sideViewLabel: l10n.structure_side_view,
            frontViewLabel: l10n.structure_front_view,
            isometricViewLabel: l10n.structure_isometric_view,
            frontLabel: l10n.structure_front_label,
            rearLabel: l10n.structure_rear_label,
            braceLabel: l10n.structure_brace_label,
            viewMode: StructureSketchView.side,
            detailLevel: SketchDetailLevel.detailed,
          ),
        ),
        SizedBox(height: 14.h),
        _SketchViewCard(
          title: l10n.structure_front_view,
          height: math.min(media.size.height * smallHeightFactor, 320.0),
          painter: StructureSketchPainter(
            result: result,
            siteWidthMeters: siteWidthMeters,
            siteDepthMeters: siteDepthMeters,
            topViewLabel: l10n.structure_top_view,
            sideViewLabel: l10n.structure_side_view,
            frontViewLabel: l10n.structure_front_view,
            isometricViewLabel: l10n.structure_isometric_view,
            frontLabel: l10n.structure_front_label,
            rearLabel: l10n.structure_rear_label,
            braceLabel: l10n.structure_brace_label,
            viewMode: StructureSketchView.front,
            detailLevel: SketchDetailLevel.detailed,
          ),
        ),
        SizedBox(height: 14.h),
        _SketchViewCard(
          title: l10n.structure_isometric_view,
          height: math.min(media.size.height * smallHeightFactor, 320.0),
          painter: StructureSketchPainter(
            result: result,
            siteWidthMeters: siteWidthMeters,
            siteDepthMeters: siteDepthMeters,
            topViewLabel: l10n.structure_top_view,
            sideViewLabel: l10n.structure_side_view,
            frontViewLabel: l10n.structure_front_view,
            isometricViewLabel: l10n.structure_isometric_view,
            frontLabel: l10n.structure_front_label,
            rearLabel: l10n.structure_rear_label,
            braceLabel: l10n.structure_brace_label,
            viewMode: StructureSketchView.isometric,
            detailLevel: SketchDetailLevel.detailed,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          l10n.structure_sketch_hint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );

    final dimensionsCard = Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.structure_geometry_dimensions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
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
          MetricRow(
            label: l10n.structure_rail_length,
            value: _meters(result.railLengthMeters),
          ),
          MetricRow(
            label: l10n.structure_brace_length,
            value: _meters(result.braceLengthMeters),
          ),
          MetricRow(
            label: l10n.structure_total_front_legs_length,
            value: _meters(result.totalFrontLegLengthMeters),
          ),
          MetricRow(
            label: l10n.structure_total_rear_legs_length,
            value: _meters(result.totalRearLegLengthMeters),
          ),
          MetricRow(
            label: l10n.structure_total_braces_length,
            value: _meters(result.totalBraceLengthMeters),
          ),
          MetricRow(
            label: l10n.structure_total_steel_length,
            value: _meters(result.totalSteelLengthMeters),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.structure_total_steel_breakdown(
              _meters(result.railLengthMeters),
              _meters(result.totalFrontLegLengthMeters),
              _meters(result.totalRearLegLengthMeters),
              _meters(result.totalBraceLengthMeters),
            ),
            key: const Key('total_steel_breakdown'),
            style: theme.textTheme.bodySmall,
          ),
          if (result.rowMode == RowMode.stepped) ...[
            SizedBox(height: 8.h),
            for (final row in result.rowResults)
              MetricRow(
                label: l10n.structure_row_offset_value(row.rowIndex + 1),
                value:
                    '${_meters(row.frontLegHeightMeters)} / ${_meters(row.rearLegHeightMeters)}',
              ),
          ] else ...[
            SizedBox(height: 8.h),
            Text(
              l10n.structure_equal_legs_explanation,
              key: const Key('full_sketch_repeated_note'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.structure_full_sketch_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
          child: useWideLayout
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: sketchColumn),
                    SizedBox(width: 16.w),
                    Expanded(flex: 2, child: dimensionsCard),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sketchColumn,
                    SizedBox(height: 16.h),
                    dimensionsCard,
                  ],
                ),
        ),
      ),
    );
  }

  String _meters(double value) => '${value.toStringAsFixed(2)} m';
}

class _SketchViewCard extends StatelessWidget {
  const _SketchViewCard({
    super.key,
    required this.title,
    required this.height,
    required this.painter,
  });

  final String title;
  final double height;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              height: height,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 3,
                boundaryMargin: const EdgeInsets.all(24),
                child: CustomPaint(
                  painter: painter,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
