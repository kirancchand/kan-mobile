import '../../../core/widgets/purchase_actions.dart';
import '../../../data/models/cart_item.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/contact_actions.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/marketplace_listing.dart';
import 'buy_sell_artwork.dart';
import 'buy_sell_theme.dart';

class BuySellDetailScreen extends StatelessWidget {
  const BuySellDetailScreen({super.key, required this.listing});
  final MarketplaceListing listing;

  @override
  Widget build(BuildContext context) => BuySellTheme(
      child: Builder(
          builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Item details')),
                bottomNavigationBar: BuySellActionBar(
                    child: PurchaseActions(
                        item: CartItem.marketplace(listing),
                        contact: TextButton.icon(
                          icon: const Icon(AppIcons.phoneCallBold),
                          label: const Text('Contact Seller'),
                          onPressed: listing.sellerPhone.isEmpty
                              ? null
                              : () => showCallSheet(context,
                                  name: listing.sellerName,
                                  phone: listing.sellerPhone),
                        ))),
                body: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      MediaGallery(attachments: listing.attachments),
                      if (listing.attachments.isEmpty &&
                          listing.imageUrls.isNotEmpty) ...[
                        BuySellGlass(
                            borderRadius: 30,
                            child: SizedBox(
                                height: 280,
                                child: PageView(children: [
                                  for (final url in listing.imageUrls)
                                    AppNetworkImage(url: url, height: 280),
                                ]))),
                        if (listing.imageUrls.length > 1) ...[
                          const SizedBox(height: 8),
                          Text(
                              '${listing.imageUrls.length} photos · swipe to see more',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: context.tokens.textMuted)),
                        ],
                        const SizedBox(height: 20),
                      ],
                      if (listing.attachments.isEmpty &&
                          listing.imageUrls.isEmpty) ...[
                        BuySellGlass(
                            borderRadius: 30,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Hero(
                                tag: 'item-${listing.id}',
                                child: BuySellArtwork(
                                    listing: listing, height: 280))),
                        const SizedBox(height: 8),
                        Text('Item illustration · ask the seller for photos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11, color: context.tokens.textMuted)),
                        const SizedBox(height: 20),
                      ],
                      BuySellGlass(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listing.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w800)),
                                const SizedBox(height: 8),
                                Text(Formatters.currency(listing.price),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                const SizedBox(height: 16),
                                Wrap(spacing: 8, runSpacing: 8, children: [
                                  if (listing.listingType case final type?)
                                    StatusChip(
                                        label: type.label,
                                        tone: type == MarketListingType.sell
                                            ? AppTone.brand
                                            : AppTone.attention),
                                  if (listing.condition != null)
                                    StatusChip(label: listing.condition!.label),
                                  StatusChip(
                                      label: listing.category,
                                      tone: AppTone.accent),
                                  StatusChip(
                                      label: listing.isAvailable
                                          ? 'Available'
                                          : 'Sold out',
                                      tone: listing.isAvailable
                                          ? AppTone.brand
                                          : AppTone.attention),
                                ]),
                                const SizedBox(height: 24),
                                Text('About this item',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 8),
                                Text(listing.description,
                                    style: const TextStyle(height: 1.6)),
                              ])),
                      const SizedBox(height: 16),
                      BuySellGlass(
                          borderRadius: 22,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(AppIcons.storefront),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(listing.sellerName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700)))
                                ]),
                                const SizedBox(height: 10),
                                Text(
                                    [
                                      if (listing.location.isNotEmpty)
                                        listing.location,
                                      if (listing.hasPostedDate)
                                        'Posted ${Formatters.relative(listing.postedAt)}',
                                    ].join(' · '),
                                    style: TextStyle(
                                        color: context.tokens.textMuted)),
                                const SizedBox(height: 12),
                                const Text(
                                    'Contact the seller to confirm condition and arrange pickup.',
                                    style:
                                        TextStyle(fontSize: 12, height: 1.5)),
                              ])),
                    ]),
              )));
}
