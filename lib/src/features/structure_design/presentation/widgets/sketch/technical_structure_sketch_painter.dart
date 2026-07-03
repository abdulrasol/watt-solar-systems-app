import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/row_frame_result.dart';

/// Technical drawing colors following engineering standards
class TechnicalColors {
  // Primary structure - black for main elements
  static const Color primaryLine = Color(0xFF1A1A1A);
  static const Color thickLine = Color(0xFF000000);

  // Secondary elements - gray
  static const Color secondaryLine = Color(0xFF4A4A4A);
  static const Color lightLine = Color(0xFF888888);

  // Dimensions - blue per engineering standards
  static const Color dimensionLine = Color(0xFF0066CC);
  static const Color dimensionText = Color(0xFF004499);

  // Center lines - red dash-dot
  static const Color centerLine = Color(0xFFFF4444);

  // Hidden lines - light gray dashed
  static const Color hiddenLine = Color(0xFFAAAAAA);

  // Section fill
  static const Color sectionFill = Color(0xFFE8E8E8);
  static const Color sectionHatch = Color(0xFFB8B8B8);

  // Panel fill
  static const Color panelFill = Color(0xFFFFE4C4);
  static const Color panelBorder = Color(0xFFD4A574);

  // Ground
  static const Color groundLine = Color(0xFF8B7355);
  static const Color groundFill = Color(0xFFF5F0E8);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFCCCCCC);
}

/// View mode for technical drawings
enum TechnicalViewMode { top, side, front, isometric, detail }

/// Technical sketch painter with comprehensive dimensions for construction
class TechnicalStructureSketchPainter extends CustomPainter {
  TechnicalStructureSketchPainter({
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.labels,
    this.viewMode = TechnicalViewMode.top,
    this.showAllDimensions = true,
    this.scale = 1.0,
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final TechnicalLabels labels;
  final TechnicalViewMode viewMode;
  final bool showAllDimensions;
  final double scale;

  // Drawing configuration
  static const double _lineWeightThin = 0.5;
  static const double _lineWeightMedium = 1.0;
  static const double _lineWeightThick = 1.5;
  static const double _dimensionOffset = 12.0;
  static const double _arrowSize = 4.0;
  static const double _extensionGap = 4.0;
  static const double _textSize = 9.0;
  static const double _titleSize = 11.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw border
    _drawBorder(canvas, size);

    // Draw based on view mode
    switch (viewMode) {
      case TechnicalViewMode.top:
        _paintTopView(canvas, size);
        break;
      case TechnicalViewMode.side:
        _paintSideView(canvas, size);
        break;
      case TechnicalViewMode.front:
        _paintFrontView(canvas, size);
        break;
      case TechnicalViewMode.isometric:
        _paintIsometricView(canvas, size);
        break;
      case TechnicalViewMode.detail:
        _paintDetailView(canvas, size);
        break;
    }

    // Draw title block
    _drawTitleBlock(canvas, size);
  }

  void _drawBorder(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    canvas.drawRect(
      rect,
      Paint()
        ..color = TechnicalColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWeightMedium,
    );
  }

  void _paintTopView(Canvas canvas, Size size) {
    final margin = 60.0;
    final drawingRect = Rect.fromLTWH(
      margin,
      margin,
      size.width - margin * 2,
      size.height - margin * 2 - 40,
    );

    // Calculate scale to fit
    final scaleX = drawingRect.width / siteWidthMeters;
    final scaleY = drawingRect.height / siteDepthMeters;
    final viewScale = math.min(scaleX, scaleY) * 0.85 * scale;

    final centerX = drawingRect.center.dx;
    final centerY = drawingRect.center.dy;

    // Site boundary
    final siteWidthPx = siteWidthMeters * viewScale;
    final siteDepthPx = siteDepthMeters * viewScale;
    final siteRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: siteWidthPx,
      height: siteDepthPx,
    );

    // Draw site boundary (light)
    canvas.drawRect(
      siteRect,
      Paint()
        ..color = TechnicalColors.lightLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWeightThin,
    );

    // Usable area
    final usableWidthPx = result.usableWidthMeters * viewScale;
    final usableDepthPx = result.usableDepthMeters * viewScale;
    final usableRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: usableWidthPx,
      height: usableDepthPx,
    );

    // Draw usable area with section fill
    canvas.drawRect(
      usableRect,
      Paint()
        ..color = TechnicalColors.groundFill
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      usableRect,
      Paint()
        ..color = TechnicalColors.secondaryLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWeightMedium,
    );

    // Draw center lines
    _drawCenterLine(
      canvas,
      Offset(usableRect.left, centerY),
      Offset(usableRect.right, centerY),
    );
    _drawCenterLine(
      canvas,
      Offset(centerX, usableRect.top),
      Offset(centerX, usableRect.bottom),
    );

    // Draw panels
    if (result.rows > 0 && result.columns > 0) {
      final cellWidth = usableRect.width / result.columns;
      final cellHeight = usableRect.height / result.rows;

      for (var row = 0; row < result.rows; row++) {
        for (var col = 0; col < result.columns; col++) {
          final panelRect = Rect.fromLTWH(
            usableRect.left + (col * cellWidth) + 1,
            usableRect.top + (row * cellHeight) + 1,
            cellWidth - 2,
            cellHeight - 2,
          );

          // Panel fill
          canvas.drawRect(
            panelRect,
            Paint()
              ..color = TechnicalColors.panelFill
              ..style = PaintingStyle.fill,
          );

          // Panel border
          canvas.drawRect(
            panelRect,
            Paint()
              ..color = TechnicalColors.panelBorder
              ..style = PaintingStyle.stroke
              ..strokeWidth = _lineWeightThin,
          );
        }
      }
    }

    // Draw support stations
    final supportCount = math.max(result.supportStationCount, 2);
    final rowDepthPx = result.projectedRowDepthMeters * viewScale;

    for (var row = 0; row < result.rows; row++) {
      final rowY =
          usableRect.top + (row + 0.5) * (usableRect.height / result.rows);
      final rowOffset = result.isUniformLegDesign
          ? 0.0
          : (result.rowResults.isNotEmpty && row < result.rowResults.length
                ? result.rowResults[row].baseOffsetMeters
                : 0.0);
      final rowOffsetPx = rowOffset * viewScale;

      for (var s = 0; s < supportCount; s++) {
        final t = supportCount == 1 ? 0.5 : s / (supportCount - 1);
        final supportX = usableRect.left + rowOffsetPx + (t * rowDepthPx);

        // Draw support station circle
        canvas.drawCircle(
          Offset(supportX, rowY),
          3,
          Paint()
            ..color = TechnicalColors.primaryLine
            ..style = PaintingStyle.fill,
        );
      }
    }

    if (!showAllDimensions) return;

    // Site dimensions
    _paintHorizontalDimension(
      canvas,
      start: Offset(siteRect.left, siteRect.bottom + _dimensionOffset),
      end: Offset(siteRect.right, siteRect.bottom + _dimensionOffset),
      label: '${siteWidthMeters.toStringAsFixed(2)}m',
    );
    _paintVerticalDimension(
      canvas,
      x: siteRect.right + _dimensionOffset,
      y1: siteRect.top,
      y2: siteRect.bottom,
      label: '${siteDepthMeters.toStringAsFixed(2)}m',
    );

    // Usable area dimensions
    _paintHorizontalDimension(
      canvas,
      start: Offset(usableRect.left, usableRect.top - _dimensionOffset * 2),
      end: Offset(usableRect.right, usableRect.top - _dimensionOffset * 2),
      label: '${result.usableWidthMeters.toStringAsFixed(2)}m',
    );
    _paintVerticalDimension(
      canvas,
      x: usableRect.left - _dimensionOffset * 2,
      y1: usableRect.top,
      y2: usableRect.bottom,
      label: '${result.usableDepthMeters.toStringAsFixed(2)}m',
    );

    // Panel grid dimensions
    if (result.columns > 1) {
      final cellWidth = usableRect.width / result.columns;
      _paintHorizontalDimension(
        canvas,
        start: Offset(
          usableRect.left,
          usableRect.bottom + _dimensionOffset * 2.5,
        ),
        end: Offset(
          usableRect.left + cellWidth,
          usableRect.bottom + _dimensionOffset * 2.5,
        ),
        label:
            '${(result.frameWidthMeters / result.columns).toStringAsFixed(2)}m',
      );
    }

    if (result.rows > 1) {
      final cellHeight = usableRect.height / result.rows;
      _paintVerticalDimension(
        canvas,
        x: usableRect.right + _dimensionOffset * 2.5,
        y1: usableRect.top,
        y2: usableRect.top + cellHeight,
        label:
            '${(result.usableDepthMeters / result.rows).toStringAsFixed(2)}m',
      );
    }

    // Row spacing dimension
    if (result.rows > 1) {
      _paintHorizontalDimension(
        canvas,
        start: Offset(usableRect.right + _dimensionOffset * 4, usableRect.top),
        end: Offset(
          usableRect.right + _dimensionOffset * 4,
          usableRect.top + (usableRect.height / result.rows),
        ),
        label: '${result.rowSpacingMeters.toStringAsFixed(2)}m',
        vertical: true,
      );
    }

    // Labels
    _paintLabel(canvas, labels.topView, Offset(8, 8), bold: true);
    _paintLabel(
      canvas,
      '${result.rows} ${labels.rows} x ${result.columns} ${labels.columns}',
      Offset(usableRect.left, usableRect.top - 20),
    );
    _paintLabel(
      canvas,
      '${result.panelCount} ${labels.panels}',
      Offset(usableRect.right - 60, usableRect.top - 20),
    );
  }

  void _paintSideView(Canvas canvas, Size size) {
    final margin = 50.0;
    final bottomMargin = 100.0;
    final drawingRect = Rect.fromLTWH(
      margin,
      margin,
      size.width - margin * 2,
      size.height - margin - bottomMargin,
    );

    // Calculate scale
    final totalDepth = result.totalFootprintDepthMeters;
    final maxHeight = result.maxRearLegHeightMeters;

    final scaleX = drawingRect.width / math.max(totalDepth, 1.0);
    final scaleY = drawingRect.height / math.max(maxHeight * 1.2, 1.0);
    final viewScale = math.min(scaleX, scaleY) * 0.9 * scale;

    final baseY = drawingRect.bottom;
    final startX =
        drawingRect.left + (drawingRect.width - totalDepth * viewScale) / 2;

    // Draw ground line
    final groundY = baseY + 10;
    _drawGroundLine(
      canvas,
      Offset(drawingRect.left - 20, groundY),
      Offset(drawingRect.right + 20, groundY),
    );

    // Draw rows
    final rowsToRender =
        result.isUniformLegDesign && result.rowResults.isNotEmpty
        ? <RowFrameResult>[result.rowResults.first]
        : result.rowResults;

    var currentX = startX;

    for (var i = 0; i < rowsToRender.length; i++) {
      final row = rowsToRender[i];
      final frontHeightPx = row.frontLegHeightMeters * viewScale;
      final rearHeightPx = row.rearLegHeightMeters * viewScale;
      final rowDepthPx = result.projectedRowDepthMeters * viewScale;

      final frontX = currentX;
      final rearX = currentX + rowDepthPx;
      final frontTopY = baseY - frontHeightPx;
      final rearTopY = baseY - rearHeightPx;

      // Draw legs (thick lines)
      _drawThickLine(canvas, Offset(frontX, baseY), Offset(frontX, frontTopY));
      _drawThickLine(canvas, Offset(rearX, baseY), Offset(rearX, rearTopY));

      // Draw frame (thick line)
      _drawThickLine(
        canvas,
        Offset(frontX, frontTopY),
        Offset(rearX, rearTopY),
      );

      // Draw braces
      _drawMediumLine(
        canvas,
        Offset(frontX, baseY),
        Offset(rearX - 8, rearTopY),
      );

      // Draw base plates
      _drawBasePlate(canvas, Offset(frontX, baseY), width: 12);
      _drawBasePlate(canvas, Offset(rearX, baseY), width: 12);

      // Draw panel outline
      final panelThickness = 8.0;
      final panelPath = Path()
        ..moveTo(frontX, frontTopY)
        ..lineTo(rearX, rearTopY)
        ..lineTo(rearX, rearTopY + panelThickness)
        ..lineTo(frontX, frontTopY + panelThickness)
        ..close();

      canvas.drawPath(
        panelPath,
        Paint()
          ..color = TechnicalColors.panelFill
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        panelPath,
        Paint()
          ..color = TechnicalColors.panelBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineWeightThin,
      );

      // Dimensions for each row
      if (showAllDimensions) {
        // Front leg height
        _paintVerticalDimension(
          canvas,
          x: frontX - _dimensionOffset - (i * 25),
          y1: baseY,
          y2: frontTopY,
          label: '${row.frontLegHeightMeters.toStringAsFixed(2)}m',
        );

        // Rear leg height
        _paintVerticalDimension(
          canvas,
          x: rearX + _dimensionOffset + (i * 25),
          y1: baseY,
          y2: rearTopY,
          label: '${row.rearLegHeightMeters.toStringAsFixed(2)}m',
        );

        // Row depth
        _paintHorizontalDimension(
          canvas,
          start: Offset(frontX, groundY + _dimensionOffset + (i * 20)),
          end: Offset(rearX, groundY + _dimensionOffset + (i * 20)),
          label: '${result.projectedRowDepthMeters.toStringAsFixed(2)}m',
        );

        // Row offset if stepped
        if (!result.isUniformLegDesign) {
          _paintHorizontalDimension(
            canvas,
            start: Offset(frontX, groundY + _dimensionOffset + 40),
            end: Offset(
              frontX + (row.baseOffsetMeters * viewScale),
              groundY + _dimensionOffset + 40,
            ),
            label:
                '${labels.offset} ${row.baseOffsetMeters.toStringAsFixed(2)}m',
          );
        }

        // Frame slope length
        _paintAlignedDimension(
          canvas,
          p1: Offset(frontX, frontTopY),
          p2: Offset(rearX, rearTopY),
          label: '${result.frameSlopeLengthMeters.toStringAsFixed(2)}m',
          offset: -25,
        );
      }

      currentX = rearX + (result.rowSpacingMeters * viewScale);
    }

    // Total footprint dimension
    if (showAllDimensions && rowsToRender.isNotEmpty) {
      _paintHorizontalDimension(
        canvas,
        start: Offset(startX, groundY + _dimensionOffset + 70),
        end: Offset(
          startX + (result.totalFootprintDepthMeters * viewScale),
          groundY + _dimensionOffset + 70,
        ),
        label:
            '${labels.totalDepth} ${result.totalFootprintDepthMeters.toStringAsFixed(2)}m',
      );
    }

    // Labels
    _paintLabel(canvas, labels.sideView, Offset(8, 8), bold: true);
    _paintLabel(
      canvas,
      labels.groundLevel,
      Offset(drawingRect.left - 40, groundY - 5),
    );
  }

  void _paintFrontView(Canvas canvas, Size size) {
    final margin = 50.0;
    final bottomMargin = 80.0;
    final drawingRect = Rect.fromLTWH(
      margin,
      margin,
      size.width - margin * 2,
      size.height - margin - bottomMargin,
    );

    // Calculate scale
    final frontHeight = result.isUniformLegDesign
        ? result.frontLegHeightMeters
        : (result.minFrontLegHeightMeters + result.maxFrontLegHeightMeters) / 2;
    final rearHeight = result.isUniformLegDesign
        ? result.rearLegHeightMeters
        : (result.minRearLegHeightMeters + result.maxRearLegHeightMeters) / 2;

    final maxHeight = math.max(frontHeight, rearHeight);
    final scaleY = drawingRect.height / math.max(maxHeight * 1.15, 1.0);
    final viewScale = scaleY * scale;

    final baseY = drawingRect.bottom;
    final centerX = drawingRect.center.dx;
    const halfWidth = 80.0; // Fixed visual width for front view

    final leftX = centerX - halfWidth;
    final rightX = centerX + halfWidth;

    final frontTopY = baseY - (frontHeight * viewScale);
    final rearTopY = baseY - (rearHeight * viewScale);

    // Draw ground line
    final groundY = baseY + 10;
    _drawGroundLine(
      canvas,
      Offset(leftX - 30, groundY),
      Offset(rightX + 30, groundY),
    );

    // Draw legs
    _drawThickLine(canvas, Offset(leftX, baseY), Offset(leftX, frontTopY));
    _drawThickLine(canvas, Offset(rightX, baseY), Offset(rightX, rearTopY));

    // Draw frame
    _drawThickLine(canvas, Offset(leftX, frontTopY), Offset(rightX, rearTopY));

    // Draw base plates
    _drawBasePlate(canvas, Offset(leftX, baseY), width: 14);
    _drawBasePlate(canvas, Offset(rightX, baseY), width: 14);

    // Draw panels
    final columns = math.max(result.columns, 1);
    final panelWidth = (rightX - leftX) / columns;

    for (var col = 0; col < columns; col++) {
      final panelLeft = leftX + (col * panelWidth);
      final panelHeight = 20.0;
      final panelTop = frontTopY + ((rearTopY - frontTopY) * (col / columns));

      final panelRect = Rect.fromLTWH(
        panelLeft + 2,
        panelTop,
        panelWidth - 4,
        panelHeight,
      );

      canvas.drawRect(
        panelRect,
        Paint()
          ..color = TechnicalColors.panelFill
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        panelRect,
        Paint()
          ..color = TechnicalColors.panelBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineWeightThin,
      );
    }

    // Draw support stations
    final supportCount = math.max(result.supportStationCount, 2);
    for (var i = 0; i < supportCount; i++) {
      final t = supportCount == 1 ? 0.0 : i / (supportCount - 1);
      final supportX = leftX + (t * (rightX - leftX));
      final supportTopY = frontTopY + (t * (rearTopY - frontTopY));

      _drawMediumLine(
        canvas,
        Offset(supportX, baseY),
        Offset(supportX, supportTopY),
      );
    }

    if (!showAllDimensions) return;

    // Width dimension
    _paintHorizontalDimension(
      canvas,
      start: Offset(leftX, groundY + _dimensionOffset),
      end: Offset(rightX, groundY + _dimensionOffset),
      label: '${result.frameWidthMeters.toStringAsFixed(2)}m',
    );

    // Heights
    _paintVerticalDimension(
      canvas,
      x: leftX - _dimensionOffset,
      y1: baseY,
      y2: frontTopY,
      label: '${frontHeight.toStringAsFixed(2)}m',
    );
    _paintVerticalDimension(
      canvas,
      x: rightX + _dimensionOffset,
      y1: baseY,
      y2: rearTopY,
      label: '${rearHeight.toStringAsFixed(2)}m',
    );

    // Support spacing
    if (supportCount > 1) {
      final firstSupportX = leftX;
      final secondSupportX = leftX + ((rightX - leftX) / (supportCount - 1));
      _paintHorizontalDimension(
        canvas,
        start: Offset(firstSupportX, groundY + _dimensionOffset * 2.5),
        end: Offset(secondSupportX, groundY + _dimensionOffset * 2.5),
        label: '${result.supportSpacingMeters.toStringAsFixed(2)}m',
      );
    }

    // Tilt angle annotation
    final tiltAngle = result.appliedTiltDegrees;
    _paintAngleArc(
      canvas,
      center: Offset(leftX, frontTopY),
      startAngle: -90,
      sweepAngle: -tiltAngle,
      radius: 30,
    );
    _paintLabel(
      canvas,
      '${tiltAngle.toStringAsFixed(1)}°',
      Offset(leftX + 15, frontTopY - 35),
    );

    // Labels
    _paintLabel(canvas, labels.frontView, Offset(8, 8), bold: true);
  }

  void _paintIsometricView(Canvas canvas, Size size) {
    final margin = 50.0;
    final drawingRect = Rect.fromLTWH(
      margin,
      margin + 20,
      size.width - margin * 2,
      size.height - margin * 2 - 20,
    );

    // Isometric projection parameters
    final isoScale =
        math.min(drawingRect.width, drawingRect.height) /
        math.max(
          result.frameWidthMeters * 1.5,
          result.totalFootprintDepthMeters * 1.5,
        ) *
        0.6 *
        scale;

    final origin = Offset(
      drawingRect.center.dx - (result.frameWidthMeters * isoScale * 0.3),
      drawingRect.bottom - 40,
    );

    // Isometric axes
    final xAxis = Offset(
      result.frameWidthMeters * isoScale * 0.866,
      -result.frameWidthMeters * isoScale * 0.5,
    );
    final yAxis = Offset(
      result.projectedRowDepthMeters * isoScale * 0.866,
      result.projectedRowDepthMeters * isoScale * 0.5,
    );

    final frontLegHeightPx = result.frontLegHeightMeters * isoScale * 1.5;
    final rearLegHeightPx = result.rearLegHeightMeters * isoScale * 1.5;
    final zFront = Offset(0, -frontLegHeightPx);
    final zRear = Offset(0, -rearLegHeightPx);

    // Calculate corners
    final frontLeft = origin;
    final frontRight = origin + xAxis;
    final backLeft = origin + yAxis;
    final backRight = origin + xAxis + yAxis;

    final topFrontLeft = frontLeft + zFront;
    final topFrontRight = frontRight + zFront;
    final topBackLeft = backLeft + zRear;
    final topBackRight = backRight + zRear;

    // Draw base frame
    _drawMediumLine(canvas, frontLeft, frontRight);
    _drawMediumLine(canvas, frontLeft, backLeft);
    _drawMediumLine(canvas, frontRight, backRight);
    _drawHiddenLine(canvas, backLeft, backRight);

    // Draw legs
    _drawThickLine(canvas, frontLeft, topFrontLeft);
    _drawThickLine(canvas, frontRight, topFrontRight);
    _drawThickLine(canvas, backLeft, topBackLeft);
    _drawThickLine(canvas, backRight, topBackRight);

    // Draw top frame
    _drawThickLine(canvas, topFrontLeft, topFrontRight);
    _drawThickLine(canvas, topFrontLeft, topBackLeft);
    _drawThickLine(canvas, topFrontRight, topBackRight);
    _drawThickLine(canvas, topBackLeft, topBackRight);

    // Draw panel surface with fill
    final topPath = Path()
      ..moveTo(topFrontLeft.dx, topFrontLeft.dy)
      ..lineTo(topFrontRight.dx, topFrontRight.dy)
      ..lineTo(topBackRight.dx, topBackRight.dy)
      ..lineTo(topBackLeft.dx, topBackLeft.dy)
      ..close();

    canvas.drawPath(
      topPath,
      Paint()
        ..color = TechnicalColors.panelFill.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      topPath,
      Paint()
        ..color = TechnicalColors.panelBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWeightMedium,
    );

    // Draw support stations
    final supportCount = math.max(result.supportStationCount, 2);
    for (var i = 0; i < supportCount; i++) {
      final t = supportCount == 1 ? 0.0 : i / (supportCount - 1);
      final baseFront = frontLeft + (xAxis * t);
      final baseRear = backLeft + (xAxis * t);
      final topFront = baseFront + zFront;
      final topRear = baseRear + zRear;

      _drawMediumLine(canvas, baseFront, topFront);
      _drawMediumLine(canvas, baseRear, topRear);
      _drawMediumLine(canvas, topFront, topRear);

      // Braces
      _drawLightLine(canvas, baseFront, topRear);
      if (i == 0 || i == supportCount - 1) {
        _drawLightLine(canvas, baseRear, topFront);
      }
    }

    // Dimension lines
    if (showAllDimensions) {
      // Width
      _paintIsometricDimension(
        canvas,
        frontLeft,
        frontRight,
        '${result.frameWidthMeters.toStringAsFixed(2)}m',
        offset: 20,
      );

      // Depth
      _paintIsometricDimension(
        canvas,
        frontLeft,
        backLeft,
        '${result.projectedRowDepthMeters.toStringAsFixed(2)}m',
        offset: 20,
      );

      // Heights
      _paintLabel(
        canvas,
        '${result.frontLegHeightMeters.toStringAsFixed(2)}m',
        Offset(frontLeft.dx - 40, (frontLeft.dy + topFrontLeft.dy) / 2),
      );
      _paintLabel(
        canvas,
        '${result.rearLegHeightMeters.toStringAsFixed(2)}m',
        Offset(backRight.dx + 10, (backRight.dy + topBackRight.dy) / 2),
      );
    }

    // Labels
    _paintLabel(canvas, labels.isometricView, Offset(8, 8), bold: true);
    _paintLabel(
      canvas,
      '${result.rows} x ${result.columns}',
      Offset(drawingRect.left, drawingRect.top),
    );
  }

  void _paintDetailView(Canvas canvas, Size size) {
    // Detail view showing connection details
    final center = Offset(size.width / 2, size.height / 2);

    // Draw title
    _paintLabel(canvas, labels.detailView, Offset(8, 8), bold: true);

    // Base plate detail
    _drawBasePlateDetail(canvas, center.translate(-80, 0));

    // Leg connection detail
    _drawLegConnectionDetail(canvas, center.translate(80, 0));
  }

  void _drawBasePlateDetail(Canvas canvas, Offset center) {
    final plateWidth = 60.0;
    final plateHeight = 40.0;
    final plateRect = Rect.fromCenter(
      center: center,
      width: plateWidth,
      height: plateHeight,
    );

    // Plate
    canvas.drawRect(
      plateRect,
      Paint()
        ..color = TechnicalColors.sectionFill
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      plateRect,
      Paint()
        ..color = TechnicalColors.primaryLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWeightThick,
    );

    // Anchor bolts
    for (final dx in [-20.0, 20.0]) {
      for (final dy in [-12.0, 12.0]) {
        canvas.drawCircle(
          center.translate(dx, dy),
          4,
          Paint()
            ..color = TechnicalColors.primaryLine
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Leg
    canvas.drawRect(
      Rect.fromCenter(
        center: center.translate(0, -plateHeight / 2 - 20),
        width: 16,
        height: 40,
      ),
      Paint()
        ..color = TechnicalColors.sectionFill
        ..style = PaintingStyle.fill,
    );

    _paintLabel(
      canvas,
      labels.basePlateDetail,
      Offset(center.dx - 30, center.dy + plateHeight / 2 + 10),
    );
  }

  void _drawLegConnectionDetail(Canvas canvas, Offset center) {
    // Simplified connection detail
    final legWidth = 20.0;
    final legHeight = 80.0;

    final legRect = Rect.fromCenter(
      center: center,
      width: legWidth,
      height: legHeight,
    );

    canvas.drawRect(
      legRect,
      Paint()
        ..color = TechnicalColors.sectionFill
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      legRect,
      Paint()
        ..color = TechnicalColors.primaryLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWeightMedium,
    );

    _paintLabel(
      canvas,
      labels.legDetail,
      Offset(center.dx - 20, center.dy + legHeight / 2 + 10),
    );
  }

  void _drawTitleBlock(Canvas canvas, Size size) {
    final blockHeight = 36.0;
    final blockWidth = 180.0;
    final blockRect = Rect.fromLTWH(
      size.width - blockWidth - 8,
      size.height - blockHeight - 8,
      blockWidth,
      blockHeight,
    );

    canvas.drawRect(
      blockRect,
      Paint()
        ..color = TechnicalColors.background
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      blockRect,
      Paint()
        ..color = TechnicalColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWeightThin,
    );

    _paintLabel(
      canvas,
      '${labels.scale} 1:${(1 / scale).toStringAsFixed(0)}',
      Offset(blockRect.left + 4, blockRect.top + 4),
    );
    _paintLabel(
      canvas,
      '${labels.date} ${DateTime.now().toString().split(' ')[0]}',
      Offset(blockRect.left + 4, blockRect.top + 18),
    );
  }

  // Helper methods

  void _drawThickLine(Canvas canvas, Offset p1, Offset p2) {
    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = TechnicalColors.thickLine
        ..strokeWidth = _lineWeightThick
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawMediumLine(Canvas canvas, Offset p1, Offset p2) {
    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = TechnicalColors.primaryLine
        ..strokeWidth = _lineWeightMedium
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawLightLine(Canvas canvas, Offset p1, Offset p2) {
    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = TechnicalColors.secondaryLine
        ..strokeWidth = _lineWeightThin
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawHiddenLine(Canvas canvas, Offset p1, Offset p2) {
    final paint = Paint()
      ..color = TechnicalColors.hiddenLine
      ..strokeWidth = _lineWeightThin
      ..strokeCap = StrokeCap.butt;

    final path = Path();
    final distance = (p2 - p1).distance;
    final direction = (p2 - p1) / distance;
    const dashLength = 8.0;
    const gapLength = 4.0;

    var current = 0.0;
    var isDash = true;

    while (current < distance) {
      final segmentLength = isDash ? dashLength : gapLength;
      final end = math.min(current + segmentLength, distance);

      if (isDash) {
        path.moveTo(
          p1.dx + direction.dx * current,
          p1.dy + direction.dy * current,
        );
        path.lineTo(p1.dx + direction.dx * end, p1.dy + direction.dy * end);
      }

      current = end;
      isDash = !isDash;
    }

    canvas.drawPath(path, paint);
  }

  void _drawCenterLine(Canvas canvas, Offset p1, Offset p2) {
    final paint = Paint()
      ..color = TechnicalColors.centerLine
      ..strokeWidth = _lineWeightThin;

    // Draw dash-dot pattern
    final path = Path();
    final distance = (p2 - p1).distance;
    final direction = (p2 - p1) / distance;
    const longDash = 15.0;
    const shortDash = 3.0;
    const gap = 3.0;

    var current = 0.0;
    var phase = 0; // 0: long dash, 1: gap, 2: short dash, 3: gap

    while (current < distance) {
      double segmentLength;
      switch (phase) {
        case 0:
          segmentLength = longDash;
          break;
        case 1:
          segmentLength = gap;
          break;
        case 2:
          segmentLength = shortDash;
          break;
        default:
          segmentLength = gap;
          break;
      }

      final end = math.min(current + segmentLength, distance);

      if (phase == 0 || phase == 2) {
        path.moveTo(
          p1.dx + direction.dx * current,
          p1.dy + direction.dy * current,
        );
        path.lineTo(p1.dx + direction.dx * end, p1.dy + direction.dy * end);
      }

      current = end;
      phase = (phase + 1) % 4;
    }

    canvas.drawPath(path, paint);
  }

  void _drawGroundLine(Canvas canvas, Offset p1, Offset p2) {
    // Solid line
    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = TechnicalColors.groundLine
        ..strokeWidth = _lineWeightMedium,
    );

    // Hatching below
    final paint = Paint()
      ..color = TechnicalColors.groundLine
      ..strokeWidth = _lineWeightThin;

    final spacing = 6.0;
    final angle = 0.785; // 45 degrees
    final dx = math.cos(angle) * spacing;
    final dy = math.sin(angle) * spacing;

    for (var i = -10; i < 30; i++) {
      final start = Offset(p1.dx + (i * dx), p1.dy + 4 + (i * dy));
      canvas.drawLine(start, start.translate(20, -20), paint);
    }
  }

  void _drawBasePlate(Canvas canvas, Offset center, {required double width}) {
    final rect = Rect.fromCenter(
      center: center.translate(0, 4),
      width: width,
      height: 8,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..color = TechnicalColors.sectionFill
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = TechnicalColors.primaryLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWeightMedium,
    );
  }

  void _paintHorizontalDimension(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required String label,
    bool vertical = false,
  }) {
    final paint = Paint()
      ..color = TechnicalColors.dimensionLine
      ..strokeWidth = _lineWeightThin;

    if (vertical) {
      // Vertical dimension (horizontal text)
      canvas.drawLine(start, end, paint);
      _drawArrowhead(canvas, start, end, paint);
      _drawArrowhead(canvas, end, start, paint);

      final midY = (start.dy + end.dy) / 2;
      _paintDimensionText(
        canvas,
        label,
        Offset(start.dx + 6, midY - 5),
        vertical: true,
      );
    } else {
      // Standard horizontal dimension
      // Extension lines
      canvas.drawLine(
        start.translate(0, -_extensionGap),
        start.translate(0, -_dimensionOffset),
        paint,
      );
      canvas.drawLine(
        end.translate(0, -_extensionGap),
        end.translate(0, -_dimensionOffset),
        paint,
      );

      // Dimension line
      final dimY = start.dy - _dimensionOffset;
      canvas.drawLine(Offset(start.dx, dimY), Offset(end.dx, dimY), paint);

      // Arrowheads
      _drawArrowhead(
        canvas,
        Offset(start.dx, dimY),
        Offset(end.dx, dimY),
        paint,
      );
      _drawArrowhead(
        canvas,
        Offset(end.dx, dimY),
        Offset(start.dx, dimY),
        paint,
      );

      // Text
      final midX = (start.dx + end.dx) / 2;
      _paintDimensionText(canvas, label, Offset(midX - 15, dimY - 14));
    }
  }

  void _paintVerticalDimension(
    Canvas canvas, {
    required double x,
    required double y1,
    required double y2,
    required String label,
  }) {
    final paint = Paint()
      ..color = TechnicalColors.dimensionLine
      ..strokeWidth = _lineWeightThin;

    // Extension lines
    final direction = x < (y1 + y2) / 2 ? 1 : -1;
    final extX = x + (_extensionGap * direction);
    final dimX = x + (_dimensionOffset * direction);

    canvas.drawLine(Offset(extX, y1), Offset(dimX, y1), paint);
    canvas.drawLine(Offset(extX, y2), Offset(dimX, y2), paint);

    // Dimension line
    canvas.drawLine(Offset(dimX, y1), Offset(dimX, y2), paint);

    // Arrowheads
    _drawArrowhead(canvas, Offset(dimX, y1), Offset(dimX, y2), paint);
    _drawArrowhead(canvas, Offset(dimX, y2), Offset(dimX, y1), paint);

    // Text
    final midY = (y1 + y2) / 2;
    _paintDimensionText(
      canvas,
      label,
      Offset(dimX - (direction > 0 ? 45 : 5), midY - 5),
    );
  }

  void _paintAlignedDimension(
    Canvas canvas, {
    required Offset p1,
    required Offset p2,
    required String label,
    required double offset,
  }) {
    final paint = Paint()
      ..color = TechnicalColors.dimensionLine
      ..strokeWidth = _lineWeightThin;

    // Calculate perpendicular offset
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final perpX = (-dy / length) * offset;
    final perpY = (dx / length) * offset;

    final start = p1.translate(perpX, perpY);
    final end = p2.translate(perpX, perpY);

    // Extension lines
    canvas.drawLine(p1, start, paint);
    canvas.drawLine(p2, end, paint);

    // Dimension line
    canvas.drawLine(start, end, paint);

    // Arrowheads
    _drawArrowhead(canvas, start, end, paint);
    _drawArrowhead(canvas, end, start, paint);

    // Text
    final midX = (start.dx + end.dx) / 2;
    final midY = (start.dy + end.dy) / 2;
    _paintDimensionText(canvas, label, Offset(midX - 20, midY - 12));
  }

  void _paintIsometricDimension(
    Canvas canvas,
    Offset p1,
    Offset p2,
    String label, {
    required double offset,
  }) {
    final paint = Paint()
      ..color = TechnicalColors.dimensionLine
      ..strokeWidth = _lineWeightThin;

    // Simple offset parallel to line
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final length = math.sqrt(dx * dx + dy * dy);

    final offsetX = (dy / length) * offset;
    final offsetY = (-dx / length) * offset;

    final start = p1.translate(offsetX, offsetY);
    final end = p2.translate(offsetX, offsetY);

    canvas.drawLine(start, end, paint);
    _drawArrowhead(canvas, start, end, paint);
    _drawArrowhead(canvas, end, start, paint);

    final midX = (start.dx + end.dx) / 2;
    final midY = (start.dy + end.dy) / 2;
    _paintDimensionText(canvas, label, Offset(midX - 20, midY - 10));
  }

  void _drawArrowhead(Canvas canvas, Offset from, Offset to, Paint paint) {
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    final arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..lineTo(
        from.dx + _arrowSize * math.cos(angle - math.pi / 6),
        from.dy + _arrowSize * math.sin(angle - math.pi / 6),
      )
      ..lineTo(
        from.dx + _arrowSize * math.cos(angle + math.pi / 6),
        from.dy + _arrowSize * math.sin(angle + math.pi / 6),
      )
      ..close();

    canvas.drawPath(path, arrowPaint);
  }

  void _paintAngleArc(
    Canvas canvas, {
    required Offset center,
    required double startAngle,
    required double sweepAngle,
    required double radius,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = TechnicalColors.dimensionLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = _lineWeightThin;

    canvas.drawArc(
      rect,
      (startAngle * math.pi) / 180,
      (sweepAngle * math.pi) / 180,
      false,
      paint,
    );
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: TechnicalColors.primaryLine,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: bold ? _titleSize : _textSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _paintDimensionText(
    Canvas canvas,
    String text,
    Offset offset, {
    bool vertical = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: TechnicalColors.dimensionText,
          fontWeight: FontWeight.w600,
          fontSize: _textSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Background for readability
    final bgRect = Rect.fromLTWH(
      offset.dx - 2,
      offset.dy - 1,
      painter.width + 4,
      painter.height + 2,
    );
    canvas.drawRect(bgRect, Paint()..color = TechnicalColors.background);

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant TechnicalStructureSketchPainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.siteWidthMeters != siteWidthMeters ||
        oldDelegate.siteDepthMeters != siteDepthMeters ||
        oldDelegate.viewMode != viewMode ||
        oldDelegate.showAllDimensions != showAllDimensions ||
        oldDelegate.scale != scale;
  }
}

/// Labels for technical drawings
class TechnicalLabels {
  const TechnicalLabels({
    required this.topView,
    required this.sideView,
    required this.frontView,
    required this.isometricView,
    required this.detailView,
    required this.rows,
    required this.columns,
    required this.panels,
    required this.offset,
    required this.totalDepth,
    required this.groundLevel,
    required this.scale,
    required this.date,
    required this.basePlateDetail,
    required this.legDetail,
  });

  final String topView;
  final String sideView;
  final String frontView;
  final String isometricView;
  final String detailView;
  final String rows;
  final String columns;
  final String panels;
  final String offset;
  final String totalDepth;
  final String groundLevel;
  final String scale;
  final String date;
  final String basePlateDetail;
  final String legDetail;
}
