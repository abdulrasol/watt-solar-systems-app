import 'dart:math' as math;
import 'package:flutter/material.dart';

class SketchDimensions {
  static void drawHorizontalDimension(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required String label,
    required double offset,
    Color color = Colors.blue,
    double fontSize = 10,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final y = start.dy + offset;
    final left = start.dx;
    final right = end.dx;

    canvas.drawLine(Offset(left, y), Offset(right, y), paint);

    _drawArrow(canvas, Offset(left, y), -1, paint);
    _drawArrow(canvas, Offset(right, y), 1, paint);

    canvas.drawLine(Offset(left, start.dy), Offset(left, y + 5), paint);
    canvas.drawLine(Offset(right, end.dy), Offset(right, y + 5), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textX = (left + right) / 2 - textPainter.width / 2;
    final textY = y - textPainter.height - 2;

    final bgPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawRect(
      Rect.fromLTWH(textX - 2, textY, textPainter.width + 4, textPainter.height),
      bgPaint,
    );

    textPainter.paint(canvas, Offset(textX, textY));
  }

  static void drawVerticalDimension(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required String label,
    required double offset,
    Color color = Colors.blue,
    double fontSize = 10,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final x = start.dx + offset;
    final top = start.dy;
    final bottom = end.dy;

    canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);

    _drawArrowVertical(canvas, Offset(x, top), -1, paint);
    _drawArrowVertical(canvas, Offset(x, bottom), 1, paint);

    canvas.drawLine(Offset(start.dx, top), Offset(x + 5, top), paint);
    canvas.drawLine(Offset(end.dx, bottom), Offset(x + 5, bottom), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textX = x - textPainter.height - 2;
    final textY = (top + bottom) / 2 + textPainter.width / 2;

    canvas.save();
    canvas.translate(textX, textY);
    canvas.rotate(-math.pi / 2);
    
    final bgPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawRect(
      Rect.fromLTWH(-2, -textPainter.height - 2, textPainter.width + 4, textPainter.height + 4),
      bgPaint,
    );
    
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  static void _drawArrow(Canvas canvas, Offset point, int direction, Paint paint) {
    final path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(point.dx - direction * 6, point.dy - 3)
      ..lineTo(point.dx - direction * 6, point.dy + 3)
      ..close();
    canvas.drawPath(path, paint);
  }

  static void _drawArrowVertical(Canvas canvas, Offset point, int direction, Paint paint) {
    final path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(point.dx - 3, point.dy - direction * 6)
      ..lineTo(point.dx + 3, point.dy - direction * 6)
      ..close();
    canvas.drawPath(path, paint);
  }

  static void drawLabel(
    Canvas canvas, {
    required Offset position,
    required String text,
    Color color = Colors.black87,
    double fontSize = 9,
    bool bold = false,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bgPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawRect(
      Rect.fromLTWH(
        position.dx - 2,
        position.dy - 1,
        textPainter.width + 4,
        textPainter.height + 2,
      ),
      bgPaint,
    );

    textPainter.paint(canvas, position);
  }

  static void drawGroundHatching(Canvas canvas, Rect area, {Color color = const Color(0xFF8B7355)}) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 0.8;

    const spacing = 6.0;
    for (double x = area.left; x < area.right; x += spacing) {
      canvas.drawLine(
        Offset(x, area.top),
        Offset(x + 8, area.bottom),
        paint,
      );
    }
  }
}
