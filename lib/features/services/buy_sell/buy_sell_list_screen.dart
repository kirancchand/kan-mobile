import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer_list_placeholder.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/marketplace_listing.dart';
import '../../../data/models/service_type.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../marketplace/marketplace_post_screen.dart';
import 'buy_sell_artwork.dart';
import 'buy_sell_detail_screen.dart';
import 'buy_sell_theme.dart';

class BuySellListScreen extends StatefulWidget {
  const BuySellListScreen({super.key});

  @override
  State<BuySellListScreen> createState() => _BuySellListScreenState();
}

class _BuySellListScreenState extends State<BuySellListScreen> {
  late Future<List<MarketplaceListing>> _future;
  String _query = '';
  String? _category;
  MarketListingType? _type;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future =
        context.read<MarketplaceRepository>().getListings(ServiceType.buySell);
  }

  Future<void> _post() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => const BuySellTheme(
                child: MarketplacePostScreen(
                    serviceType: ServiceType.buySell,
                    formWrapper: BuySellGlass.form),
              )),
    );
    if (created == true && mounted) setState(_reload);
  }

  void _open(MarketplaceListing item) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => BuySellDetailScreen(listing: item)));
  }

  @override
  Widget build(BuildContext context) => BuySellTheme(
        child: Builder(
            builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Buy & Sell')),
                  bottomNavigationBar: BuySellActionBar(
                      child: FilledButton.icon(
                    onPressed: _post,
                    icon: const Icon(AppIcons.plusBold),
                    label: const Text('Sell an item'),
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
                          all.map((item) => item.category).toSet().toList();
                      final types = MarketListingType.values
                          .where((type) =>
                              all.any((item) => item.listingType == type))
                          .toList();
                      final items = all
                          .where((item) =>
                              (_category == null ||
                                  item.category == _category) &&
                              (_type == null || item.listingType == _type) &&
                              '${item.title} ${item.category} ${item.sellerName}'
                                  .toLowerCase()
                                  .contains(_query))
                          .toList();
                      return CustomScrollView(slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 22),
                                  BuySellGlass(
                                      borderRadius: 18,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Search items, categories or sellers',
                                          prefixIcon:
                                              Icon(AppIcons.magnifyingGlass),
                                        ),
                                        onChanged: (value) => setState(() =>
                                            _query =
                                                value.trim().toLowerCase()),
                                      )),
                                  if (types.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    Wrap(spacing: 8, runSpacing: 8, children: [
                                      _typeChip('Buy & Sell', null),
                                      ...types.map((type) =>
                                          _typeChip(type.label, type)),
                                    ]),
                                  ],
                                  const SizedBox(height: 14),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(children: [
                                      _categoryChip('All products', null),
                                      ...categories.map((category) =>
                                          _categoryChip(category, category)),
                                    ]),
                                  ),
                                  const SizedBox(height: 22),
                                  _MarketHero(onPost: _post),
                                  const SizedBox(height: 22),
                                  Text('Discover local finds',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 5),
                                  Text(
                                      '${items.length} ${items.length == 1 ? 'item' : 'items'} to discover',
                                      style: TextStyle(
                                          color: context.tokens.textMuted)),
                                  const SizedBox(height: 16),
                                ]),
                          ),
                        ),
                        if (items.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyState(
                              icon: AppIcons.storefront,
                              title: all.isEmpty
                                  ? 'Give something a new home'
                                  : 'No matches found',
                              message: all.isEmpty
                                  ? 'Be the first to sell an item in your village.'
                                  : 'Try another item, seller or category.',
                              actionLabel: all.isEmpty ? 'Sell an item' : null,
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
                                itemCount: items.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 14,
                                  mainAxisExtent: 326 +
                                      (MediaQuery.textScalerOf(context)
                                                      .scale(14) -
                                                  14)
                                              .clamp(0, 56) *
                                          12,
                                ),
                                itemBuilder: (context, index) => _BuySellCard(
                                  item: items[index],
                                  onTap: () => _open(items[index]),
                                ),
                              );
                            }),
                          ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: BuySellGlass(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: 22,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                leading: const Icon(AppIcons.storefront),
                                title: const Text('Ready for a new home?'),
                                subtitle:
                                    const Text('Sell what you no longer need.'),
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

  Widget _typeChip(String label, MarketListingType? value) => ChoiceChip(
        label: Text(label),
        selected: _type == value,
        onSelected: (_) => setState(() => _type = value),
      );

  Widget _categoryChip(String label, String? value) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          avatar: const Icon(AppIcons.storefront, size: 18),
          label: Text(label),
          selected: _category == value,
          onSelected: (_) => setState(() => _category = value),
        ),
      );
}

class _MarketHero extends StatelessWidget {
  const _MarketHero({required this.onPost});
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF527EFF), Color(0xFF153CB4)],
          ),
          boxShadow: [
            BoxShadow(
                color: BuySellTheme.cobalt.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('YOUR VILLAGE MARKETPLACE',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          const Text('Great finds.\nCloser to home.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const Text('Buy, sell and give everyday things a new story.',
              style: TextStyle(color: Colors.white, height: 1.5)),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFE780),
                foregroundColor: const Color(0xFF172642)),
            onPressed: onPost,
            icon: const Icon(AppIcons.plusBold, size: 18),
            label: const Text('Start selling'),
          ),
        ]),
      );
}

class _BuySellCard extends StatelessWidget {
  const _BuySellCard({required this.item, required this.onTap});
  final MarketplaceListing item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BuySellGlass(
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
              child: Stack(children: [
                Hero(
                    tag: 'item-${item.id}',
                    child: MediaCover(
                        attachments: item.attachments,
                        height: 150,
                        child: item.imageUrls.isEmpty
                            ? BuySellArtwork(listing: item, height: 150)
                            : AppNetworkImage(
                                url: item.imageUrls.first,
                                height: 150,
                                width: double.infinity))),
                if (item.listingType case final type?)
                  Positioned(
                      top: 8,
                      left: 8,
                      child: StatusChip(
                          label: type.label,
                          tone: type == MarketListingType.sell
                              ? AppTone.brand
                              : AppTone.attention)),
              ]),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        [item.category, item.condition?.label]
                            .nonNulls
                            .join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: context.tokens.textMuted)),
                    const SizedBox(height: 5),
                    Text(item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(item.sellerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: context.tokens.textMuted)),
                    const Spacer(),
                    Row(children: [
                      Expanded(
                          child: Text(Formatters.currency(item.price),
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w800))),
                      const Icon(AppIcons.caretRight, size: 18),
                    ]),
                    if (!item.isAvailable)
                      const Text('Sold out', style: TextStyle(fontSize: 11)),
                  ]),
            )),
          ]),
        ),
      );
}
