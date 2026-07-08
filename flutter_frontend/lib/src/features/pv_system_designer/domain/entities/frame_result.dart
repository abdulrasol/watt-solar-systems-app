import 'package:watt/src/features/pv_system_designer/domain/entities/bom_item.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/row_frame_result.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';

class FrameResult {
  const FrameResult({
    required this.idealAzimuthDegrees,
    required this.appliedAzimuthDegrees,
    required this.idealTiltDegrees,
    required this.appliedTiltDegrees,
    required this.isOrientationConstrained,
    required this.rowMode,
    required this.rows,
    required this.columns,
    required this.panelCount,
    required this.maxRows,
    required this.maxColumns,
    required this.frameWidthMeters,
    required this.frameSlopeLengthMeters,
    required this.projectedRowDepthMeters,
    required this.rowSpacingMeters,
    required this.totalFootprintDepthMeters,
    required this.frontLegHeightMeters,
    required this.rearLegHeightMeters,
    required this.minFrontLegHeightMeters,
    required this.maxFrontLegHeightMeters,
    required this.minRearLegHeightMeters,
    required this.maxRearLegHeightMeters,
    required this.railLengthMeters,
    required this.braceLengthMeters,
    required this.supportSpacingMeters,
    required this.supportStationCount,
    required this.totalFrontLegLengthMeters,
    required this.totalRearLegLengthMeters,
    required this.totalBraceLengthMeters,
    required this.totalSteelLengthMeters,
    required this.frontLegCount,
    required this.rearLegCount,
    required this.anchorCount,
    required this.usableWidthMeters,
    required this.usableDepthMeters,
    required this.panelOrientation,
    required this.rowResults,
    required this.isUniformLegDesign,
    required this.bomItems,
  });

  final double idealAzimuthDegrees;
  final double appliedAzimuthDegrees;
  final double idealTiltDegrees;
  final double appliedTiltDegrees;
  final bool isOrientationConstrained;
  final RowMode rowMode;
  final int rows;
  final int columns;
  final int panelCount;
  final int maxRows;
  final int maxColumns;
  final double frameWidthMeters;
  final double frameSlopeLengthMeters;
  final double projectedRowDepthMeters;
  final double rowSpacingMeters;
  final double totalFootprintDepthMeters;
  final double frontLegHeightMeters;
  final double rearLegHeightMeters;
  final double minFrontLegHeightMeters;
  final double maxFrontLegHeightMeters;
  final double minRearLegHeightMeters;
  final double maxRearLegHeightMeters;
  final double railLengthMeters;
  final double braceLengthMeters;
  final double supportSpacingMeters;
  final int supportStationCount;
  final double totalFrontLegLengthMeters;
  final double totalRearLegLengthMeters;
  final double totalBraceLengthMeters;
  final double totalSteelLengthMeters;
  final int frontLegCount;
  final int rearLegCount;
  final int anchorCount;
  final double usableWidthMeters;
  final double usableDepthMeters;
  final PanelOrientation panelOrientation;
  final List<RowFrameResult> rowResults;
  final bool isUniformLegDesign;
  final List<BomItem> bomItems;
}
