import '../admin_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../data/models/admin_hierarchy.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../state/admin_state.dart';
import 'head_admin_location_detail_screen.dart';
import '../admin_directory_screen.dart';
import '../add_branch_user_screen.dart';
import '../../home/add_organisation_screen.dart';

/// Shared dashboard for Main Admin and all five subordinate levels.
class HeadAdminDashboard extends StatefulWidget {
  const HeadAdminDashboard({super.key});

  @override
  State<HeadAdminDashboard> createState() => _HeadAdminDashboardState();
}

class _HeadAdminDashboardState extends State<HeadAdminDashboard> {
  final List<String> _path = [];
  final ScrollController _scroll = ScrollController();
  final _loadingSubadmins = <String>{};
  final _subadminLoadErrors = <String, String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadSubadmins(context.read<AdminState>().account);
    });
  }

  Future<void> _loadSubadmins(AdminAccount? account) async {
    if (account == null ||
        (account.level != AdminLevel.main &&
            account.level != AdminLevel.state &&
            account.level != AdminLevel.district &&
            account.level != AdminLevel.area)) {
      return;
    }
    final token = context.read<AuthRepository?>()?.tokens?.accessToken;
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() => _subadminLoadErrors[account.id] =
            'API login is required to load subadmins.');
      }
      return;
    }
    if (mounted) {
      setState(() {
        _loadingSubadmins.add(account.id);
        _subadminLoadErrors.remove(account.id);
      });
    }
    try {
      final repo = context.read<AdminRepository>();
      if (account.level == AdminLevel.main) {
        await repo.loadStatesForMain(
            mainAccountId: account.id, accessToken: token);
      } else if (account.level == AdminLevel.state) {
        await repo.loadDistrictsForState(
            stateAccountId: account.id, accessToken: token);
      } else if (account.level == AdminLevel.district) {
        await repo.loadAreasForDistrict(
            districtAccountId: account.id, accessToken: token);
      } else if (account.masterAreaId != null) {
        await repo.loadBranchesForArea(
            areaAccountId: account.id, accessToken: token);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _subadminLoadErrors[account.id] =
            error.toString().replaceFirst('Bad state: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loadingSubadmins.remove(account.id));
    }
  }

  void _openAdmin(AdminAccount child) {
    _navigate(() {
      _path.add(child.id);
    });
    if (child.level == AdminLevel.state ||
        child.level == AdminLevel.district ||
        child.level == AdminLevel.area) {
      _loadSubadmins(child);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _navigate(VoidCallback update) {
    setState(update);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _openDirectory(String targetId, {bool businesses = false}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminDirectoryScreen(targetId: targetId, businesses: businesses),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AdminState>();
    final viewer = session.account;
    if (viewer == null) return const SizedBox.shrink();
    final repo = context.read<AdminRepository>();
    final data = repo.getOverview(
      viewerId: viewer.id,
      targetId: _path.isEmpty ? viewer.id : _path.last,
    );
    final account = data.account;
    final textTheme = Theme.of(context).textTheme;
    final breadcrumbs = [viewer.id, ..._path];

    Widget heading(String text) => Padding(
          padding:
              const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
          child: Text(text, style: textTheme.titleLarge),
        );

    return PopScope(
      canPop: _path.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _path.isNotEmpty) _navigate(() => _path.removeLast());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _path.isEmpty
              ? null
              : BackButton(
                  onPressed: () => _navigate(() => _path.removeLast()),
                ),
          title: Text(account.level.label),
          actions: [
            IconButton(
              icon: const Icon(AppIcons.signOut),
              tooltip: 'Logout as ${session.adminName}',
              onPressed: session.logout,
            ),
          ],
        ),
        body: ListView(
          key: ValueKey(account.id),
          controller: _scroll,
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final (index, id) in breadcrumbs.indexed)
                  TextButton(
                    onPressed: index == breadcrumbs.length - 1
                        ? null
                        : () => _navigate(
                            () => _path.removeRange(index, _path.length)),
                    child: Text(repo.accountById(id).territory),
                  ),
              ],
            ),
            Text(account.territory, style: textTheme.headlineSmall),
            Text(account.name, style: textTheme.bodyLarge),
            if (viewer.level == AdminLevel.branch)
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(AppIcons.buildings),
                    label: const Text('Add Organisation'),
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute<bool>(
                            builder: (_) =>
                                const AddOrganisationScreen(branchAdmin: true),
                          ));
                      if (mounted) setState(() {});
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(AppIcons.usersThree),
                    label: const Text('Add User'),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<bool>(
                          builder: (_) => const AddBranchUserScreen(),
                        )),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
                '${data.descendantCount} subadmins • ${data.locations.length} branches'),
            OutlinedButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: const Text('Territory map'),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminMapScreen(targetId: account.id),
                  )),
            ),
            heading('Statistics'),
            LayoutBuilder(builder: (context, constraints) {
              final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
              return GridView.count(
                crossAxisCount: constraints.maxWidth >= 650 ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisExtent: 155 + (scale - 1) * 50,
                children: [
                  StatCard(
                      label: 'Active Users',
                      value: '${data.activeUsers}',
                      icon: AppIcons.usersThree,
                      onTap: () => _openDirectory(account.id)),
                  StatCard(
                      label: 'Businesses',
                      value: '${data.registeredBusinesses}',
                      icon: AppIcons.storefront,
                      onTap: () =>
                          _openDirectory(account.id, businesses: true)),
                  StatCard(
                      label: 'WhatsApp Groups',
                      value: '${data.groups}',
                      icon: AppIcons.usersThree),
                  StatCard(
                      label: 'Group Members',
                      value: '${data.members}',
                      icon: AppIcons.usersThree),
                  StatCard(
                      label: 'Transaction Value',
                      value: Formatters.currency(data.transactionValue),
                      icon: AppIcons.currencyInr),
                  StatCard(
                      label: 'Subadmins',
                      value: '${data.descendantCount}',
                      icon: AppIcons.shieldCheck),
                ],
              );
            }),
            heading('Subadmins'),
            if (_loadingSubadmins.contains(account.id))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: LinearProgressIndicator(),
              ),
            if (_subadminLoadErrors.containsKey(account.id))
              AppCard(
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: const Text('Could not load subadmins'),
                  subtitle: Text(_subadminLoadErrors[account.id]!),
                  trailing: TextButton(
                    onPressed: () => _loadSubadmins(account),
                    child: const Text('Retry'),
                  ),
                ),
              ),
            if (data.children.isEmpty &&
                !_loadingSubadmins.contains(account.id) &&
                !_subadminLoadErrors.containsKey(account.id))
              Text(account.level == AdminLevel.branch
                  ? 'Branch level — no subadmins. Shops and organisations report to this branch.'
                  : 'No subadmin territories configured yet.'),
            for (final child in data.children)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _AdminTile(
                  viewerId: viewer.id,
                  account: child,
                  onTap: () => _openAdmin(child),
                ),
              ),
            heading('Service Usage'),
            if (data.serviceUsage.isEmpty) const Text('No service usage yet.'),
            for (final entry in data.serviceUsage.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.key),
                trailing: Text('${entry.value}', style: textTheme.titleMedium),
              ),
            heading('Branch Records'),
            for (final location in data.locations)
              AppCard(
                child: ListTile(
                  title: Text(location.locationName),
                  subtitle: const Text(
                      'Registered businesses, residents and transactions'),
                  trailing: const Icon(AppIcons.caretRight, size: 18),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            HeadAdminLocationDetailScreen(analytics: location)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile(
      {required this.viewerId, required this.account, required this.onTap});
  final String viewerId;
  final AdminAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Computed here so only tiles scrolled into view pay for their stats.
    final overview = context
        .read<AdminRepository>()
        .getOverview(viewerId: viewerId, targetId: account.id);
    return AppCard(
      child: ListTile(
        key: ValueKey('admin-${account.id}'),
        title: Text('${account.level.label} • ${account.territory}'),
        subtitle: Text(
          '${account.name}${account.isDemo ? ' • Dummy' : ''}\n'
          '${overview.activeUsers} users • ${overview.registeredBusinesses} businesses\n'
          '${overview.groups} groups • ${Formatters.currency(overview.transactionValue)}',
        ),
        trailing: const Icon(AppIcons.caretRight, size: 18),
        onTap: onTap,
      ),
    );
  }
}
