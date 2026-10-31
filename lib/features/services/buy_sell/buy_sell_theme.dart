import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

/// The ice-blue and cobalt marketplace palette from samples/buysell.jpg.
class BuySellTheme extends StatelessWidget {
  const BuySellTheme({super.key, required this.child});

  final Widget child;
  static const cobalt = Color(0xFF2453D4);
  static const ice = Color(0xFFF3F7FF);
  static const mist = Color(0xFFDCE8FF);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final dark = base.brightness == Brightness.dark;
    final primary = dark ? const Color(0xFFACC8FF) : cobalt;
    final background = dark ? const Color(0xFF101A30) : ice;
    final surface = dark ? const Color(0xFF1C2B46) : Colors.white;
    final soft = dark ? const Color(0xFF263F69) : mist;
    final ink = dark ? const Color(0xFFF0F5FF) : const Color(0xFF172642);
    final muted = dark ? const Color(0xFFBDCCE5) : const Color(0xFF526582);
    final border = dark ? const Color(0xFF425B80) : const Color(0xFFCFDCF2);
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
          color: cobalt.withValues(alpha: dark ? 0.03 : 0.06),
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
        AppTone.neutral: dark ? surface : ice,
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
                  const Color(0xFF101B32),
                  const Color(0xFF233F68),
                  const Color(0xFF192C4A)
                ]
              : [ice, const Color(0xFFDCEAFF), const Color(0xFFECEDFF)],
        )))),
        Positioned(
            top: 80,
            right: -80,
            child: _BuySellGlow(
                color:
                    dark ? const Color(0xFF365DAB) : const Color(0xFF97BEFF))),
        Positioned(
            bottom: 100,
            left: -100,
            child: _BuySellGlow(
                color:
                    dark ? const Color(0xFF535B9B) : const Color(0xFFC2CAFF))),
        child,
      ])),
    );
  }
}

class _BuySellGlow extends StatelessWidget {
  const _BuySellGlow({required this.color});
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

/// Frosted marketplace panels, clipped before applying a shared backdrop blur.
class BuySellGlass extends StatelessWidget {
  const BuySellGlass(
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
      BuySellGlass(padding: const EdgeInsets.all(18), child: child);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);
    final fill =
        color ?? (dark ? const Color(0xFF1C2D49) : const Color(0xFFF7FAFF));
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: [
        BoxShadow(
            color: BuySellTheme.cobalt.withValues(alpha: dark ? 0.05 : 0.09),
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

class BuySellActionBar extends StatelessWidget {
  const BuySellActionBar({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: BuySellGlass(padding: const EdgeInsets.all(8), child: child),
      ));
}
