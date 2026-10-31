import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:mv_app/core/widgets/media_gallery.dart';
import 'package:mv_app/core/services/video/local_video_source.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/models/media_attachment.dart';
import 'package:mv_app/data/models/marketplace_listing.dart';
import 'package:mv_app/data/models/book_listing.dart';
import 'package:mv_app/data/models/ride_listing.dart';
import 'package:mv_app/data/models/vehicle_type.dart';
import 'package:mv_app/data/models/video_submission.dart';
import 'package:mv_app/data/models/delivery_order.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:mv_app/data/repositories/video_repository.dart';
import 'package:mv_app/data/repositories/delivery_repository.dart';
import 'package:mv_app/features/services/marketplace/marketplace_detail_screen.dart';
import 'package:mv_app/features/services/library/book_detail_screen.dart';
import 'package:mv_app/features/services/ride_pool/ride_detail_screen.dart';
import 'package:mv_app/features/services/youtube/youtube_screen.dart';
import 'package:mv_app/features/services/delivery/delivery_screen.dart';

final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=');
List<MediaAttachment> get _items => [
      MediaAttachment(name: 'front.png', kind: MediaKind.image, bytes: _png),
      MediaAttachment(name: 'back.png', kind: MediaKind.image, bytes: _png),
      MediaAttachment(
          name: 'tour.mp4',
          kind: MediaKind.video,
          bytes: Uint8List.fromList([1, 2, 3])),
    ];

class _VideoPlatform extends VideoPlayerPlatform {
  bool playing = false;
  bool disposed = false;
  Duration position = Duration.zero;
  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async => 1;
  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    final events = StreamController<VideoEvent>(onCancel: () async {});
    events.add(VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 30),
        size: const Size(640, 360)));
    return events.stream;
  }

  @override
  Future<void> dispose(int playerId) async {
    disposed = true;
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> play(int playerId) async {
    playing = true;
  }

  @override
  Future<void> pause(int playerId) async {
    playing = false;
  }

  @override
  Future<void> setVolume(int playerId, double volume) async {}
  @override
  Future<void> seekTo(int playerId, Duration value) async {
    position = value;
  }

  @override
  Future<Duration> getPosition(int playerId) async => position;
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(color: Colors.black);
}

class _Videos extends VideoRepository {
  @override
  Future<List<VideoSubmission>> getVideos() async => [
        VideoSubmission(
            id: 'media',
            title: 'Village',
            submittedBy: 'Neighbour',
            description: 'A tour',
            status: VideoStatus.pending,
            submittedAt: DateTime.now(),
            attachments: _items)
      ];
}

class _Deliveries extends DeliveryRepository {
  @override
  Future<List<DeliveryOrder>> getOrders() async => [
        DeliveryOrder(
            id: 'media',
            itemDescription: 'Parcel',
            pickupAddress: 'A',
            dropAddress: 'B',
            requestedBy: 'Neighbour',
            fee: 25,
            status: DeliveryStatus.requested,
            requestedAt: DateTime.now(),
            attachments: _items)
      ];
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
      'Gallery swipes, selects thumbnails, expands and handles a shrinking list',
      (tester) async {
    var items = _items;
    late StateSetter update;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatefulBuilder(builder: (context, setState) {
      update = setState;
      return MediaGallery(attachments: items);
    }))));
    expect(find.text('1 / 3 · 2 images · 1 video'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3 · 2 images · 1 video'), findsOneWidget);
    await tester.tap(find.byTooltip('Open full screen'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Show media 3: tour.mp4'));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3 · 2 images · 1 video'), findsOneWidget);
    update(() => items = [items.first]);
    await tester.pumpAndSettle();
    expect(find.text('1 / 1 · 1 image'), findsOneWidget);
    update(() => items = []);
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Video plays, seeks, pauses in background and releases on gallery navigation',
      (tester) async {
    final original = VideoPlayerPlatform.instance;
    final platform = _VideoPlatform();
    VideoPlayerPlatform.instance = platform;
    addTearDown(() => VideoPlayerPlatform.instance = original);
    var released = false;
    late VideoPlayerController controller;
    Future<LocalVideoSource> load(MediaAttachment _) async {
      controller = VideoPlayerController.networkUrl(
          Uri.parse('https://example.test/video.mp4'));
      return LocalVideoSource(controller, () async {
        released = true;
      });
    }

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: MediaGallery(
                attachments: _items,
                initialIndex: 2,
                expanded: true,
                videoLoader: load))));
    await tester.pumpAndSettle();
    expect(platform.playing, isFalse);
    await tester.tap(find.byTooltip('Play video'));
    await tester.pump();
    expect(platform.playing, isTrue);
    await tester.tapAt(tester.getCenter(find.byType(VideoProgressIndicator)));
    await tester.pump();
    expect(platform.position.inSeconds, greaterThan(0));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(platform.playing, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.tap(find.byTooltip('Previous media'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3 · 2 images · 1 video'), findsOneWidget);
    expect(
        find.byType(AttachmentVideoPlayer, skipOffstage: false), findsNothing);
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(platform.disposed, isTrue);
    expect(released, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Video errors offer retry and a late source is released after leaving',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AttachmentVideoPlayer(
                attachment: _items.last,
                loader: (_) async => throw StateError('unsupported')))));
    await tester.pumpAndSettle();
    expect(find.text('Retry video'), findsOneWidget);
    final pending = Completer<LocalVideoSource>();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AttachmentVideoPlayer(
                key: const ValueKey('pending'),
                attachment: _items.last,
                loader: (_) => pending.future))));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    var released = false;
    pending.complete(LocalVideoSource(
        VideoPlayerController.networkUrl(
            Uri.parse('https://example.test/video.mp4')), () async {
      released = true;
    }));
    await tester.pumpAndSettle();
    expect(released, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    for (final type in ServiceType.values) {
      testWidgets(
          '${type.label} displays mixed media at narrow width, dark=$dark',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 740));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final videos = _Videos();
        final deliveries = _Deliveries();
        addTearDown(videos.dispose);
        addTearDown(deliveries.dispose);
        final screen = switch (type) {
          ServiceType.library => BookDetailScreen(
              book: BookListing(
                  id: 'media',
                  title: 'Book',
                  author: 'Author',
                  listingType: BookListingType.sell,
                  price: 50,
                  ownerName: 'Owner',
                  ownerPhone: '123',
                  genre: 'Fiction',
                  postedAt: DateTime.now(),
                  attachments: _items)),
          ServiceType.ridePool => RideDetailScreen(
              ride: RideListing(
                  id: 'media',
                  vehicleType: VehicleType.car,
                  driverName: 'Driver',
                  driverPhone: '123',
                  from: 'Village',
                  to: 'Town',
                  departureTime: DateTime.now(),
                  postedAt: DateTime.now(),
                  seatsAvailable: 2,
                  pricePerSeat: 30,
                  vehicleInfo: 'Car',
                  attachments: _items)),
          ServiceType.youtube => const YoutubeScreen(),
          ServiceType.delivery => const DeliveryScreen(),
          _ => MarketplaceDetailScreen(
              listing: MarketplaceListing(
                  id: 'media',
                  serviceType: type,
                  title: 'Item',
                  description: 'Description',
                  price: 50,
                  category: 'General',
                  condition: ListingCondition.good,
                  sellerName: 'Seller',
                  sellerPhone: '123',
                  location: 'Village',
                  postedAt: DateTime.now(),
                  icon: Icons.store,
                  color: Colors.blue,
                  attachments: _items)),
        };
        await tester.pumpWidget(MultiProvider(
            providers: [
              Provider<VideoRepository>.value(value: videos),
              Provider<DeliveryRepository>.value(value: deliveries),
            ],
            child: MaterialApp(
                theme: dark ? AppTheme.dark : AppTheme.light,
                builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(1.6)),
                    child: child!),
                home: screen)));
        await tester.pumpAndSettle();
        expect(find.text('1 / 3 · 2 images · 1 video'), findsOneWidget);
        await tester.tap(find.byTooltip('Next media'));
        await tester.pumpAndSettle();
        expect(find.text('2 / 3 · 2 images · 1 video'), findsOneWidget);
        await tester.tap(find.byTooltip('Next media'));
        await tester.pumpAndSettle();
        expect(find.text('3 / 3 · 2 images · 1 video'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
