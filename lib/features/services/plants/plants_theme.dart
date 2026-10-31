import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';

/// Mint glass surfaces inspired by samples/plant1.jpg and plant2.jpg.
class PlantsTheme extends StatelessWidget {
  const PlantsTheme({super.key, required this.child});
  final Widget child;
  static const forest = Color(0xFF315E45);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final dark = base.brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF20382B) : const Color(0xFFFCFFF9);
    final primary = dark ? const Color(0xFFB8DDA8) : forest;
    final soft = dark ? const Color(0xFF304C37) : const Color(0xFFDFEEDB);
    final ink = dark ? const Color(0xFFF0F8EB) : const Color(0xFF22392A);
    final muted = dark ? const Color(0xFFBCD0B7) : const Color(0xFF526C57);
    final border = dark ? const Color(0xFF526E55) : const Color(0xFFD0E2CD);
    final scheme = base.colorScheme.copyWith(
      primary: primary,
      onPrimary: dark ? const Color(0xFF172D1D) : Colors.white,
      primaryContainer: soft,
      onPrimaryContainer: primary,
      secondary: primary,
      secondaryContainer: soft,
      onSecondaryContainer: ink,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      surfaceContainerHighest: soft,
      outline: border,
      outlineVariant: border,
    );
    final textTheme = base.textTheme.apply(bodyColor: ink, displayColor: ink);
    final outline = OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: border));
    return Theme(
      data: base.copyWith(
        colorScheme: scheme,
        textTheme: textTheme,
        scaffoldBackgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: primary),
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          foregroundColor: primary,
          iconTheme: IconThemeData(color: primary),
          titleTextStyle: textTheme.titleLarge
              ?.copyWith(color: primary, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
        extensions: [
          context.tokens.copyWith(
            brand: primary,
            textMuted: muted,
            border: border,
            skeletonBase: soft,
            skeletonHighlight: surface,
            toneInk: {
              ...context.tokens.toneInk,
              AppTone.brand: primary,
              AppTone.lime: primary,
              AppTone.neutral: muted
            },
            toneSoft: {
              ...context.tokens.toneSoft,
              AppTone.brand: soft,
              AppTone.lime: soft,
              AppTone.neutral: surface
            },
          )
        ],
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        )),
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: surface.withValues(alpha: 0.55),
          border: outline,
          enabledBorder: outline,
          focusedBorder: outline.copyWith(
              borderSide: BorderSide(color: primary, width: 2)),
          prefixIconColor: muted,
          labelStyle: TextStyle(color: muted),
          hintStyle: TextStyle(color: muted),
        ),
        chipTheme: base.chipTheme.copyWith(
          backgroundColor: surface.withValues(alpha: 0.65),
          selectedColor: soft,
          labelStyle: TextStyle(color: ink),
          checkmarkColor: primary,
          side: BorderSide(color: border),
        ),
        bottomSheetTheme:
            base.bottomSheetTheme.copyWith(backgroundColor: surface),
      ),
      child: BackdropGroup(
          child: Stack(children: [
        Positioned.fill(
            child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
                  const Color(0xFF13271C),
                  const Color(0xFF254532),
                  const Color(0xFF202F22)
                ]
              : [
                  const Color(0xFFFAFCEE),
                  const Color(0xFFD7ECE0),
                  const Color(0xFFE5EFCB)
                ],
        )))),
        Positioned(
            top: 80,
            right: -90,
            child: _LeafGlow(
                color:
                    dark ? const Color(0xFF65935B) : const Color(0xFFABCF8D))),
        Positioned(
            bottom: 100,
            left: -110,
            child: _LeafGlow(
                color:
                    dark ? const Color(0xFF376D5B) : const Color(0xFF97CEC0))),
        child,
      ])),
    );
  }
}

class _LeafGlow extends StatelessWidget {
  const _LeafGlow({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => IgnorePointer(
          child: Container(
        width: 330,
        height: 330,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              color.withValues(alpha: 0.65),
              color.withValues(alpha: 0)
            ])),
      ));
}

/// Frosted panels share a grouped backdrop, clipped to each rounded surface.
class PlantsGlass extends StatelessWidget {
  const PlantsGlass(
      {super.key,
      required this.child,
      this.padding = EdgeInsets.zero,
      this.borderRadius = 24});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  static Widget form(Widget child) =>
      PlantsGlass(padding: const EdgeInsets.all(18), child: child);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: [
        BoxShadow(
            color:
                const Color(0xFF294C37).withValues(alpha: dark ? 0.06 : 0.09),
            blurRadius: 22,
            offset: const Offset(0, 8))
      ]),
      child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter.grouped(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: (dark ? const Color(0xFF20382B) : const Color(0xFFFAFFF5))
                  .withValues(alpha: dark ? 0.76 : 0.60),
              shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: BorderSide(
                      color:
                          Colors.white.withValues(alpha: dark ? 0.20 : 0.86))),
              child: Padding(padding: padding, child: child),
            ),
          )),
    );
  }
}

class PlantsActionBar extends StatelessWidget {
  const PlantsActionBar({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: PlantsGlass(padding: const EdgeInsets.all(8), child: child),
      ));
}

/// Botanical illustration, not a photograph of a seller's actual plant.
class PlantArtwork extends StatelessWidget {
  const PlantArtwork({super.key, this.height = 180, this.variant = 0});
  final double height;
  final int variant;
  @override
  Widget build(BuildContext context) => Semantics(
      label: 'Plant illustration',
      image: true,
      child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _PlantPainter(variant))));
}

class _PlantPainter extends CustomPainter {
  _PlantPainter(this.variant);
  final int variant;
  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.height / 240, size.width / 150);
    canvas.save();
    canvas.translate(size.width / 2, (size.height - 240 * scale) / 2);
    canvas.scale(scale);
    final shadow = Paint()
      ..color = const Color(0xFF315E45).withValues(alpha: 0.12);
    canvas.drawOval(const Rect.fromLTWH(-55, 216, 110, 12), shadow);
    final stem = Paint()
      ..color = const Color(0xFF42694B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 7; i++) {
      final left = i.isEven;
      final x = (left ? -1 : 1) * (28.0 + (i % 3) * 12);
      final y = 42.0 + i * 17;
      canvas.drawPath(
          Path()
            ..moveTo(0, 180)
            ..quadraticBezierTo(x * 0.25, y + 18, x, y),
          stem);
      final leaf = Path()
        ..moveTo(x, y + 20)
        ..quadraticBezierTo(x + (left ? -42 : 42), y - 18, x, y - 32)
        ..quadraticBezierTo(x + (left ? 24 : -24), y - 4, x, y + 20);
      canvas.drawPath(
          leaf,
          Paint()
            ..color = [
              const Color(0xFF315E45),
              const Color(0xFF64884B),
              const Color(0xFF8EB26C)
            ][(i + variant) % 3]);
    }
    canvas.drawPath(
        Path()
          ..moveTo(-42, 170)
          ..lineTo(42, 170)
          ..lineTo(30, 219)
          ..quadraticBezierTo(0, 231, -30, 219)
          ..close(),
        Paint()
          ..shader = const LinearGradient(
                  colors: [Color(0xFFFDFDF5), Color(0xFFD3DACB)])
              .createShader(const Rect.fromLTWH(-42, 170, 84, 55)));
    canvas.drawOval(const Rect.fromLTWH(-42, 164, 84, 15),
        Paint()..color = const Color(0xFFD9DECE));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlantPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
