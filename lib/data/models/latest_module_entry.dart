import 'book_listing.dart';
import 'delivery_order.dart';
import 'marketplace_listing.dart';
import 'ride_listing.dart';
import 'service_type.dart';
import 'video_submission.dart';

/// One repository-backed home highlight. Empty and failed modules remain visible.
class LatestModuleEntry {
  const LatestModuleEntry(
      {required this.service, this.item, this.postedAt, this.failed = false});
  final ServiceType service;
  final Object? item;
  final DateTime? postedAt;
  final bool failed;

  String get title => switch (item) {
        MarketplaceListing listing => listing.title,
        BookListing book => book.title,
        RideListing ride => '${ride.from} → ${ride.to}',
        VideoSubmission video => video.title,
        DeliveryOrder order => order.itemDescription,
        _ => failed ? 'Latest entry unavailable' : 'No entries yet',
      };
}
