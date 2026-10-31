import 'package:flutter/painting.dart';

/// Raw Emerald + Teal + Sunshine palette (design.md §1 and §19).
///
/// Widgets should not read these directly — go through
/// `Theme.of(context).colorScheme` or `context.tokens` (see app_tokens.dart)
/// so light and dark mode both resolve correctly. The only exceptions are
/// the theme builders themselves.
class AppColors {
  AppColors._();

  // ── Brand (light) ────────────────────────────────────────────────────
  static const Color emerald = Color(0xFF00A878); // primary brand
  static const Color teal = Color(0xFF00B8A9); // secondary brand
  static const Color sunshine = Color(0xFFFFC857); // events, highlights
  static const Color lime = Color(0xFFB8E04B); // sparing secondary emphasis
  static const Color coral = Color(0xFFFF6B5E); // errors, attention

  // Brand tones deep enough to carry white text / sit as text on white at
  // WCAG AA (4.5:1). #00A878 with white text is only ~3:1, so filled
  // buttons, links and focus states use [emeraldDeep] instead.
  static const Color emeraldDeep = Color(0xFF00805C);
  static const Color emeraldInk = Color(0xFF00724F);
  static const Color tealInk = Color(0xFF00756B);
  static const Color sunshineInk = Color(0xFF7A5800);
  static const Color limeInk = Color(0xFF4D6B00);
  static const Color coralInk = Color(0xFFB3342A);

  // ── Neutrals (light) ─────────────────────────────────────────────────
  static const Color midnight = Color(0xFF102A2A); // primary text
  static const Color cloud = Color(0xFFF7FAF8); // main background
  static const Color mist = Color(0xFFE8F2EF); // secondary bg / borders
  static const Color white = Color(0xFFFFFFFF); // surfaces
  static const Color muted = Color(0xFF66756B); // secondary text / nav
  static const Color inputBorder = Color(0xFFD3E2DD);
  static const Color outline = Color(0xFFB9CBC5);

  // Soft tints (chip / badge backgrounds).
  static const Color emeraldSoft = Color(0xFFDDF4EC);
  static const Color tealSoft = Color(0xFFD9F4F1);
  static const Color sunshineSoft = Color(0xFFFFF1CF);
  static const Color limeSoft = Color(0xFFEEF8D6);
  static const Color coralSoft = Color(0xFFFFE5E2);
  static const Color neutralSoft = Color(0xFFEDF2F0);
  static const Color neutralInk = Color(0xFF4E5E59);

  // ── Dark foundation (design.md §19) ─────────────────────────────────
  static const Color darkBackground = Color(0xFF081414);
  static const Color darkSurface = Color(0xFF102A2A);
  static const Color darkSurfaceHigh = Color(0xFF173636);
  static const Color darkSurfaceHighest = Color(0xFF1D4242);
  static const Color darkPrimary = Color(0xFF00B894);
  static const Color darkSecondary = Color(0xFF20C7B7);
  static const Color darkText = Color(0xFFF5FAF8);
  static const Color darkTextSecondary = Color(0xFFA8BCB6);
  static const Color darkBorder = Color(0xFF1F3D3B);
  static const Color darkOutline = Color(0xFF3D5A56);
  static const Color darkCoral = Color(0xFFFF8A7F);

  static const Color darkEmeraldSoft = Color(0xFF0E3A31);
  static const Color darkTealSoft = Color(0xFF0E3634);
  static const Color darkSunshineSoft = Color(0xFF3A3016);
  static const Color darkLimeSoft = Color(0xFF2A3514);
  static const Color darkCoralSoft = Color(0xFF3D1B19);
  static const Color darkNeutralSoft = Color(0xFF1A3432);
}
