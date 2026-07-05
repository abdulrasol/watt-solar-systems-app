import 'dart:math' as math;

import 'package:solar_hub/src/features/pv_system_designer/domain/entities/bom_item.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/row_frame_result.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';

class StructureDesignCalculator {
  static const double defaultSupportSpacingMeters = 1.6;

  FrameResult calculate(PvSystemDesignState s) {
    final idealAzimuth = s.latitude >= 0 ? 180.0 : 0.0;
    final appliedAzimuth = _resolveAppliedAzimuth(idealAzimuth: idealAzimuth, preference: s.facingPreference);
    final idealTilt = s.latitude.abs().clamp(10.0, 40.0);
    final appliedTilt = idealTilt;
    final isConstrained = (appliedAzimuth - idealAzimuth).abs() > 0.1;

    final usableWidth = math.max(0.0, s.roofWidthM - (s.sideClearanceM * 2));
    final usableDepth = math.max(0.0, s.roofLengthM - s.frontClearanceM - s.rearClearanceM);

    final panelSpan = s.isPortrait ? s.panelWidthM : s.panelLengthM;
    final panelSlope = s.isPortrait ? s.panelLengthM : s.panelWidthM;
    final panelOrientation = s.isPortrait ? PanelOrientation.portrait : PanelOrientation.landscape;

    final projectedRowDepth = _projectedRowDepth(panelSlope, appliedTilt);
    final heightRise = _heightRise(panelSlope, appliedTilt);
    final rowSpacing = _rowSpacing(latitude: s.latitude, heightRise: heightRise, interRowGap: s.interRowGapM);

    final autoLayout = _maximizeLayout(
      usableWidth: usableWidth,
      usableDepth: usableDepth,
      panelSpan: panelSpan,
      horizontalGap: s.horizontalGapM,
      projectedRowDepth: projectedRowDepth,
      rowSpacing: rowSpacing,
      targetPanelCount: s.targetPanelCount,
    );

    final rows = _resolveManual(requested: s.manualRows, maximum: autoLayout.rows, fallback: autoLayout.rows);
    final columns = _resolveManual(requested: s.manualColumns, maximum: autoLayout.columns, fallback: autoLayout.columns);
    final panelCount = rows * columns;
    final frameWidth = _frameWidth(columns, panelSpan, s.horizontalGapM);
    final supportStationCount = _supportStationCount(frameWidth);
    final rowSlopeLength = panelSlope;
    final totalFootprint = rows <= 0
        ? 0.0
        : (rows * projectedRowDepth) + ((rows - 1) * rowSpacing) + s.frontClearanceM + s.rearClearanceM;

    final frontLegCount = rows == 0 ? 0 : supportStationCount * rows;
    final rearLegCount = rows == 0 ? 0 : supportStationCount * rows;
    final rearLegHeight = s.frontLegClearanceM + heightRise;
    final railLength = columns <= 0 ? 0.0 : frameWidth * 2 * rows;
    final braceHorizontalSpan = projectedRowDepth * 0.65;
    final braceLength = math.sqrt(math.pow(heightRise, 2) + math.pow(braceHorizontalSpan, 2));
    final anchorCount = frontLegCount + rearLegCount;
    final rowOffsets = _normalizeRowOffsets(s.rowBaseOffsetsM, rows);
    final rowResults = List<RowFrameResult>.generate(rows, (index) {
      final baseOffset = s.rowMode == RowMode.stepped ? rowOffsets[index] : 0.0;
      return RowFrameResult(
        rowIndex: index,
        baseOffsetMeters: baseOffset,
        frontLegHeightMeters: s.frontLegClearanceM + baseOffset,
        rearLegHeightMeters: rearLegHeight + baseOffset,
        rowSpacingMeters: rowSpacing,
        localFootprintDepthMeters: projectedRowDepth,
      );
    });
    final minFrontLeg = rowResults.isEmpty ? s.frontLegClearanceM : rowResults.map((r) => r.frontLegHeightMeters).reduce(math.min);
    final maxFrontLeg = rowResults.isEmpty ? s.frontLegClearanceM : rowResults.map((r) => r.frontLegHeightMeters).reduce(math.max);
    final minRearLeg = rowResults.isEmpty ? rearLegHeight : rowResults.map((r) => r.rearLegHeightMeters).reduce(math.min);
    final maxRearLeg = rowResults.isEmpty ? rearLegHeight : rowResults.map((r) => r.rearLegHeightMeters).reduce(math.max);
    final isUniform = rowResults.isEmpty ||
        rowResults.every(
          (r) =>
              (r.frontLegHeightMeters - rowResults.first.frontLegHeightMeters).abs() < 1e-9 &&
              (r.rearLegHeightMeters - rowResults.first.rearLegHeightMeters).abs() < 1e-9,
        );
    final braceCount = rowResults.isEmpty ? 0 : supportStationCount * rows;
    final totalFrontLegLength = rowResults.fold<double>(0, (sum, r) => sum + (r.frontLegHeightMeters * supportStationCount));
    final totalRearLegLength = rowResults.fold<double>(0, (sum, r) => sum + (r.rearLegHeightMeters * supportStationCount));
    final totalBraceLength = braceLength * braceCount;
    final totalSteelLength = railLength + totalFrontLegLength + totalRearLegLength + totalBraceLength;

    final bomItems = <BomItem>[
      BomItem(name: 'Rails', unit: 'm', quantity: railLength, note: '2 rails x repeated row x row count'),
      BomItem(name: 'Front legs', unit: 'pcs', quantity: frontLegCount.toDouble(), note: 'support stations x row count'),
      BomItem(name: 'Rear legs', unit: 'pcs', quantity: rearLegCount.toDouble(), note: 'support stations x row count'),
      BomItem(name: 'Cross braces', unit: 'pcs', quantity: braceCount.toDouble(), note: '1 brace per support station x row count'),
      BomItem(name: 'Anchors', unit: 'pcs', quantity: anchorCount.toDouble(), note: '1 anchor per leg'),
    ];

    return FrameResult(
      idealAzimuthDegrees: idealAzimuth,
      appliedAzimuthDegrees: appliedAzimuth,
      idealTiltDegrees: idealTilt,
      appliedTiltDegrees: appliedTilt,
      isOrientationConstrained: isConstrained,
      rowMode: s.rowMode,
      rows: rows,
      columns: columns,
      panelCount: panelCount,
      maxRows: autoLayout.rows,
      maxColumns: autoLayout.columns,
      frameWidthMeters: frameWidth,
      frameSlopeLengthMeters: rowSlopeLength,
      projectedRowDepthMeters: projectedRowDepth,
      rowSpacingMeters: rowSpacing,
      totalFootprintDepthMeters: totalFootprint,
      frontLegHeightMeters: s.frontLegClearanceM,
      rearLegHeightMeters: rearLegHeight,
      minFrontLegHeightMeters: minFrontLeg,
      maxFrontLegHeightMeters: maxFrontLeg,
      minRearLegHeightMeters: minRearLeg,
      maxRearLegHeightMeters: maxRearLeg,
      railLengthMeters: railLength,
      braceLengthMeters: braceLength,
      supportSpacingMeters: defaultSupportSpacingMeters,
      supportStationCount: supportStationCount,
      totalFrontLegLengthMeters: totalFrontLegLength,
      totalRearLegLengthMeters: totalRearLegLength,
      totalBraceLengthMeters: totalBraceLength,
      totalSteelLengthMeters: totalSteelLength,
      frontLegCount: frontLegCount,
      rearLegCount: rearLegCount,
      anchorCount: anchorCount,
      usableWidthMeters: usableWidth,
      usableDepthMeters: usableDepth,
      panelOrientation: panelOrientation,
      rowResults: rowResults,
      isUniformLegDesign: isUniform,
      bomItems: bomItems,
    );
  }

  _Layout _maximizeLayout({
    required double usableWidth,
    required double usableDepth,
    required double panelSpan,
    required double horizontalGap,
    required double projectedRowDepth,
    required double rowSpacing,
    int? targetPanelCount,
  }) {
    final columnPitch = panelSpan + horizontalGap;
    final rowPitch = projectedRowDepth + rowSpacing;
    final maxColumns = usableWidth <= 0 || panelSpan <= 0
        ? 0
        : math.max(0, (((usableWidth + horizontalGap) / columnPitch).floor()));
    final maxRows = usableDepth <= 0 || projectedRowDepth <= 0
        ? 0
        : math.max(0, (((usableDepth + rowSpacing) / rowPitch).floor()));

    int bestRows = 0;
    int bestColumns = 0;
    int bestCount = 0;

    for (var rows = 1; rows <= maxRows; rows++) {
      final occupiedDepth = (rows * projectedRowDepth) + ((rows - 1) * rowSpacing);
      if (occupiedDepth > usableDepth + 1e-9) continue;
      for (var columns = 1; columns <= maxColumns; columns++) {
        final occupiedWidth = (columns * panelSpan) + ((columns - 1) * horizontalGap);
        if (occupiedWidth > usableWidth + 1e-9) continue;
        final count = rows * columns;
        if (targetPanelCount != null && count > targetPanelCount) continue;
        if (count > bestCount || (count == bestCount && rows <= bestRows) || bestRows == 0) {
          bestRows = rows;
          bestColumns = columns;
          bestCount = count;
        }
      }
    }
    return _Layout(rows: bestRows, columns: bestColumns);
  }

  double _resolveAppliedAzimuth({required double idealAzimuth, required FacingDirectionPreference preference}) {
    return switch (preference) {
      FacingDirectionPreference.any => idealAzimuth,
      FacingDirectionPreference.north => 0.0,
      FacingDirectionPreference.northEast => 45.0,
      FacingDirectionPreference.east => 90.0,
      FacingDirectionPreference.southEast => 135.0,
      FacingDirectionPreference.south => 180.0,
      FacingDirectionPreference.southWest => 225.0,
      FacingDirectionPreference.west => 270.0,
      FacingDirectionPreference.northWest => 315.0,
    };
  }

  double _heightRise(double panelSlope, double tiltDegrees) {
    final tiltRadians = tiltDegrees * math.pi / 180.0;
    return panelSlope * math.sin(tiltRadians);
  }

  double _projectedRowDepth(double panelSlope, double tiltDegrees) {
    final tiltRadians = tiltDegrees * math.pi / 180.0;
    return panelSlope * math.cos(tiltRadians);
  }

  double _rowSpacing({required double latitude, required double heightRise, required double interRowGap}) {
    final winterElevation = (90 - latitude.abs() - 23.5).clamp(15.0, 65.0);
    final winterRadians = winterElevation * math.pi / 180.0;
    final shadowLength = heightRise / math.tan(winterRadians);
    return shadowLength + interRowGap;
  }

  double _frameWidth(int columns, double panelSpan, double horizontalGap) {
    if (columns <= 0) return 0.0;
    return (columns * panelSpan) + ((columns - 1) * horizontalGap);
  }

  int _supportStationCount(double frameWidthMeters) {
    if (frameWidthMeters <= 0) return 0;
    return (frameWidthMeters / defaultSupportSpacingMeters).ceil() + 1;
  }

  int _resolveManual({required int? requested, required int maximum, required int fallback}) {
    if (maximum <= 0) return 0;
    if (requested == null || requested <= 0) return fallback;
    return requested.clamp(1, maximum);
  }

  List<double> _normalizeRowOffsets(List<double> offsets, int rows) {
    if (rows <= 0) return const [];
    return List<double>.generate(rows, (index) => index < offsets.length ? offsets[index] : 0.0);
  }
}

class _Layout {
  const _Layout({required this.rows, required this.columns});
  final int rows;
  final int columns;
}
