import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/data/models/shop_org.dart';
import 'package:mv_app/data/models/organisation_content.dart';
import 'package:mv_app/data/models/organisation_draft.dart';
import 'package:mv_app/data/services/organisation_content_api.dart';
import 'package:mv_app/data/repositories/home_repository.dart';
import 'package:mv_app/features/profile/organisation_products_screen.dart';
import 'package:mv_app/features/profile/organisation_advertisements_screen.dart';

// UI-only fixture. The actual HTTP save behavior is covered by the Postman
// simulation in organisation_content_test.dart.
class _SaveOutcomeApi extends OrganisationContentApi {
  _SaveOutcomeApi(this.outcome);
  final Object outcome;
  int writes = 0;
  @override
  Future<List<OrganisationOption>> productOptions(ShopOrg organisation) async =>
      [const OrganisationOption(value: '3', label: 'Rice')];
  @override
  Future<List<OrganisationProduct>> products(ShopOrg organisation) async => [];
  @override
  Future<ProductSaveResult> addProduct(ShopOrg organisation,
      {required String productId,
      required num price,
      required int quantity,
      required String description}) async {
    writes++;
    if (outcome is ProductSaveException) throw outcome;
    return outcome as ProductSaveResult;
  }
}

void main() {
  for (final outcome in [
    ProductSaveResult.confirmed,
    ProductSaveResult.unconfirmed,
    const ProductSaveException('Product insert rejected by server')
  ]) {
    testWidgets('Product form displays the actual save outcome: $outcome',
        (tester) async {
      final api = _SaveOutcomeApi(outcome);
      final home = HomeRepository(organisationContentApi: api);
      addTearDown(home.dispose);
      const org = ShopOrg(
          id: '2',
          name: 'Village store',
          category: ShopCategory.grocery,
          phone: '',
          address: '',
          timings: '',
          membershipUserTypeId: 5);
      await tester.pumpWidget(Provider<HomeRepository>.value(
          value: home,
          child: const MaterialApp(
              home: OrganisationProductsScreen(organisation: org))));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add product'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rice').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '300');
      await tester.enterText(find.byType(TextFormField).at(1), '5');
      await tester.enterText(find.byType(TextFormField).at(2), 'Rice pack');
      final save = find.widgetWithText(FilledButton, 'Add product');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(api.writes, 1);
      if (outcome == ProductSaveResult.confirmed) {
        expect(find.text('Product added'), findsOneWidget);
        expect(find.byType(TextFormField), findsNothing);
      } else {
        expect(find.text('Product added'), findsNothing);
        expect(find.text('Rice pack'), findsOneWidget);
        if (outcome == ProductSaveResult.unconfirmed) {
          expect(find.textContaining('could not be confirmed'), findsOneWidget);
          expect(tester.widget<FilledButton>(save).onPressed, isNull);
          await tester.ensureVisible(find.text('View products'));
          await tester.tap(find.text('View products'));
          await tester.pumpAndSettle();
          expect(find.byType(TextFormField), findsNothing);
          expect(api.writes, 1);
        } else {
          expect(
              find.text('Product insert rejected by server'), findsOneWidget);
          expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
        }
      }
    });
  }

  testWidgets(
      'Direct navigation cannot expose management forms to ordinary members',
      (tester) async {
    final home = HomeRepository();
    addTearDown(home.dispose);
    const organisation = ShopOrg(
        id: '2',
        name: 'Village store',
        category: ShopCategory.grocery,
        phone: '',
        address: '',
        timings: '',
        membershipUserTypeId: 7);
    for (final page in [
      const OrganisationProductsScreen(organisation: organisation),
      const OrganisationAdvertisementsScreen(organisation: organisation),
    ]) {
      await tester.pumpWidget(Provider<HomeRepository>.value(
          value: home, child: MaterialApp(home: page)));
      expect(find.text('You cannot manage this organisation.'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    }
  });
}
