import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/sketch/sketch_dimensions.dart';

enum SketchViewMode { top, side, front, isometric, all }

class FrameSketchPainter extends CustomPainter {
  final PvSystemDesignState state;
  final FrameResult? frameResult;
  final bool isDark;
  final SketchViewMode viewMode;

  FrameSketchPainter({
    required this.state,
    required this.frameResult,
    required this.isDark,
    this.viewMode = SketchViewMode.all,
  });

  Color get _bgColor => isDark ? const Color(0xFF1A2220) : const Color(0xFFF8FAF9);
  Color get _lineColor => isDark ? Colors.white70 : Colors.black87;
  Color get _dimColor => Colors.blue.shade700;
  Color get _panelColor => Colors.amber.shade700;
  Color get _frameColor => isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00897B);
  Color get _groundColor => isDark ? const Color(0xFF3E2723) : const Color(0xFF8D6E63);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = _bgColor);

    switch (viewMode) {
      case SketchViewMode.top:
        _drawTopView(canvas, size, 0, 0, size.width, size.height);
      case SketchViewMode.side:
        _drawSideView(canvas, size, 0, 0, size.width, size.height);
      case SketchViewMode.front:
        _drawFrontView(canvas, size, 0, 0, size.width, size.height);
      case SketchViewMode.isometric:
        _drawIsometricView(canvas, size, 0, 0, size.width, size.height);
      case SketchViewMode.all:
        final halfW = size.width / 2;
        final halfH = size.height / 2;
        _drawTopView(canvas, size, 0, 0, halfW, halfH);
        _drawSideView(canvas, size, halfW, 0, halfW, halfH);
        _drawFrontView(canvas, size, 0, halfH, halfW, halfH);
        _drawIsometricView(canvas, size, halfW, halfH, halfW, halfH);
    }
  }

  void _drawTopView(Canvas canvas, Size fullSize, double x, double y, double w, double h) {
    final padding = 30.0;
    final viewRect = Rect.fromLTWH(x + padding, y + padding, w - padding * 2, h - padding * 2);

    SketchDimensions.drawLabel(
      canvas,
      position: Offset(x + 10, y + 10),
      text: 'TOP VIEW',
      color: _lineColor,
      fontSize: 11,
      bold: true,
    );

    final roofPaint = Paint()
      ..color = isDark ? const Color(0xFF2A3633) : const Color(0xFFE8EDE9)
      ..style = PaintingStyle.fill;
    canvas.drawRect(viewRect, roofPaint);

    final borderPaint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(viewRect, borderPaint);

    final cellW = viewRect.width / state.cols;
    final cellH = viewRect.height / state.rows;

    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        final index = r * state.cols + c;
        final cellType = state.grid[index];
        final cellRect = Rect.fromLTWH(
          viewRect.left + c * cellW + 1,
          viewRect.top + r * cellH + 1,
          cellW - 2,
          cellH - 2,
        );

        final paint = Paint();
        switch (cellType) {
          case CellType.panel:
            paint.color = _panelColor.withValues(alpha: 0.85);
            canvas.drawRect(cellRect, paint);
            canvas.drawRect(cellRect, Paint()..color = Colors.orange.shade900..strokeWidth = 0.5..style = PaintingStyle.stroke);
          case CellType.obstacle:
            paint.color = Colors.redAccent.withValues(alpha: 0.7);
            canvas.drawRect(cellRect, paint);
            _drawX(canvas, cellRect, Colors.white);
          case CellType.tree:
            paint.color = Colors.green.withValues(alpha: 0.7);
            canvas.drawCircle(cellRect.center, cellRect.shortestSide / 3, paint);
            paint.color = Colors.brown;
            canvas.drawCircle(cellRect.center, cellRect.shortestSide / 6, paint);
          case CellType.shadow:
            paint.color = Colors.grey.withValues(alpha: 0.4);
            canvas.drawRect(cellRect, paint);
          case CellType.excluded:
            paint.color = isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.15);
            canvas.drawRect(cellRect, paint);
          case CellType.empty:
            continue;
        }
      }
    }

    SketchDimensions.drawHorizontalDimension(
      canvas,
      start: Offset(viewRect.left, viewRect.bottom),
      end: Offset(viewRect.right, viewRect.bottom),
      label: '${state.roofWidthM.toStringAsFixed(1)} m',
      offset: 15,
      color: _dimColor,
    );

    SketchDimensions.drawVerticalDimension(
      canvas,
      start: Offset(viewRect.left, viewRect.top),
      end: Offset(viewRect.left, viewRect.bottom),
      label: '${state.roofLengthM.toStringAsFixed(1)} m',
      offset: -18,
      color: _dimColor,
    );

    _drawCompass(canvas, Offset(viewRect.right - 20, viewRect.top + 20));
  }

  void _drawSideView(Canvas canvas, Size fullSize, double x, double y, double w, double h) {
    if (frameResult == null) {
      SketchDimensions.drawLabel(
        canvas,
        position: Offset(x + 10, y + 10),
        text: 'SIDE VIEW (No data)',
        color: Colors.grey,
        fontSize: 11,
      );
      return;
    }

    final padding = 30.0;
    final viewRect = Rect.fromLTWH(x + padding, y + padding + 10, w - padding * 2, h - padding * 2 - 20);

    SketchDimensions.drawLabel(
      canvas,
      position: Offset(x + 10, y + 10),
      text: 'SIDE VIEW',
      color: _lineColor,
      fontSize: 11,
      bold: true,
    );

    final groundY = viewRect.bottom - 20;
    final groundRect = Rect.fromLTWH(viewRect.left, groundY, viewRect.width, 15);
    canvas.drawRect(groundRect, Paint()..color = _groundColor.withValues(alpha: 0.3));
    SketchDimensions.drawGroundHatching(canvas, groundRect, color: _groundColor);

    final groundPaint = Paint()..color = _groundColor..strokeWidth = 2;
    canvas.drawLine(Offset(viewRect.left, groundY), Offset(viewRect.right, groundY), groundPaint);

    final rows = frameResult!.rows;
    final rowSpacing = viewRect.width / (rows + 1);
    final maxLegHeight = math.max(frameResult!.frontLegHeightMeters, frameResult!.rearLegHeightMeters);
    final scale = (viewRect.height - 60) / (maxLegHeight + 0.5);

    final framePaint = Paint()
      ..color = _frameColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final panelPaint = Paint()
      ..color = _panelColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < rows; i++) {
      final cx = viewRect.left + rowSpacing * (i + 1);
      final frontH = frameResult!.frontLegHeightMeters * scale;
      final rearH = frameResult!.rearLegHeightMeters * scale;
      final panelDepth = 25.0;

      final frontBase = Offset(cx - panelDepth / 2, groundY);
      final frontTop = Offset(cx - panelDepth / 2, groundY - frontH);
      final rearBase = Offset(cx + panelDepth / 2, groundY);
      final rearTop = Offset(cx + panelDepth / 2, groundY - rearH);

      canvas.drawLine(frontBase, frontTop, framePaint);
      canvas.drawLine(rearBase, rearTop, framePaint);

      final bracePaint = Paint()
        ..color = _frameColor.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(frontBase, rearTop, bracePaint);

      final topRailPaint = Paint()
        ..color = _frameColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(frontTop, rearTop, topRailPaint);

      final panelPath = Path()
        ..moveTo(frontTop.dx - 2, frontTop.dy)
        ..lineTo(rearTop.dx + 2, rearTop.dy)
        ..lineTo(rearTop.dx + 2, rearTop.dy - 4)
        ..lineTo(frontTop.dx - 2, frontTop.dy - 4)
        ..close();
      canvas.drawPath(panelPath, panelPaint);

      if (i == 0) {
        SketchDimensions.drawVerticalDimension(
          canvas,
          start: frontBase,
          end: frontTop,
          label: '${frameResult!.frontLegHeightMeters.toStringAsFixed(2)} m',
          offset: -20,
          color: _dimColor,
          fontSize: 8,
        );
      }

      if (i == rows - 1) {
        SketchDimensions.drawVerticalDimension(
          canvas,
          start: rearBase,
          end: rearTop,
          label: '${frameResult!.rearLegHeightMeters.toStringAsFixed(2)} m',
          offset: 20,
          color: _dimColor,
          fontSize: 8,
        );
      }
    }

    if (rows > 1) {
      final x1 = viewRect.left + rowSpacing;
      final x2 = viewRect.left + rowSpacing * 2;
      SketchDimensions.drawHorizontalDimension(
        canvas,
        start: Offset(x1, groundY),
        end: Offset(x2, groundY),
        label: '${frameResult!.rowSpacingMeters.toStringAsFixed(2)} m',
        offset: 30,
        color: _dimColor,
        fontSize: 8,
      );
    }

    final tiltAngle = frameResult!.appliedTiltDegrees;
    final arcCenter = Offset(viewRect.left + rowSpacing, groundY - frameResult!.frontLegHeightMeters * scale);
    final arcPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: 15),
      -math.pi / 2,
      -tiltAngle * math.pi / 180,
      false,
      arcPaint,
    );
    SketchDimensions.drawLabel(
      canvas,
      position: Offset(arcCenter.dx + 18, arcCenter.dy - 15),
      text: '${tiltAngle.toStringAsFixed(0)}°',
      color: Colors.orange,
      fontSize: 8,
      bold: true,
    );
  }

  void _drawFrontView(Canvas canvas, Size fullSize, double x, double y, double w, double h) {
    if (frameResult == null) {
      SketchDimensions.drawLabel(
        canvas,
        position: Offset(x + 10, y + 10),
        text: 'FRONT VIEW (No data)',
        color: Colors.grey,
        fontSize: 11,
      );
      return;
    }

    final padding = 30.0;
    final viewRect = Rect.fromLTWH(x + padding, y + padding + 10, w - padding * 2, h - padding * 2 - 20);

    SketchDimensions.drawLabel(
      canvas,
      position: Offset(x + 10, y + 10),
      text: 'FRONT VIEW',
      color: _lineColor,
      fontSize: 11,
      bold: true,
    );

    final groundY = viewRect.bottom - 20;
    final groundRect = Rect.fromLTWH(viewRect.left, groundY, viewRect.width, 15);
    canvas.drawRect(groundRect, Paint()..color = _groundColor.withValues(alpha: 0.3));
    SketchDimensions.drawGroundHatching(canvas, groundRect, color: _groundColor);

    final groundPaint = Paint()..color = _groundColor..strokeWidth = 2;
    canvas.drawLine(Offset(viewRect.left, groundY), Offset(viewRect.right, groundY), groundPaint);

    final stations = frameResult!.supportStationCount;
    final stationSpacing = viewRect.width / (stations + 1);
    final maxLegHeight = math.max(frameResult!.frontLegHeightMeters, frameResult!.rearLegHeightMeters);
    final scale = (viewRect.height - 60) / (maxLegHeight + 0.5);

    final legPaint = Paint()
      ..color = _frameColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int s = 0; s < stations; s++) {
      final sx = viewRect.left + stationSpacing * (s + 1);
      final legH = frameResult!.frontLegHeightMeters * scale;
      final topY = groundY - legH;

      canvas.drawLine(Offset(sx, groundY), Offset(sx, topY), legPaint);

      final basePaint = Paint()
        ..color = _frameColor
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(sx - 8, groundY - 3, 16, 3), basePaint);
    }

    final railY = groundY - frameResult!.frontLegHeightMeters * scale;
    final railPaint = Paint()
      ..color = _frameColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(viewRect.left + stationSpacing, railY),
      Offset(viewRect.right - stationSpacing, railY),
      railPaint,
    );

    final panelH = 6.0;
    final tiltOffset = math.sin(frameResult!.appliedTiltDegrees * math.pi / 180) * 8;
    final panelPath = Path()
      ..moveTo(viewRect.left + stationSpacing, railY)
      ..lineTo(viewRect.right - stationSpacing, railY)
      ..lineTo(viewRect.right - stationSpacing, railY - panelH - tiltOffset)
      ..lineTo(viewRect.left + stationSpacing, railY - panelH + tiltOffset)
      ..close();
    canvas.drawPath(panelPath, Paint()..color = _panelColor.withValues(alpha: 0.6)..style = PaintingStyle.fill);
    canvas.drawPath(panelPath, Paint()..color = Colors.orange.shade900..strokeWidth = 0.8..style = PaintingStyle.stroke);

    SketchDimensions.drawHorizontalDimension(
      canvas,
      start: Offset(viewRect.left + stationSpacing, groundY),
      end: Offset(viewRect.right - stationSpacing, groundY),
      label: '${frameResult!.frameWidthMeters.toStringAsFixed(2)} m',
      offset: 25,
      color: _dimColor,
      fontSize: 8,
    );
  }

  void _drawIsometricView(Canvas canvas, Size fullSize, double x, double y, double w, double h) {
    if (frameResult == null) {
      SketchDimensions.drawLabel(
        canvas,
        position: Offset(x + 10, y + 10),
        text: '3D VIEW (No data)',
        color: Colors.grey,
        fontSize: 11,
      );
      return;
    }

    SketchDimensions.drawLabel(
      canvas,
      position: Offset(x + 10, y + 10),
      text: 'ISOMETRIC VIEW',
      color: _lineColor,
      fontSize: 11,
      bold: true,
    );

    final centerX = x + w / 2;
    final centerY = y + h / 2 + 20;
    final scale = math.min(w, h) / 120;

    final rows = frameResult!.rows;
    final cols = frameResult!.columns;
    final rowDepth = 12.0 * scale;
    final colWidth = 8.0 * scale;
    final heightRise = 10.0 * scale;

    final startX = centerX - (rows * rowDepth) / 2;
    final startY = centerY + (rows * rowDepth) / 4;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final isoX = startX + r * rowDepth * 0.7 + c * colWidth * 0.5;
        final isoY = startY - r * rowDepth * 0.4 - c * colWidth * 0.3;

        final p1 = Offset(isoX, isoY);
        final p2 = Offset(isoX + colWidth * 0.5, isoY - colWidth * 0.3);
        final p3 = Offset(isoX + colWidth * 0.5, isoY - colWidth * 0.3 - heightRise);
        final p4 = Offset(isoX, isoY - heightRise);

        final panelPath = Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p3.dx, p3.dy)
          ..lineTo(p4.dx, p4.dy)
          ..close();

        canvas.drawPath(panelPath, Paint()..color = _panelColor.withValues(alpha: 0.7)..style = PaintingStyle.fill);
        canvas.drawPath(panelPath, Paint()..color = Colors.orange.shade900..strokeWidth = 0.5..style = PaintingStyle.stroke);

        final legPaint = Paint()
          ..color = _frameColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawLine(p1, Offset(p1.dx, p1.dy + 15 * scale), legPaint);
        canvas.drawLine(p2, Offset(p2.dx, p2.dy + 15 * scale), legPaint);
      }
    }
  }

  void _drawX(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(rect.left + 3, rect.top + 3), Offset(rect.right - 3, rect.bottom - 3), paint);
    canvas.drawLine(Offset(rect.right - 3, rect.top + 3), Offset(rect.left + 3, rect.bottom - 3), paint);
  }

  void _drawCompass(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 12, paint);
    canvas.drawLine(Offset(center.dx, center.dy - 12), Offset(center.dx, center.dy + 12), paint);
    canvas.drawLine(Offset(center.dx - 12, center.dy), Offset(center.dx + 12, center.dy), paint);

    final nPaint = Paint()..color = Colors.red;
    final nPath = Path()
      ..moveTo(center.dx, center.dy - 10)
      ..lineTo(center.dx - 3, center.dy - 4)
      ..lineTo(center.dx + 3, center.dy - 4)
      ..close();
    canvas.drawPath(nPath, nPaint);

    SketchDimensions.drawLabel(
      canvas,
      position: Offset(center.dx - 3, center.dy - 22),
      text: 'N',
      color: Colors.red,
      fontSize: 8,
      bold: true,
    );
  }

  @override
  bool shouldRepaint(covariant FrameSketchPainter oldDelegate) {
    return oldDelegate.state != state || oldDelegate.frameResult != frameResult || oldDelegate.viewMode != viewMode;
  }
}
