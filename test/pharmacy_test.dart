import 'fixtures/mock_marketplace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/marketplace_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/features/services/pharmacy/pharmacy_list_screen.dart';
import 'package:mv_app/features/services/service_router.dart';
import 'package:mv_app/state/app_state.dart';
import 'package:provider/provider.dart';

Widget pharmacyApp({bool dark = false, double scale = 1, bool route = false}) {
  final groups = WhatsAppGroupRepository();
  return MultiProvider(
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
        theme: dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!),
        home: route
            ? Builder(
                builder: (context) => Scaffold(
                        body: TextButton(
                      onPressed: () =>
                          openService(context, ServiceType.pharmacy),
                      child: Text(ServiceType.pharmacy.label),
                    )))
            : const PharmacyListScreen(),
      ));
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  for (final dark in [false, true]) {
    testWidgets('Pharmacy route, category search and contact work, dark=$dark',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(pharmacyApp(dark: dark, route: true));
      await tester.tap(find.text('Pharmacy'));
      await tester.pumpAndSettle();
      expect(find.byType(PharmacyListScreen), findsOneWidget);
      expect(find.text('Medicine'), findsNothing);
      expect(find.byType(BackdropFilter), findsWidgets);
      final filter = find.widgetWithText(ChoiceChip, 'Devices');
      await tester.ensureVisible(filter);
      await tester.tap(filter);
      await tester.pumpAndSettle();
      expect(find.text('Digital BP Monitor'), findsOneWidget);
      expect(find.text('Paracetamol 500mg (Strip of 10)'), findsNothing);
      await tester.ensureVisible(find.text('Digital BP Monitor'));
      await tester.tap(find.text('Digital BP Monitor'));
      await tester.pumpAndSettle();
      expect(find.text('Product information'), findsOneWidget);
      await tester.tap(find.text('Contact Pharmacy'));
      await tester.pumpAndSettle();
      expect(find.text('9876500002'), findsOneWidget);
      await tester.tap(find.text('Call'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Call 9876500002'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'All'));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
      await tester.enterText(find.byType(TextField), 'sundarpalli');
      await tester.pumpAndSettle();
      expect(find.text('Multivitamin Tablets (30 count)'), findsOneWidget);
      expect(find.text('Digital BP Monitor'), findsNothing);
      await tester.enterText(find.byType(TextField), 'unlisted product');
      await tester.pumpAndSettle();
      expect(find.text('No matching products'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'Pharmacy posting retains the renamed service and refreshes catalog',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(pharmacyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('List a product'));
    await tester.pumpAndSettle();
    expect(find.text('Post in Pharmacy'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Digital thermometer');
    await tester.enterText(
        fields.at(1), 'Digital thermometer with a storage case.');
    await tester.enterText(fields.at(2), 'Devices');
    await tester.enterText(fields.at(3), '120');
    await tester.ensureVisible(find.text('Post Listing'));
    await tester.tap(find.text('Post Listing'));
    await tester.pumpAndSettle();
    expect(find.text('Digital thermometer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pharmacy supports enlarged text on narrow phones',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(pharmacyApp(dark: true, scale: 1.6));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
