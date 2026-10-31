import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../../core/theme/app_icons.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader(
      {super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg, AppSpacing.xs, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          if (actionLabel != null)
            TextButton.icon(
              onPressed: onAction,
              label: Text(actionLabel!),
              icon: const Icon(AppIcons.caretRightBold, size: 14),
              iconAlignment: IconAlignment.end,
            ),
        ],
      ),
    );
  }
}
