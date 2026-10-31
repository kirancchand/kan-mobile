import 'map_location.dart';
import 'media_attachment.dart';

enum BookListingType { rent, buy, sell }

extension BookListingTypeLabel on BookListingType {
  String get label {
    switch (this) {
      case BookListingType.rent:
        return 'For Rent';
      case BookListingType.buy:
        return 'Wanted (Buy)';
      case BookListingType.sell:
        return 'For Sale';
    }
  }
}

class BookListing {
  final List<MediaAttachment> attachments;
  final String id;
  final String? locationId;
  final MapLocation? pickupPoint;
  final String? ownerId;
  final String title;
  final String author;
  final BookListingType listingType;
  final double price;
  final String? rentPerWeek;
  final String ownerName;
  final String ownerPhone;
  final String genre;
  final DateTime postedAt;

  const BookListing({
    required this.id,
    this.locationId,
    this.pickupPoint,
    this.ownerId,
    this.attachments = const [],
    required this.title,
    required this.author,
    required this.listingType,
    required this.price,
    this.rentPerWeek,
    required this.ownerName,
    required this.ownerPhone,
    required this.genre,
    required this.postedAt,
  });

  /// Only real media is shown; missing media uses a neutral placeholder.
  String get coverUrl => '';
}
