import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_tokens.dart';
import 'empty_state.dart';

/// Friendly, consistent error view (design.md §17). Never shows the raw
/// exception — only a plain-language message and a recovery action.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = "Couldn't load this right now",
    this.message = 'Please check your connection and try again.',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: AppIcons.info,
      tone: AppTone.attention,
      title: title,
      message: message,
      actionLabel: onRetry == null ? null : 'Try again',
      onAction: onRetry,
    );
  }
}
