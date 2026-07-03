import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility functions for technical sketch painters
class PainterUtils {
  /// Draw text on canvas with consistent styling
  static void drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontWeight: fontWeight,
          fontSize: fontSize,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  /// Draw an arrowhead at the end of a line
  static void drawArrowhead(Canvas canvas, Offset from, Offset to, Paint paint) {
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
}
