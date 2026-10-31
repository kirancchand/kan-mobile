import '../buy_sell/buy_sell_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/shimmer_list_placeholder.dart';
import '../../../data/models/marketplace_listing.dart';
import '../../../data/models/service_type.dart';
import '../../../data/repositories/marketplace_repository.dart';
import 'marketplace_detail_screen.dart';
import '../plants/plants_list_screen.dart';
import '../cake/cake_list_screen.dart';
import '../pharmacy/pharmacy_list_screen.dart';
import 'marketplace_post_screen.dart';
import '../../../core/theme/app_icons.dart';

/// Marketplace entry point: Plants, Cake and Pharmacy have dedicated presentation;
/// all services share [MarketplaceListing], filtered by [serviceType].
class MarketplaceListScreen extends StatefulWidget {
  final ServiceType serviceType;

  const MarketplaceListScreen({super.key, required this.serviceType});

  @override
  State<MarketplaceListScreen> createState() => _MarketplaceListScreenState();
}

class _MarketplaceListScreenState extends State<MarketplaceListScreen> {
  late Future<List<MarketplaceListing>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future =
        context.read<MarketplaceRepository>().getListings(widget.serviceType);
  }

  Future<void> _openPostScreen() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) =>
              MarketplacePostScreen(serviceType: widget.serviceType)),
    );
    if (created == true) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serviceType == ServiceType.buySell) {
      return const BuySellListScreen();
    }
    if (widget.serviceType == ServiceType.plants) {
      return const PlantsListScreen();
    }
    if (widget.serviceType == ServiceType.cake) {
      return const CakeListScreen();
    }
    if (widget.serviceType == ServiceType.pharmacy) {
      return const PharmacyListScreen();
    }
    final type = widget.serviceType;
    return Scaffold(
      appBar: AppBar(title: Text(type.label)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPostScreen,
        icon: const Icon(AppIcons.plusBold),
        label: const Text('Post'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(AppIcons.magnifyingGlass),
                hintText: 'Search ${type.label.toLowerCase()}',
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MarketplaceListing>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorState(onRetry: () => setState(_reload));
                }
                if (!snapshot.hasData) {
                  return const ShimmerListPlaceholder();
                }
                final listings = snapshot.data!.where((l) {
                  if (_query.isEmpty) return true;
                  return l.title.toLowerCase().contains(_query) ||
                      l.category.toLowerCase().contains(_query);
                }).toList();

                if (listings.isEmpty) {
                  if (_query.isNotEmpty) {
                    return EmptyState(
                      icon: AppIcons.magnifyingGlass,
                      title: 'No matches found',
                      message:
                          'Nothing in ${type.label} matches "$_query". Try another word.',
                    );
                  }
                  return EmptyState(
                    icon: type.icon,
                    title: 'Nothing listed yet',
                    message:
                        'Neighbours find what they need here. Be the first to post in ${type.label}.',
                    actionLabel: 'Post a listing',
                    onAction: _openPostScreen,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.fabClearance),
                  itemCount: listings.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.ms),
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return AppCard(
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  MarketplaceDetailScreen(listing: listing)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.ms),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: 'listing-${listing.id}',
                                child: AppNetworkImage(
                                    url: listing.imageUrl,
                                    width: 84,
                                    height: 84,
                                    borderRadius: AppRadius.md),
                              ),
                              const SizedBox(width: AppSpacing.ms),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      listing.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppSpacing.xs + 2),
                                    Wrap(
                                      spacing: AppSpacing.xs + 2,
                                      runSpacing: AppSpacing.xs,
                                      children: [
                                        StatusChip(label: listing.category),
                                        StatusChip(
                                            label: listing.condition?.label ??
                                                'Not stated'),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            Formatters.currency(listing.price),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                        ),
                                        Text(
                                          Formatters.relative(listing.postedAt),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate(delay: (index * 35).ms)
                        .fadeIn(duration: 240.ms)
                        .slideY(begin: 0.06, end: 0, curve: Curves.easeOut);
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
