import 'dart:math' as math;

import 'package:solar_hub/src/features/structure_design/domain/entities/bom_item.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/panel_spec.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/row_frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';

class StructureDesignCalculator {
  static const double defaultSupportSpacingMeters = 1.6;

  FrameResult calculate(StructureDesignInput input) {
    final idealAzimuth = input.latitude >= 0 ? 180.0 : 0.0;
    final appliedAzimuth = _resolveAppliedAzimuth(idealAzimuth: idealAzimuth, preference: input.facingPreference);
    final idealTilt = input.latitude.abs().clamp(10.0, 40.0);
    final appliedTilt = idealTilt;
    final isConstrained = (appliedAzimuth - idealAzimuth).abs() > 0.1;

    final usableWidth = math.max(0.0, input.siteWidthMeters - (input.sideClearanceMeters * 2));
    final usableDepth = math.max(0.0, input.siteDepthMeters - input.frontClearanceMeters - input.rearClearanceMeters);

    final projectedRowDepth = _projectedRowDepthMeters(input.panelSpec, appliedTilt);
    final heightRise = _heightRiseMeters(input.panelSpec, appliedTilt);
    final rowSpacing = _rowSpacingMeters(latitude: input.latitude, heightRise: heightRise, interRowGapMeters: input.interRowGapMeters);

    final autoLayout = _maximizeLayout(
      usableWidth: usableWidth,
      usableDepth: usableDepth,
      panelSpec: input.panelSpec,
      projectedRowDepth: projectedRowDepth,
      rowSpacing: rowSpacing,
      targetPanelCount: input.targetPanelCount,
    );

    final rows = _resolveManualCount(requested: input.manualRows, maximum: autoLayout.rows, fallback: autoLayout.rows);
    final columns = _resolveManualCount(requested: input.manualColumns, maximum: autoLayout.columns, fallback: autoLayout.columns);

    final panelCount = rows * columns;
    final frameWidth = _frameWidthMeters(columns, input.panelSpec);
    final supportStationCount = _supportStationCount(frameWidth);
    final rowSlopeLength = _frameSlopeLengthMeters(1, input.panelSpec);
    final totalFootprintDepth = rows <= 0
        ? 0.0
        : (rows * projectedRowDepth) + ((rows - 1) * rowSpacing) + input.frontClearanceMeters + input.rearClearanceMeters;

    final frontLegCount = rows == 0 ? 0 : supportStationCount * rows;
    final rearLegCount = rows == 0 ? 0 : supportStationCount * rows;
    final rearLegHeight = input.frontLegClearanceMeters + heightRise;
    // Rails run horizontally along the frame width (perpendicular to slope)
    // Each row has 2 rails (left and right sides of panels)
    final railLength = columns <= 0 ? 0.0 : frameWidth * 2 * rows;
    // Brace forms a triangle between front leg, rear leg, and ground anchor
    // The brace runs diagonally from front leg (at ~65% of depth) to rear leg top
    final braceHorizontalSpan = projectedRowDepth * 0.65;
    final braceLength = math.sqrt(math.pow(heightRise, 2) + math.pow(braceHorizontalSpan, 2));
    final anchorCount = frontLegCount + rearLegCount;
    final rowOffsets = _normalizeRowOffsets(input.rowBaseOffsetsMeters, rows);
    final rowResults = List<RowFrameResult>.generate(rows, (index) {
      final baseOffset = input.rowMode == RowMode.stepped ? rowOffsets[index] : 0.0;
      return RowFrameResult(
        rowIndex: index,
        baseOffsetMeters: baseOffset,
        frontLegHeightMeters: input.frontLegClearanceMeters + baseOffset,
        rearLegHeightMeters: rearLegHeight + baseOffset,
        rowSpacingMeters: rowSpacing,
        localFootprintDepthMeters: projectedRowDepth,
      );
    });
    final minFrontLeg = rowResults.isEmpty ? input.frontLegClearanceMeters : rowResults.map((row) => row.frontLegHeightMeters).reduce(math.min);
    final maxFrontLeg = rowResults.isEmpty ? input.frontLegClearanceMeters : rowResults.map((row) => row.frontLegHeightMeters).reduce(math.max);
    final minRearLeg = rowResults.isEmpty ? rearLegHeight : rowResults.map((row) => row.rearLegHeightMeters).reduce(math.min);
    final maxRearLeg = rowResults.isEmpty ? rearLegHeight : rowResults.map((row) => row.rearLegHeightMeters).reduce(math.max);
    final isUniformLegDesign =
        rowResults.isEmpty ||
        rowResults.every(
          (row) =>
              (row.frontLegHeightMeters - rowResults.first.frontLegHeightMeters).abs() < 1e-9 &&
              (row.rearLegHeightMeters - rowResults.first.rearLegHeightMeters).abs() < 1e-9,
        );
    final braceCount = rowResults.isEmpty ? 0 : supportStationCount * rows;
    final totalFrontLegLength = rowResults.fold<double>(0, (sum, row) => sum + (row.frontLegHeightMeters * supportStationCount));
    final totalRearLegLength = rowResults.fold<double>(0, (sum, row) => sum + (row.rearLegHeightMeters * supportStationCount));
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
      rowMode: input.rowMode,
      rows: rows,
      columns: columns,
      panelCount: panelCount,
      maxRows: autoLayout.rows,
      maxColumns: autoLayout.columns,
      frameWidthMeters: frameWidth,
      frameSlopeLengthMeters: rowSlopeLength,
      projectedRowDepthMeters: projectedRowDepth,
      rowSpacingMeters: rowSpacing,
      totalFootprintDepthMeters: totalFootprintDepth,
      frontLegHeightMeters: input.frontLegClearanceMeters,
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
      panelOrientation: input.panelSpec.orientation,
      rowResults: rowResults,
      isUniformLegDesign: isUniformLegDesign,
      bomItems: bomItems,
    );
  }

  double resolveIdealAzimuth(double latitude) => latitude >= 0 ? 180.0 : 0.0;

  double resolveTilt(double latitude) => latitude.abs().clamp(10.0, 40.0);

  double resolveAppliedAzimuth({required double latitude, required FacingDirectionPreference preference}) {
    return _resolveAppliedAzimuth(idealAzimuth: resolveIdealAzimuth(latitude), preference: preference);
  }

  double projectedRowDepthFor(PanelSpec panelSpec, double tiltDegrees) {
    return _projectedRowDepthMeters(panelSpec, tiltDegrees);
  }

  int supportStationCountFor(double frameWidthMeters) {
    return _supportStationCount(frameWidthMeters);
  }

  double rowSpacingFor({required double latitude, required double heightRise, required double interRowGapMeters}) {
    return _rowSpacingMeters(latitude: latitude, heightRise: heightRise, interRowGapMeters: interRowGapMeters);
  }

  _Layout _maximizeLayout({
    required double usableWidth,
    required double usableDepth,
    required PanelSpec panelSpec,
    required double projectedRowDepth,
    required double rowSpacing,
    int? targetPanelCount,
  }) {
    final columnPitch = panelSpec.spanAcrossRowMeters + panelSpec.horizontalGapMeters;
    final rowPitch = projectedRowDepth + rowSpacing;
    final maxColumns = usableWidth <= 0 || panelSpec.spanAcrossRowMeters <= 0
        ? 0
        : math.max(0, (((usableWidth + panelSpec.horizontalGapMeters) / columnPitch).floor()));

    final maxRows = usableDepth <= 0 || projectedRowDepth <= 0 ? 0 : math.max(0, (((usableDepth + rowSpacing) / rowPitch).floor()));

    int bestRows = 0;
    int bestColumns = 0;
    int bestCount = 0;

    for (var rows = 1; rows <= maxRows; rows++) {
      final occupiedDepth = (rows * projectedRowDepth) + ((rows - 1) * rowSpacing);
      if (occupiedDepth > usableDepth + 1e-9) {
        continue;
      }
      for (var columns = 1; columns <= maxColumns; columns++) {
        final occupiedWidth = (columns * panelSpec.spanAcrossRowMeters) + ((columns - 1) * panelSpec.horizontalGapMeters);
        if (occupiedWidth > usableWidth + 1e-9) {
          continue;
        }
        final count = rows * columns;
        if (targetPanelCount != null && count > targetPanelCount) {
          continue;
        }
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
    final allowedAzimuth = switch (preference) {
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
    return allowedAzimuth;
  }

  double _frameSlopeLengthMeters(int rows, PanelSpec panelSpec) {
    if (rows <= 0) return 0.0;
    return (rows * panelSpec.slopeRunMeters) + ((rows - 1) * panelSpec.verticalGapMeters);
  }

  double _frameWidthMeters(int columns, PanelSpec panelSpec) {
    if (columns <= 0) return 0.0;
    return (columns * panelSpec.spanAcrossRowMeters) + ((columns - 1) * panelSpec.horizontalGapMeters);
  }

  int _supportStationCount(double frameWidthMeters) {
    if (frameWidthMeters <= 0) {
      return 0;
    }
    return (frameWidthMeters / defaultSupportSpacingMeters).ceil() + 1;
  }

  int _resolveManualCount({required int? requested, required int maximum, required int fallback}) {
    if (maximum <= 0) return 0;
    if (requested == null || requested <= 0) {
      return fallback;
    }
    return requested.clamp(1, maximum);
  }

  double _heightRiseMeters(PanelSpec panelSpec, double tiltDegrees) {
    final tiltRadians = tiltDegrees * math.pi / 180.0;
    return _frameSlopeLengthMeters(1, panelSpec) * math.sin(tiltRadians);
  }

  double _projectedRowDepthMeters(PanelSpec panelSpec, double tiltDegrees) {
    final tiltRadians = tiltDegrees * math.pi / 180.0;
    return _frameSlopeLengthMeters(1, panelSpec) * math.cos(tiltRadians);
  }

  /// Calculates minimum row spacing to prevent shadow casting between rows.
  /// Uses winter solstice sun elevation (worst case) at solar noon.
  /// Formula: shadow_length = height_rise / tan(sun_elevation)
  /// Sun elevation at winter solstice = 90 - latitude - 23.5 (Earth's axial tilt)
  double _rowSpacingMeters({required double latitude, required double heightRise, required double interRowGapMeters}) {
    // Winter solstice sun elevation at solar noon (minimum elevation of the year)
    final winterElevation = (90 - latitude.abs() - 23.5).clamp(15.0, 65.0);
    final winterRadians = winterElevation * math.pi / 180.0;
    // Calculate shadow length cast by the rear of the panel row
    final shadowLength = heightRise / math.tan(winterRadians);
    // Row spacing = shadow length + minimum working gap
    // This ensures no shading even on winter solstice at solar noon
    return shadowLength + interRowGapMeters;
  }

  List<double> _normalizeRowOffsets(List<double> offsets, int rows) {
    if (rows <= 0) {
      return const [];
    }
    return List<double>.generate(rows, (index) {
      if (index < offsets.length) {
        return offsets[index];
      }
      return 0.0;
    });
  }
}

class _Layout {
  const _Layout({required this.rows, required this.columns});

  final int rows;
  final int columns;
}
