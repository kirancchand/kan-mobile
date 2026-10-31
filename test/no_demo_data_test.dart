import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/core/theme/app_tokens.dart';
import 'package:mv_app/data/models/advertisement.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:mv_app/data/repositories/admin_repository.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/book_repository.dart';
import 'package:mv_app/data/repositories/delivery_repository.dart';
import 'package:mv_app/data/repositories/location_repository.dart';
import 'package:mv_app/data/repositories/marketplace_repository.dart';
import 'package:mv_app/data/repositories/ride_repository.dart';
import 'package:mv_app/data/repositories/video_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/features/profile/location_group_screen.dart';
import 'package:mv_app/state/app_state.dart';

void main() {
  test(
      'Production source cannot import bundled fixtures or random stock photos',
      () {
    for (final file
        in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      expect(source, isNot(contains('/mock/')), reason: file.path);
      expect(source, isNot(contains('picsum.photos')), reason: file.path);
      expect(source, isNot(contains('test/fixtures')), reason: file.path);
    }
  });

  test('Every local catalog starts empty and keeps user-created records',
      () async {
    final market = MarketplaceRepository();
    final books = BookRepository();
    final rides = RideRepository();
    final videos = VideoRepository();
    final deliveries = DeliveryRepository();
    addTearDown(market.dispose);
    addTearDown(books.dispose);
    addTearDown(rides.dispose);
    addTearDown(videos.dispose);
    addTearDown(deliveries.dispose);
    for (final service
        in ServiceType.values.where((s) => s.isGenericMarketplace)) {
      expect(await market.getListings(service), isEmpty);
    }
    expect(await books.getBooks(), isEmpty);
    expect(await rides.getRides(), isEmpty);
    expect(await videos.getVideos(), isEmpty);
    expect(await deliveries.getOrders(), isEmpty);
    expect(await LocationRepository().getLocations(), isEmpty);
    expect(AdminRepository().accounts, isEmpty);
    final created = await market.createListing(
        type: ServiceType.plants,
        title: 'My plant',
        description: 'User supplied',
        price: 10,
        category: 'Other',
        sellerName: 'Owner',
        sellerPhone: '123',
        location: 'My ward');
    expect(await market.getListings(ServiceType.plants), [created]);
    expect(created.imageUrl, isEmpty);
  });

  test('Missing banner media and WhatsApp assignments are never manufactured',
      () async {
    const ad = Advertisement(
        id: 'ad',
        title: 'Title',
        subtitle: '',
        sponsor: '',
        color: Colors.teal,
        icon: Icons.image);
    expect(ad.bannerImageUrl, isEmpty);
    final groups = WhatsAppGroupRepository();
    await expectLater(groups.assignUserToGroup('branch'), throwsStateError);
    expect(groups.groupsFor('branch'), isEmpty);
  });

  testWidgets(
      'Missing location resolves to an empty state, not endless loading',
      (tester) async {
    final groups = WhatsAppGroupRepository();
    final auth = AuthRepository(groups);
    final app = AppState(whatsAppGroupRepository: groups, authRepository: auth);
    addTearDown(app.dispose);
    addTearDown(auth.dispose);
    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: app),
          Provider(create: (_) => LocationRepository()),
        ],
        child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.light]),
            home: const LocationGroupScreen())));
    await tester.pumpAndSettle();
    expect(
        find.text('No village or WhatsApp group is assigned to this account.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
