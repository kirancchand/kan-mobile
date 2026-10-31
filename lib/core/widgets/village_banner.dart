import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';
import 'textured_surface.dart';

/// Emerald → teal hero surface with a small, locally drawn village scene
/// (works offline). Used sparingly: the top of Home, Services and
/// Registration.
class VillageBanner extends StatelessWidget {
  const VillageBanner(
      {super.key,
      required this.title,
      required this.subtitle,
      this.eyebrow = 'LIFE IS BETTER TOGETHER',
      this.action});
  final String title;
  final String subtitle;
  final String eyebrow;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    return TexturedSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: tokens.accent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(eyebrow,
                    style: text.labelSmall?.copyWith(
                        color: tokens.onAccent,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: AppSpacing.ms),
              Text(title,
                  style: text.headlineMedium?.copyWith(color: AppColors.white)),
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle,
                  style: text.bodyMedium?.copyWith(color: AppColors.white)),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.md),
                Theme(
                  // Buttons on the hero invert to white-on-emerald ink so
                  // they stay visible against the gradient.
                  data: Theme.of(context).copyWith(
                    filledButtonTheme: FilledButtonThemeData(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.emeraldInk,
                        minimumSize: const Size(64, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md)),
                        textStyle: text.labelLarge,
                      ),
                    ),
                  ),
                  child: action!,
                ),
              ],
            ]),
          ),
          const SizedBox(
              height: 110,
              width: double.infinity,
              child: ExcludeSemantics(
                  child: CustomPaint(painter: _VillagePainter()))),
        ],
      ),
    );
  }
}

class _VillagePainter extends CustomPainter {
  const _VillagePainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 360, size.height / 126);
    final paint = Paint();
    final white = AppColors.white;
    void rect(double x, double y, double w, double h, Color color) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, w, h), const Radius.circular(3)),
          paint..color = color);
    }

    canvas.drawCircle(
        const Offset(288, 35), 20, paint..color = AppColors.sunshine);
    final hill = Path()
      ..moveTo(0, 93)
      ..quadraticBezierTo(100, 48, 205, 95)
      ..quadraticBezierTo(280, 62, 360, 86)
      ..lineTo(360, 126)
      ..lineTo(0, 126)
      ..close();
    canvas.drawPath(hill, paint..color = white.withValues(alpha: 0.14));
    void house(double x, double y, double w, Color color) {
      rect(x, y, w, 49, color);
      final roof = Path()
        ..moveTo(x - 7, y)
        ..lineTo(x + w / 2, y - 25)
        ..lineTo(x + w + 7, y)
        ..close();
      canvas.drawPath(roof, paint..color = AppColors.sunshine);
      rect(x + w / 2 - 6, y + 23, 12, 26, AppColors.midnight);
      rect(x + 7, y + 10, 10, 10, AppColors.teal);
      rect(x + w - 17, y + 10, 10, 10, AppColors.teal);
    }

    house(69, 60, 62, white.withValues(alpha: 0.92));
    house(155, 48, 70, white);
    house(247, 70, 48, white.withValues(alpha: 0.92));
    for (final x in [32.0, 326.0]) {
      rect(x - 3, 75, 6, 40, white.withValues(alpha: 0.6));
      canvas.drawOval(
          Rect.fromCenter(center: Offset(x, 65), width: 30, height: 50),
          paint..color = AppColors.lime);
    }
    canvas.drawPath(
        Path()
          ..moveTo(0, 119)
          ..quadraticBezierTo(170, 100, 360, 119)
          ..lineTo(360, 126)
          ..lineTo(0, 126)
          ..close(),
        paint..color = white.withValues(alpha: 0.25));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VillagePainter oldDelegate) => false;
}
