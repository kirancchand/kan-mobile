import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/textured_surface.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/admin_models.dart';
import '../../../data/models/location.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../state/admin_state.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_list_placeholder.dart';
import '../../../core/theme/app_icons.dart';

class LocationAdminDashboard extends StatefulWidget {
  final String locationId;

  const LocationAdminDashboard({super.key, required this.locationId});

  @override
  State<LocationAdminDashboard> createState() => _LocationAdminDashboardState();
}

class _LocationAdminDashboardState extends State<LocationAdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _future = _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<_DashboardData> _load() async {
    final adminRepo = context.read<AdminRepository>();
    final locationRepo = context.read<LocationRepository>();
    final results = await Future.wait([
      locationRepo.getById(widget.locationId),
      adminRepo.getRegisteredEntities(widget.locationId),
      adminRepo.getTransactions(widget.locationId),
      adminRepo.getAnalyticsForLocation(widget.locationId),
    ]);
    return _DashboardData(
      location: results[0] as VillageLocation?,
      entities: results[1] as List<RegisteredEntity>,
      transactions: results[2] as List<LocationTransaction>,
      analytics: results[3] as LocationAnalytics?,
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = context.watch<AdminState>();

    return FutureBuilder<_DashboardData>(
      future: _future,
      builder: (context, snapshot) {
        final locationName = snapshot.data?.location?.name ?? '...';
        return Scaffold(
          appBar: AppBar(
            title: Text('$locationName Admin'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Registered'),
                Tab(text: 'Transactions'),
                Tab(text: 'Analytics'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(AppIcons.signOut),
                tooltip: 'Logout as ${adminState.adminName}',
                onPressed: () => adminState.logout(),
              ),
            ],
          ),
          body: snapshot.hasError
              ? ErrorState(onRetry: () => setState(() {
                    _future = _load();
                  }))
              : !snapshot.hasData
                  ? const ShimmerListPlaceholder()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _RegisteredTab(entities: snapshot.data!.entities),
                        _TransactionsTab(
                            transactions: snapshot.data!.transactions),
                        _AnalyticsTab(analytics: snapshot.data!.analytics),
                      ],
                    ),
        );
      },
    );
  }
}

class _DashboardData {
  final VillageLocation? location;
  final List<RegisteredEntity> entities;
  final List<LocationTransaction> transactions;
  final LocationAnalytics? analytics;

  _DashboardData(
      {required this.location,
      required this.entities,
      required this.transactions,
      required this.analytics});
}

class _RegisteredTab extends StatelessWidget {
  final List<RegisteredEntity> entities;

  const _RegisteredTab({required this.entities});

  @override
  Widget build(BuildContext context) {
    if (entities.isEmpty) {
      return const EmptyState(
        icon: AppIcons.usersThree,
        title: 'No registrations yet',
        message:
            'Residents and businesses who register in your location will be listed here.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: entities.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final e = entities[index];
        return AppCard(
          child: ListTile(
            leading: IconBadge(
              icon: e.type == 'Business' ? AppIcons.storefront : AppIcons.user,
              tone: e.type == 'Business' ? AppTone.info : AppTone.brand,
            ),
            title: Text(e.name),
            subtitle: Text('${e.type} • ${e.category}'),
            trailing: Text(Formatters.date(e.registeredOn)),
          ),
        );
      },
    );
  }
}

class _TransactionsTab extends StatelessWidget {
  final List<LocationTransaction> transactions;

  const _TransactionsTab({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const EmptyState(
        icon: AppIcons.receipt,
        tone: AppTone.accent,
        title: 'No transactions yet',
        message: 'Service payments made in your location will appear here.',
      );
    }
    final total = transactions.fold<double>(0, (sum, t) => sum + t.amount);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TexturedSurface(
            padding: const EdgeInsets.all(AppSpacing.md + 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('Total Transaction Value',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.white)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(Formatters.currency(total),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final t = transactions[index];
              return AppCard(
                child: ListTile(
                  title: Text(t.description),
                  subtitle: Text(
                      '${t.serviceLabel} • ${Formatters.dateTime(t.timestamp)}'),
                  trailing: Text(Formatters.currency(t.amount),
                      style: Theme.of(context).textTheme.titleSmall),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  final LocationAnalytics? analytics;

  const _AnalyticsTab({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final a = analytics;
    if (a == null) {
      return const EmptyState(
        icon: AppIcons.chartBar,
        title: 'No analytics available',
        message:
            'Usage insights appear once residents start using services in your location.',
      );
    }
    final textTheme = Theme.of(context).textTheme;
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.ms,
          crossAxisSpacing: AppSpacing.ms,
          childAspectRatio: 1.35 / textScale,
          children: [
            StatCard(
                label: 'Active Users',
                value: '${a.activeUsers}',
                icon: AppIcons.usersThree),
            StatCard(
                label: 'Businesses',
                value: '${a.registeredBusinesses}',
                icon: AppIcons.storefront,
                tone: AppTone.info),
            StatCard(
                label: 'WhatsApp Groups',
                value: '${a.whatsAppGroupCount}',
                icon: AppIcons.usersThree,
                tone: AppTone.lime),
            StatCard(
                label: 'Group Members',
                value: '${a.totalWhatsAppMembers}',
                icon: AppIcons.usersThree,
                tone: AppTone.accent),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Service Usage', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.ms),
        ...a.serviceUsageCounts.entries.map((entry) {
          final maxVal =
              a.serviceUsageCounts.values.reduce((x, y) => x > y ? x : y);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.ms),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: textTheme.titleSmall),
                    Text('${entry.value}', style: textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: entry.value / maxVal,
                    minHeight: 8,
                    valueColor: AlwaysStoppedAnimation(context.tokens.brand),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
