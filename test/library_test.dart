import 'fixtures/mock_books.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/book_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/features/services/library/library_list_screen.dart';
import 'package:mv_app/features/services/library/library_theme.dart';
import 'package:mv_app/state/app_state.dart';
import 'package:provider/provider.dart';

Widget libraryApp({bool dark = false, double scale = 1}) {
  final groups = WhatsAppGroupRepository();
  return MultiProvider(
      providers: [
        Provider(create: (_) => BookRepository(initialItems: mockBooks)),
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
        home: const LibraryListScreen(),
      ));
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  for (final dark in [false, true]) {
    testWidgets('Glass library filters, search and rental contact, dark=$dark',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(libraryApp(dark: dark));
      await tester.pumpAndSettle();
      expect(find.byType(BackdropFilter), findsWidgets);
      await tester.tap(find.widgetWithText(ChoiceChip, 'For Rent'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('shelf-bk_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('shelf-bk_2')), findsNothing);
      await tester.enterText(find.byType(TextField), 'Coelho');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('shelf-bk_3')), findsOneWidget);
      expect(find.byKey(const ValueKey('shelf-bk_1')), findsNothing);
      await tester.ensureVisible(find.byKey(const ValueKey('shelf-bk_3')));
      await tester.tap(find.byKey(const ValueKey('shelf-bk_3')));
      await tester.pumpAndSettle();
      expect(find.text('₹15/week'), findsOneWidget);
      await tester.tap(find.text('Contact Owner to Rent'));
      await tester.pumpAndSettle();
      expect(find.text('9876511003'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Wanted books show buyer budget and contact', (tester) async {
    await tester.pumpWidget(libraryApp());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Wanted (Buy)'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('shelf-bk_4')));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('shelf-bk_4')));
    await tester.pumpAndSettle();
    expect(find.text('Budget ₹150'), findsOneWidget);
    expect(find.text('Contact Buyer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Posting a sale book refreshes the glass bookshelf',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(libraryApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('List a Book'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryGlass), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'For Sale'));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Village Stories');
    await tester.enterText(fields.at(1), 'Local Author');
    await tester.enterText(fields.at(2), 'Fiction');
    await tester.enterText(fields.at(3), '100');
    await tester.ensureVisible(find.text('List Book'));
    await tester.tap(find.text('List Book'));
    await tester.pumpAndSettle();
    expect(find.text('Village Stories'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'not in this library');
    await tester.pumpAndSettle();
    expect(find.text('No matching books'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Library fits a narrow phone with enlarged text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(libraryApp(scale: 1.6));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
