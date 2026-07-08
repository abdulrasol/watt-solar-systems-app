import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:watt/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/sketch/technical_drawings_sheet.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/technical_sketch/technical_view_mode.dart';

/// Enhanced technical sketch painter with comprehensive dimensions
class EnhancedTechnicalSketchPainter extends CustomPainter {
  EnhancedTechnicalSketchPainter({
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.labels,
    required this.viewMode,
    required this.showAllDimensions,
    required this.showGrid,
    required this.showAnnotations,
    required this.scale,
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final TechnicalDrawingsLabels labels;
  final TechnicalViewMode viewMode;
  final bool showAllDimensions;
  final bool showGrid;
  final bool showAnnotations;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSheetBorder(canvas, size);
    _drawTitleBlock(canvas, size);

    final contentRect = Rect.fromLTWH(40, 60, size.width - 80, size.height - 120);

    if (showGrid) {
      _drawGrid(canvas, contentRect);
    }

    switch (viewMode) {
      case TechnicalViewMode.top:
        _paintTopView(canvas, contentRect);
      case TechnicalViewMode.side:
        _paintSideView(canvas, contentRect);
      case TechnicalViewMode.front:
        _paintFrontView(canvas, contentRect);
      case TechnicalViewMode.isometric:
        _paintIsometricView(canvas, contentRect);
      case TechnicalViewMode.detail:
        _paintDetailView(canvas, contentRect);
    }
  }

  void _drawSheetBorder(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final outerRect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawRect(outerRect, borderPaint);

    final innerRect = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    canvas.drawRect(
      innerRect,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawTitleBlock(Canvas canvas, Size size) {
    final titleBlockHeight = 48.0;
    final titleBlockWidth = 280.0;
    final titleBlockRect = Rect.fromLTWH(size.width - titleBlockWidth - 20, size.height - titleBlockHeight - 16, titleBlockWidth, titleBlockHeight);

    canvas.drawRect(titleBlockRect, Paint()..color = Colors.grey.shade100);
    canvas.drawRect(
      titleBlockRect,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    final divisionPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 0.5;

    canvas.drawLine(Offset(titleBlockRect.left, titleBlockRect.top + 16), Offset(titleBlockRect.right, titleBlockRect.top + 16), divisionPaint);
    canvas.drawLine(Offset(titleBlockRect.left, titleBlockRect.top + 32), Offset(titleBlockRect.right, titleBlockRect.top + 32), divisionPaint);
    canvas.drawLine(Offset(titleBlockRect.left + 140, titleBlockRect.top + 16), Offset(titleBlockRect.left + 140, titleBlockRect.bottom), divisionPaint);

    _drawText(canvas, labels.technicalDrawings, Offset(titleBlockRect.left + 4, titleBlockRect.top + 2), fontSize: 10, fontWeight: FontWeight.bold);
    _drawText(canvas, '${result.panelCount} ${labels.panels}', Offset(titleBlockRect.left + 4, titleBlockRect.top + 18), fontSize: 9);
    _drawText(canvas, '${labels.scale}: 1:${(1 / scale).toStringAsFixed(0)}', Offset(titleBlockRect.left + 144, titleBlockRect.top + 18), fontSize: 9);
    _drawText(canvas, '${result.rows}×${result.columns} ${labels.layout}', Offset(titleBlockRect.left + 4, titleBlockRect.top + 34), fontSize: 9);
    _drawText(canvas, DateTime.now().toString().substring(0, 10), Offset(titleBlockRect.left + 144, titleBlockRect.top + 34), fontSize: 9);
  }

  void _drawGrid(Canvas canvas, Rect rect) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;

    const gridSize = 20.0;

    for (double x = rect.left; x <= rect.right; x += gridSize) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
    }
    for (double y = rect.top; y <= rect.bottom; y += gridSize) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
    }
  }

  void _paintTopView(Canvas canvas, Rect rect) {
    if (showAnnotations) {
      _drawViewTitle(canvas, labels.topView, rect);
    }

    final drawingRect = Rect.fromLTWH(rect.left + 20, rect.top + 30, rect.width - 40, rect.height - 50);

    final scaleX = drawingRect.width / math.max(siteWidthMeters, 1.0);
    final scaleY = drawingRect.height / math.max(siteDepthMeters, 1.0);
    final viewScale = math.min(scaleX, scaleY) * 0.85;

    final siteWidthPx = siteWidthMeters * viewScale;
    final siteDepthPx = siteDepthMeters * viewScale;
    final usableWidthPx = result.usableWidthMeters * viewScale;
    final usableDepthPx = result.usableDepthMeters * viewScale;

    final siteRect = Rect.fromCenter(center: drawingRect.center, width: siteWidthPx, height: siteDepthPx);
    final usableRect = Rect.fromCenter(center: drawingRect.center, width: usableWidthPx, height: usableDepthPx);

    canvas.drawRect(
      siteRect,
      Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      siteRect,
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    canvas.drawRect(
      usableRect,
      Paint()
        ..color = const Color(0xFFE8F5E9)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      usableRect,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    if (result.rows > 0 && result.columns > 0) {
      final cellWidth = usableRect.width / result.columns;
      final cellHeight = usableRect.height / result.rows;

      for (var row = 0; row < result.rows; row++) {
        for (var col = 0; col < result.columns; col++) {
          final panelRect = Rect.fromLTWH(usableRect.left + (col * cellWidth) + 1, usableRect.top + (row * cellHeight) + 1, cellWidth - 2, cellHeight - 2);

          canvas.drawRect(
            panelRect,
            Paint()
              ..color = const Color(0xFFFFE0B2)
              ..style = PaintingStyle.fill,
          );
          canvas.drawRect(
            panelRect,
            Paint()
              ..color = const Color(0xFFE65100)
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke,
          );

          if (showAnnotations) {
            final gridPaint = Paint()
              ..color = const Color(0xFFFFCC80)
              ..strokeWidth = 0.5;
            canvas.drawLine(Offset(panelRect.left, panelRect.center.dy), Offset(panelRect.right, panelRect.center.dy), gridPaint);
            canvas.drawLine(Offset(panelRect.center.dx, panelRect.top), Offset(panelRect.center.dx, panelRect.bottom), gridPaint);
          }
        }
      }
    }

    if (showAllDimensions) {
      _paintHorizontalDimension(canvas, siteRect.left, siteRect.bottom + 15, siteRect.right, '${siteWidthMeters.toStringAsFixed(2)} m');
      _paintVerticalDimension(canvas, siteRect.right + 15, siteRect.bottom, siteRect.top, '${siteDepthMeters.toStringAsFixed(2)} m', leftSide: false);

      _paintHorizontalDimension(
        canvas,
        usableRect.left,
        usableRect.top - 10,
        usableRect.right,
        '${result.usableWidthMeters.toStringAsFixed(2)} m',
        above: true,
      );
      _paintVerticalDimension(
        canvas,
        usableRect.left - 10,
        usableRect.bottom,
        usableRect.top,
        '${result.usableDepthMeters.toStringAsFixed(2)} m',
        leftSide: true,
      );

      if (showAnnotations) {
        _drawText(
          canvas,
          '${result.rows} ${labels.rows} × ${result.columns} ${labels.columns}',
          Offset(usableRect.center.dx - 40, usableRect.center.dy - 6),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE65100),
        );
        _drawText(
          canvas,
          '${result.panelCount} ${labels.panels}',
          Offset(usableRect.center.dx - 25, usableRect.center.dy + 8),
          fontSize: 10,
          color: Colors.grey.shade700,
        );
      }
    }
  }

  void _paintSideView(Canvas canvas, Rect rect) {
    if (showAnnotations) {
      _drawViewTitle(canvas, labels.sideView, rect);
    }

    // Tighter margins so more space is available for the drawing
    final drawingRect = Rect.fromLTWH(rect.left + 20, rect.top + 35, rect.width - 40, rect.height - 70);

    final baseY = drawingRect.bottom - 30;
    final startX = drawingRect.left + 50; // space for left dim label
    final availableWidth = drawingRect.width - 100; // dim label space both sides
    final availableHeight = drawingRect.height - 70; // dim label space top & bottom

    final maxHeight = math.max(result.maxRearLegHeightMeters, result.rearLegHeightMeters + 0.5);
    final totalDepth = math.max(result.totalFootprintDepthMeters, 1.0);

    final scaleX = availableWidth / totalDepth;
    final scaleY = availableHeight / maxHeight;
    // Use the height-driven scale (scaleY) boosted, capped by available width.
    // This makes the structure tall instead of a tiny strip at the bottom.
    final viewScale = math.min(scaleX, scaleY * 0.70);

    final groundPaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(startX - 20, baseY), Offset(startX + availableWidth + 20, baseY), groundPaint);

    final hatchPaint = Paint()
      ..color = const Color(0xFFD4C4B0)
      ..strokeWidth = 1;
    for (var i = 0; i < 10; i++) {
      final x = startX - 20 + (i * 15);
      canvas.drawLine(Offset(x, baseY), Offset(x + 8, baseY + 12), hatchPaint);
    }

    final legPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final framePaint = Paint()
      ..color = const Color(0xFF455A64)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final bracePaint = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    var currentX = startX;
    final rowsToRender = result.isUniformLegDesign && result.rowResults.isNotEmpty ? <dynamic>[result.rowResults.first] : result.rowResults;

    for (final row in rowsToRender) {
      final frontTopY = baseY - (row.frontLegHeightMeters * viewScale);
      final rearTopY = baseY - (row.rearLegHeightMeters * viewScale);
      final rearX = currentX + (result.projectedRowDepthMeters * viewScale);

      canvas.drawLine(Offset(currentX, baseY), Offset(currentX, frontTopY), legPaint);
      canvas.drawLine(Offset(rearX, baseY), Offset(rearX, rearTopY), legPaint);
      canvas.drawLine(Offset(currentX, frontTopY), Offset(rearX, rearTopY), framePaint);

      final braceEndX = rearX - 15;
      canvas.drawLine(Offset(currentX, baseY), Offset(braceEndX, rearTopY), bracePaint);

      _drawBasePlate(canvas, Offset(currentX, baseY), 12);
      _drawBasePlate(canvas, Offset(rearX, baseY), 12);

      if (showAllDimensions) {
        final braceRun = result.projectedRowDepthMeters - (15 / viewScale);
        final braceRise = row.rearLegHeightMeters;
        final braceLengthMeters = math.sqrt(braceRun * braceRun + braceRise * braceRise);

        _paintVerticalDimension(canvas, currentX - 30, baseY, frontTopY, '${row.frontLegHeightMeters.toStringAsFixed(2)} m', leftSide: true);
        _paintVerticalDimension(canvas, rearX + 35, baseY, rearTopY, '${row.rearLegHeightMeters.toStringAsFixed(2)} m', leftSide: false);
        _paintDiagonalDimension(canvas, Offset(currentX, baseY), Offset(braceEndX, rearTopY), '${braceLengthMeters.toStringAsFixed(2)} m');

        if (row.rowIndex == 0 || !result.isUniformLegDesign) {
          _paintHorizontalDimension(canvas, currentX, baseY + 35, rearX, '${result.projectedRowDepthMeters.toStringAsFixed(2)} m');
        }
      }

      if (showAnnotations) {
        _drawText(canvas, labels.front, Offset(currentX - 8, frontTopY - 25), fontSize: 9, color: const Color(0xFF37474F));
        _drawText(canvas, labels.rear, Offset(rearX - 8, rearTopY - 25), fontSize: 9, color: const Color(0xFF37474F));
        _drawText(canvas, labels.brace, Offset((currentX + rearX) / 2 - 15, (baseY + rearTopY) / 2 - 15), fontSize: 8, color: const Color(0xFF78909C));
      }

      currentX = rearX + (result.rowSpacingMeters * viewScale);
    }

    if (showAllDimensions && rowsToRender.isNotEmpty) {
      final firstFrontX = startX;
      final lastRearX = currentX - (result.rowSpacingMeters * viewScale);

      if (result.rows > 1) {
        _paintHorizontalDimension(canvas, firstFrontX, baseY + 55, lastRearX, '${result.totalFootprintDepthMeters.toStringAsFixed(2)} m');
      }
    }
  }

  void _paintFrontView(Canvas canvas, Rect rect) {
    if (showAnnotations) {
      _drawViewTitle(canvas, labels.frontView, rect);
    }

    // Generous drawing area with space for dimension labels
    final drawingRect = Rect.fromLTWH(
      rect.left + 20,
      rect.top + 30,
      rect.width - 40,
      rect.height - 60,
    );

    final availableWidth = drawingRect.width - 80; // leave room for vertical dim labels
    final availableHeight = drawingRect.height - 80; // leave room for horizontal dim labels

    final maxHeight = math.max(result.rearLegHeightMeters, result.frontLegHeightMeters);
    final scaleX = availableWidth / math.max(result.frameWidthMeters, 1.0);
    final scaleY = availableHeight / math.max(maxHeight, 1.0);
    final viewScale = math.min(scaleX, scaleY); // no extra shrink

    final frameWidthPx = result.frameWidthMeters * viewScale;
    final frontHeightPx = result.frontLegHeightMeters * viewScale;
    final rearHeightPx = result.rearLegHeightMeters * viewScale;

    // Centre horizontally; anchor baseline to bottom of drawing area
    final centerX = drawingRect.center.dx;
    final baseY = drawingRect.bottom - 30;

    final leftX = centerX - (frameWidthPx / 2);
    final rightX = centerX + (frameWidthPx / 2);

    // Front view: all support legs have the same visible height (front-leg height).
    // The tilt is implied by the sloped top rail.
    final frontTopY = baseY - frontHeightPx; // leftmost top point (lower)
    final rearTopY = baseY - rearHeightPx;   // rightmost top point (higher / rear)

    // ── Ground line ──────────────────────────────────────────────────────────
    final groundPaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(leftX - 30, baseY), Offset(rightX + 30, baseY), groundPaint);

    // Hatch marks below ground
    final hatchPaint = Paint()
      ..color = const Color(0xFFD4C4B0)
      ..strokeWidth = 1;
    final hatchCount = ((frameWidthPx + 60) / 18).ceil();
    for (var i = 0; i < hatchCount; i++) {
      final x = leftX - 30 + (i * 18);
      canvas.drawLine(Offset(x, baseY), Offset(x + 10, baseY + 14), hatchPaint);
    }

    // ── Ground rail (horizontal bar at front-leg height) ─────────────────────
    final groundRailPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(Offset(leftX, frontTopY), Offset(rightX, frontTopY), groundRailPaint);

    // ── Vertical support legs ─────────────────────────────────────────────────
    final legPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final supportCount = math.max(result.supportStationCount, 2);
    final supportSpacing = frameWidthPx / (supportCount - 1);

    for (var i = 0; i < supportCount; i++) {
      final x = leftX + (i * supportSpacing);
      canvas.drawLine(Offset(x, frontTopY), Offset(x, baseY), legPaint);
      _drawBasePlate(canvas, Offset(x, baseY), 14);
    }

    // ── Tilted panel surface (sloped top rail from front-left to rear-right) ──
    final topRailPaint = Paint()
      ..color = const Color(0xFF455A64)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Panel top rail: slopes from frontTopY (left) to rearTopY (right)
    canvas.drawLine(Offset(leftX, frontTopY), Offset(rightX, rearTopY), topRailPaint);

    // Filled panel surface to represent the tilted panel array
    final panelSurfacePath = Path()
      ..moveTo(leftX, frontTopY)
      ..lineTo(rightX, rearTopY)
      ..lineTo(rightX, frontTopY) // project down to the ground rail level
      ..lineTo(leftX, frontTopY)
      ..close();

    canvas.drawPath(
      panelSurfacePath,
      Paint()
        ..color = const Color(0xFF37474F).withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    // Panel grid lines (columns)
    final panelGridPaint = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = 1.5;
    for (var c = 0; c <= result.columns; c++) {
      final t = result.columns == 0 ? 0.0 : c / result.columns;
      final x = leftX + t * frameWidthPx;
      // Interpolate top-rail Y
      final topY = frontTopY + t * (rearTopY - frontTopY);
      canvas.drawLine(Offset(x, topY), Offset(x, frontTopY), panelGridPaint);
    }

    // ── X-braces in the outer bays only ──────────────────────────────────────
    if (supportCount >= 2) {
      final bracePaint = Paint()
        ..color = const Color(0xFF78909C)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      // Left outer bay
      final x0 = leftX;
      final x1 = leftX + supportSpacing;
      canvas.drawLine(Offset(x0, frontTopY), Offset(x1, baseY), bracePaint);
      canvas.drawLine(Offset(x0, baseY), Offset(x1, frontTopY), bracePaint);

      if (supportCount > 2) {
        // Right outer bay
        final x2 = rightX - supportSpacing;
        final x3 = rightX;
        canvas.drawLine(Offset(x2, frontTopY), Offset(x3, baseY), bracePaint);
        canvas.drawLine(Offset(x2, baseY), Offset(x3, frontTopY), bracePaint);
      }
    }

    // ── Dimension lines ───────────────────────────────────────────────────────
    if (showAllDimensions) {
      // Total frame width
      _paintHorizontalDimension(canvas, leftX, baseY + 22, rightX, '${result.frameWidthMeters.toStringAsFixed(2)} m');

      // Front leg height (left side)
      _paintVerticalDimension(canvas, leftX - 32, baseY, frontTopY, '${result.frontLegHeightMeters.toStringAsFixed(2)} m', leftSide: true);

      // Rear leg height (right side) — shown only when different from front
      if ((result.rearLegHeightMeters - result.frontLegHeightMeters).abs() > 0.01) {
        _paintVerticalDimension(canvas, rightX + 32, baseY, rearTopY, '${result.rearLegHeightMeters.toStringAsFixed(2)} m', leftSide: false);
      }

      // Support spacing
      if (supportCount > 1) {
        _paintHorizontalDimension(
          canvas,
          leftX,
          baseY + 42,
          leftX + supportSpacing,
          '${result.supportSpacingMeters.toStringAsFixed(2)} m',
        );
      }
    }

    // ── Annotation label ──────────────────────────────────────────────────────
    if (showAnnotations) {
      _drawText(
        canvas,
        '${result.columns} ${labels.columns} · ${result.supportStationCount} ${labels.supports}',
        Offset(centerX - 50, frontTopY - 20),
        fontSize: 9,
        color: Colors.grey.shade600,
      );
    }
  }

  void _paintIsometricView(Canvas canvas, Rect rect) {
    if (showAnnotations) {
      _drawViewTitle(canvas, labels.isometricView, rect);
    }

    final drawingRect = Rect.fromLTWH(rect.left + 20, rect.top + 30, rect.width - 40, rect.height - 50);

    final centerX = drawingRect.center.dx;
    // Shift slightly below centre so labels above have room
    final centerY = drawingRect.center.dy + 10;

    // Smaller divisor → larger drawing (~2× bigger than before)
    final isoScale = math.min(drawingRect.width, drawingRect.height) / 180;

    final frameWidth = result.frameWidthMeters * isoScale * 15;
    final frameDepth = result.projectedRowDepthMeters * isoScale * 15;
    final frontLegHeight = result.frontLegHeightMeters * isoScale * 15;
    final rearLegHeight = result.rearLegHeightMeters * isoScale * 15;

    final xAxis = Offset(frameWidth * 0.866, frameWidth * 0.5);
    final yAxis = Offset(frameDepth * 0.866, -frameDepth * 0.5);
    final frontZ = Offset(0, -frontLegHeight);
    final rearZ = Offset(0, -rearLegHeight);

    final baseCenter = Offset(centerX, centerY);
    final frontLeft = baseCenter - (xAxis * 0.5) - (yAxis * 0.5);
    final frontRight = baseCenter + (xAxis * 0.5) - (yAxis * 0.5);
    final backLeft = baseCenter - (xAxis * 0.5) + (yAxis * 0.5);
    final backRight = baseCenter + (xAxis * 0.5) + (yAxis * 0.5);

    final legPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final framePaint = Paint()
      ..color = const Color(0xFF455A64)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final bracePaint = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final panelFill = Paint()
      ..color = const Color(0xFFFFE0B2)
      ..style = PaintingStyle.fill;

    final supportStations = result.supportStationCount;

    final topFrontLeft = frontLeft + frontZ;
    final topFrontRight = frontRight + frontZ;
    final topBackLeft = backLeft + rearZ;
    final topBackRight = backRight + rearZ;

    final topPath = Path()
      ..moveTo(topFrontLeft.dx, topFrontLeft.dy)
      ..lineTo(topFrontRight.dx, topFrontRight.dy)
      ..lineTo(topBackRight.dx, topBackRight.dy)
      ..lineTo(topBackLeft.dx, topBackLeft.dy)
      ..close();

    canvas.drawPath(topPath, panelFill);
    canvas.drawPath(topPath, framePaint);

    final gridPaint = Paint()
      ..color = const Color(0xFFFFCC80)
      ..strokeWidth = 1;

    final cols = result.columns;
    final rows = result.rows;

    for (var i = 0; i <= cols; i++) {
      final t = i / cols;
      final start = topFrontLeft + (xAxis * t);
      final end = topBackLeft + (xAxis * t);
      canvas.drawLine(start, end, gridPaint);
    }
    for (var i = 0; i <= rows; i++) {
      final t = i / rows;
      final start = topFrontLeft + (yAxis * t);
      final end = topFrontRight + (yAxis * t);
      canvas.drawLine(start, end, gridPaint);
    }

    canvas.drawLine(frontLeft, frontRight, framePaint);
    canvas.drawLine(frontLeft, backLeft, framePaint);
    canvas.drawLine(frontRight, backRight, framePaint);
    canvas.drawLine(backLeft, backRight, framePaint);

    for (var i = 0; i < supportStations; i++) {
      final t = supportStations == 1 ? 0.0 : i / (supportStations - 1);
      final baseFront = frontLeft + (xAxis * t);
      final baseRear = backLeft + (xAxis * t);
      final topFront = baseFront + frontZ;
      final topRear = baseRear + rearZ;

      canvas.drawLine(baseFront, topFront, legPaint);
      canvas.drawLine(baseRear, topRear, legPaint);
      canvas.drawLine(topFront, topRear, framePaint);
      canvas.drawLine(baseFront, topRear, bracePaint);

      if (i == 0 || i == supportStations - 1) {
        canvas.drawLine(baseRear, topFront, bracePaint);
      }

      if (i == 0) {
        _drawBasePlateIso(canvas, baseFront, 10);
      }
      if (i == supportStations - 1) {
        _drawBasePlateIso(canvas, baseRear, 10);
      }
    }

    if (showAllDimensions) {
      _drawText(canvas, '${frontLegHeight.toStringAsFixed(2)} m', Offset(frontLeft.dx - 35, (frontLeft.dy + topFrontLeft.dy) / 2 - 5), fontSize: 9);
      _drawText(canvas, '${rearLegHeight.toStringAsFixed(2)} m', Offset(backRight.dx + 10, (backRight.dy + topBackRight.dy) / 2 - 5), fontSize: 9);
    }

    if (showAnnotations) {
      _drawText(
        canvas,
        '${result.rows} × ${result.columns}',
        Offset(drawingRect.left + 4, drawingRect.top + 4),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFE65100),
      );
    }
  }

  void _paintDetailView(Canvas canvas, Rect rect) {
    if (showAnnotations) {
      _drawViewTitle(canvas, labels.detailView, rect);
    }
  }

  void _drawViewTitle(Canvas canvas, String title, Rect rect) {
    _drawText(canvas, title, Offset(rect.left + 10, rect.top + 10), fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87);
  }

  void _drawText(Canvas canvas, String text, Offset offset, {double fontSize = 12, FontWeight fontWeight = FontWeight.normal, Color color = Colors.black}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _drawBasePlate(Canvas canvas, Offset center, double size) {
    final rect = Rect.fromCenter(center: center, width: size, height: size / 2);
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF546E7A)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF37474F)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawBasePlateIso(Canvas canvas, Offset center, double size) {
    final path = Path()
      ..moveTo(center.dx - size / 2, center.dy)
      ..lineTo(center.dx, center.dy - size / 4)
      ..lineTo(center.dx + size / 2, center.dy)
      ..lineTo(center.dx, center.dy + size / 4)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF546E7A)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF37474F)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintHorizontalDimension(Canvas canvas, double startX, double y, double endX, String label, {bool above = false}) {
    final paint = Paint()
      ..color = const Color(0xFF0066CC)
      ..strokeWidth = 1;

    final extensionLength = above ? -8.0 : 8.0;
    final textOffset = above ? -18.0 : 6.0;

    canvas.drawLine(Offset(startX, y + extensionLength), Offset(startX, y - extensionLength), paint);
    canvas.drawLine(Offset(endX, y + extensionLength), Offset(endX, y - extensionLength), paint);
    canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);

    _drawArrowhead(canvas, Offset(startX, y), Offset(endX, y), paint);
    _drawArrowhead(canvas, Offset(endX, y), Offset(startX, y), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Color(0xFF004499), fontWeight: FontWeight.w600, fontSize: 10, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelX = (startX + endX) / 2 - (textPainter.width / 2);
    final labelY = y + textOffset;

    final bgRect = Rect.fromLTWH(labelX - 4, labelY - 2, textPainter.width + 8, textPainter.height + 4);
    canvas.drawRect(bgRect, Paint()..color = Colors.white);

    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  void _paintVerticalDimension(Canvas canvas, double x, double bottomY, double topY, String label, {required bool leftSide}) {
    final paint = Paint()
      ..color = const Color(0xFF0066CC)
      ..strokeWidth = 1;

    final extensionLength = leftSide ? -8.0 : 8.0;
    final textOffset = leftSide ? -6.0 : 6.0;

    canvas.drawLine(Offset(x + extensionLength, bottomY), Offset(x - extensionLength, bottomY), paint);
    canvas.drawLine(Offset(x + extensionLength, topY), Offset(x - extensionLength, topY), paint);
    canvas.drawLine(Offset(x, bottomY), Offset(x, topY), paint);

    _drawArrowhead(canvas, Offset(x, bottomY), Offset(x, topY), paint);
    _drawArrowhead(canvas, Offset(x, topY), Offset(x, bottomY), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Color(0xFF004499), fontWeight: FontWeight.w600, fontSize: 10, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelX = leftSide ? x - textPainter.width - textOffset : x + textOffset;
    final labelY = (bottomY + topY) / 2 - (textPainter.height / 2);

    final bgRect = Rect.fromLTWH(labelX - 4, labelY - 2, textPainter.width + 8, textPainter.height + 4);
    canvas.drawRect(bgRect, Paint()..color = Colors.white);

    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  void _paintDiagonalDimension(Canvas canvas, Offset start, Offset end, String label) {
    final paint = Paint()
      ..color = const Color(0xFF0066CC)
      ..strokeWidth = 1;

    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final offset = 30.0;
    final perpAngle = angle - math.pi / 2;

    final dimStart = Offset(start.dx + offset * math.cos(perpAngle), start.dy + offset * math.sin(perpAngle));
    final dimEnd = Offset(end.dx + offset * math.cos(perpAngle), end.dy + offset * math.sin(perpAngle));

    final extLength = 6.0;
    final extStart1 = Offset(start.dx - extLength * math.cos(perpAngle), start.dy - extLength * math.sin(perpAngle));
    final extStart2 = Offset(start.dx + extLength * math.cos(perpAngle), start.dy + extLength * math.sin(perpAngle));
    final extEnd1 = Offset(end.dx - extLength * math.cos(perpAngle), end.dy - extLength * math.sin(perpAngle));
    final extEnd2 = Offset(end.dx + extLength * math.cos(perpAngle), end.dy + extLength * math.sin(perpAngle));

    canvas.drawLine(extStart1, extStart2, paint);
    canvas.drawLine(extEnd1, extEnd2, paint);
    canvas.drawLine(Offset(start.dx + extLength * math.cos(perpAngle), start.dy + extLength * math.sin(perpAngle)), dimStart, paint);
    canvas.drawLine(Offset(end.dx + extLength * math.cos(perpAngle), end.dy + extLength * math.sin(perpAngle)), dimEnd, paint);
    canvas.drawLine(dimStart, dimEnd, paint);

    _drawArrowhead(canvas, dimStart, dimEnd, paint);
    _drawArrowhead(canvas, dimEnd, dimStart, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Color(0xFF004499), fontWeight: FontWeight.w600, fontSize: 9, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelX = (dimStart.dx + dimEnd.dx) / 2 - (textPainter.width / 2);
    final labelY = (dimStart.dy + dimEnd.dy) / 2 - (textPainter.height / 2);

    final bgRect = Rect.fromLTWH(labelX - 4, labelY - 2, textPainter.width + 8, textPainter.height + 4);
    canvas.drawRect(bgRect, Paint()..color = Colors.white);

    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  void _drawArrowhead(Canvas canvas, Offset from, Offset to, Paint paint) {
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const arrowSize = 5.0;

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..lineTo(from.dx + arrowSize * math.cos(angle - math.pi / 6), from.dy + arrowSize * math.sin(angle - math.pi / 6))
      ..lineTo(from.dx + arrowSize * math.cos(angle + math.pi / 6), from.dy + arrowSize * math.sin(angle + math.pi / 6))
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant EnhancedTechnicalSketchPainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.siteWidthMeters != siteWidthMeters ||
        oldDelegate.siteDepthMeters != siteDepthMeters ||
        oldDelegate.viewMode != viewMode ||
        oldDelegate.showAllDimensions != showAllDimensions ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showAnnotations != showAnnotations ||
        oldDelegate.scale != scale;
  }
}
