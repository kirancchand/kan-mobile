import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Local decorative artwork; a seller photo can replace it during integration.
class CakeArtwork extends StatelessWidget {
  const CakeArtwork({super.key, this.category = '', this.height = 180});

  final String category;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Cake illustration',
        image: true,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _CakePainter(category.toLowerCase().contains('chocolate')),
          ),
        ),
      );
}

class _CakePainter extends CustomPainter {
  const _CakePainter(this.chocolate);
  final bool chocolate;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 230, size.height / 220);
    canvas.save();
    canvas.translate(
        (size.width - 230 * scale) / 2, (size.height - 220 * scale) / 2);
    canvas.scale(scale);

    final body = chocolate ? const Color(0xFF754335) : const Color(0xFFF7D6AA);
    final icing = chocolate ? const Color(0xFF482724) : const Color(0xFFFFF9E9);
    final top = chocolate ? const Color(0xFF92584B) : const Color(0xFFFFEAD3);
    canvas.drawOval(const Rect.fromLTWH(20, 186, 190, 20),
        Paint()..color = const Color(0xFF9F4157).withValues(alpha: 0.15));
    canvas.drawOval(const Rect.fromLTWH(16, 175, 198, 24),
        Paint()..color = const Color(0xFFFFF9ED));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(38, 87, 154, 97), const Radius.circular(18)),
      Paint()
        ..shader = LinearGradient(colors: [body, Color.lerp(body, icing, 0.4)!])
            .createShader(const Rect.fromLTWH(38, 87, 154, 97)),
    );
    for (final y in [130.0, 154.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(38, y)
          ..quadraticBezierTo(115, y + 24, 192, y),
        Paint()
          ..color = chocolate ? const Color(0xFFD7A286) : Colors.white
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke,
      );
    }
    final drip = Path()
      ..moveTo(38, 84)
      ..lineTo(192, 84)
      ..lineTo(192, 113)
      ..quadraticBezierTo(181, 131, 175, 112)
      ..quadraticBezierTo(166, 101, 161, 127)
      ..quadraticBezierTo(154, 152, 145, 121)
      ..quadraticBezierTo(136, 107, 128, 124)
      ..quadraticBezierTo(116, 141, 105, 118)
      ..quadraticBezierTo(94, 107, 88, 138)
      ..quadraticBezierTo(77, 155, 69, 122)
      ..quadraticBezierTo(60, 108, 54, 124)
      ..quadraticBezierTo(41, 137, 38, 111)
      ..close();
    canvas.drawPath(drip, Paint()..color = icing);
    canvas.drawOval(const Rect.fromLTWH(38, 61, 154, 55), Paint()..color = top);

    for (var i = 0; i < 9; i++) {
      final angle = i * math.pi * 2 / 9;
      final center =
          Offset(115 + math.cos(angle) * 59, 86 + math.sin(angle) * 17);
      canvas.drawCircle(center, 10, Paint()..color = icing);
      canvas.drawCircle(center.translate(-2, -3), 6,
          Paint()..color = chocolate ? top : Colors.white);
    }
    // A pair of berries, a candle, and confetti keep the reference's playful feel.
    for (final x in [91.0, 137.0]) {
      canvas.drawOval(Rect.fromLTWH(x - 11, 68, 22, 23),
          Paint()..color = const Color(0xFFE65B79));
      canvas.drawOval(Rect.fromLTWH(x - 6, 69, 7, 10),
          Paint()..color = const Color(0xFFFFABC0));
    }
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(111, 42, 8, 35), const Radius.circular(3)),
        Paint()..color = const Color(0xFFEB7293));
    canvas.drawOval(const Rect.fromLTWH(111, 28, 8, 15),
        Paint()..color = const Color(0xFFFFBA55));
    for (var i = 0; i < 12; i++) {
      final x = 16.0 + (i * 47 % 200);
      final y = 18.0 + (i * 31 % 165);
      if (x > 35 && x < 195 && y > 40) continue;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(i * 0.7);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(0, 0, 3, 8), const Radius.circular(2)),
          Paint()
            ..color = [
              const Color(0xFFF49AAD),
              const Color(0xFFE8B969),
              const Color(0xFF9ABCAB)
            ][i % 3]);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CakePainter oldDelegate) =>
      oldDelegate.chocolate != chocolate;
}
