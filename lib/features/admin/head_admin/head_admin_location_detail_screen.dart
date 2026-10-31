import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/admin_models.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_list_placeholder.dart';
import '../../../core/theme/app_icons.dart';

/// Read-only view of one location's businesses/people & transactions, as
/// drilled into from the Head Admin's consolidated dashboard.
class HeadAdminLocationDetailScreen extends StatefulWidget {
  final LocationAnalytics analytics;

  const HeadAdminLocationDetailScreen({super.key, required this.analytics});

  @override
  State<HeadAdminLocationDetailScreen> createState() =>
      _HeadAdminLocationDetailScreenState();
}

class _HeadAdminLocationDetailScreenState
    extends State<HeadAdminLocationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Object>> _future;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  void _load() {
    final repo = context.read<AdminRepository>();
    _future = Future.wait([
      repo.getRegisteredEntities(widget.analytics.locationId),
      repo.getTransactions(widget.analytics.locationId),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.analytics;
    return Scaffold(
      appBar: AppBar(
        title: Text(a.locationName),
        bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Registered'), Tab(text: 'Transactions')]),
      ),
      body: FutureBuilder<List<Object>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(onRetry: () => setState(_load));
          }
          if (!snapshot.hasData) return const ShimmerListPlaceholder();
          final entities = snapshot.data![0] as List<RegisteredEntity>;
          final transactions = snapshot.data![1] as List<LocationTransaction>;

          return TabBarView(
            controller: _tabController,
            children: [
              entities.isEmpty
                  ? const EmptyState(
                      icon: AppIcons.usersThree,
                      title: 'No registrations yet',
                      message:
                          'Residents and businesses who register in this location will be listed here.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: entities.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final e = entities[index];
                        return AppCard(
                          child: ListTile(
                            leading: IconBadge(
                              icon: e.type == 'Business'
                                  ? AppIcons.storefront
                                  : AppIcons.user,
                              tone: e.type == 'Business'
                                  ? AppTone.info
                                  : AppTone.brand,
                            ),
                            title: Text(e.name),
                            subtitle: Text('${e.type} • ${e.category}'),
                            trailing: Text(Formatters.date(e.registeredOn)),
                          ),
                        );
                      },
                    ),
              transactions.isEmpty
                  ? const EmptyState(
                      icon: AppIcons.receipt,
                      tone: AppTone.accent,
                      title: 'No transactions yet',
                      message:
                          'Service payments made in this location will appear here.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
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
            ],
          );
        },
      ),
    );
  }
}
