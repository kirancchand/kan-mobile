import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/location.dart';
import '../../data/repositories/location_repository.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/shimmer_list_placeholder.dart';
import '../../core/theme/app_icons.dart';

/// Full-screen searchable picker over the location database (Section 4).
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late Future<List<VillageLocation>> _future;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<LocationRepository>().getLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Village')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(AppIcons.magnifyingGlass),
                hintText: 'Search village or district',
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<VillageLocation>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorState(onRetry: () => setState(_load));
                }
                if (!snapshot.hasData) {
                  return const ShimmerListPlaceholder();
                }
                final locations = snapshot.data!.where((l) {
                  if (_query.isEmpty) return true;
                  return l.name.toLowerCase().contains(_query) ||
                      l.district.toLowerCase().contains(_query) ||
                      l.state.toLowerCase().contains(_query);
                }).toList();

                if (locations.isEmpty) {
                  return EmptyState(
                    icon: AppIcons.mapPin,
                    title: 'No matching villages found',
                    message: 'Check the spelling, or search by district or state instead.',
                    actionLabel: 'Clear search',
                    onAction: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
                  itemCount: locations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final loc = locations[index];
                    return AppCard(
                      child: ListTile(
                        leading: const IconBadge(icon: AppIcons.mapPin),
                        title: Text(loc.name),
                        subtitle: Text('${loc.district}, ${loc.state}'),
                        trailing: Text('${loc.registeredUsers} members'),
                        onTap: () => Navigator.pop(context, loc),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
