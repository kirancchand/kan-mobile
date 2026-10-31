import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/contact_actions.dart';
import '../../../data/models/emergency_contact.dart';

/// Emergency numbers use the Coral "attention" tone (design.md §2).
class EmergencyContactsSection extends StatelessWidget {
  final List<EmergencyContact> contacts;

  const EmergencyContactsSection({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) return const SizedBox.shrink();
    final tokens = context.tokens;
    final ink = tokens.ink(AppTone.attention);
    final soft = tokens.soft(AppTone.attention);
    final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
    return SizedBox(
      height: 84 + 24 * textScale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.ms),
        itemBuilder: (context, index) {
          final c = contacts[index];
          return Material(
            color: soft,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.card),
              onTap: () => showCallSheet(context, name: c.name, phone: c.phone),
              child: Container(
                width: 100,
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(c.icon, color: ink, size: 26),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      c.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: ink),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate(delay: (index * 40).ms)
              .fadeIn(duration: 250.ms)
              .slideX(begin: 0.15, end: 0, curve: Curves.easeOut);
        },
      ),
    );
  }
}
