import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter type scale (design.md §6). Screens should use
/// `Theme.of(context).textTheme.*` — never hard-coded font sizes.
///
/// | Spec role  | TextTheme slot                    | Size |
/// |------------|-----------------------------------|------|
/// | Display    | displayLarge / displayMedium      | 34 / 32 |
/// | H1         | headlineLarge                     | 28 |
/// | H2         | headlineMedium / headlineSmall    | 24 / 22 |
/// | H3         | titleLarge                        | 19 |
/// | Body       | titleMedium (emphasised) / bodyLarge / bodyMedium | 16 / 16 / 15 |
/// | Secondary  | titleSmall / bodySmall / labelMedium | 14 / 13 / 13 |
/// | Caption    | labelSmall                        | 12 |
class AppTypography {
  AppTypography._();

  static TextTheme textTheme({required Color text, required Color muted}) {
    final base = GoogleFonts.interTextTheme();
    TextStyle? s(TextStyle? style, double size, FontWeight weight,
            {double height = 1.4, double letterSpacing = 0, Color? color}) =>
        style?.copyWith(
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: letterSpacing,
          color: color ?? text,
        );

    return base.copyWith(
      displayLarge: s(base.displayLarge, 34, FontWeight.w700, height: 1.15, letterSpacing: -0.5),
      displayMedium: s(base.displayMedium, 32, FontWeight.w700, height: 1.15, letterSpacing: -0.5),
      displaySmall: s(base.displaySmall, 30, FontWeight.w700, height: 1.2, letterSpacing: -0.4),
      headlineLarge: s(base.headlineLarge, 28, FontWeight.w700, height: 1.2, letterSpacing: -0.3),
      headlineMedium: s(base.headlineMedium, 24, FontWeight.w700, height: 1.25, letterSpacing: -0.2),
      headlineSmall: s(base.headlineSmall, 22, FontWeight.w600, height: 1.25, letterSpacing: -0.2),
      titleLarge: s(base.titleLarge, 19, FontWeight.w600, height: 1.3),
      titleMedium: s(base.titleMedium, 16, FontWeight.w600, height: 1.35),
      titleSmall: s(base.titleSmall, 14, FontWeight.w600, height: 1.35),
      bodyLarge: s(base.bodyLarge, 16, FontWeight.w400, height: 1.5),
      bodyMedium: s(base.bodyMedium, 15, FontWeight.w400, height: 1.45),
      bodySmall: s(base.bodySmall, 13, FontWeight.w400, height: 1.4, color: muted),
      labelLarge: s(base.labelLarge, 15, FontWeight.w600, height: 1.2, letterSpacing: 0.1),
      labelMedium: s(base.labelMedium, 13, FontWeight.w600, height: 1.2),
      labelSmall: s(base.labelSmall, 12, FontWeight.w500, height: 1.25, letterSpacing: 0.1),
    );
  }
}
