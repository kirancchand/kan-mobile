import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer_list_placeholder.dart';
import '../../../data/models/marketplace_listing.dart';
import '../../../data/models/service_type.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../marketplace/marketplace_post_screen.dart';
import 'plants_detail_screen.dart';
import 'plants_theme.dart';

class PlantsListScreen extends StatefulWidget {
  const PlantsListScreen({super.key});
  @override
  State<PlantsListScreen> createState() => _PlantsListScreenState();
}

class _PlantsListScreenState extends State<PlantsListScreen> {
  late Future<List<MarketplaceListing>> _future;
  String _query = '';
  String? _category;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future =
        context.read<MarketplaceRepository>().getListings(ServiceType.plants);
  }

  Future<void> _post() async {
    final created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => const PlantsTheme(
                child: MarketplacePostScreen(
                    serviceType: ServiceType.plants,
                    formWrapper: PlantsGlass.form))));
    if (created == true && mounted) setState(_reload);
  }

  void _open(MarketplaceListing listing) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => PlantsDetailScreen(listing: listing)));

  @override
  Widget build(BuildContext context) => PlantsTheme(
      child: Builder(
          builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Plants')),
                bottomNavigationBar: PlantsActionBar(
                    child: FilledButton.icon(
                        onPressed: _post,
                        icon: const Icon(AppIcons.plusBold),
                        label: const Text('List a plant'))),
                body: FutureBuilder<List<MarketplaceListing>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorState(onRetry: () => setState(_reload));
                      }
                      if (!snapshot.hasData) {
                        return const ShimmerListPlaceholder();
                      }
                      final all = snapshot.data!;
                      final categories =
                          all.map((p) => p.category).toSet().toList();
                      final plants = all
                          .where((p) =>
                              (_category == null || p.category == _category) &&
                              '${p.title} ${p.category}'
                                  .toLowerCase()
                                  .contains(_query))
                          .toList();
                      final largeText =
                          MediaQuery.textScalerOf(context).scale(14) > 19;
                      return CustomScrollView(slivers: [
                        SliverToBoxAdapter(
                            child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 4, 20, 16),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PlantsGlass(
                                          borderRadius: 28,
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 14, 12, 14),
                                          child: Row(children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text('GROW SOMETHING GOOD',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          letterSpacing: 1,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                      'A little green.\nA little joy.',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800)),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                      'Find your next plant\nfrom a neighbour.',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: context.tokens
                                                              .textMuted)),
                                                ])),
                                            if (!largeText)
                                              const SizedBox(
                                                  width: 100,
                                                  child: PlantArtwork(
                                                      height: 190)),
                                          ])),
                                      const SizedBox(height: 22),
                                      Text('What are we growing today?',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                      const SizedBox(height: 14),
                                      PlantsGlass(
                                          borderRadius: 18,
                                          child: TextField(
                                              decoration: const InputDecoration(
                                                  hintText: 'Search plants',
                                                  prefixIcon: Icon(AppIcons
                                                      .magnifyingGlass)),
                                              onChanged: (value) => setState(
                                                  () => _query = value
                                                      .trim()
                                                      .toLowerCase()))),
                                      const SizedBox(height: 12),
                                      SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(children: [
                                            _chip('All', null),
                                            ...categories.map((category) =>
                                                _chip(category, category)),
                                          ])),
                                      const SizedBox(height: 20),
                                      Text('Plants from your community',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ]))),
                        if (plants.isEmpty)
                          SliverFillRemaining(
                              hasScrollBody: false,
                              child: EmptyState(
                                  icon: AppIcons.leaf,
                                  title: all.isEmpty
                                      ? 'Start a greener village'
                                      : 'No matching plants',
                                  message: all.isEmpty
                                      ? 'Share your first plant with a neighbour.'
                                      : 'Try another search or category.',
                                  actionLabel: 'List a plant',
                                  onAction: _post))
                        else
                          SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverLayoutBuilder(
                                  builder: (context, constraints) {
                                final columns = largeText ||
                                        constraints.crossAxisExtent < 300
                                    ? 1
                                    : constraints.crossAxisExtent >= 650
                                        ? 3
                                        : 2;
                                return SliverGrid.builder(
                                    itemCount: plants.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: columns,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 14,
                                            mainAxisExtent:
                                                largeText ? 385 : 310),
                                    itemBuilder: (context, index) {
                                      final plant = plants[index];
                                      return PlantsGlass(
                                          child: InkWell(
                                              onTap: () => _open(plant),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Hero(
                                                            tag:
                                                                'plant-${plant.id}',
                                                            child: MediaCover(
                                                                attachments: plant
                                                                    .attachments,
                                                                height: 145,
                                                                child: PlantArtwork(
                                                                    height: 145,
                                                                    variant: plant
                                                                            .id
                                                                            .hashCode %
                                                                        3))),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(plant.title,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 13)),
                                                        const SizedBox(
                                                            height: 6),
                                                        Text(plant.category,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: context
                                                                    .tokens
                                                                    .textMuted)),
                                                        const Spacer(),
                                                        Row(children: [
                                                          Expanded(
                                                              child: Text(
                                                                  Formatters
                                                                      .currency(
                                                                          plant
                                                                              .price),
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700))),
                                                          const Icon(
                                                              AppIcons
                                                                  .caretRight,
                                                              size: 18)
                                                        ]),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                            plant.isAvailable
                                                                ? plant.location
                                                                : 'Sold out',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: context
                                                                    .tokens
                                                                    .textMuted)),
                                                      ]))));
                                    });
                              })),
                        if (plants.isNotEmpty)
                          SliverToBoxAdapter(
                              child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: PlantsGlass(
                                      child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                          leading: const Icon(AppIcons.leaf,
                                              size: 32),
                                          title:
                                              const Text('Room for one more?'),
                                          subtitle: const Text(
                                              'Share a sapling or a plant you have grown.'),
                                          trailing:
                                              const Icon(AppIcons.caretRight),
                                          onTap: _post)))),
                      ]);
                    }),
              )));

  Widget _chip(String label, String? category) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
          label: Text(label),
          selected: _category == category,
          onSelected: (_) => setState(() => _category = category)));
}
