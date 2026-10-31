import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/contact_actions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer_list_placeholder.dart';
import '../../../data/models/marketplace_listing.dart';
import '../../../data/models/service_type.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../marketplace/marketplace_post_screen.dart';
import 'pharmacy_artwork.dart';
import 'pharmacy_detail_screen.dart';
import 'pharmacy_theme.dart';

class PharmacyListScreen extends StatefulWidget {
  const PharmacyListScreen({super.key});
  @override
  State<PharmacyListScreen> createState() => _PharmacyListScreenState();
}

class _PharmacyListScreenState extends State<PharmacyListScreen> {
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
        context.read<MarketplaceRepository>().getListings(ServiceType.pharmacy);
  }

  Future<void> _post() async {
    final created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => const PharmacyTheme(
                child: MarketplacePostScreen(
                    serviceType: ServiceType.pharmacy,
                    formWrapper: PharmacyGlass.form))));
    if (created == true && mounted) setState(_reload);
  }

  void _open(MarketplaceListing listing) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PharmacyDetailScreen(listing: listing)));

  @override
  Widget build(BuildContext context) => PharmacyTheme(
      child: Builder(
          builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Pharmacy')),
                bottomNavigationBar: PharmacyActionBar(
                    child: FilledButton.icon(
                        onPressed: _post,
                        icon: const Icon(AppIcons.plusBold),
                        label: const Text('List a product'))),
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
                      final products = all
                          .where((item) =>
                              (_category == null ||
                                  item.category == _category) &&
                              '${item.title} ${item.category} ${item.sellerName}'
                                  .toLowerCase()
                                  .contains(_query))
                          .toList();
                      final sellers = <String, MarketplaceListing>{};
                      for (final item in all) {
                        sellers.putIfAbsent(
                            '${item.sellerName}|${item.sellerPhone}',
                            () => item);
                      }
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
                                      PharmacyGlass(
                                          borderRadius: 28,
                                          padding: const EdgeInsets.all(20),
                                          child: Row(children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text('YOUR LOCAL PHARMACY',
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          letterSpacing: 1)),
                                                  const SizedBox(height: 10),
                                                  Text('Care, closer\nto home.',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800)),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                      'Medicines & health essentials from local sellers.',
                                                      style: TextStyle(
                                                          color: context
                                                              .tokens.textMuted,
                                                          fontSize: 12,
                                                          height: 1.5)),
                                                ])),
                                            if (!largeText)
                                              const SizedBox(
                                                  width: 105,
                                                  child: PharmacyArtwork(
                                                      height: 160)),
                                          ])),
                                      const SizedBox(height: 20),
                                      PharmacyGlass(
                                          borderRadius: 18,
                                          child: TextField(
                                              decoration: const InputDecoration(
                                                  hintText:
                                                      'Search products or pharmacies',
                                                  prefixIcon: Icon(AppIcons
                                                      .magnifyingGlass)),
                                              onChanged: (value) => setState(
                                                  () => _query = value
                                                      .trim()
                                                      .toLowerCase()))),
                                      const SizedBox(height: 20),
                                      Text('Shop by category',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      const SizedBox(height: 10),
                                      SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(children: [
                                            _chip('All', null),
                                            ...categories.map((category) =>
                                                _chip(category, category))
                                          ])),
                                      const SizedBox(height: 22),
                                      Text('Health essentials',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 5),
                                      Text(
                                          '${products.length} ${products.length == 1 ? 'product' : 'products'} in the catalog',
                                          style: TextStyle(
                                              color: context.tokens.textMuted,
                                              fontSize: 12)),
                                    ]))),
                        if (products.isEmpty)
                          SliverToBoxAdapter(
                              child: EmptyState(
                                  icon: AppIcons.pill,
                                  title: all.isEmpty
                                      ? 'No products listed yet'
                                      : 'No matching products',
                                  message: all.isEmpty
                                      ? 'List a pharmacy product to get started.'
                                      : 'Try another product, pharmacy or category.'))
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
                                    itemCount: products.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: columns,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 14,
                                            mainAxisExtent:
                                                largeText ? 390 : 325),
                                    itemBuilder: (context, index) {
                                      final product = products[index];
                                      return PharmacyGlass(
                                          child: InkWell(
                                              onTap: () => _open(product),
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
                                                                'pharmacy-${product.id}',
                                                            child: MediaCover(
                                                                attachments: product
                                                                    .attachments,
                                                                height: 135,
                                                                child: PharmacyArtwork(
                                                                    category:
                                                                        product
                                                                            .category,
                                                                    height:
                                                                        135))),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(product.category,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: context
                                                                    .tokens
                                                                    .textMuted,
                                                                fontSize: 11)),
                                                        const SizedBox(
                                                            height: 6),
                                                        Text(product.title,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                        const SizedBox(
                                                            height: 6),
                                                        Text(product.sellerName,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: context
                                                                    .tokens
                                                                    .textMuted,
                                                                fontSize: 11)),
                                                        const Spacer(),
                                                        Row(children: [
                                                          Expanded(
                                                              child: Text(
                                                                  Formatters
                                                                      .currency(
                                                                          product
                                                                              .price),
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800))),
                                                          const Icon(
                                                              AppIcons
                                                                  .caretRight,
                                                              size: 18)
                                                        ]),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                            product.isAvailable
                                                                ? 'Available'
                                                                : 'Sold out',
                                                            style: TextStyle(
                                                                color: context
                                                                    .tokens
                                                                    .textMuted,
                                                                fontSize: 10)),
                                                      ]))));
                                    });
                              })),
                        if (sellers.isNotEmpty) ...[
                          SliverToBoxAdapter(
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 24, 20, 12),
                                  child: Text('Local pharmacies',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge))),
                          SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              sliver: SliverList.separated(
                                  itemCount: sellers.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final seller =
                                        sellers.values.elementAt(index);
                                    return PharmacyGlass(
                                        child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(16),
                                            leading:
                                                const Icon(AppIcons.storefront),
                                            title: Text(seller.sellerName),
                                            subtitle: Text(seller.location),
                                            trailing:
                                                const Icon(AppIcons.phoneCall),
                                            onTap: () => showCallSheet(context,
                                                name: seller.sellerName,
                                                phone: seller.sellerPhone)));
                                  })),
                        ],
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
