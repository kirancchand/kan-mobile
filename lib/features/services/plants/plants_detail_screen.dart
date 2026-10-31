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
import 'plants_theme.dart';

class PlantsDetailScreen extends StatelessWidget {
  const PlantsDetailScreen({super.key, required this.listing});
  final MarketplaceListing listing;
  @override
  Widget build(BuildContext context) => PlantsTheme(
      child: Builder(
          builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Your next green companion')),
                bottomNavigationBar: PlantsActionBar(
                    child: PurchaseActions(
                        item: CartItem.marketplace(listing),
                        contact: TextButton.icon(
                            onPressed: () => showCallSheet(context,
                                name: listing.sellerName,
                                phone: listing.sellerPhone),
                            icon: const Icon(AppIcons.phoneCallBold),
                            label: const Text('Contact Seller')))),
                body: ListView(padding: const EdgeInsets.all(20), children: [
                  MediaGallery(attachments: listing.attachments),
                  if (listing.attachments.isEmpty) ...[
                    PlantsGlass(
                        borderRadius: 32,
                        child: Hero(
                            tag: 'plant-${listing.id}',
                            child: PlantArtwork(
                                height: 280,
                                variant: listing.id.hashCode % 3))),
                    const SizedBox(height: 8),
                    Text('Illustration · ask the seller for current photos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11, color: context.tokens.textMuted)),
                    const SizedBox(height: 20),
                  ],
                  PlantsGlass(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing.title,
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
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
                                  label:
                                      listing.condition?.label ?? 'Not stated'),
                              StatusChip(
                                  label: listing.isAvailable
                                      ? 'Available'
                                      : 'Sold out',
                                  tone: listing.isAvailable
                                      ? AppTone.brand
                                      : AppTone.attention)
                            ]),
                            const SizedBox(height: 24),
                            Text('About this plant',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(listing.description,
                                style: const TextStyle(height: 1.6)),
                          ])),
                  const SizedBox(height: 16),
                  PlantsGlass(
                      child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(AppIcons.user),
                          title: Text(listing.sellerName),
                          subtitle: Text(
                              '${listing.location} · ${Formatters.relative(listing.postedAt)}'))),
                ]),
              )));
}
