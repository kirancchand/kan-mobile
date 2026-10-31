import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../data/models/service_definition.dart';
import '../../services/service_router.dart';

/// Icon + label category grid. White tiles keep the page calm; colour comes
/// only from each service's tinted icon badge.
class ServicesGrid extends StatelessWidget {
  final List<ServiceDefinition> services;
  final int? crossAxisCount;

  const ServicesGrid({super.key, required this.services, this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    return LayoutBuilder(builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
      if (services.isEmpty) return const SizedBox.shrink();
      final singleService = services.length == 1;
      final preferredColumns = crossAxisCount ??
          (constraints.maxWidth / (104 * textScale)).floor().clamp(2, 6);
      final columns = preferredColumns.clamp(1, services.length);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: services.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: AppSpacing.ms,
          crossAxisSpacing: AppSpacing.ms,
          mainAxisExtent: 88 + 40 * textScale,
        ),
        itemBuilder: (context, index) {
          final service = services[index];
          return Material(
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: BorderSide(color: tokens.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => openCatalogService(context, service),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: singleService
                    ? Row(
                        children: [
                          IconBadge(
                              icon: service.icon,
                              color: service.color,
                              size: 48),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                if (service.description.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    service.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconBadge(
                              icon: service.icon,
                              color: service.color,
                              size: 48),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            service.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
              ),
            ),
          )
              .animate(delay: (index * 40).ms)
              .fadeIn(duration: 250.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
        },
      );
    });
  }
}
