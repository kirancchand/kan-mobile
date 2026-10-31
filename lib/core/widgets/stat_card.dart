import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';
import 'app_card.dart';
import 'icon_badge.dart';

/// Metric tile used by the admin dashboards.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.tone = AppTone.brand,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final AppTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconBadge(icon: icon, tone: tone, size: 36),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Text(label,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
