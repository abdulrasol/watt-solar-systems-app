import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/row_frame_result.dart';

/// Enhanced color palette for professional engineering sketches
class SketchColors {
  // Panel colors - warm orange gradient
  static const Color panelGradientStart = Color(0xFFFFB347);
  static const Color panelGradientEnd = Color(0xFFFF8C42);
  static const Color panelBorder = Color(0xFFE67E22);

  // Structure colors - steel blue-gray
  static const Color legColor = Color(0xFF5A6B7A);
  static const Color legHighlight = Color(0xFF7A8B9A);
  static const Color frameColor = Color(0xFF365A6B);
  static const Color frameHighlight = Color(0xFF4A7A8B);

  // Brace colors - lighter steel
  static const Color braceColor = Color(0xFF8BA3B0);
  static const Color braceHighlight = Color(0xFFA5BDC8);

  // Dimension colors
  static const Color dimensionColor = Color(0xFF6B8E99);
  static const Color dimensionText = Color(0xFF4A6572);

  // Background colors
  static const Color groundColor = Color(0xFFE8F0E8);
  static const Color workAreaColor = Color(0xFFEAF4F8);
  static const Color usableAreaColor = Color(0xFFDCEFD8);

  // Text colors
  static const Color titleColor = Color(0xFF38515E);
  static const Color labelColor = Color(0xFF466977);
  static const Color valueColor = Color(0xFF2C3E50);

  // UI colors
  static const Color cardBackground = Color(0xFFF9FBFC);
  static const Color cardBorder = Color(0xFFDDE5EA);
  static const Color shadowColor = Color(0x1A000000);
}

/// Detail level for sketch rendering
enum SketchDetailLevel { preview, detailed }

/// View mode for sketch display
enum StructureSketchView { top, side, front, isometric }

/// Enhanced CustomPainter for structure design sketches with professional
/// engineering drawing standards
class StructureSketchPainter extends CustomPainter {
  StructureSketchPainter({
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.topViewLabel,
    required this.sideViewLabel,
    required this.frontViewLabel,
    required this.isometricViewLabel,
    required this.frontLabel,
    required this.rearLabel,
    required this.braceLabel,
    this.detailLevel = SketchDetailLevel.preview,
    this.repeatedRowLabel,
    this.rowOffsetLabel,
    this.viewMode,
    this.showShadows = true,
    this.showGradients = true,
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final String topViewLabel;
  final String sideViewLabel;
  final String frontViewLabel;
  final String isometricViewLabel;
  final String frontLabel;
  final String rearLabel;
  final String braceLabel;
  final SketchDetailLevel detailLevel;
  final String? repeatedRowLabel;
  final String? rowOffsetLabel;
  final StructureSketchView? viewMode;
  final bool showShadows;
  final bool showGradients;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw card background with rounded corners
    _drawCardBackground(canvas, size);

    // If viewMode is specified, draw only that view
    if (viewMode != null) {
      final viewRect = Rect.fromLTWH(16, 16, size.width - 32, size.height - 32);
      switch (viewMode!) {
        case StructureSketchView.top:
          _paintTopView(canvas, viewRect, showTitle: false);
        case StructureSketchView.side:
          _paintSideView(canvas, viewRect, showTitle: false);
        case StructureSketchView.front:
          _paintFrontView(canvas, viewRect, showTitle: false);
        case StructureSketchView.isometric:
          _paintIsometricView(canvas, viewRect, showTitle: false);
      }
      return;
    }

    // Draw all four views in a grid layout
    _paintAllViews(canvas, size);
  }

  void _drawCardBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Background with subtle gradient
    final backgroundPaint = Paint()
      ..color = SketchColors.cardBackground
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));
    canvas.drawRRect(rrect, backgroundPaint);

    // Border
    final borderPaint = Paint()
      ..color = SketchColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, borderPaint);

    // Subtle shadow
    if (showShadows) {
      final shadowPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            rect.shift(const Offset(0, 2)),
            const Radius.circular(18),
          ),
        );
      final shadowPaint = Paint()
        ..color = SketchColors.shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(shadowPath, shadowPaint);
    }
  }

  void _paintAllViews(Canvas canvas, Size size) {
    final contentRect = Rect.fromLTWH(16, 16, size.width - 32, size.height - 32);
    final gap = detailLevel == SketchDetailLevel.detailed ? 14.0 : 10.0;

    // Top view takes top half
    final topHeight = detailLevel == SketchDetailLevel.detailed
        ? contentRect.height * 0.42
        : contentRect.height * 0.46;
    final topRect = Rect.fromLTWH(
      contentRect.left,
      contentRect.top,
      contentRect.width,
      topHeight,
    );

    // Bottom half split between side and front/isometric
    final lowerTop = topRect.bottom + gap;
    final lowerHeight = contentRect.bottom - lowerTop;
    final halfWidth = (contentRect.width - gap) / 2;

    final sideRect = Rect.fromLTWH(
      contentRect.left,
      lowerTop,
      halfWidth,
      lowerHeight,
    );

    final rightRect = Rect.fromLTWH(
      contentRect.left + halfWidth + gap,
      lowerTop,
      halfWidth,
      lowerHeight,
    );

    final rightGap = detailLevel == SketchDetailLevel.detailed ? 12.0 : 8.0;
    final frontHeight = (rightRect.height - rightGap) / 2;
    final frontRect = Rect.fromLTWH(
      rightRect.left,
      rightRect.top,
      rightRect.width,
      frontHeight,
    );
    final isoRect = Rect.fromLTWH(
      rightRect.left,
      rightRect.top + frontHeight + rightGap,
      rightRect.width,
      frontHeight,
    );

    _paintTopView(canvas, topRect);
    _paintSideView(canvas, sideRect);
    _paintFrontView(canvas, frontRect);
    _paintIsometricView(canvas, isoRect);
  }

  void _paintTopView(Canvas canvas, Rect rect, {bool showTitle = true}) {
    if (showTitle) {
      _paintTitle(canvas, topViewLabel, Offset(rect.left, rect.top));
    }

    final frameTop = rect.top + (showTitle ? 22 : 0);
    final drawingRect = Rect.fromLTWH(
      rect.left,
      frameTop,
      rect.width,
      rect.height - (showTitle ? 22 : 0),
    );

    final workRect = Rect.fromLTWH(
      drawingRect.left + 8,
      drawingRect.top + 8,
      drawingRect.width - 16,
      drawingRect.height - 16,
    );

    // Work area background
    canvas.drawRRect(
      RRect.fromRectAndRadius(workRect, const Radius.circular(12)),
      Paint()..color = SketchColors.workAreaColor,
    );

    // Calculate usable area
    final usableWidthRatio = siteWidthMeters <= 0
        ? 0.0
        : result.usableWidthMeters / siteWidthMeters;
    final usableDepthRatio = siteDepthMeters <= 0
        ? 0.0
        : result.usableDepthMeters / siteDepthMeters;

    final usableRect = Rect.fromLTWH(
      workRect.left + (workRect.width * (1 - usableWidthRatio) / 2),
      workRect.top + (workRect.height * (1 - usableDepthRatio) / 2),
      workRect.width * usableWidthRatio,
      workRect.height * usableDepthRatio,
    );

    // Usable area with gradient
    if (showGradients) {
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          SketchColors.usableAreaColor.withValues(alpha: 0.8),
          SketchColors.usableAreaColor,
        ],
      );
      final shader = gradient.createShader(usableRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(usableRect, const Radius.circular(10)),
        Paint()..shader = shader,
      );
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(usableRect, const Radius.circular(10)),
        Paint()..color = SketchColors.usableAreaColor,
      );
    }

    if (result.rows == 0 || result.columns == 0) return;

    // Draw panels with gradient
    final cellWidth = usableRect.width / result.columns;
    final cellHeight = usableRect.height / result.rows;

    for (var row = 0; row < result.rows; row++) {
      for (var col = 0; col < result.columns; col++) {
        final panelRect = Rect.fromLTWH(
          usableRect.left + (col * cellWidth) + 2,
          usableRect.top + (row * cellHeight) + 2,
          math.max(4, cellWidth - 4),
          math.max(4, cellHeight - 4),
        );

        if (showGradients) {
          final gradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              SketchColors.panelGradientStart,
              SketchColors.panelGradientEnd,
            ],
          );
          final shader = gradient.createShader(panelRect);
          canvas.drawRRect(
            RRect.fromRectAndRadius(panelRect, const Radius.circular(4)),
            Paint()
              ..shader = shader
              ..style = PaintingStyle.fill,
          );
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(panelRect, const Radius.circular(4)),
            Paint()..color = SketchColors.panelGradientStart,
          );
        }

        // Panel border
        canvas.drawRRect(
          RRect.fromRectAndRadius(panelRect, const Radius.circular(4)),
          Paint()
            ..color = SketchColors.panelBorder
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );
      }
    }

    // Draw dimensions in detailed mode
    if (detailLevel == SketchDetailLevel.detailed) {
      _paintDimensionLine(
        canvas,
        start: Offset(usableRect.left, usableRect.bottom + 10),
        end: Offset(usableRect.right, usableRect.bottom + 10),
        label: '${result.frameWidthMeters.toStringAsFixed(2)} m',
      );
      _paintVerticalDimension(
        canvas,
        x: usableRect.right + 12,
        baseY: usableRect.bottom,
        topY: usableRect.top,
        label: '${result.totalFootprintDepthMeters.toStringAsFixed(2)} m',
      );

      if (result.rows > 1) {
        final rowPitch = usableRect.height / result.rows;
        _paintSmallLabel(
          canvas,
          '${result.rows} rows',
          Offset(usableRect.left + 4, usableRect.top + 4),
        );
        _paintSmallLabel(
          canvas,
          '${result.rowSpacingMeters.toStringAsFixed(2)} m gap',
          Offset(usableRect.left + 4, usableRect.top + rowPitch - 18),
        );
      }

      // Panel count
      _paintValueLabel(
        canvas,
        '${result.panelCount} panels',
        Offset(usableRect.right - 60, usableRect.top + 4),
      );
    }
  }

  void _paintSideView(Canvas canvas, Rect rect, {bool showTitle = true}) {
    if (showTitle) {
      _paintTitle(canvas, sideViewLabel, Offset(rect.left, rect.top));
    }

    final contentTop = rect.top + (showTitle ? 22 : 0);
    final bottomReserve = detailLevel == SketchDetailLevel.detailed
        ? (result.rows > 1 ? 66.0 : 52.0)
        : 12.0;
    final baseY = rect.bottom - bottomReserve;
    final startX = rect.left + 20;
    final width = rect.width - 40;

    final depthScale =
        width / math.max(result.totalFootprintDepthMeters - 0.5, 1.0);
    final heightScale = (baseY - contentTop - 10) /
        math.max(
          result.maxRearLegHeightMeters,
          result.rearLegHeightMeters + 0.1,
        );

    // Ground line
    final groundPaint = Paint()
      ..color = SketchColors.groundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(startX, baseY),
      Offset(rect.right - 12, baseY),
      groundPaint,
    );

    // Structure paints
    final legPaint = Paint()
      ..color = SketchColors.legColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final framePaint = Paint()
      ..color = SketchColors.frameColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final bracePaint = Paint()
      ..color = SketchColors.braceColor
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final rowsToRender = result.isUniformLegDesign && result.rowResults.isNotEmpty
        ? <RowFrameResult>[result.rowResults.first]
        : result.rowResults;

    var currentX = startX;
    for (final row in rowsToRender) {
      final frontTopY = baseY - (row.frontLegHeightMeters * heightScale);
      final rearTopY = baseY - (row.rearLegHeightMeters * heightScale);
      final rearX = currentX + (result.projectedRowDepthMeters * depthScale);

      // Front leg with shadow
      if (showShadows) {
        canvas.drawLine(
          Offset(currentX + 1, baseY + 1),
          Offset(currentX + 1, frontTopY + 1),
          Paint()
            ..color = SketchColors.shadowColor
            ..strokeWidth = 3.5,
        );
      }
      canvas.drawLine(
        Offset(currentX, baseY),
        Offset(currentX, frontTopY),
        legPaint,
      );

      // Rear leg
      canvas.drawLine(
        Offset(rearX, baseY),
        Offset(rearX, rearTopY),
        legPaint,
      );

      // Frame slope
      canvas.drawLine(
        Offset(currentX, frontTopY),
        Offset(rearX, rearTopY),
        framePaint,
      );

      // Brace
      canvas.drawLine(
        Offset(currentX, baseY),
        Offset(rearX - 10, rearTopY),
        bracePaint,
      );

      // Labels
      if (row.rowIndex == 0) {
        _paintSmallLabel(
          canvas,
          frontLabel,
          Offset(currentX - 16, frontTopY - 26),
        );
        _paintSmallLabel(
          canvas,
          rearLabel,
          Offset(rearX - 18, rearTopY - 28),
        );
        _paintSmallLabel(
          canvas,
          braceLabel,
          Offset((currentX + rearX) / 2 - 12, rearTopY - 10),
        );
      } else if (!result.isUniformLegDesign) {
        _paintSmallLabel(
          canvas,
          '${row.rowIndex + 1}',
          Offset(currentX + 4, frontTopY - 16),
        );
      }

      // Dimensions
      if (detailLevel == SketchDetailLevel.detailed) {
        _paintVerticalDimension(
          canvas,
          x: currentX - 12,
          baseY: baseY,
          topY: frontTopY,
          label: '${row.frontLegHeightMeters.toStringAsFixed(2)} m',
        );
        _paintVerticalDimension(
          canvas,
          x: rearX + 12,
          baseY: baseY,
          topY: rearTopY,
          label: '${row.rearLegHeightMeters.toStringAsFixed(2)} m',
        );
        _paintSmallLabel(
          canvas,
          '${result.frameSlopeLengthMeters.toStringAsFixed(2)} m',
          Offset(
            ((currentX + rearX) / 2) - 20,
            ((frontTopY + rearTopY) / 2) - 28,
          ),
        );

        if (!result.isUniformLegDesign) {
          _paintSmallLabel(
            canvas,
            '${rowOffsetLabel ?? 'Offset'} ${row.baseOffsetMeters.toStringAsFixed(2)} m',
            Offset(currentX, baseY + 4),
          );
        }
      }

      currentX = rearX + (result.rowSpacingMeters * depthScale);
    }

    // Bottom dimensions
    if (detailLevel == SketchDetailLevel.detailed && result.rowResults.isNotEmpty) {
      final firstFrontX = startX;
      final firstRearX = startX + (result.projectedRowDepthMeters * depthScale);

      _paintDimensionLine(
        canvas,
        start: Offset(firstFrontX, baseY + 24),
        end: Offset(firstRearX, baseY + 24),
        label: '${result.projectedRowDepthMeters.toStringAsFixed(2)} m',
      );

      if (result.rows > 1 && !result.isUniformLegDesign) {
        _paintDimensionLine(
          canvas,
          start: Offset(firstRearX, baseY + 40),
          end: Offset(
            firstRearX + (result.rowSpacingMeters * depthScale),
            baseY + 40,
          ),
          label: '${result.rowSpacingMeters.toStringAsFixed(2)} m',
        );
        _paintDimensionLine(
          canvas,
          start: Offset(firstFrontX, baseY + 56),
          end: Offset(
            firstFrontX + (result.totalFootprintDepthMeters * depthScale),
            baseY + 56,
          ),
          label: '${result.totalFootprintDepthMeters.toStringAsFixed(2)} m',
        );
      }
    }
  }

  void _paintFrontView(Canvas canvas, Rect rect, {bool showTitle = true}) {
    if (showTitle) {
      _paintTitle(canvas, frontViewLabel, Offset(rect.left, rect.top));
    }

    final drawingRect = Rect.fromLTWH(
      rect.left,
      rect.top + (showTitle ? 22 : 0),
      rect.width,
      rect.height - (showTitle ? 22 : 0),
    );

    final baseY = drawingRect.bottom - 10;
    final leftX = drawingRect.left + 18;
    final rightX = drawingRect.right - 18;
    final width = rightX - leftX;

    final maxHeight = math.max(
      result.maxRearLegHeightMeters,
      result.rearLegHeightMeters,
    );
    final heightScale = (drawingRect.height - 18) / math.max(maxHeight, 0.5);

    final frontHeight = result.isUniformLegDesign
        ? result.frontLegHeightMeters
        : ((result.minFrontLegHeightMeters + result.maxFrontLegHeightMeters) / 2);
    final rearHeight = result.isUniformLegDesign
        ? result.rearLegHeightMeters
        : ((result.minRearLegHeightMeters + result.maxRearLegHeightMeters) / 2);

    final topY = baseY - (rearHeight * heightScale);
    final frontTopY = baseY - (frontHeight * heightScale);

    // Structure paints
    final legPaint = Paint()
      ..color = SketchColors.legColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final framePaint = Paint()
      ..color = SketchColors.frameColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final groundPaint = Paint()
      ..color = SketchColors.groundColor
      ..strokeWidth = 2;

    // Ground line
    canvas.drawLine(Offset(leftX, baseY), Offset(rightX, baseY), groundPaint);

    // Legs
    canvas.drawLine(Offset(leftX, baseY), Offset(leftX, frontTopY), legPaint);
    canvas.drawLine(Offset(rightX, baseY), Offset(rightX, topY), legPaint);

    // Frame slope
    canvas.drawLine(Offset(leftX, frontTopY), Offset(rightX, topY), framePaint);

    // Panels
    final columns = math.max(result.columns, 1);
    final panelGap = 4.0;
    final panelWidth = math.max(
      8.0,
      (width - ((columns - 1) * panelGap)) / columns,
    );

    for (var col = 0; col < columns; col++) {
      final panelLeft = leftX + (col * (panelWidth + panelGap));
      final panelRect = Rect.fromLTWH(
        panelLeft,
        topY + 4,
        panelWidth,
        math.max(8.0, (baseY - topY) * 0.32),
      );

      if (showGradients) {
        final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            SketchColors.panelGradientStart,
            SketchColors.panelGradientEnd,
          ],
        );
        final shader = gradient.createShader(panelRect);
        canvas.drawRRect(
          RRect.fromRectAndRadius(panelRect, const Radius.circular(3)),
          Paint()
            ..shader = shader
            ..style = PaintingStyle.fill,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(panelRect, const Radius.circular(3)),
          Paint()..color = SketchColors.panelGradientStart,
        );
      }

      // Panel border
      canvas.drawRRect(
        RRect.fromRectAndRadius(panelRect, const Radius.circular(3)),
        Paint()
          ..color = SketchColors.panelBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // Dimensions
    if (detailLevel == SketchDetailLevel.detailed) {
      _paintDimensionLine(
        canvas,
        start: Offset(leftX, baseY + 12),
        end: Offset(rightX, baseY + 12),
        label: '${result.frameWidthMeters.toStringAsFixed(2)} m',
      );
      _paintVerticalDimension(
        canvas,
        x: rightX + 10,
        baseY: baseY,
        topY: topY,
        label: '${rearHeight.toStringAsFixed(2)} m',
      );
    }
  }

  void _paintIsometricView(Canvas canvas, Rect rect, {bool showTitle = true}) {
    if (showTitle) {
      _paintTitle(canvas, isometricViewLabel, Offset(rect.left, rect.top));
    }

    final drawingRect = Rect.fromLTWH(
      rect.left,
      rect.top + (showTitle ? 22 : 0),
      rect.width,
      rect.height - (showTitle ? 22 : 0),
    );

    final origin = Offset(drawingRect.left + 34, drawingRect.bottom - 28);
    final isoWidth = math.max(drawingRect.width - 88, 48.0);
    final isoDepth = math.max(drawingRect.height * 0.28, 20.0);

    final maxLegHeight = math.max(
      result.maxRearLegHeightMeters,
      result.rearLegHeightMeters,
    );
    final heightScale = (drawingRect.height * 0.46) / math.max(maxLegHeight, 1);

    final frontLegHeight = result.isUniformLegDesign
        ? result.frontLegHeightMeters
        : result.minFrontLegHeightMeters;
    final rearLegHeight = result.isUniformLegDesign
        ? result.rearLegHeightMeters
        : result.maxRearLegHeightMeters;

    final cols = math.max(result.columns, 1);
    final rows = math.max(result.rows, 1);

    // Isometric axes
    final xAxis = Offset(isoWidth * 0.76, -isoDepth);
    final yAxis = Offset(isoWidth * 0.34, isoDepth * 0.7);
    final frontZ = Offset(0, -(frontLegHeight * heightScale));
    final rearZ = Offset(0, -(rearLegHeight * heightScale));

    final supportStations = math.max(result.supportStationCount, 2);

    // Paints
    final framePaint = Paint()
      ..color = SketchColors.frameColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    final legPaint = Paint()
      ..color = SketchColors.legColor
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final bracePaint = Paint()
      ..color = SketchColors.braceColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Panel fill with gradient
    final panelFill = Paint()
      ..color = SketchColors.panelGradientStart.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    // Calculate corners
    final frontLeft = origin;
    final frontRight = origin + xAxis;
    final backLeft = origin + yAxis;
    final backRight = origin + xAxis + yAxis;
    final topFrontLeft = frontLeft + frontZ;
    final topFrontRight = frontRight + frontZ;
    final topBackLeft = backLeft + rearZ;
    final topBackRight = backRight + rearZ;

    // Draw panel surface with gradient
    final topPath = Path()
      ..moveTo(topFrontLeft.dx, topFrontLeft.dy)
      ..lineTo(topFrontRight.dx, topFrontRight.dy)
      ..lineTo(topBackRight.dx, topBackRight.dy)
      ..lineTo(topBackLeft.dx, topBackLeft.dy)
      ..close();

    if (showGradients) {
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          SketchColors.panelGradientStart.withValues(alpha: 0.85),
          SketchColors.panelGradientEnd.withValues(alpha: 0.65),
        ],
      );
      final shader = gradient.createShader(
        Rect.fromPoints(topFrontLeft, topBackRight),
      );
      canvas.drawPath(
        topPath,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.fill,
      );
    } else {
      canvas.drawPath(topPath, panelFill);
    }

    canvas.drawPath(topPath, framePaint);

    // Grid lines on panel surface
    for (var i = 0; i <= cols; i++) {
      final t = i / cols;
      final start = topFrontLeft + (xAxis * t);
      final end = topBackLeft + (xAxis * t);
      canvas.drawLine(start, end, framePaint);
    }
    for (var i = 0; i <= rows; i++) {
      final t = i / rows;
      final start = topFrontLeft + (yAxis * t);
      final end = topFrontRight + (yAxis * t);
      canvas.drawLine(start, end, framePaint);
    }

    // Base frame
    canvas.drawLine(frontLeft, frontRight, framePaint);
    canvas.drawLine(frontLeft, backLeft, framePaint);
    canvas.drawLine(frontRight, backRight, framePaint);
    canvas.drawLine(backLeft, backRight, framePaint);

    // Support legs and braces
    for (var i = 0; i < supportStations; i++) {
      final t = supportStations == 1 ? 0.0 : i / (supportStations - 1);
      final baseFront = frontLeft + (xAxis * t);
      final baseRear = backLeft + (xAxis * t);
      final topFront = baseFront + frontZ;
      final topRear = baseRear + rearZ;

      // Legs
      canvas.drawLine(baseFront, topFront, legPaint);
      canvas.drawLine(baseRear, topRear, legPaint);

      // Frame
      canvas.drawLine(topFront, topRear, framePaint);

      // Braces
      canvas.drawLine(baseFront, topRear, bracePaint);

      if (i == 0 || i == supportStations - 1) {
        canvas.drawLine(baseRear, topFront, bracePaint);
      }
    }

    // Labels
    if (detailLevel == SketchDetailLevel.detailed) {
      _paintValueLabel(
        canvas,
        '${result.rows} x ${result.columns}',
        Offset(drawingRect.left + 4, drawingRect.top + 4),
      );
      _paintSmallLabel(
        canvas,
        '${frontLegHeight.toStringAsFixed(2)} m',
        Offset(frontLeft.dx - 10, (frontLeft.dy + topFrontLeft.dy) / 2 - 6),
      );
      _paintSmallLabel(
        canvas,
        '${rearLegHeight.toStringAsFixed(2)} m',
        Offset(backRight.dx - 30, (backRight.dy + topBackRight.dy) / 2 - 6),
      );
      _paintSmallLabel(
        canvas,
        '${result.frameSlopeLengthMeters.toStringAsFixed(2)} m',
        Offset(
          ((topFrontRight.dx + topBackRight.dx) / 2) - 26,
          ((topFrontRight.dy + topBackRight.dy) / 2) - 18,
        ),
      );
    }
  }

  // Helper methods for painting text and dimensions

  void _paintTitle(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: SketchColors.titleColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _paintSmallLabel(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: SketchColors.labelColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _paintValueLabel(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: SketchColors.valueColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _paintDimensionLine(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required String label,
  }) {
    final paint = Paint()
      ..color = SketchColors.dimensionColor
      ..strokeWidth = 1.2;

    // Main line
    canvas.drawLine(start, end, paint);

    // Extension lines with arrowheads
    _drawArrowhead(canvas, start, end, paint);
    _drawArrowhead(canvas, end, start, paint);

    // Label with background
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: SketchColors.dimensionText,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelX = (start.dx + end.dx) / 2 - (textPainter.width / 2);
    final labelY = start.dy - textPainter.height - 4;

    // Background for label
    final bgRect = Rect.fromLTWH(
      labelX - 4,
      labelY - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = SketchColors.cardBackground,
    );

    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  void _paintVerticalDimension(
    Canvas canvas, {
    required double x,
    required double baseY,
    required double topY,
    required String label,
  }) {
    final paint = Paint()
      ..color = SketchColors.dimensionColor
      ..strokeWidth = 1.2;

    // Main line
    canvas.drawLine(Offset(x, baseY), Offset(x, topY), paint);

    // Extension lines with arrowheads
    _drawArrowhead(canvas, Offset(x, baseY), Offset(x, topY), paint);
    _drawArrowhead(canvas, Offset(x, topY), Offset(x, baseY), paint);

    // Label with background
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: SketchColors.dimensionText,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelX = x - textPainter.width - 6;
    final labelY = (baseY + topY) / 2 - (textPainter.height / 2);

    // Background for label
    final bgRect = Rect.fromLTWH(
      labelX - 4,
      labelY - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = SketchColors.cardBackground,
    );

    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  void _drawArrowhead(Canvas canvas, Offset from, Offset to, Paint paint) {
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const arrowSize = 5.0;

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..lineTo(
        from.dx + arrowSize * math.cos(angle - math.pi / 6),
        from.dy + arrowSize * math.sin(angle - math.pi / 6),
      )
      ..lineTo(
        from.dx + arrowSize * math.cos(angle + math.pi / 6),
        from.dy + arrowSize * math.sin(angle + math.pi / 6),
      )
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant StructureSketchPainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.siteWidthMeters != siteWidthMeters ||
        oldDelegate.siteDepthMeters != siteDepthMeters ||
        oldDelegate.topViewLabel != topViewLabel ||
        oldDelegate.sideViewLabel != sideViewLabel ||
        oldDelegate.frontViewLabel != frontViewLabel ||
        oldDelegate.isometricViewLabel != isometricViewLabel ||
        oldDelegate.detailLevel != detailLevel ||
        oldDelegate.repeatedRowLabel != repeatedRowLabel ||
        oldDelegate.rowOffsetLabel != rowOffsetLabel ||
        oldDelegate.viewMode != viewMode ||
        oldDelegate.showShadows != showShadows ||
        oldDelegate.showGradients != showGradients;
  }
}
