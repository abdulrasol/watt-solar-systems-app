import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/results/bom_table.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/results/geometry_card.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/results/summary_card.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/results/row_details_card.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/sketch/sketch_card.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/sketch/structure_sketch_painter.dart';

/// Main results view widget that combines all result components
class StructureResultsView extends StatelessWidget {
  const StructureResultsView({
    super.key,
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.l10n,
    this.panelPowerWatts = 550,
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final dynamic l10n;
  final double panelPowerWatts;

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          SummaryCard(
            result: result,
            panelPowerWatts: panelPowerWatts,
            totalPowerLabel: l10n.structure_total_power ?? 'Total Power',
            panelCountLabel: l10n.structure_panel_count ?? 'Panels',
            footprintLabel: l10n.structure_footprint ?? 'Footprint',
            dimensionsLabel: l10n.structure_dimensions ?? 'Dimensions',
            tiltLabel: l10n.structure_tilt ?? 'Tilt',
            azimuthLabel: l10n.structure_azimuth ?? 'Azimuth',
          ),
          SizedBox(height: 16.h),

          // Sketch Gallery
          SketchGallery(
            result: result,
            siteWidthMeters: siteWidthMeters,
            siteDepthMeters: siteDepthMeters,
            topViewLabel: l10n.structure_top_view ?? 'Top View',
            sideViewLabel: l10n.structure_side_view ?? 'Side View',
            frontViewLabel: l10n.structure_front_view ?? 'Front View',
            isometricViewLabel: l10n.structure_isometric_view ?? 'Isometric',
            frontLabel: l10n.structure_front ?? 'Front',
            rearLabel: l10n.structure_rear ?? 'Rear',
            braceLabel: l10n.structure_brace ?? 'Brace',
            onSketchTap: (view) => _showFullScreenSketch(context, view),
          ),
          SizedBox(height: 16.h),

          // Geometry Card
          GeometryCard(
            result: result,
            title: l10n.structure_geometry ?? 'Geometry',
            frameWidthLabel: l10n.structure_frame_width ?? 'Frame Width',
            frameDepthLabel: l10n.structure_frame_depth ?? 'Frame Depth',
            rowSpacingLabel: l10n.structure_row_spacing ?? 'Row Spacing',
            frontLegHeightLabel: l10n.structure_front_leg_height ?? 'Front Leg Height',
            rearLegHeightLabel: l10n.structure_rear_leg_height ?? 'Rear Leg Height',
            slopeLengthLabel: l10n.structure_slope_length ?? 'Slope Length',
            projectedDepthLabel: l10n.structure_projected_depth ?? 'Projected Depth',
            supportSpacingLabel: l10n.structure_support_spacing ?? 'Support Spacing',
            braceLengthLabel: l10n.structure_brace_length ?? 'Brace Length',
          ),
          SizedBox(height: 16.h),

          // Row Details (if multiple rows with different heights)
          if (!result.isUniformLegDesign && result.rowResults.length > 1) ...[
            RowDetailsCard(
              result: result,
              title: l10n.structure_row_details ?? 'Row Details',
              rowLabel: l10n.structure_row ?? 'Row',
              frontHeightLabel: l10n.structure_front_leg_height ?? 'Front Height',
              rearHeightLabel: l10n.structure_rear_leg_height ?? 'Rear Height',
              offsetLabel: l10n.structure_offset ?? 'Offset',
            ),
            SizedBox(height: 16.h),
          ],

          // BOM Table
          BomTable(
            result: result,
            title: l10n.structure_bom ?? 'Bill of Materials',
            itemLabel: l10n.structure_item ?? 'items',
            quantityLabel: l10n.structure_quantity ?? 'Quantity',
            unitLabel: l10n.structure_unit ?? 'Unit',
            totalLabel: l10n.structure_total_steel ?? 'Total Steel Length',
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  void _showFullScreenSketch(BuildContext context, StructureSketchView view) {
    final title = switch (view) {
      StructureSketchView.top => l10n.structure_top_view ?? 'Top View',
      StructureSketchView.side => l10n.structure_side_view ?? 'Side View',
      StructureSketchView.front => l10n.structure_front_view ?? 'Front View',
      StructureSketchView.isometric => l10n.structure_isometric_view ?? 'Isometric View',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenSketchViewer(
          result: result,
          siteWidthMeters: siteWidthMeters,
          siteDepthMeters: siteDepthMeters,
          viewMode: view,
          title: title,
          topViewLabel: l10n.structure_top_view ?? 'Top View',
          sideViewLabel: l10n.structure_side_view ?? 'Side View',
          frontViewLabel: l10n.structure_front_view ?? 'Front View',
          isometricViewLabel: l10n.structure_isometric_view ?? 'Isometric',
          frontLabel: l10n.structure_front ?? 'Front',
          rearLabel: l10n.structure_rear ?? 'Rear',
          braceLabel: l10n.structure_brace ?? 'Brace',
        ),
      ),
    );
  }
}
