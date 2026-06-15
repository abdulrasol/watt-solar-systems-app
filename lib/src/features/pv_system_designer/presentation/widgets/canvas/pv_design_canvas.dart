import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/obstacle.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/panel_layout.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';

class PvDesignCanvas extends StatelessWidget {
  const PvDesignCanvas({
    super.key,
    required this.state,
    this.onCellTap,
    this.onCanvasTap,
    this.showShadows = true,
  });

  final PvSystemDesignState state;
  final ValueChanged<int>? onCellTap;
  final ValueChanged<Offset>? onCanvasTap;
  final bool showShadows;

  @override
  Widget build(BuildContext context) {
    final site = state.site;
    final layout = state.layout;
    final aspect = site.roofLengthM / site.roofWidthM;

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(64),
      minScale: 0.2,
      maxScale: 5.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * 0.92;
          final height = width * aspect;

          return GestureDetector(
            onTapUp: (details) => _handleTap(details.localPosition, width, height),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: CustomPaint(
                size: Size(width, height),
                painter: _PvCanvasPainter(
                  state: state,
                  cellWidth: width / layout.cols,
                  cellHeight: height / layout.rows,
                  showShadows: showShadows,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(Offset local, double width, double height) {
    final cellW = width / state.layout.cols;
    final cellH = height / state.layout.rows;
    final col = (local.dx / cellW).floor().clamp(0, state.layout.cols - 1);
    final row = (local.dy / cellH).floor().clamp(0, state.layout.rows - 1);
    final index = row * state.layout.cols + col;

    if (state.activeTool == PvToolMode.placeWall ||
        state.activeTool == PvToolMode.placeChimney ||
        state.activeTool == PvToolMode.placeVent) {
      final metersX = local.dx / width * state.site.roofWidthM;
      final metersY = local.dy / height * state.site.roofLengthM;
      onCanvasTap?.call(Offset(metersX, metersY));
    } else {
      onCellTap?.call(index);
    }
  }
}

class _PvCanvasPainter extends CustomPainter {
  const _PvCanvasPainter({
    required this.state,
    required this.cellWidth,
    required this.cellHeight,
    required this.showShadows,
  });

  final PvSystemDesignState state;
  final double cellWidth;
  final double cellHeight;
  final bool showShadows;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawCells(canvas);
    _drawObstacles(canvas, size);
    _drawPolygon(canvas, size);
    if (showShadows) _drawShadows(canvas);
    _drawGridLines(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade200;
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawCells(Canvas canvas) {
    for (var r = 0; r < state.layout.rows; r++) {
      for (var c = 0; c < state.layout.cols; c++) {
        final idx = r * state.layout.cols + c;
        final cell = state.layout.cells[idx];
        final rect = Rect.fromLTWH(
          c * cellWidth + 1,
          r * cellHeight + 1,
          cellWidth - 2,
          cellHeight - 2,
        );
        final paint = Paint()..color = _cellColor(cell);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(4.r)),
          paint,
        );
      }
    }
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 0.5;

    for (var c = 0; c <= state.layout.cols; c++) {
      final x = c * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var r = 0; r <= state.layout.rows; r++) {
      final y = r * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawObstacles(Canvas canvas, Size size) {
    for (final obstacle in state.obstacles) {
      final x = obstacle.position.dx / state.site.roofWidthM * size.width;
      final y = obstacle.position.dy / state.site.roofLengthM * size.height;
      final w = obstacle.size.width / state.site.roofWidthM * size.width;
      final h = obstacle.size.height / state.site.roofLengthM * size.height;
      final rect = Rect.fromCenter(center: Offset(x, y), width: w, height: h);
      final paint = Paint()..color = obstacle.type.color.withValues(alpha: 0.7);
      canvas.drawRect(rect, paint);
    }
  }

  void _drawPolygon(Canvas canvas, Size size) {
    if (state.polygonVertices.length < 2) return;
    final points = state.polygonVertices.map((v) {
      return Offset(
        v.dx / state.site.roofWidthM * size.width,
        v.dy / state.site.roofLengthM * size.height,
      );
    }).toList();

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    if (state.polygonVertices.length > 2) path.close();
    canvas.drawPath(path, paint);

    final vertexPaint = Paint()..color = Colors.blue;
    for (final p in points) {
      canvas.drawCircle(p, 5, vertexPaint);
    }
  }

  void _drawShadows(Canvas canvas) {
    final shaded = state.shading.shadedCells;
    if (shaded.isEmpty) return;
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    for (final idx in shaded) {
      final r = idx ~/ state.layout.cols;
      final c = idx % state.layout.cols;
      final rect = Rect.fromLTWH(
        c * cellWidth + 1,
        r * cellHeight + 1,
        cellWidth - 2,
        cellHeight - 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(4.r)),
        paint,
      );
    }
  }

  Color _cellColor(PvCellType type) {
    return switch (type) {
      PvCellType.empty => Colors.transparent,
      PvCellType.panel => Colors.amber.shade400,
      PvCellType.obstacle => Colors.red.shade300,
      PvCellType.shadow => Colors.grey.shade500,
      PvCellType.tree => Colors.green.shade400,
      PvCellType.excluded => Colors.grey.shade300,
    };
  }

  @override
  bool shouldRepaint(covariant _PvCanvasPainter oldDelegate) => true;
}
