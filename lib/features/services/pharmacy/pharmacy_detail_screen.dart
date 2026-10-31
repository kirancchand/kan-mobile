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
import 'pharmacy_artwork.dart';
import 'pharmacy_theme.dart';

class PharmacyDetailScreen extends StatelessWidget {
  const PharmacyDetailScreen({super.key, required this.listing});
  final MarketplaceListing listing;
  @override
  Widget build(BuildContext context) => PharmacyTheme(
      child: Builder(
          builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Product Details')),
                bottomNavigationBar: PharmacyActionBar(
                    child: PurchaseActions(
                        item: CartItem.marketplace(listing),
                        contact: TextButton.icon(
                            onPressed: () => showCallSheet(context,
                                name: listing.sellerName,
                                phone: listing.sellerPhone),
                            icon: const Icon(AppIcons.phoneCallBold),
                            label: const Text('Contact Pharmacy')))),
                body: ListView(padding: const EdgeInsets.all(20), children: [
                  MediaGallery(attachments: listing.attachments),
                  if (listing.attachments.isEmpty) ...[
                    PharmacyGlass(
                        borderRadius: 30,
                        child: Hero(
                            tag: 'pharmacy-${listing.id}',
                            child: PharmacyArtwork(
                                category: listing.category, height: 255))),
                    const SizedBox(height: 8),
                    Text('Product illustration',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: context.tokens.textMuted, fontSize: 11)),
                    const SizedBox(height: 20),
                  ],
                  PharmacyGlass(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            Text(Formatters.currency(listing.price),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                            const SizedBox(height: 16),
                            Wrap(spacing: 8, runSpacing: 8, children: [
                              StatusChip(label: listing.category),
                              StatusChip(
                                  label: listing.isAvailable
                                      ? 'Available'
                                      : 'Sold out',
                                  tone: listing.isAvailable
                                      ? AppTone.brand
                                      : AppTone.attention)
                            ]),
                            const SizedBox(height: 24),
                            Text('Product information',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(listing.description,
                                style: const TextStyle(height: 1.6)),
                          ])),
                  const SizedBox(height: 16),
                  PharmacyGlass(
                      child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(AppIcons.storefront),
                          title: Text(listing.sellerName),
                          subtitle: Text(
                              '${listing.location} · Posted ${Formatters.relative(listing.postedAt)}'))),
                ]),
              )));
}
