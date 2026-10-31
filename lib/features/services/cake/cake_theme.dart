import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

/// The cream and raspberry dessert palette from samples/cake.jpg.
class CakeTheme extends StatelessWidget {
  const CakeTheme({super.key, required this.child});

  final Widget child;
  static const raspberry = Color(0xFFB72F59);
  static const cream = Color(0xFFFFFAF2);
  static const blush = Color(0xFFFFE2E7);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final dark = base.brightness == Brightness.dark;
    final primary = dark ? const Color(0xFFFFA9C0) : raspberry;
    final background = dark ? const Color(0xFF241820) : cream;
    final surface = dark ? const Color(0xFF33232C) : Colors.white;
    final soft = dark ? const Color(0xFF4B2938) : blush;
    final ink = dark ? const Color(0xFFFFF2ED) : const Color(0xFF39242C);
    final muted = dark ? const Color(0xFFDBBFC9) : const Color(0xFF7B606A);
    final border = dark ? const Color(0xFF63404F) : const Color(0xFFF0DCE1);
    final scheme = base.colorScheme.copyWith(
      primary: primary,
      onPrimary: dark ? background : Colors.white,
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
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: border),
    );
    final tokens = context.tokens.copyWith(
      brand: primary,
      accent: primary,
      onAccent: scheme.onPrimary,
      textMuted: muted,
      border: border,
      skeletonBase: soft,
      skeletonHighlight: surface,
      cardShadow: [
        BoxShadow(
          color: raspberry.withValues(alpha: dark ? 0.03 : 0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
      toneInk: {
        ...context.tokens.toneInk,
        AppTone.brand: primary,
        AppTone.accent: primary,
        AppTone.neutral: muted,
      },
      toneSoft: {
        ...context.tokens.toneSoft,
        AppTone.brand: soft,
        AppTone.accent: soft,
        AppTone.neutral: dark ? surface : cream,
      },
    );
    return Theme(
      data: base.copyWith(
        colorScheme: scheme,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: textTheme,
        iconTheme: IconThemeData(color: primary),
        extensions: [tokens],
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          foregroundColor: primary,
          centerTitle: true,
          iconTheme: IconThemeData(color: primary),
          titleTextStyle: textTheme.titleLarge?.copyWith(
            color: primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: scheme.onPrimary,
            minimumSize: const Size(48, 52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: surface.withValues(alpha: 0.55),
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputBorder.copyWith(
            borderSide: BorderSide(color: primary, width: 2),
          ),
          prefixIconColor: muted,
          labelStyle: TextStyle(color: muted),
          hintStyle: TextStyle(color: muted),
        ),
        chipTheme: base.chipTheme.copyWith(
          backgroundColor: surface.withValues(alpha: 0.65),
          selectedColor: soft,
          checkmarkColor: primary,
          labelStyle: TextStyle(color: ink),
          side: BorderSide(color: border),
        ),
        bottomSheetTheme: base.bottomSheetTheme.copyWith(
          backgroundColor: surface,
        ),
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
                  const Color(0xFF281B26),
                  const Color(0xFF452738),
                  const Color(0xFF30222D)
                ]
              : [cream, const Color(0xFFFFE3EB), const Color(0xFFFFEDDC)],
        )))),
        Positioned(
            top: 80,
            right: -80,
            child: _CakeGlow(
                color:
                    dark ? const Color(0xFF914764) : const Color(0xFFF39BBD))),
        Positioned(
            bottom: 100,
            left: -100,
            child: _CakeGlow(
                color:
                    dark ? const Color(0xFF865A48) : const Color(0xFFF8C99F))),
        child,
      ])),
    );
  }
}

class _CakeGlow extends StatelessWidget {
  const _CakeGlow({required this.color});
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

/// Frosted dessert panels, clipped before applying a shared backdrop blur.
class CakeGlass extends StatelessWidget {
  const CakeGlass(
      {super.key,
      required this.child,
      this.padding = EdgeInsets.zero,
      this.borderRadius = 24,
      this.color});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;

  static Widget form(Widget child) =>
      CakeGlass(padding: const EdgeInsets.all(18), child: child);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);
    final fill =
        color ?? (dark ? const Color(0xFF382630) : const Color(0xFFFFFBF7));
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: [
        BoxShadow(
            color: CakeTheme.raspberry.withValues(alpha: dark ? 0.05 : 0.09),
            blurRadius: 22,
            offset: const Offset(0, 8))
      ]),
      child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter.grouped(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: fill.withValues(alpha: dark ? 0.76 : 0.60),
              shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: BorderSide(
                      color:
                          Colors.white.withValues(alpha: dark ? 0.18 : 0.86))),
              child: Padding(padding: padding, child: child),
            ),
          )),
    );
  }
}

class CakeActionBar extends StatelessWidget {
  const CakeActionBar({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: CakeGlass(padding: const EdgeInsets.all(8), child: child),
      ));
}
