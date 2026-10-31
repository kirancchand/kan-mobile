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
import 'cake_artwork.dart';
import 'cake_detail_screen.dart';
import 'cake_theme.dart';

class CakeListScreen extends StatefulWidget {
  const CakeListScreen({super.key});

  @override
  State<CakeListScreen> createState() => _CakeListScreenState();
}

class _CakeListScreenState extends State<CakeListScreen> {
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
        context.read<MarketplaceRepository>().getListings(ServiceType.cake);
  }

  Future<void> _post() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => const CakeTheme(
                child: MarketplacePostScreen(
                    serviceType: ServiceType.cake, formWrapper: CakeGlass.form),
              )),
    );
    if (created == true && mounted) setState(_reload);
  }

  void _open(MarketplaceListing cake) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => CakeDetailScreen(listing: cake)));
  }

  @override
  Widget build(BuildContext context) => CakeTheme(
        child: Builder(
            builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Cake Marketplace')),
                  bottomNavigationBar: CakeActionBar(
                      child: FilledButton.icon(
                    onPressed: _post,
                    icon: const Icon(AppIcons.plusBold),
                    label: const Text('List a cake'),
                  )),
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
                          all.map((cake) => cake.category).toSet().toList();
                      final cakes = all
                          .where((cake) =>
                              (_category == null ||
                                  cake.category == _category) &&
                              '${cake.title} ${cake.category} ${cake.sellerName}'
                                  .toLowerCase()
                                  .contains(_query))
                          .toList();
                      final available = all.where((cake) => cake.isAvailable);
                      final featured =
                          available.isEmpty ? null : available.first;
                      return CustomScrollView(slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SweetHero(
                                      featured: featured,
                                      onOpen: featured == null
                                          ? null
                                          : () => _open(featured)),
                                  const SizedBox(height: 22),
                                  CakeGlass(
                                      borderRadius: 18,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Search cakes, flavours or bakers',
                                          prefixIcon:
                                              Icon(AppIcons.magnifyingGlass),
                                        ),
                                        onChanged: (value) => setState(() =>
                                            _query =
                                                value.trim().toLowerCase()),
                                      )),
                                  const SizedBox(height: 14),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(children: [
                                      _categoryChip('All cakes', null),
                                      ...categories.map((category) =>
                                          _categoryChip(category, category)),
                                    ]),
                                  ),
                                  const SizedBox(height: 22),
                                  Text('From local bakers',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 5),
                                  Text(
                                      '${cakes.length} ${cakes.length == 1 ? 'cake' : 'cakes'} to discover',
                                      style: TextStyle(
                                          color: context.tokens.textMuted)),
                                  const SizedBox(height: 16),
                                ]),
                          ),
                        ),
                        if (cakes.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyState(
                              icon: AppIcons.cake,
                              title: all.isEmpty
                                  ? 'Share something sweet'
                                  : 'No matching cakes',
                              message: all.isEmpty
                                  ? 'Be the first baker to list a cake.'
                                  : 'Try another flavour, baker or category.',
                              actionLabel: all.isEmpty ? 'List a cake' : null,
                              onAction: all.isEmpty ? _post : null,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverLayoutBuilder(
                                builder: (context, constraints) {
                              final largeText =
                                  MediaQuery.textScalerOf(context).scale(14) >
                                      19;
                              final columns =
                                  largeText || constraints.crossAxisExtent < 300
                                      ? 1
                                      : constraints.crossAxisExtent >= 680
                                          ? 3
                                          : 2;
                              return SliverGrid.builder(
                                itemCount: cakes.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 14,
                                  mainAxisExtent: largeText ? 430 : 326,
                                ),
                                itemBuilder: (context, index) => _CakeCard(
                                  cake: cakes[index],
                                  onTap: () => _open(cakes[index]),
                                ),
                              );
                            }),
                          ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: CakeGlass(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: 22,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                leading: const Icon(AppIcons.cake),
                                title: const Text('Baked with love?'),
                                subtitle: const Text(
                                    'Share your bakes with the village.'),
                                trailing: const Icon(AppIcons.caretRight),
                                onTap: _post,
                              ),
                            ),
                          ),
                        ),
                      ]);
                    },
                  ),
                )),
      );

  Widget _categoryChip(String label, String? value) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          avatar: const Icon(AppIcons.cake, size: 18),
          label: Text(label),
          selected: _category == value,
          onSelected: (_) => setState(() => _category = value),
        ),
      );
}

class _SweetHero extends StatelessWidget {
  const _SweetHero({required this.featured, required this.onOpen});
  final MarketplaceListing? featured;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return CakeGlass(
      borderRadius: 28,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 8, 18),
        child: LayoutBuilder(builder: (context, constraints) {
          final copy =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('A SLICE OF JOY',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                    color: dark ? CakeTheme.blush : const Color(0xFF783047))),
            const SizedBox(height: 8),
            const Text('Little cakes.\nBig smiles.',
                style: TextStyle(
                    fontSize: 27, fontWeight: FontWeight.w800, height: 1.1)),
            const SizedBox(height: 10),
            const Text('Sweet moments,\nmade close to home.',
                style: TextStyle(fontSize: 12, height: 1.5)),
            if (onOpen != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: onOpen, child: const Text('Explore cake')),
            ],
          ]);
          final art =
              CakeArtwork(category: featured?.category ?? '', height: 180);
          if (MediaQuery.textScalerOf(context).scale(14) > 19) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [copy, art]);
          }
          return Row(children: [
            Expanded(flex: 6, child: copy),
            Expanded(flex: 5, child: art)
          ]);
        }),
      ),
    );
  }
}

class _CakeCard extends StatelessWidget {
  const _CakeCard({required this.cake, required this.onTap});
  final MarketplaceListing cake;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CakeGlass(
        borderRadius: 22,
        child: InkWell(
          onTap: onTap,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.55),
              child: Hero(
                  tag: 'cake-${cake.id}',
                  child: MediaCover(
                      attachments: cake.attachments,
                      height: 150,
                      child:
                          CakeArtwork(category: cake.category, height: 150))),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cake.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: context.tokens.textMuted)),
                    const SizedBox(height: 5),
                    Text(cake.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(cake.sellerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: context.tokens.textMuted)),
                    const Spacer(),
                    Row(children: [
                      Expanded(
                          child: Text(Formatters.currency(cake.price),
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w800))),
                      const Icon(AppIcons.caretRight, size: 18),
                    ]),
                    if (!cake.isAvailable)
                      const Text('Sold out', style: TextStyle(fontSize: 11)),
                  ]),
            )),
          ]),
        ),
      );
}
