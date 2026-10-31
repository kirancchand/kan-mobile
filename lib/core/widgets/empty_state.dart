import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';
import 'app_button.dart';
import 'icon_badge.dart';

/// Designed empty state (design.md §15): what is empty ([title]), why it
/// matters ([message]) and what to do next ([actionLabel] / [onAction]).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppTone tone;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.tone = AppTone.brand,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl, horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(icon: icon, tone: tone, size: 72),
            const SizedBox(height: AppSpacing.md),
            Text(title, textAlign: TextAlign.center, style: textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: context.tokens.textMuted),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.secondary,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
