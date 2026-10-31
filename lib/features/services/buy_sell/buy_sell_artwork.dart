import 'package:flutter/material.dart';
import '../../../data/models/marketplace_listing.dart';

/// Local category illustration until seller photography is available.
class BuySellArtwork extends StatelessWidget {
  const BuySellArtwork(
      {super.key, required this.listing, required this.height});
  final MarketplaceListing listing;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '${listing.category} illustration',
        image: true,
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.surface
              ],
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.55),
                border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
              ),
              child: Icon(listing.icon,
                  size: height * 0.38,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      );
}
