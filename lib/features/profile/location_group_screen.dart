import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/models/location.dart';
import '../../data/models/whatsapp_group.dart';
import '../../data/repositories/location_repository.dart';
import '../../state/app_state.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/shimmer_list_placeholder.dart';
import '../../core/theme/app_icons.dart';

class LocationGroupScreen extends StatefulWidget {
  const LocationGroupScreen({super.key});

  @override
  State<LocationGroupScreen> createState() => _LocationGroupScreenState();
}

class _LocationGroupScreenState extends State<LocationGroupScreen> {
  late Future<VillageLocation?> _future;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser;
    _future = user == null
        ? Future.value(null)
        : context.read<LocationRepository>().getById(user.locationId);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Location & Group')),
      body: FutureBuilder<VillageLocation?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ShimmerListPlaceholder();
          }
          if (snapshot.data == null) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                  'No village or WhatsApp group is assigned to this account.'),
            );
          }
          final location = snapshot.data;
          final groups = user == null
              ? <WhatsAppGroup>[]
              : appState.whatsAppGroupRepository.groupsFor(user.locationId);
          final myGroup =
              groups.where((g) => g.id == user?.whatsAppGroupId).toList();

          final textTheme = Theme.of(context).textTheme;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  leading: const IconBadge(icon: AppIcons.mapPin),
                  title: Text(location?.displayName ?? 'Unknown'),
                  subtitle: Text(
                      '${location?.state ?? ''} • ${location?.registeredUsers ?? 0} registered members'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Your WhatsApp Group', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (myGroup.isEmpty)
                Text('No group assigned yet.',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: context.tokens.textMuted))
              else
                AppCard(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    leading: const IconBadge(
                        icon: AppIcons.usersThree, tone: AppTone.info),
                    title: Text(
                        '${location?.name ?? ''} — ${myGroup.first.displayName}'),
                    subtitle: Text(
                        '${myGroup.first.memberCount}/${myGroup.first.memberLimit} members'),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text('All Groups for This Village', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              ...groups.map((g) {
                final isMine = g.id == user?.whatsAppGroupId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    child: ListTile(
                      leading: Icon(AppIcons.usersThree,
                          color: isMine
                              ? context.tokens.brand
                              : context.tokens.textMuted),
                      title: Text(g.displayName),
                      subtitle:
                          Text('${g.memberCount}/${g.memberLimit} members'),
                      trailing: isMine
                          ? const StatusChip(
                              label: 'Your group', tone: AppTone.brand)
                          : null,
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Only groups assigned by the service appear here.',
                style: textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
