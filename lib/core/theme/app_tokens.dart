import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_shadows.dart';

/// Semantic tone used by chips, icon badges and status indicators so
/// screens say *what* something means rather than picking a raw color.
///
/// - [brand]     Emerald — primary, success, "available"
/// - [info]      Teal — secondary services, in-progress states
/// - [accent]    Sunshine — events, highlights, pending attention
/// - [lime]      Lime — sparing secondary emphasis
/// - [attention] Coral — errors, warnings, emergency, destructive
/// - [neutral]   Muted grey-green — metadata
enum AppTone { brand, info, accent, lime, attention, neutral }

/// Design tokens that don't fit in [ColorScheme] (design.md §2). Read via
/// `context.tokens`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.brand,
    required this.accent,
    required this.onAccent,
    required this.textMuted,
    required this.border,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.heroGradient,
    required this.cardShadow,
    required this.toneInk,
    required this.toneSoft,
  });

  /// The exact brand emerald — for icons, indicators and decoration (not
  /// for text on white, see [AppColors.emeraldDeep]).
  final Color brand;
  final Color accent;
  final Color onAccent;
  final Color textMuted;
  final Color border;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Gradient heroGradient;
  final List<BoxShadow> cardShadow;
  final Map<AppTone, Color> toneInk;
  final Map<AppTone, Color> toneSoft;

  /// Foreground (text/icon) color for [tone], readable on [soft].
  Color ink(AppTone tone) => toneInk[tone]!;

  /// Tinted background for [tone].
  Color soft(AppTone tone) => toneSoft[tone]!;

  static final AppTokens light = AppTokens(
    brand: AppColors.emerald,
    accent: AppColors.sunshine,
    onAccent: AppColors.midnight,
    textMuted: AppColors.muted,
    border: AppColors.mist,
    skeletonBase: AppColors.mist,
    skeletonHighlight: AppColors.cloud,
    heroGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      // Emerald → teal → blue-teal, as in the brand texture reference; each
      // stop keeps white text at WCAG AA.
      colors: [Color(0xFF007A57), Color(0xFF00857A), Color(0xFF00758F)],
    ),
    cardShadow: AppShadows.cardLight,
    toneInk: const {
      AppTone.brand: AppColors.emeraldInk,
      AppTone.info: AppColors.tealInk,
      AppTone.accent: AppColors.sunshineInk,
      AppTone.lime: AppColors.limeInk,
      AppTone.attention: AppColors.coralInk,
      AppTone.neutral: AppColors.neutralInk,
    },
    toneSoft: const {
      AppTone.brand: AppColors.emeraldSoft,
      AppTone.info: AppColors.tealSoft,
      AppTone.accent: AppColors.sunshineSoft,
      AppTone.lime: AppColors.limeSoft,
      AppTone.attention: AppColors.coralSoft,
      AppTone.neutral: AppColors.neutralSoft,
    },
  );

  static final AppTokens dark = AppTokens(
    brand: AppColors.darkPrimary,
    accent: AppColors.sunshine,
    onAccent: AppColors.midnight,
    textMuted: AppColors.darkTextSecondary,
    border: AppColors.darkBorder,
    skeletonBase: AppColors.darkSurface,
    skeletonHighlight: AppColors.darkSurfaceHighest,
    heroGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A4A3C), Color(0xFF0C514B), Color(0xFF0B4757)],
    ),
    cardShadow: AppShadows.cardDark,
    toneInk: const {
      AppTone.brand: AppColors.darkPrimary,
      AppTone.info: AppColors.darkSecondary,
      AppTone.accent: AppColors.sunshine,
      AppTone.lime: AppColors.lime,
      AppTone.attention: AppColors.darkCoral,
      AppTone.neutral: AppColors.darkTextSecondary,
    },
    toneSoft: const {
      AppTone.brand: AppColors.darkEmeraldSoft,
      AppTone.info: AppColors.darkTealSoft,
      AppTone.accent: AppColors.darkSunshineSoft,
      AppTone.lime: AppColors.darkLimeSoft,
      AppTone.attention: AppColors.darkCoralSoft,
      AppTone.neutral: AppColors.darkNeutralSoft,
    },
  );

  @override
  AppTokens copyWith({
    Color? brand,
    Color? accent,
    Color? onAccent,
    Color? textMuted,
    Color? border,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Gradient? heroGradient,
    List<BoxShadow>? cardShadow,
    Map<AppTone, Color>? toneInk,
    Map<AppTone, Color>? toneSoft,
  }) {
    return AppTokens(
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      heroGradient: heroGradient ?? this.heroGradient,
      cardShadow: cardShadow ?? this.cardShadow,
      toneInk: toneInk ?? this.toneInk,
      toneSoft: toneSoft ?? this.toneSoft,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Map<AppTone, Color> lerpMap(Map<AppTone, Color> a, Map<AppTone, Color> b) =>
        {for (final tone in AppTone.values) tone: Color.lerp(a[tone], b[tone], t)!};
    return AppTokens(
      brand: Color.lerp(brand, other.brand, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
      heroGradient: Gradient.lerp(heroGradient, other.heroGradient, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      toneInk: lerpMap(toneInk, other.toneInk),
      toneSoft: lerpMap(toneSoft, other.toneSoft),
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
