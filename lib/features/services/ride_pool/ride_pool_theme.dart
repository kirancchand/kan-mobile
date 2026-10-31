import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';

/// Indigo, lavender and orange glass surfaces inspired by samples/ride pool.jpg.
class RidePoolTheme extends StatelessWidget {
  const RidePoolTheme({super.key, required this.child});
  final Widget child;
  static const indigo = Color(0xFF4D5EB1);
  static const orange = Color(0xFFFF9147);
  static const lavender = Color(0xFFEEF0FA);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final dark = base.brightness == Brightness.dark;
    final primary = dark ? const Color(0xFFB9C3FF) : indigo;
    final surface = dark ? const Color(0xFF222741) : const Color(0xFFFAFBFF);
    final soft = dark ? const Color(0xFF30395D) : const Color(0xFFE3E8FF);
    final ink = dark ? const Color(0xFFF0F2FF) : const Color(0xFF272F4D);
    final muted = dark ? const Color(0xFFC0C8E3) : const Color(0xFF596581);
    final border = dark ? const Color(0xFF586484) : const Color(0xFFCED6F0);
    final scheme = base.colorScheme.copyWith(
      primary: primary,
      onPrimary: dark ? const Color(0xFF202956) : Colors.white,
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
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border));
    return Theme(
        data: base.copyWith(
          colorScheme: scheme,
          textTheme: textTheme,
          scaffoldBackgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: primary),
          extensions: [
            context.tokens.copyWith(
              brand: primary,
              border: border,
              textMuted: muted,
              skeletonBase: soft,
              skeletonHighlight: surface,
              accent: orange,
              onAccent: const Color(0xFF34200F),
              toneInk: {
                ...context.tokens.toneInk,
                AppTone.info: primary,
                AppTone.brand: primary,
                AppTone.neutral: muted
              },
              toneSoft: {
                ...context.tokens.toneSoft,
                AppTone.info: soft,
                AppTone.brand: soft,
                AppTone.neutral: surface
              },
            )
          ],
          appBarTheme: base.appBarTheme.copyWith(
            backgroundColor: Colors.transparent,
            foregroundColor: primary,
            iconTheme: IconThemeData(color: primary),
            titleTextStyle: textTheme.titleLarge
                ?.copyWith(color: primary, fontWeight: FontWeight.w700),
          ),
          filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: const Color(0xFF34200F),
            minimumSize: const Size(48, 52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          )),
          inputDecorationTheme: base.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: surface.withValues(alpha: 0.86),
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
              side: BorderSide(color: border),
              checkmarkColor: primary),
          segmentedButtonTheme: SegmentedButtonThemeData(
              style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(ink),
            backgroundColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected)
                    ? soft
                    : surface.withValues(alpha: 0.5)),
            side: WidgetStatePropertyAll(BorderSide(color: border)),
          )),
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
                    const Color(0xFF171B30),
                    const Color(0xFF2B355B),
                    const Color(0xFF242238)
                  ]
                : [lavender, const Color(0xFFDCE5FF), const Color(0xFFF3E9F0)],
          )))),
          Positioned(
              top: 90,
              right: -100,
              child: _RideGlow(
                  color: dark
                      ? const Color(0xFF5667B2)
                      : const Color(0xFFABBBF3))),
          Positioned(
              bottom: 100,
              left: -100,
              child: _RideGlow(
                  color: dark
                      ? const Color(0xFF815A54)
                      : const Color(0xFFF7CCAF))),
          child,
        ])));
  }
}

class _RideGlow extends StatelessWidget {
  const _RideGlow({required this.color});
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

class RidePoolGlass extends StatelessWidget {
  const RidePoolGlass(
      {super.key,
      required this.child,
      this.padding = EdgeInsets.zero,
      this.borderRadius = 24,
      this.prominent = false});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool prominent;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);
    final fill = prominent
        ? (dark ? const Color(0xFF303D76) : RidePoolTheme.indigo)
        : (dark ? const Color(0xFF252D4A) : const Color(0xFFFAFBFF));
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: [
        BoxShadow(
            color: RidePoolTheme.indigo.withValues(alpha: dark ? 0.06 : 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8))
      ]),
      child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter.grouped(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: fill.withValues(
                  alpha: prominent
                      ? 0.88
                      : dark
                          ? 0.76
                          : 0.62),
              shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: BorderSide(
                      color: Colors.white
                          .withValues(alpha: dark || prominent ? 0.25 : 0.86))),
              child: Padding(padding: padding, child: child),
            ),
          )),
    );
  }
}

class RidePoolActionBar extends StatelessWidget {
  const RidePoolActionBar({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: RidePoolGlass(padding: const EdgeInsets.all(8), child: child),
      ));
}
