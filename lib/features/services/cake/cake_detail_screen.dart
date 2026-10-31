import '../../../core/widgets/purchase_actions.dart';
import '../../../data/models/cart_item.dart';
import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/contact_actions.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/marketplace_listing.dart';
import 'cake_artwork.dart';
import 'cake_theme.dart';

class CakeDetailScreen extends StatelessWidget {
  const CakeDetailScreen({super.key, required this.listing});
  final MarketplaceListing listing;

  @override
  Widget build(BuildContext context) => CakeTheme(
      child: Builder(
          builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Something sweet')),
                bottomNavigationBar: CakeActionBar(
                    child: PurchaseActions(
                        item: CartItem.marketplace(listing),
                        contact: TextButton.icon(
                          icon: const Icon(AppIcons.phoneCallBold),
                          label: const Text('Contact Baker'),
                          onPressed: () => showCallSheet(context,
                              name: listing.sellerName,
                              phone: listing.sellerPhone),
                        ))),
                body: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      MediaGallery(attachments: listing.attachments),
                      if (listing.attachments.isEmpty) ...[
                        CakeGlass(
                            borderRadius: 30,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Hero(
                                tag: 'cake-${listing.id}',
                                child: CakeArtwork(
                                    category: listing.category, height: 280))),
                        const SizedBox(height: 8),
                        Text('Cake illustration · ask the baker for photos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11, color: context.tokens.textMuted)),
                        const SizedBox(height: 20),
                      ],
                      CakeGlass(
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
                                Text('About this bake',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 8),
                                Text(listing.description,
                                    style: const TextStyle(height: 1.6)),
                              ])),
                      const SizedBox(height: 16),
                      CakeGlass(
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
                                    '${listing.location} · Posted ${Formatters.relative(listing.postedAt)}',
                                    style: TextStyle(
                                        color: context.tokens.textMuted)),
                                const SizedBox(height: 12),
                                const Text(
                                    'Ask your baker about sizes, custom messages and pickup.',
                                    style:
                                        TextStyle(fontSize: 12, height: 1.5)),
                              ])),
                    ]),
              )));
}
