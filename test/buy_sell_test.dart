import 'fixtures/mock_marketplace.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/core/widgets/status_chip.dart';
import 'package:mv_app/data/models/marketplace_listing.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/marketplace_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/market_api.dart';
import 'package:mv_app/features/services/buy_sell/buy_sell_list_screen.dart';
import 'package:mv_app/features/services/buy_sell/buy_sell_theme.dart';
import 'package:mv_app/features/services/service_router.dart';
import 'package:mv_app/state/app_state.dart';
import 'package:provider/provider.dart';

Widget buySellApp(
    {bool dark = false,
    double textScale = 1,
    bool route = false,
    MarketApi? marketApi}) {
  final groups = WhatsAppGroupRepository();
  return MultiProvider(
    providers: [
      Provider(
          create: (_) => MarketplaceRepository(
              marketApi: marketApi, initialListings: mockMarketplaceListings)),
      ChangeNotifierProvider(
          create: (_) => AppState(
                whatsAppGroupRepository: groups,
                authRepository: AuthRepository(groups),
              )),
    ],
    child: MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: route
          ? Builder(
              builder: (context) => Scaffold(
                    body: TextButton(
                        onPressed: () =>
                            openService(context, ServiceType.buySell),
                        child: const Text('Open marketplace')),
                  ))
          : const BuySellListScreen(),
    ),
  );
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final dark in [false, true]) {
    testWidgets(
        'Buy & Sell routing, category search and seller contact, dark=$dark',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(buySellApp(dark: dark, route: true));
      await tester.tap(find.text('Open marketplace'));
      await tester.pumpAndSettle();
      expect(find.byType(BuySellListScreen), findsOneWidget);
      expect(find.byType(BackdropFilter), findsWidgets);
      await tester
          .ensureVisible(find.widgetWithText(ChoiceChip, 'Electronics'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Electronics'));
      await tester.pumpAndSettle();
      expect(find.text('Ceiling Fan (2 units)'), findsOneWidget);
      expect(find.text('Study Table with Chair'), findsNothing);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ceiling Fan (2 units)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ceiling Fan (2 units)'));
      await tester.pumpAndSettle();
      expect(find.text('About this item'), findsOneWidget);
      await tester.tap(find.text('Contact Seller'));
      await tester.pumpAndSettle();
      expect(find.text('9876543211'), findsOneWidget);
      await tester.tap(find.text('Call'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Call 9876543211'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 1000));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('All products'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All products'));
      await tester.enterText(find.byType(TextField), 'study');
      await tester.pumpAndSettle();
      expect(find.text('Study Table with Chair'), findsOneWidget);
      expect(find.text('Ceiling Fan (2 units)'), findsNothing);
      await tester.enterText(find.byType(TextField), 'no such item');
      await tester.pumpAndSettle();
      expect(find.text('No matches found'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'Posting an item uses the blue glass theme and refreshes its catalog',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buySellApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sell an item'));
    await tester.pumpAndSettle();
    expect(find.text('Post in Buy & Sell'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(Theme.of(tester.element(find.byType(Form))).colorScheme.primary,
        BuySellTheme.cobalt);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Garden tool set');
    await tester.enterText(
        fields.at(1), 'A set of garden tools in good condition.');
    await tester.enterText(fields.at(2), 'Tools');
    await tester.enterText(fields.at(3), '450');
    await tester.ensureVisible(find.text('Post Listing'));
    await tester.tap(find.text('Post Listing'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Garden tool set'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Tools'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Buy & Sell API listings are tagged and filter by buy/sell',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Map<String, Object?> row(int id, String name, String type) => {
          'market_id': '$id',
          'category_name': 'Vehicles',
          'product_name': name,
          'product_desc': '',
          'images': '{}',
          'price': 100,
          'location': 'tvm',
          'type': type,
        };
    final rows = [
      row(2, 'Scooter for sale', 'Sell'),
      row(1, 'Want a bike', 'buy')
    ];
    await tester.pumpWidget(buySellApp(
        marketApi: MarketApi(
            baseUrl: 'http://village.test',
            client: MockClient((_) async => http.Response(
                jsonEncode({'totalCount': rows.length, 'result': rows}),
                200)))));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, 'Buy & Sell'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Scooter for sale'), findsOneWidget);
    expect(find.text('Want a bike'), findsOneWidget);
    expect(find.widgetWithText(StatusChip, 'Sell'), findsOneWidget);
    expect(find.widgetWithText(StatusChip, 'Buy'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 1000));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sell'));
    await tester.pumpAndSettle();
    expect(find.text('1 item to discover'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Scooter for sale'), findsOneWidget);
    expect(find.text('Want a bike'), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 1000));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Buy'));
    await tester.pumpAndSettle();
    expect(find.text('1 item to discover'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Buy & Sell'));
    await tester.pumpAndSettle();
    expect(find.text('2 items to discover'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Post form sends the chosen buy/sell type to addProduct',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final sentTypes = <String>[];
    await tester.pumpWidget(buySellApp(
        marketApi: MarketApi(
            baseUrl: 'http://village.test',
            client: MockClient((request) async {
              if (request.url.path == '/api/market/add') {
                sentTypes.add(RegExp(r'name="type"\r\n\r\n(\w+)\r\n')
                    .firstMatch(latin1.decode(request.bodyBytes))![1]!);
                return http.Response(jsonEncode('Inserted Successfully'), 200);
              }
              return http.Response(
                  jsonEncode({'totalCount': 0, 'result': []}), 200);
            }))));
    await tester.pumpAndSettle();

    Future<void> post(String? choice) async {
      await tester.tap(find.text('Sell an item').last);
      await tester.pumpAndSettle();
      final toggle = find.byType(SegmentedButton<MarketListingType>);
      expect(toggle, findsOneWidget);
      if (choice != null) {
        await tester
            .tap(find.descendant(of: toggle, matching: find.text(choice)));
        await tester.pumpAndSettle();
      }
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Bicycle');
      await tester.enterText(fields.at(1), 'Kids bicycle');
      await tester.enterText(fields.at(2), 'Vehicles');
      await tester.enterText(fields.at(3), '1500');
      await tester.ensureVisible(find.text('Post Listing'));
      await tester.tap(find.text('Post Listing'));
      await tester.pumpAndSettle();
      expect(find.byType(SegmentedButton<MarketListingType>), findsNothing);
    }

    await post(null);
    await post('Buy');
    expect(sentTypes, ['sell', 'buy']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mock listings without a type hide the buy/sell filter',
      (tester) async {
    await tester.pumpWidget(buySellApp());
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ChoiceChip, 'Buy & Sell'), findsNothing);
  });

  testWidgets('Buy & Sell catalog fits a narrow phone with enlarged text',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buySellApp(textScale: 1.6));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
