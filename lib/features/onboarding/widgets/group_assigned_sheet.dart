import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../data/models/location.dart';
import '../../../data/models/whatsapp_group.dart';
import '../../../core/theme/app_icons.dart';

/// Confirms the WhatsApp group auto-assignment outcome (Section 4) right
/// after registration completes.
class GroupAssignedSheet extends StatelessWidget {
  final VillageLocation location;
  final WhatsAppGroup group;

  const GroupAssignedSheet({super.key, required this.location, required this.group});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconBadge(icon: AppIcons.checkCircle, size: 72)
                .animate()
                .scale(duration: 350.ms, curve: Curves.easeOutBack),
            const SizedBox(height: AppSpacing.md),
            Text("You're all set!", style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Registered for ${location.displayName}",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: tokens.soft(AppTone.brand),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.usersThree, color: tokens.ink(AppTone.brand)),
                  const SizedBox(width: AppSpacing.ms),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Added to ${location.name} — ${group.displayName}',
                          style: textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${group.memberCount}/${group.memberLimit} members',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'Go to Home', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
