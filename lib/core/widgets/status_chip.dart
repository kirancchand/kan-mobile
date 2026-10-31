import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';

/// Small labelled status/tag. Meaning is always carried by the [label]
/// text, with [tone] as a secondary cue (design.md §18).
class StatusChip extends StatelessWidget {
  final String label;
  final AppTone tone;

  const StatusChip({super.key, required this.label, this.tone = AppTone.neutral});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: tokens.soft(tone),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tokens.ink(tone),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
