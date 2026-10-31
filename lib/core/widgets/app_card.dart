import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';

/// Drop-in replacement for Material's [Card]: white surface, Mist border
/// and a subtle shadow (design.md §9).
///
/// Usage is identical to [Card] — wrap any content, optionally with
/// [margin] — so any interactive child (e.g. a [ListTile] with its own
/// `onTap`) keeps working unchanged; this widget only owns the decoration.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.margin,
    this.color,
    this.borderRadius = AppRadius.card,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = BorderRadius.circular(borderRadius);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: tokens.cardShadow,
      ),
      child: Material(
        color: color ?? Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: tokens.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
