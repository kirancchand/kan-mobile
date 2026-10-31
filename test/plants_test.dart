import 'fixtures/mock_marketplace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/repositories/marketplace_repository.dart';
import 'package:mv_app/features/services/plants/plants_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/state/app_state.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  for (final dark in [false, true]) {
    testWidgets('Plants search, categories and details work, dark=$dark',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(Provider(
        create: (_) =>
            MarketplaceRepository(initialListings: mockMarketplaceListings),
        child: MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: const PlantsListScreen()),
      ));
      await tester.pumpAndSettle();
      expect(find.text('A little green.\nA little joy.'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsWidgets);
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Indoor'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Indoor'));
      await tester.pumpAndSettle();
      expect(find.text('Money Plant (Pothos)'), findsOneWidget);
      expect(find.text('Tulsi Plant (Holy Basil)'), findsNothing);
      await tester.ensureVisible(find.text('Money Plant (Pothos)'));
      await tester.tap(find.text('Money Plant (Pothos)'));
      await tester.pumpAndSettle();
      expect(find.text('About this plant'), findsOneWidget);
      expect(find.text('Contact Seller'), findsOneWidget);
      expect(find.text('Illustration · ask the seller for current photos'),
          findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('All'));
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'mango');
      await tester.pumpAndSettle();
      expect(find.text('Mango Sapling (Grafted)'), findsOneWidget);
      expect(find.text('Money Plant (Pothos)'), findsNothing);
      await tester.enterText(find.byType(TextField), 'no such plant');
      await tester.pumpAndSettle();
      expect(find.text('No matching plants'), findsOneWidget);
      await tester.tap(find.text('List a plant').first);
      await tester.pumpAndSettle();
      expect(find.text('Post in Plants'), findsOneWidget);
      expect(find.text('Post Listing'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Plant glass form posts a listing and refreshes the grid',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final groups = WhatsAppGroupRepository();
    await tester.pumpWidget(MultiProvider(
        providers: [
          Provider(
              create: (_) => MarketplaceRepository(
                  initialListings: mockMarketplaceListings)),
          ChangeNotifierProvider(
              create: (_) => AppState(
                  whatsAppGroupRepository: groups,
                  authRepository: AuthRepository(groups))),
        ],
        child: MaterialApp(
            theme: AppTheme.light, home: const PlantsListScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('List a plant'));
    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Rose sapling');
    await tester.enterText(fields.at(1), 'A rose sapling in a clay pot.');
    await tester.enterText(fields.at(2), 'Flowers');
    await tester.enterText(fields.at(3), '120');
    await tester.ensureVisible(find.text('Post Listing'));
    await tester.tap(find.text('Post Listing'));
    await tester.pumpAndSettle();
    expect(find.text('Rose sapling'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Flowers'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Plant glass grid fits narrow screens with enlarged text',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(Provider(
        create: (_) =>
            MarketplaceRepository(initialListings: mockMarketplaceListings),
        child: MaterialApp(
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.6)),
              child: child!),
          home: const PlantsListScreen(),
        )));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
