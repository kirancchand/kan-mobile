import '../../../core/widgets/purchase_actions.dart';
import '../../../data/models/cart_item.dart';
import '../../../core/widgets/media_gallery.dart';
import '../buy_sell/buy_sell_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/semantic_tones.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/contact_actions.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/marketplace_listing.dart';
import '../../../data/models/service_type.dart';
import '../plants/plants_detail_screen.dart';
import '../cake/cake_detail_screen.dart';
import '../pharmacy/pharmacy_detail_screen.dart';
import '../../../core/theme/app_icons.dart';

class MarketplaceDetailScreen extends StatelessWidget {
  final MarketplaceListing listing;

  const MarketplaceDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    if (listing.serviceType == ServiceType.buySell) {
      return BuySellDetailScreen(listing: listing);
    }
    if (listing.serviceType == ServiceType.plants) {
      return PlantsDetailScreen(listing: listing);
    }
    if (listing.serviceType == ServiceType.cake) {
      return CakeDetailScreen(listing: listing);
    }
    if (listing.serviceType == ServiceType.pharmacy) {
      return PharmacyDetailScreen(listing: listing);
    }
    final tone = listing.serviceType.tone;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          MediaGallery(attachments: listing.attachments),
          Stack(
            children: [
              Hero(
                tag: 'listing-${listing.id}',
                child: AppNetworkImage(
                    url: listing.imageUrl, height: 280, width: double.infinity),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.midnight.withValues(alpha: 0.5),
                        AppColors.midnight.withValues(alpha: 0)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                          Text(listing.title, style: textTheme.headlineSmall),
                    ),
                    const SizedBox(width: AppSpacing.ms),
                    IconBadge(icon: listing.icon, tone: tone),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  Formatters.currency(listing.price),
                  style: textTheme.headlineMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: AppSpacing.ms),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StatusChip(label: listing.category, tone: tone),
                    StatusChip(label: listing.condition?.label ?? 'Not stated'),
                    StatusChip(
                      label: listing.isAvailable ? 'Available' : 'Sold Out',
                      tone: listing.isAvailable
                          ? AppTone.brand
                          : AppTone.attention,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Description', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(listing.description,
                    style: textTheme.bodyMedium?.copyWith(height: 1.55)),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: ListTile(
                    leading: const IconBadge(
                        icon: AppIcons.user, tone: AppTone.neutral),
                    title: Text(listing.sellerName),
                    subtitle: Text(
                        '${listing.location} • Posted ${Formatters.relative(listing.postedAt)}'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PurchaseActions(
                    item: CartItem.marketplace(listing),
                    contact: TextButton.icon(
                      icon: const Icon(AppIcons.phoneCallBold),
                      label: const Text('Contact Seller'),
                      onPressed: () => showCallSheet(context,
                          name: listing.sellerName, phone: listing.sellerPhone),
                    )),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 220.ms),
    );
  }
}
