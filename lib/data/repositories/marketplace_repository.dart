import '../models/map_location.dart';
import '../models/media_attachment.dart';
import 'package:flutter/foundation.dart';
import '../models/marketplace_listing.dart';
import '../models/service_type.dart';
import '../services/market_api.dart';

/// Serves the generic marketplace services: Buy & Sell, Plants, Cake,
/// Pharmacy. Shared data is filtered by [ServiceType]; Plants, Cake and Pharmacy use their own
/// presentation while retaining the same repository and posting flow.
class MarketplaceRepository {
  MarketplaceRepository(
      {MarketApi? marketApi,
      Iterable<MarketplaceListing> initialListings = const []})
      : _marketApi = marketApi,
        _listings = List.of(initialListings);

  /// When set, Buy & Sell is read from `listProduct` and posted through
  /// `addProduct` instead of session-only listings.
  final MarketApi? _marketApi;
  final _changes = ValueNotifier<int>(0);
  Listenable get changes => _changes;
  void dispose() {
    _changes.dispose();
    _marketApi?.dispose();
  }

  final List<MarketplaceListing> _listings;

  Future<List<MarketplaceListing>> getListings(ServiceType type) async {
    final api = _marketApi;
    // Server order (newest market_id first) is kept: rows carry no date.
    if (api != null && type == ServiceType.buySell) return api.listProducts();
    await Future.delayed(const Duration(milliseconds: 250));
    return _listings.where((l) => l.serviceType == type).toList()
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  Future<MarketplaceListing> createListing({
    required ServiceType type,
    required String title,
    String? locationId,
    MapLocation? pickupPoint,
    String? sellerId,
    required String description,
    required double price,
    required String category,
    ListingCondition? condition,
    MarketListingType? listingType,
    required String sellerName,
    required String sellerPhone,
    required String location,
    List<MediaAttachment> attachments = const [],
  }) async {
    final api = _marketApi;
    if (api != null && type == ServiceType.buySell) {
      await api.addProduct(
        productName: title,
        productDesc: description,
        price: price,
        categoryName: category,
        location: pickupPoint?.label ?? location,
        registeredUserId:
            sellerId != null && RegExp(r'^\d+$').hasMatch(sellerId)
                ? sellerId
                : null,
        type: listingType ?? MarketListingType.sell,
        images: attachments,
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    final listing = MarketplaceListing(
      attachments: List.unmodifiable(attachments),
      id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      serviceType: type,
      title: title,
      locationId: locationId,
      pickupPoint: pickupPoint,
      sellerId: sellerId,
      description: description,
      price: price,
      category: category,
      condition: condition,
      listingType: listingType,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
      location: location,
      postedAt: DateTime.now(),
      icon: type.icon,
      color: type.color,
    );
    _listings.insert(0, listing);
    _changes.value++;
    return listing;
  }
}
