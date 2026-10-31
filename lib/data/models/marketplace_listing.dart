import 'map_location.dart';
import 'media_attachment.dart';
import 'package:flutter/material.dart';
import 'service_type.dart';

enum ListingCondition { newItem, likeNew, good, fair }

/// The village market's `type` column: whether the poster is buying or selling.
enum MarketListingType {
  buy('Buy'),
  sell('Sell');

  const MarketListingType(this.label);
  final String label;

  static MarketListingType? parse(Object? value) =>
      switch ('${value ?? ''}'.trim().toLowerCase()) {
        'buy' => buy,
        'sell' => sell,
        _ => null,
      };
}

extension ListingConditionLabel on ListingCondition {
  String get label {
    switch (this) {
      case ListingCondition.newItem:
        return 'New';
      case ListingCondition.likeNew:
        return 'Like New';
      case ListingCondition.good:
        return 'Good';
      case ListingCondition.fair:
        return 'Fair';
    }
  }
}

/// Generic listing used by every marketplace-style service (Buy & Sell,
/// Plants, Cake, Pharmacy). Shared data supports generic and feature-specific
/// screens, with each listing associated with a [ServiceType].
class MarketplaceListing {
  final List<MediaAttachment> attachments;

  /// Seller photos hosted by the village API.
  final List<String> imageUrls;
  final String id;
  final String? locationId;
  final MapLocation? pickupPoint;
  final String? sellerId;
  final ServiceType serviceType;
  final String title;
  final String description;
  final double price;
  final String category;

  /// Null when the source (e.g. the village market API) does not record it.
  final ListingCondition? condition;

  /// Null for listings that do not come from the village market API.
  final MarketListingType? listingType;
  final String sellerName;
  final String sellerPhone;
  final String location;
  final DateTime postedAt;
  final IconData icon;
  final Color color;
  bool isAvailable;

  MarketplaceListing({
    required this.id,
    this.locationId,
    this.pickupPoint,
    this.sellerId,
    this.attachments = const [],
    this.imageUrls = const [],
    required this.serviceType,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.condition,
    this.listingType,
    required this.sellerName,
    required this.sellerPhone,
    required this.location,
    required this.postedAt,
    required this.icon,
    required this.color,
    this.isAvailable = true,
  });

  /// False for API rows that carry no creation time.
  bool get hasPostedDate => postedAt.millisecondsSinceEpoch > 0;

  /// Only real media is shown; missing media uses a neutral placeholder.
  String get imageUrl => imageUrls.isEmpty ? '' : imageUrls.first;
}
