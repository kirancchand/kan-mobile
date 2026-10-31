import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Emerald + Teal + Sunshine design system (design.md). Light and dark
/// schemes are built by hand from [AppColors] — not seeded — so every role
/// is intentional. Semantic extras (sunshine, lime, status tones, hero
/// gradient) live in [AppTokens].
class AppTheme {
  AppTheme._();

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.emeraldDeep,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.emeraldSoft,
    onPrimaryContainer: AppColors.emeraldInk,
    secondary: AppColors.teal,
    onSecondary: AppColors.midnight,
    secondaryContainer: AppColors.tealSoft,
    onSecondaryContainer: AppColors.tealInk,
    tertiary: AppColors.sunshine,
    onTertiary: AppColors.midnight,
    tertiaryContainer: AppColors.sunshineSoft,
    onTertiaryContainer: AppColors.sunshineInk,
    error: AppColors.coralInk,
    onError: AppColors.white,
    errorContainer: AppColors.coralSoft,
    onErrorContainer: AppColors.coralInk,
    surface: AppColors.white,
    onSurface: AppColors.midnight,
    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.cloud,
    surfaceContainer: Color(0xFFEFF6F3),
    surfaceContainerHigh: AppColors.mist,
    surfaceContainerHighest: AppColors.mist,
    onSurfaceVariant: AppColors.muted,
    outline: AppColors.outline,
    outlineVariant: AppColors.mist,
    inverseSurface: AppColors.midnight,
    onInverseSurface: AppColors.cloud,
    inversePrimary: AppColors.darkPrimary,
    shadow: AppColors.midnight,
    scrim: AppColors.midnight,
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkBackground,
    primaryContainer: AppColors.darkEmeraldSoft,
    onPrimaryContainer: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.darkBackground,
    secondaryContainer: AppColors.darkTealSoft,
    onSecondaryContainer: AppColors.darkSecondary,
    tertiary: AppColors.sunshine,
    onTertiary: AppColors.midnight,
    tertiaryContainer: AppColors.darkSunshineSoft,
    onTertiaryContainer: AppColors.sunshine,
    error: AppColors.darkCoral,
    onError: AppColors.darkBackground,
    errorContainer: AppColors.darkCoralSoft,
    onErrorContainer: AppColors.darkCoral,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkText,
    surfaceContainerLowest: AppColors.darkBackground,
    surfaceContainerLow: Color(0xFF0C1F1F),
    surfaceContainer: AppColors.darkSurface,
    surfaceContainerHigh: AppColors.darkSurfaceHigh,
    surfaceContainerHighest: AppColors.darkSurfaceHighest,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkBorder,
    inverseSurface: AppColors.darkText,
    onInverseSurface: AppColors.midnight,
    inversePrimary: AppColors.emeraldDeep,
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  static ThemeData get light => _build(_lightScheme, AppTokens.light);

  static ThemeData get dark => _build(_darkScheme, AppTokens.dark);

  static ThemeData _build(ColorScheme scheme, AppTokens tokens) {
    final isDark = scheme.brightness == Brightness.dark;
    final textTheme = AppTypography.textTheme(text: scheme.onSurface, muted: tokens.textMuted);
    final background = isDark ? AppColors.darkBackground : AppColors.cloud;
    final inputBorder = isDark ? AppColors.darkOutline : AppColors.inputBorder;
    final radiusMd = BorderRadius.circular(AppRadius.md);
    final disabledBg = scheme.onSurface.withValues(alpha: 0.08);
    final disabledFg = scheme.onSurface.withValues(alpha: 0.38);

    OutlineInputBorder inputOutline(Color color, [double width = 1]) =>
        OutlineInputBorder(borderRadius: radiusMd, borderSide: BorderSide(color: color, width: width));

    const buttonPadding = EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg);
    const buttonMinSize = Size(64, 52);
    final buttonShape = RoundedRectangleBorder(borderRadius: radiusMd);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [tokens],
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.md,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: tokens.border),
        ),
      ),
      // Primary button (design.md §10).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: disabledBg,
          disabledForegroundColor: disabledFg,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: buttonPadding,
          minimumSize: buttonMinSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.pressed) ? scheme.onPrimary.withValues(alpha: 0.14) : null),
        ),
      ),
      // FilledButton = primary; FilledButton.tonal = secondary (Mist bg).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          disabledBackgroundColor: disabledBg,
          disabledForegroundColor: disabledFg,
          padding: buttonPadding,
          minimumSize: buttonMinSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          disabledForegroundColor: disabledFg,
          side: BorderSide(color: inputBorder),
          padding: buttonPadding,
          minimumSize: buttonMinSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.ms, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 1,
        extendedTextStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.white,
        border: inputOutline(inputBorder),
        enabledBorder: inputOutline(inputBorder),
        focusedBorder: inputOutline(scheme.primary, 2),
        errorBorder: inputOutline(scheme.error, 1.4),
        focusedErrorBorder: inputOutline(scheme.error, 2),
        disabledBorder: inputOutline(tokens.border),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        hintStyle: textTheme.bodyLarge?.copyWith(color: tokens.textMuted),
        labelStyle: textTheme.bodyLarge?.copyWith(color: tokens.textMuted),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
        prefixIconColor: tokens.textMuted,
        suffixIconColor: tokens.textMuted,
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        disabledColor: disabledBg,
        showCheckmark: false,
        labelStyle: textTheme.labelMedium?.copyWith(color: scheme.onSurface),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
              color: states.contains(WidgetState.selected) ? scheme.primary : inputBorder,
            )),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: inputBorder),
          textStyle: textTheme.labelMedium,
          minimumSize: const Size(48, 48),
          shape: buttonShape,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        height: 72,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? scheme.primary : tokens.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? scheme.primary : tokens.textMuted, size: 24);
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: tokens.textMuted,
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        indicatorColor: scheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: tokens.border,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: tokens.textMuted,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        leadingAndTrailingTextStyle: textTheme.bodySmall,
        minVerticalPadding: AppSpacing.sm,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surface,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: isDark ? AppColors.emeraldDeep : AppColors.lime,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
      dividerTheme: DividerThemeData(color: tokens.border, space: 1, thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? scheme.onPrimary : tokens.textMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? scheme.primary : scheme.surfaceContainerHighest),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.transparent : inputBorder),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: scheme.inverseSurface, borderRadius: BorderRadius.circular(AppRadius.sm)),
        textStyle: textTheme.labelSmall?.copyWith(color: scheme.onInverseSurface),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionHandleColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.24),
      ),
    );
  }
}
