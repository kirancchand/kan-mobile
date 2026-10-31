import 'admin_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/models/admin_hierarchy.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/home_repository.dart';
import '../../state/admin_state.dart';

/// A territory's complete directory, with recursive child-territory browsing.
class AdminDirectoryScreen extends StatefulWidget {
  const AdminDirectoryScreen({
    super.key,
    required this.targetId,
    this.businesses = false,
  });

  final String targetId;
  final bool businesses;

  @override
  State<AdminDirectoryScreen> createState() => _AdminDirectoryScreenState();
}

class _AdminDirectoryScreenState extends State<AdminDirectoryScreen> {
  bool _hierarchy = false;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewer = context.watch<AdminState>().account;
    final repo = context.read<AdminRepository>();
    final title = widget.businesses ? 'Businesses' : 'Users';
    if (viewer == null || !repo.canView(viewer.id, widget.targetId)) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Text('Sign in with an authorised admin account.'),
        ),
      );
    }
    return ListenableBuilder(
      listenable: Listenable.merge([
        context.read<AuthRepository?>()?.changes,
        context.read<HomeRepository?>()?.changes,
      ]),
      builder: (context, _) {
        final data =
            repo.getOverview(viewerId: viewer.id, targetId: widget.targetId);
        final users = widget.businesses
            ? <AdminResident>[]
            : repo.getUsers(viewerId: viewer.id, targetId: widget.targetId);
        final businesses = data.businesses;
        final filteredUsers = users
            .where((user) =>
                '${user.name} ${user.phone ?? ''} ${user.branch.territory} ${user.userType.label}'
                    .toLowerCase()
                    .contains(_query))
            .toList();
        final filteredBusinesses = businesses
            .where((business) =>
                '${business.name} ${business.category} ${business.branch.territory} ${business.address ?? ''} ${business.phone ?? ''}'
                    .toLowerCase()
                    .contains(_query))
            .toList();
        final total = widget.businesses ? businesses.length : users.length;
        final count = widget.businesses
            ? filteredBusinesses.length
            : filteredUsers.length;
        final noun = title.toLowerCase();
        return Scaffold(
          appBar: AppBar(title: Text(title), actions: [
            IconButton(
                tooltip: 'Map view',
                icon: const Icon(Icons.map_outlined),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminMapScreen(targetId: widget.targetId),
                    ))),
          ]),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.account.territory,
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('$total available $noun'),
                    const Text('Only available records are shown.'),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        ChoiceChip(
                          label: Text('View all $noun'),
                          selected: !_hierarchy,
                          onSelected: (_) => setState(() => _hierarchy = false),
                        ),
                        ChoiceChip(
                          label: const Text('View by hierarchy'),
                          selected: _hierarchy,
                          onSelected: (_) => setState(() => _hierarchy = true),
                        ),
                      ],
                    ),
                    if (!_hierarchy) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Search $noun',
                          hintText: widget.businesses
                              ? 'Name, category or branch'
                              : 'Name, phone or branch',
                          prefixIcon: const Icon(Icons.search),
                        ),
                        controller: _search,
                        onChanged: (value) =>
                            setState(() => _query = value.trim().toLowerCase()),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: _hierarchy
                    ? data.children.isEmpty
                        ? const Center(
                            child: Text(
                                'Branch level — no lower hierarchy. Select View all to see records.'))
                        : ListView.builder(
                            itemCount: data.children.length,
                            itemBuilder: (context, index) {
                              final child = data.children[index];
                              return ListTile(
                                key: ValueKey('hierarchy-${child.id}'),
                                title: Text(
                                    '${child.level.label} • ${child.territory}'),
                                subtitle: Text(
                                    '${child.name}${child.isDemo ? ' • Dummy' : ''}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminDirectoryScreen(
                                          targetId: child.id,
                                          businesses: widget.businesses),
                                    )),
                              );
                            },
                          )
                    : count == 0
                        ? Center(
                            child: Text(total == 0
                                ? 'No $noun registered in this territory yet.'
                                : 'No matching $noun.'))
                        : ListView.builder(
                            itemCount: count,
                            itemBuilder: (context, index) {
                              if (widget.businesses) {
                                final business = filteredBusinesses[index];
                                return ListTile(
                                  leading: Icon(business.isOrganisation
                                      ? Icons.apartment
                                      : Icons.storefront),
                                  title: Text(business.name),
                                  subtitle: Text([
                                    '${business.isOrganisation ? 'Organisation' : 'Shop'} • ${business.category}',
                                    'Branch: ${business.branch.territory}',
                                    if (business.address != null)
                                      business.address!,
                                    if (business.phone != null) business.phone!,
                                  ].join('\n')),
                                );
                              }
                              final user = filteredUsers[index];
                              return ListTile(
                                key: ValueKey('resident-${user.id}'),
                                leading: const Icon(Icons.person_outline),
                                title: Text(user.name),
                                subtitle: Text([
                                  'User type: ${user.userType.label}',
                                  if (user.phone != null) user.phone!,
                                  'Branch: ${user.branch.territory}',
                                ].join('\n')),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
