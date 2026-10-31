import 'fixtures/mock_marketplace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/marketplace_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/features/services/cake/cake_list_screen.dart';
import 'package:mv_app/features/services/cake/cake_theme.dart';
import 'package:mv_app/features/services/service_router.dart';
import 'package:mv_app/state/app_state.dart';
import 'package:provider/provider.dart';

Widget cakeApp({bool dark = false, double textScale = 1, bool route = false}) {
  final groups = WhatsAppGroupRepository();
  return MultiProvider(
    providers: [
      Provider(
          create: (_) =>
              MarketplaceRepository(initialListings: mockMarketplaceListings)),
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
                        onPressed: () => openService(context, ServiceType.cake),
                        child: const Text('Open cakes')),
                  ))
          : const CakeListScreen(),
    ),
  );
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final dark in [false, true]) {
    testWidgets('Cake routing, flavour search and baker contact, dark=$dark',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(cakeApp(dark: dark, route: true));
      await tester.tap(find.text('Open cakes'));
      await tester.pumpAndSettle();
      expect(find.byType(CakeListScreen), findsOneWidget);
      expect(find.byType(BackdropFilter), findsWidgets);
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Vanilla'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Vanilla'));
      await tester.pumpAndSettle();
      expect(find.text('Vanilla Birthday Cake (0.5 kg)'), findsOneWidget);
      expect(find.text('Chocolate Truffle Cake (1 kg)'), findsNothing);
      await tester.ensureVisible(find.text('Vanilla Birthday Cake (0.5 kg)'));
      await tester.tap(find.text('Vanilla Birthday Cake (0.5 kg)'));
      await tester.pumpAndSettle();
      expect(find.text('About this bake'), findsOneWidget);
      await tester.tap(find.text('Contact Baker'));
      await tester.pumpAndSettle();
      expect(find.text('9876543217'), findsOneWidget);
      await tester.tap(find.text('Call'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Call 9876543217'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('All cakes'));
      await tester.tap(find.text('All cakes'));
      await tester.enterText(find.byType(TextField), 'chocolate');
      await tester.pumpAndSettle();
      expect(find.text('Chocolate Truffle Cake (1 kg)'), findsOneWidget);
      expect(find.text('Vanilla Birthday Cake (0.5 kg)'), findsNothing);
      await tester.enterText(find.byType(TextField), 'no such bake');
      await tester.pumpAndSettle();
      expect(find.text('No matching cakes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Posting a cake uses the cake theme and refreshes its catalog',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(cakeApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('List a cake'));
    await tester.pumpAndSettle();
    expect(find.text('Post in Cake Marketplace'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(Theme.of(tester.element(find.byType(Form))).colorScheme.primary,
        CakeTheme.raspberry);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Lemon celebration cake');
    await tester.enterText(
        fields.at(1), 'Homemade lemon cake for village celebrations.');
    await tester.enterText(fields.at(2), 'Lemon');
    await tester.enterText(fields.at(3), '450');
    await tester.ensureVisible(find.text('Post Listing'));
    await tester.tap(find.text('Post Listing'));
    await tester.pumpAndSettle();
    expect(find.text('Lemon celebration cake'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Lemon'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cake catalog fits a narrow phone with enlarged text',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(cakeApp(textScale: 1.6));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
