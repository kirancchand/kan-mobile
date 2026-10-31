import 'package:flutter/material.dart';
import '../../core/widgets/village_top_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/village_carousel.dart';
import '../../core/widgets/app_card.dart';
import 'service_catalog_builder.dart';
import 'service_router.dart';
import '../../core/theme/app_icons.dart';

class ServicesHomeScreen extends StatelessWidget {
  const ServicesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VillageTopBar(subtitle: Text('Services')),
      body: ServiceCatalogBuilder(
          builder: (context, services, refresh) => RefreshIndicator(
              onRefresh: refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
                itemCount: services.isEmpty ? 2 : services.length + 1,
                separatorBuilder: (_, index) => SizedBox(
                    height: index == 0 ? AppSpacing.lg : AppSpacing.ms),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const VillageCarousel();
                  }
                  if (services.isEmpty) {
                    return const Text('No services available');
                  }
                  final service = services[index - 1];
                  return AppCard(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      leading: IconBadge(
                          icon: service.icon, color: service.color, size: 48),
                      title: Text(service.label),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(service.description),
                      ),
                      trailing: const Icon(AppIcons.caretRight, size: 18),
                      onTap: () => openCatalogService(context, service),
                    ),
                  )
                      .animate(delay: (index * 35).ms)
                      .fadeIn(duration: 240.ms)
                      .slideX(begin: 0.08, end: 0, curve: Curves.easeOut);
                },
              ))),
    );
  }
}
