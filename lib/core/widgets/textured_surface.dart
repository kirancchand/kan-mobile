import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';

/// Brand hero surface: the emerald → teal → blue-teal gradient overlaid with
/// a staggered pattern of faint outline icons, after the brand texture
/// reference (texture.jpeg). Use only for prominent brand moments (hero
/// banners, profile header, headline totals) — not for regular cards.
class TexturedSurface extends StatelessWidget {
  const TexturedSurface({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.xl,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: context.tokens.heroGradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                  child: CustomPaint(painter: _IconPatternPainter())),
            ),
          ),
          Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ],
      ),
    );
  }
}

class _IconPatternPainter extends CustomPainter {
  const _IconPatternPainter();

  static const _icons = [
    AppIcons.house,
    AppIcons.tree,
    AppIcons.bicycle,
    AppIcons.storefront,
    AppIcons.leaf,
    AppIcons.bookOpen,
    AppIcons.pottedPlant,
    AppIcons.cake,
    AppIcons.tractor,
    AppIcons.flowerLotus,
    AppIcons.car,
    AppIcons.usersThree,
  ];

  static const double _cell = 60;
  static const double _iconSize = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final color = AppColors.white.withValues(alpha: 0.11);
    final painters = [
      for (final icon in _icons)
        TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              fontSize: _iconSize,
              color: color,
            ),
          ),
        )..layout(),
    ];

    var i = 0;
    for (var row = 0; row * _cell < size.height + _cell; row++) {
      // Offset alternate rows by half a cell for the staggered look.
      final xStart = row.isOdd ? _cell / 2 : 0.0;
      for (var x = xStart - _cell / 2; x < size.width + _cell; x += _cell) {
        final p = painters[(i + row * 5) % painters.length];
        p.paint(
            canvas,
            Offset(x + (_cell - p.width) / 2,
                row * _cell + (_cell - p.height) / 2));
        i++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IconPatternPainter oldDelegate) => false;
}
