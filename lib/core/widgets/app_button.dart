import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

enum AppButtonVariant { primary, secondary, accent }

/// Full-width action button with default / pressed / disabled / loading
/// states (design.md §10).
///
/// - [AppButtonVariant.primary]   Emerald bg, white text
/// - [AppButtonVariant.secondary] Mist bg, Midnight text
/// - [AppButtonVariant.accent]    Sunshine bg, Midnight text
///
/// While [isLoading] the button is disabled and shows a spinner, so
/// callers no longer need `onPressed: _isSubmitting ? null : _submit`.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;

    final ButtonStyle? style = switch (variant) {
      AppButtonVariant.primary => null,
      AppButtonVariant.secondary => FilledButton.styleFrom(
          backgroundColor: scheme.surfaceContainerHighest,
          foregroundColor: scheme.onSurface,
        ),
      AppButtonVariant.accent => FilledButton.styleFrom(
          backgroundColor: tokens.accent,
          foregroundColor: tokens.onAccent,
        ),
    };

    // Loading buttons are disabled, so the spinner sits on the neutral
    // disabled fill regardless of variant.
    final spinnerColor = scheme.onSurface.withValues(alpha: 0.5);

    final child = isLoading
        ? Semantics(
            label: '$label, loading',
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: spinnerColor, strokeWidth: 2.4),
            ),
          )
        : Text(label);

    final effectiveOnPressed = isLoading ? null : onPressed;
    final button = icon != null && !isLoading
        ? FilledButton.icon(onPressed: effectiveOnPressed, style: style, icon: Icon(icon, size: 18), label: child)
        : FilledButton(onPressed: effectiveOnPressed, style: style, child: child);

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
