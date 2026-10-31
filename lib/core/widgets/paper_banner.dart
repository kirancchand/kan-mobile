import 'package:flutter/material.dart';

/// Paper-cut edges shared by the home page's community banners.
class PaperBanner extends StatelessWidget {
  const PaperBanner({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  static const teal = Color(0xFF386B68);
  static const terracotta = Color(0xFFB76547);
  static const mustard = Color(0xFFF0CD72);

  @override
  Widget build(BuildContext context) => ClipPath(
        clipper: const _PaperEdgeClipper(),
        child: ColoredBox(color: color, child: child),
      );
}

class _PaperEdgeClipper extends CustomClipper<Path> {
  const _PaperEdgeClipper();

  @override
  Path getClip(Size size) {
    const depth = 6.0;
    final steps = (size.width / 18).ceil();
    final step = size.width / steps;
    final path = Path()..moveTo(0, depth);
    for (var i = 1; i <= steps; i++) {
      path.lineTo(i * step, i.isOdd ? 0 : depth);
    }
    path.lineTo(size.width, size.height - depth);
    for (var i = steps - 1; i >= 0; i--) {
      path.lineTo(i * step, size.height - (i.isEven ? depth : 0));
    }
    return path..close();
  }

  @override
  bool shouldReclip(_PaperEdgeClipper oldClipper) => false;
}
