import 'package:flutter/material.dart';

class CustomPolygonPainter extends CustomPainter {
  final List<Offset> vertices;
  final int rows;
  final int cols;

  CustomPolygonPainter({
    required this.vertices,
    required this.rows,
    required this.cols,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (vertices.isEmpty) return;

    final colWidth = size.width / cols;
    final rowHeight = size.height / rows;

    final paintLine = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final paintLineClosed = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Create Path of vertices
    final path = Path();
    for (int i = 0; i < vertices.length; i++) {
      final c = vertices[i].dx;
      final r = vertices[i].dy;
      final point = Offset((c + 0.5) * colWidth, (r + 0.5) * rowHeight);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, paintLine);

    // Draw closed dashed/dotted line back to start
    if (vertices.length > 2) {
      final start = Offset((vertices[0].dx + 0.5) * colWidth, (vertices[0].dy + 0.5) * rowHeight);
      final end = Offset((vertices.last.dx + 0.5) * colWidth, (vertices.last.dy + 0.5) * rowHeight);
      canvas.drawLine(start, end, paintLineClosed);
    }

    // Draw vertex handles
    final paintVertex = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final paintVertexGlow = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < vertices.length; i++) {
      final c = vertices[i].dx;
      final r = vertices[i].dy;
      final point = Offset((c + 0.5) * colWidth, (r + 0.5) * rowHeight);

      // Draw glowing background for each vertex
      canvas.drawCircle(point, 12.0, paintVertexGlow);
      // Draw inner solid circle
      canvas.drawCircle(point, 6.0, paintVertex);

      // Draw text overlay index
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        point - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPolygonPainter oldDelegate) {
    return oldDelegate.vertices != vertices ||
        oldDelegate.rows != rows ||
        oldDelegate.cols != cols;
  }
}
