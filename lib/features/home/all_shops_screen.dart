import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/home_repository.dart';
import 'add_organisation_screen.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../data/models/shop_org.dart';
import '../../data/models/organisation_category.dart';
import 'widgets/shops_directory_section.dart';
import '../../core/theme/app_icons.dart';

class AllShopsScreen extends StatefulWidget {
  const AllShopsScreen({super.key});

  @override
  State<AllShopsScreen> createState() => _AllShopsScreenState();
}

class _AllShopsScreenState extends State<AllShopsScreen> {
  final _searchController = TextEditingController();
  String? _filter;
  String _query = '';
  late Future<_DirectoryData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DirectoryData> _load() async {
    final repository = context.read<HomeRepository>();
    final results = await Future.wait<Object>([
      repository.getOrganisationDirectory(),
      repository.getOrganisationCategories(),
    ]);
    final categories = results[1] as List<OrganisationCategory>;
    if (mounted && !categories.any((category) => category.name == _filter)) {
      _filter = null;
    }
    return _DirectoryData(results[0] as List<ShopOrg>, categories);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    try {
      await _future;
    } catch (_) {
      // FutureBuilder displays the error and retry action.
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DirectoryData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shops & Organizations')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shops & Organizations')),
            body: ErrorState(onRetry: _refresh),
          );
        }
        return _buildDirectory(snapshot.data!.shops, snapshot.data!.categories);
      },
    );
  }

  Widget _buildDirectory(
      List<ShopOrg> shops, List<OrganisationCategory> categories) {
    final filtered = shops.where((s) {
      if (_filter != null &&
          (s.organisationType?.isNotEmpty == true
                  ? s.organisationType
                  : s.category.label) !=
              _filter) {
        return false;
      }
      if (_query.isNotEmpty &&
          !s.name.toLowerCase().contains(_query.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Shops & Organizations'), actions: [
        IconButton(
            onPressed: _refresh,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh)),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(context,
              MaterialPageRoute(builder: (_) => const AddOrganisationScreen()));
          if (added == true && mounted) {
            _searchController.clear();
            setState(() {
              _query = '';
              _filter = null;
            });
            await _refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Organisation'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.ms),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(AppIcons.magnifyingGlass),
                  hintText: 'Search shops & organizations'),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                ...categories.map((c) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: _filter == c.name,
                        onSelected: (_) => setState(() => _filter = c.name),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: AppIcons.storefront,
                    title: shops.isEmpty
                        ? 'No organisations yet'
                        : 'No matches found',
                    message:
                        'Try a different name or category to find local shops and organizations.',
                    actionLabel: 'Clear search & filters',
                    onAction: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                        _filter = null;
                      });
                    },
                  )
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 96),
                        children: [ShopsDirectorySection(shops: filtered)]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DirectoryData {
  const _DirectoryData(this.shops, this.categories);
  final List<ShopOrg> shops;
  final List<OrganisationCategory> categories;
}
