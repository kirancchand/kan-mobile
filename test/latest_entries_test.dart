import 'fixtures/mock_marketplace.dart';
import 'fixtures/mock_deliveries.dart';
import 'fixtures/mock_videos.dart';
import 'fixtures/mock_rides.dart';
import 'fixtures/mock_books.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/models/book_listing.dart';
import 'package:mv_app/data/models/delivery_order.dart';
import 'package:mv_app/data/models/marketplace_listing.dart';
import 'package:mv_app/data/models/ride_listing.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:mv_app/data/models/vehicle_type.dart';
import 'package:mv_app/data/models/video_submission.dart';
import 'package:mv_app/data/repositories/book_repository.dart';
import 'package:mv_app/data/repositories/delivery_repository.dart';
import 'package:mv_app/data/repositories/latest_entries_repository.dart';
import 'package:mv_app/data/repositories/marketplace_repository.dart';
import 'package:mv_app/data/repositories/ride_repository.dart';
import 'package:mv_app/data/repositories/video_repository.dart';
import 'package:mv_app/features/home/widgets/latest_entries_slider.dart';
import 'package:provider/provider.dart';

class _Fixture {
  _Fixture({MarketplaceRepository? marketplace, DeliveryRepository? deliveries})
      : marketplace = marketplace ??
            MarketplaceRepository(initialListings: mockMarketplaceListings),
        deliveries =
            deliveries ?? DeliveryRepository(initialItems: mockDeliveries) {
    latest = LatestEntriesRepository(
        marketplace: this.marketplace,
        books: books,
        rides: rides,
        videos: videos,
        deliveries: this.deliveries);
  }
  final MarketplaceRepository marketplace;
  final DeliveryRepository deliveries;
  final books = BookRepository(initialItems: mockBooks);
  final rides = RideRepository(initialItems: mockRides);
  final videos = VideoRepository(initialItems: mockVideos);
  late final LatestEntriesRepository latest;
  void dispose() {
    latest.dispose();
    marketplace.dispose();
    deliveries.dispose();
    books.dispose();
    rides.dispose();
    videos.dispose();
  }

  Widget app(
          {bool dark = false, double scale = 1, bool reducedMotion = false}) =>
      MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: latest),
            Provider.value(value: marketplace),
            Provider.value(value: books),
            Provider.value(value: rides),
            Provider.value(value: videos),
            Provider.value(value: deliveries),
          ],
          child: MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: reducedMotion),
                child: child!),
            home: const Scaffold(
                body: SingleChildScrollView(child: LatestEntriesSlider())),
          ));
}

class _PartialFailure extends MarketplaceRepository {
  _PartialFailure() : super(initialListings: mockMarketplaceListings);
  @override
  Future<List<MarketplaceListing>> getListings(ServiceType type) {
    if (type == ServiceType.plants) throw StateError('Unavailable');
    return super.getListings(type);
  }
}

class _EmptyDelivery extends DeliveryRepository {
  @override
  Future<List<DeliveryOrder>> getOrders() async => [];
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('One newest entry per module, rides selected by posting not departure',
      () async {
    final f = _Fixture();
    addTearDown(f.dispose);
    final entries = await f.latest.getLatestEntries();
    expect(entries.map((entry) => entry.service), ServiceType.values);
    for (final entry in entries) {
      expect(entry.failed, isFalse);
      expect(entry.item, isNotNull);
      final timestamp = switch (entry.item) {
        MarketplaceListing value => value.postedAt,
        BookListing value => value.postedAt,
        RideListing value => value.postedAt,
        VideoSubmission value => value.submittedAt,
        DeliveryOrder value => value.requestedAt,
        _ => null,
      };
      expect(entry.postedAt, timestamp);
      if (entry.item case MarketplaceListing value) {
        final all = await f.marketplace.getListings(entry.service);
        expect(all.every((other) => !other.postedAt.isAfter(value.postedAt)),
            isTrue);
      }
    }
    final ride = entries
        .singleWhere((entry) => entry.service == ServiceType.ridePool)
        .item as RideListing;
    expect(ride.id, 'ride_4');
    expect((await f.rides.getRides()).first.id, isNot(ride.id));
    final posted = await f.rides.postRide(
        vehicleType: VehicleType.bike,
        driverName: 'Tester',
        driverPhone: '123',
        from: 'New village',
        to: 'Town',
        departureTime: DateTime.now().add(const Duration(days: 10)),
        seatsAvailable: 1,
        pricePerSeat: 40,
        vehicleInfo: 'Blue bike');
    final updated = await f.latest.getLatestEntries();
    expect(
        updated
            .singleWhere((entry) => entry.service == ServiceType.ridePool)
            .item,
        same(posted));
  });

  test('An empty module or failed source does not hide other services',
      () async {
    final f =
        _Fixture(marketplace: _PartialFailure(), deliveries: _EmptyDelivery());
    addTearDown(f.dispose);
    final entries = await f.latest.getLatestEntries();
    expect(entries.length, 8);
    expect(entries.singleWhere((e) => e.service == ServiceType.plants).failed,
        isTrue);
    expect(entries.singleWhere((e) => e.service == ServiceType.delivery).item,
        isNull);
    expect(entries.singleWhere((e) => e.service == ServiceType.cake).item,
        isA<MarketplaceListing>());
  });

  testWidgets(
      'Slider navigates, opens details and automatically updates after posting',
      (tester) async {
    final f = _Fixture();
    addTearDown(f.dispose);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(f.app());
    await tester.pumpAndSettle();
    expect(find.text('1 / 8'), findsOneWidget);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Next latest entry'));
      await tester.pumpAndSettle();
    }
    expect(find.text('3 / 8'), findsOneWidget);
    final future = f.marketplace.createListing(
        type: ServiceType.plants,
        title: 'Newest fern',
        description: 'A local fern',
        price: 100,
        category: 'Indoor',
        condition: ListingCondition.newItem,
        sellerName: 'Tester',
        sellerPhone: '123',
        location: 'Village');
    await tester.pump(const Duration(milliseconds: 350));
    await future;
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Newest fern'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('latest-plants')));
    await tester.pumpAndSettle();
    expect(find.text('About this plant'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('3 / 8'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous latest entry'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Slider advances automatically and wraps to the first entry',
      (tester) async {
    final f = _Fixture();
    addTearDown(f.dispose);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(f.app());
    await tester.pumpAndSettle();
    for (var page = 1; page <= 8; page++) {
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('${page % 8 + 1} / 8'), findsOneWidget);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduced motion disables automatic rotation', (tester) async {
    final f = _Fixture();
    addTearDown(f.dispose);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(f.app(reducedMotion: true));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.text('1 / 8'), findsOneWidget);
    await tester.tap(find.byTooltip('Next latest entry'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 8'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final dark in [false, true]) {
    testWidgets(
        'All latest-entry pages fit narrow enlarged-text layout, dark=$dark',
        (tester) async {
      final f = _Fixture();
      addTearDown(f.dispose);
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(f.app(dark: dark, scale: 1.6));
      await tester.pumpAndSettle();
      for (var i = 0; i < 7; i++) {
        await tester.ensureVisible(find.byTooltip('Next latest entry'));
        await tester.tap(find.byTooltip('Next latest entry'));
        await tester.pumpAndSettle();
      }
      expect(find.text('8 / 8'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
