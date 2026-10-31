import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/village_top_bar.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/village_carousel.dart';
import '../../core/widgets/shimmer_list_placeholder.dart';
import '../../data/services/advertisements_api.dart';
import '../../data/models/emergency_contact.dart';
import '../../data/models/location.dart';
import '../services/service_catalog_builder.dart';
import '../../data/models/shop_org.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/repositories/latest_entries_repository.dart';
import 'widgets/latest_entries_slider.dart';
import '../../data/repositories/location_repository.dart';
import '../../state/app_state.dart';
import 'all_events_screen.dart';
import 'all_shops_screen.dart';
import 'widgets/ad_carousel.dart';
import 'widgets/emergency_contacts_section.dart';
import 'widgets/events_feed.dart';
import 'widgets/services_grid.dart';
import 'widgets/shops_directory_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _serviceRevision = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchType = 'product';
  Timer? _searchDebounce;
  Future<HomeSearchResults>? _searchFuture;
  late Future<_HomeData> _future;
  late Future<AdvertisementFeed> _advertisementFuture;

  @override
  void initState() {
    super.initState();
    _advertisementFuture = _loadAdvertisements();
    _future = _load();
  }

  Future<AdvertisementFeed> _loadAdvertisements() {
    final future = context.read<HomeRepository>().getAdvertisementFeed();
    // The Home body may still be loading when this independent request fails.
    // Keep the original future for the section's error state.
    future.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return future;
  }

  Future<_HomeData> _load() async {
    final homeRepo = context.read<HomeRepository>();
    final locationRepo = context.read<LocationRepository>();
    final user = context.read<AppState>().currentUser;

    final results = await Future.wait([
      homeRepo.getEmergencyContacts(),
      homeRepo.getShops(),
      if (user != null)
        locationRepo.getById(user.locationId)
      else
        Future.value(null),
    ]);

    return _HomeData(
      contacts: results[0] as List<EmergencyContact>,
      shops: results[1] as List<ShopOrg>,
      location: results[2] as VillageLocation?,
    );
  }

  Future<void> _refresh() async {
    context.read<LatestEntriesRepository>().refresh();
    setState(() {
      _serviceRevision++;
      _future = _load();
      _advertisementFuture = _loadAdvertisements();
    });
    try {
      await Future.wait<Object?>([_future, _advertisementFuture]);
    } catch (_) {
      // Each section displays its own error and retry action.
    }
  }

  void _queueSearch(String value) {
    _searchDebounce?.cancel();
    setState(() {
      _searchQuery = value;
      _searchFuture = null;
    });
    if (value.trim().isEmpty) return;
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted || _searchController.text.trim() != value.trim()) return;
      final repository = context.read<HomeRepository>();
      final search = repository.searchHome(value, _searchType);
      setState(() {
        _searchFuture = search;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        context.watch<AppState>().currentUser?.name.split(' ').first;

    return Scaffold(
      appBar: VillageTopBar(
        subtitle: FutureBuilder<_HomeData>(
          future: _future,
          builder: (context, snapshot) {
            final location = snapshot.data?.location?.name;
            return Text([
              userName == null ? _greeting() : '${_greeting()}, $userName',
              if (location != null) location,
            ].join(' • '));
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_HomeData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListView(
                children: [ErrorState(onRetry: _refresh)],
              );
            }
            if (!snapshot.hasData) {
              return ListView(
                children: const [
                  SizedBox(height: AppSpacing.md),
                  ShimmerBanner(),
                  SizedBox(height: AppSpacing.lg),
                  ShimmerListPlaceholder(itemCount: 3),
                ],
              );
            }
            final data = snapshot.data!;
            final query = _searchQuery.trim().toLowerCase();
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(AppIcons.magnifyingGlass),
                      hintText:
                          'Search ${_searchType == 'organisationType' ? 'organisation types' : '${_searchType}s'}',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                _searchDebounce?.cancel();
                                setState(() {
                                  _searchQuery = '';
                                  _searchFuture = null;
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                          SizedBox(
                            height: 24,
                            child: VerticalDivider(
                              width: 1,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Filter search',
                            icon: const Icon(Icons.tune),
                            initialValue: _searchType,
                            onSelected: (value) {
                              setState(() => _searchType = value);
                              if (_searchController.text.trim().isNotEmpty) {
                                _queueSearch(_searchController.text);
                              }
                            },
                            itemBuilder: (context) => [
                              CheckedPopupMenuItem(
                                value: 'product',
                                checked: _searchType == 'product',
                                child: const Text('Product'),
                              ),
                              CheckedPopupMenuItem(
                                value: 'organisation',
                                checked: _searchType == 'organisation',
                                child: const Text('Organisation'),
                              ),
                              CheckedPopupMenuItem(
                                value: 'organisationType',
                                checked: _searchType == 'organisationType',
                                child: const Text('Organisation type'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onChanged: _queueSearch,
                  ),
                ),
                if (query.isNotEmpty) ...[
                  FutureBuilder<HomeSearchResults>(
                    future: _searchFuture,
                    builder: (context, result) {
                      if (result.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child:
                              Text('Search is unavailable. Please try again.'),
                        );
                      }
                      if (_searchFuture == null || !result.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: ShimmerListPlaceholder(itemCount: 2),
                        );
                      }
                      final matches = result.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (matches.items.isNotEmpty) ...[
                            const SectionHeader(title: 'Search results'),
                            ...matches.items.map((item) => ListTile(
                                  leading: Icon(item.product.isNotEmpty
                                      ? AppIcons.tag
                                      : item.organisation.isNotEmpty
                                          ? AppIcons.storefront
                                          : AppIcons.gridFour),
                                  title: Text(item.title),
                                  subtitle: item.subtitle.isEmpty
                                      ? null
                                      : Text(item.subtitle),
                                )),
                          ],
                          if (matches.items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Text('No matching results found.'),
                            ),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: VillageCarousel(homeBannerStyle: true),
                ),
                const SectionHeader(title: 'Explore services'),
                ServiceCatalogBuilder(
                    key: ValueKey(_serviceRevision),
                    builder: (context, services, refresh) => services.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Text('No services available'))
                        : ServicesGrid(services: services)),
                const LatestEntriesSlider(),
                FutureBuilder<AdvertisementFeed>(
                  future: _advertisementFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Column(children: [
                        const SectionHeader(title: 'Village Events & Updates'),
                        ErrorState(
                            onRetry: () => setState(() {
                                  _advertisementFuture = _loadAdvertisements();
                                })),
                      ]);
                    }
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: ShimmerListPlaceholder(itemCount: 2),
                      );
                    }
                    final feed = snapshot.data!;
                    return Column(children: [
                      SectionHeader(
                        title: 'Village Events & Updates',
                        actionLabel: 'View All',
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllEventsScreen(
                                events: feed.events, types: feed.types),
                          ),
                        ),
                      ),
                      EventsFeed(
                          events: feed.events, types: feed.types, maxItems: 3),
                      const SizedBox(height: AppSpacing.lg),
                      AdCarousel(ads: feed.ads),
                    ]);
                  },
                ),
                const SectionHeader(title: 'Emergency Contacts'),
                EmergencyContactsSection(contacts: data.contacts),
                if (query.isEmpty) ...[
                  SectionHeader(
                    title: 'Shops & Organizations',
                    actionLabel: 'View All',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllShopsScreen()),
                    ),
                  ),
                  ListenableBuilder(
                    listenable: context.read<HomeRepository>().changes,
                    builder: (context, _) => ShopsDirectorySection(
                      shops:
                          context.read<HomeRepository>().shops.take(4).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
              ],
            ).animate().fadeIn(duration: 220.ms);
          },
        ),
      ),
    );
  }
}

class _HomeData {
  final List<EmergencyContact> contacts;
  final List<ShopOrg> shops;
  final VillageLocation? location;

  _HomeData({
    required this.contacts,
    required this.shops,
    required this.location,
  });
}
