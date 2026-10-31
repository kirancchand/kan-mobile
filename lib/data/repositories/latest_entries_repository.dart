import 'package:flutter/foundation.dart';
import '../models/latest_module_entry.dart';
import '../models/service_type.dart';
import 'book_repository.dart';
import 'delivery_repository.dart';
import 'marketplace_repository.dart';
import 'ride_repository.dart';
import 'video_repository.dart';

/// Combines the newest creation from each service, independent of list sort order.
class LatestEntriesRepository extends ChangeNotifier {
  LatestEntriesRepository(
      {required this.marketplace,
      required this.books,
      required this.rides,
      required this.videos,
      required this.deliveries}) {
    for (final source in _sources) {
      source.addListener(refresh);
    }
  }
  final MarketplaceRepository marketplace;
  final BookRepository books;
  final RideRepository rides;
  final VideoRepository videos;
  final DeliveryRepository deliveries;
  List<Listenable> get _sources => [
        marketplace.changes,
        books.changes,
        rides.changes,
        videos.changes,
        deliveries.changes
      ];

  void refresh() => notifyListeners();

  Future<List<LatestModuleEntry>> getLatestEntries() =>
      Future.wait(ServiceType.values.map((service) => switch (service) {
            ServiceType.buySell ||
            ServiceType.plants ||
            ServiceType.pharmacy ||
            ServiceType.cake =>
              _latest(service, () => marketplace.getListings(service),
                  (entry) => entry.postedAt),
            ServiceType.library =>
              _latest(service, books.getBooks, (entry) => entry.postedAt),
            ServiceType.ridePool =>
              _latest(service, rides.getRides, (entry) => entry.postedAt),
            ServiceType.youtube =>
              _latest(service, videos.getVideos, (entry) => entry.submittedAt),
            ServiceType.delivery => _latest(
                service, deliveries.getOrders, (entry) => entry.requestedAt),
          }));

  Future<LatestModuleEntry> _latest<T extends Object>(ServiceType service,
      Future<List<T>> Function() fetch, DateTime Function(T) timestamp) async {
    try {
      final entries = await fetch();
      if (entries.isEmpty) return LatestModuleEntry(service: service);
      final newest =
          entries.reduce((a, b) => timestamp(b).isAfter(timestamp(a)) ? b : a);
      return LatestModuleEntry(
          service: service, item: newest, postedAt: timestamp(newest));
    } catch (_) {
      return LatestModuleEntry(service: service, failed: true);
    }
  }

  @override
  void dispose() {
    for (final source in _sources) {
      source.removeListener(refresh);
    }
    super.dispose();
  }
}
