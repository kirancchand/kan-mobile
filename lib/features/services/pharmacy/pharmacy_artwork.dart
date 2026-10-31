import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Generic product artwork for the catalog, not branded packaging.
class PharmacyArtwork extends StatelessWidget {
  const PharmacyArtwork({super.key, this.category = '', this.height = 170});
  final String category;
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Health product illustration',
        image: true,
        child: SizedBox(
            width: double.infinity,
            height: height,
            child: CustomPaint(painter: _ProductPainter(category))),
      );
}

class _ProductPainter extends CustomPainter {
  const _ProductPainter(this.category);
  final String category;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 210, size.height / 190);
    canvas.save();
    canvas.translate(
        (size.width - 210 * scale) / 2, (size.height - 190 * scale) / 2);
    canvas.scale(scale);
    canvas.drawOval(const Rect.fromLTWH(22, 160, 168, 18),
        Paint()..color = const Color(0xFF19777B).withValues(alpha: 0.12));
    if (category.toLowerCase().contains('device')) {
      _rect(canvas, const Rect.fromLTWH(32, 38, 148, 127),
          const Color(0xFFEFF6F7), 20);
      _rect(canvas, const Rect.fromLTWH(44, 50, 124, 67),
          const Color(0xFFB0D5D1), 10);
      final line = Path()
        ..moveTo(54, 86)
        ..lineTo(76, 86)
        ..lineTo(85, 72)
        ..lineTo(97, 100)
        ..lineTo(113, 63)
        ..lineTo(128, 87)
        ..lineTo(155, 87);
      canvas.drawPath(
          line,
          Paint()
            ..color = const Color(0xFF24787B)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeJoin = StrokeJoin.round);
      canvas.drawCircle(
          const Offset(106, 140), 13, Paint()..color = const Color(0xFF188D8D));
      canvas.drawCircle(
          const Offset(106, 140), 6, Paint()..color = Colors.white);
    } else if (category.toLowerCase().contains('pain')) {
      canvas.save();
      canvas.translate(104, 94);
      canvas.rotate(-0.16);
      _rect(canvas, const Rect.fromLTWH(-54, -70, 108, 142),
          const Color(0xFFE9F0F3), 14);
      for (var row = 0; row < 3; row++) {
        for (var col = 0; col < 2; col++) {
          final x = -34.0 + col * 45;
          final y = -51.0 + row * 43;
          _rect(canvas, Rect.fromLTWH(x - 3, y - 3, 34, 35),
              const Color(0xFFCADBE1), 14);
          _rect(
              canvas, Rect.fromLTWH(x, y, 27, 28), const Color(0xFFFCFEFF), 12);
          canvas.drawLine(
              Offset(x + 5, y + 14),
              Offset(x + 22, y + 14),
              Paint()
                ..color = const Color(0xFFDAE5E8)
                ..strokeWidth = 2);
        }
      }
      canvas.restore();
    } else {
      _rect(canvas, const Rect.fromLTWH(40, 48, 105, 118),
          const Color(0xFFF7FDFD), 22);
      _rect(canvas, const Rect.fromLTWH(56, 26, 73, 35),
          const Color(0xFF127E80), 8);
      for (var i = 0; i < 8; i++) {
        canvas.drawLine(
            Offset(64.0 + i * 8, 31),
            Offset(64.0 + i * 8, 53),
            Paint()
              ..color = const Color(0xFF55AAAA)
              ..strokeWidth = 2);
      }
      _rect(canvas, const Rect.fromLTWH(41, 83, 103, 61),
          const Color(0xFF37A4A1), 2);
      canvas.drawRect(
          const Rect.fromLTWH(86, 94, 13, 37), Paint()..color = Colors.white);
      canvas.drawRect(
          const Rect.fromLTWH(74, 106, 37, 13), Paint()..color = Colors.white);
      canvas.save();
      canvas.translate(157, 145);
      canvas.rotate(-0.55);
      _rect(canvas, const Rect.fromLTWH(-13, -33, 26, 60),
          const Color(0xFF8ED8CD), 13);
      canvas.drawLine(
          const Offset(-12, -3),
          const Offset(12, -3),
          Paint()
            ..color = Colors.white
            ..strokeWidth = 2);
      canvas.restore();
    }
    canvas.restore();
  }

  void _rect(Canvas canvas, Rect rect, Color color, double radius) =>
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)),
          Paint()..color = color);
  @override
  bool shouldRepaint(_ProductPainter oldDelegate) =>
      oldDelegate.category != category;
}
