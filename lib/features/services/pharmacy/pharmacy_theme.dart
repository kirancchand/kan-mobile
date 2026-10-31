import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';

/// Teal pharmacy glass surfaces inspired by medicine.jpg and pharmacy.jpg.
class PharmacyTheme extends StatelessWidget {
  const PharmacyTheme({super.key, required this.child});
  final Widget child;
  static const teal = Color(0xFF087F83);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final dark = base.brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF193943) : const Color(0xFFF5FEFF);
    final primary = dark ? const Color(0xFF89DCDD) : teal;
    final soft = dark ? const Color(0xFF28515B) : const Color(0xFFD9F2EF);
    final ink = dark ? const Color(0xFFEBFAFD) : const Color(0xFF173846);
    final muted = dark ? const Color(0xFFB7D2DB) : const Color(0xFF506D79);
    final border = dark ? const Color(0xFF4F7480) : const Color(0xFFC6E4E6);
    final scheme = base.colorScheme.copyWith(
      primary: primary,
      onPrimary: dark ? const Color(0xFF12303D) : Colors.white,
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
                  const Color(0xFF102A36),
                  const Color(0xFF1C4650),
                  const Color(0xFF203344)
                ]
              : [
                  const Color(0xFFF4FDFF),
                  const Color(0xFFD3F0EC),
                  const Color(0xFFE4F0F6)
                ],
        )))),
        Positioned(
            top: 80,
            right: -90,
            child: _PharmacyGlow(
                color:
                    dark ? const Color(0xFF438D96) : const Color(0xFF82D1CE))),
        Positioned(
            bottom: 100,
            left: -110,
            child: _PharmacyGlow(
                color:
                    dark ? const Color(0xFF3D607D) : const Color(0xFFA3CBE1))),
        child,
      ])),
    );
  }
}

class _PharmacyGlow extends StatelessWidget {
  const _PharmacyGlow({required this.color});
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
class PharmacyGlass extends StatelessWidget {
  const PharmacyGlass(
      {super.key,
      required this.child,
      this.padding = EdgeInsets.zero,
      this.borderRadius = 24});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  static Widget form(Widget child) =>
      PharmacyGlass(padding: const EdgeInsets.all(18), child: child);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: [
        BoxShadow(
            color:
                const Color(0xFF245465).withValues(alpha: dark ? 0.06 : 0.09),
            blurRadius: 22,
            offset: const Offset(0, 8))
      ]),
      child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter.grouped(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: (dark ? const Color(0xFF193943) : const Color(0xFFF5FEFF))
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

class PharmacyActionBar extends StatelessWidget {
  const PharmacyActionBar({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: PharmacyGlass(padding: const EdgeInsets.all(8), child: child),
      ));
}
