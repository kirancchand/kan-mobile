import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';

/// An icon on a soft tinted rounded square — the single leading-visual
/// treatment for list rows, tiles and headers so screens stay consistent.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.tone = AppTone.brand,
    this.size = 44,
    this.iconSize,
    this.color,
  });

  final Color? color;
  final IconData icon;
  final AppTone tone;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.12) ?? tokens.soft(tone),
        borderRadius:
            BorderRadius.circular(size >= 64 ? AppRadius.xl : AppRadius.md),
      ),
      child: Icon(icon,
          color: color ?? tokens.ink(tone), size: iconSize ?? size * 0.5),
    );
  }
}
