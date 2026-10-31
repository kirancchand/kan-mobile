import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/core/theme/app_tokens.dart';
import 'package:mv_app/data/models/organisation_content.dart';
import 'package:mv_app/data/models/organisation_draft.dart';
import 'package:mv_app/data/models/shop_org.dart';
import 'package:mv_app/data/repositories/home_repository.dart';
import 'package:mv_app/data/services/organisation_content_api.dart';
import 'package:mv_app/features/home/organisation_detail_screen.dart';
import 'package:mv_app/features/home/widgets/shops_directory_section.dart';
import 'package:mv_app/features/profile/organisation_members_screen.dart';

class _CatalogApi extends OrganisationContentApi {
  @override
  Future<List<OrganisationProduct>> products(ShopOrg organisation) async => [
        for (var index = 0; index < 11; index++)
          OrganisationProduct(
            productId: '$index',
            name: 'Catalog item $index',
            price: 25 + index,
            quantity: 4 + index,
            description: 'Fresh produce',
          ),
      ];

  @override
  Future<List<OrganisationOption>> productOptions(ShopOrg organisation) async =>
      const [];

  @override
  Future<List<OrganisationAdvertisement>> advertisements(
          ShopOrg organisation) async =>
      const [
        OrganisationAdvertisement(
          name: 'Harvest weekend offer',
          description: 'Fresh produce discount',
          startDate: '2026-10-20',
          endDate: '2026-10-22',
        ),
      ];

  @override
  Future<List<OrganisationMember>> members(ShopOrg organisation) async =>
      const [
        OrganisationMember(name: 'Asha Menon', role: 'President'),
        OrganisationMember(name: 'Ravi Kumar', role: 'Secretary'),
      ];
}

void main() {
  for (final dark in [false, true]) {
    testWidgets('Organisation card opens details and returns, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final organisation = ShopOrg.fromJson({
        'organisation_id': 12,
        'organisation': 'Community Hospital',
        'organisation_type': {'value': '6', 'label': 'Hospital'},
        'organisation_address':
            'A long address on Village Road, near the town centre',
        'organisation_contact': '0987654321',
        'organisation_email': 'reception@community-hospital.example.com',
        'branch': {'value': '114', 'label': 'Kallankari'},
        'status': {'value': '1', 'label': 'Active'},
        'timings': '9 AM–5 PM',
        'latitude': '10.5',
        'longitude': 76.25,
      });
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
          brightness: dark ? Brightness.dark : Brightness.light,
          extensions: [dark ? AppTokens.dark : AppTokens.light],
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: Scaffold(
            body: ListView(children: [
          ShopsDirectorySection(shops: [organisation]),
        ])),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Community Hospital'));
      await tester.pumpAndSettle();
      expect(find.byType(OrganisationDetailScreen), findsOneWidget);
      expect(find.text('Community Hospital'), findsOneWidget);
      expect(find.text('Hospital'), findsOneWidget);
      expect(find.text('Call'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Route'), findsWidgets);
      expect(find.text('Share'), findsWidgets);
      await tester.dragUntilVisible(
        find.text('CORE ATTRIBUTES'),
        find.byType(ListView).last,
        const Offset(0, -300),
      );
      expect(find.text('CORE ATTRIBUTES'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('View all  >>'), findsOneWidget);
      for (final value in [
        organisation.address,
        organisation.phone,
        organisation.email,
        'Kallankari',
        'Active',
        '9 AM–5 PM',
        '10.500000,76.250000',
      ]) {
        final field = find.text(value);
        await tester.ensureVisible(field.first);
        expect(field, findsWidgets);
      }
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(OrganisationDetailScreen), findsNothing);
      expect(find.text('Community Hospital'), findsOneWidget);
    });
  }

  testWidgets('Missing details and partial coordinates have no invented values',
      (tester) async {
    final organisation = ShopOrg.fromJson({
      'organisation_id': 1,
      'organisation': 'Local organisation',
      'latitude': -1,
      'longitude': null,
    });
    expect(organisation.mapLocation, isNull);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [AppTokens.light]),
      home: OrganisationDetailScreen(organisation: organisation),
    ));
    expect(find.text('Not provided'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Managed business details expose the catalog add product action',
      (tester) async {
    final organisation = ShopOrg.fromJson({
      'organisation_id': 14,
      'organisation': 'Green Harvest',
      'organisation_type': {'value': '12', 'label': 'Business'},
      'f_usertype_id': 5,
      'organisation_address': 'Market Road',
    });

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [AppTokens.light]),
      home: OrganisationDetailScreen(organisation: organisation),
    ));

    expect(organisation.isBusiness, isTrue);
    expect(find.text('Product Catalog'), findsOneWidget);
    expect(find.text('Add Product'), findsOneWidget);
    expect(find.text('Add offer / adv / events'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Managed non-business organisation also exposes Add Product',
      (tester) async {
    final organisation = ShopOrg.fromJson({
      'organisation_id': 15,
      'organisation': 'Anaswara Club',
      'organisation_type': {'value': '6', 'label': 'Club'},
      'f_usertype_id': 5,
    });

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [AppTokens.light]),
      home: OrganisationDetailScreen(organisation: organisation),
    ));

    expect(organisation.isBusiness, isFalse);
    expect(find.text('Product Catalog'), findsOneWidget);
    expect(find.text('Add Product'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Product catalog previews ten items and Browse All filters',
      (tester) async {
    final home = HomeRepository(organisationContentApi: _CatalogApi());
    addTearDown(home.dispose);
    const organisation = ShopOrg(
      id: '23',
      name: 'Green Harvest',
      category: ShopCategory.grocery,
      phone: '',
      address: '',
      timings: '',
      membershipUserTypeId: 5,
    );

    await tester.pumpWidget(Provider<HomeRepository>.value(
      value: home,
      child: MaterialApp(
        theme: ThemeData(extensions: [AppTokens.light]),
        home: const OrganisationDetailScreen(organisation: organisation),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Catalog item 0'), findsOneWidget);
    expect(find.text('Catalog item 9'), findsOneWidget);
    expect(find.text('Catalog item 10'), findsNothing);
    await tester.dragUntilVisible(
      find.text('Add offer / adv / events'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    expect(find.text('Advertisements'), findsOneWidget);
    expect(find.text('Harvest weekend offer'), findsOneWidget);
    expect(find.text('View all  >>'), findsOneWidget);
    await tester.tap(find.text('View all  >>'));
    await tester.pumpAndSettle();
    expect(find.text('Organisation advertisements'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add offer / adv / events'));
    await tester.pumpAndSettle();
    expect(find.text('Organisation advertisements'), findsOneWidget);
    expect(find.text('Add advertisement'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Browse all products  >>'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Browse all products  >>'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'no-such-item');
    await tester.pump();
    expect(find.text('No products match your search.'), findsOneWidget);
  });

  testWidgets('Members list and View all show API member records',
      (tester) async {
    final home = HomeRepository(organisationContentApi: _CatalogApi());
    addTearDown(home.dispose);
    const organisation = ShopOrg(
      id: '23',
      name: 'Anaswara Club',
      category: ShopCategory.organization,
      phone: '',
      address: '',
      timings: '',
    );

    await tester.pumpWidget(Provider<HomeRepository>.value(
      value: home,
      child: MaterialApp(
        theme: ThemeData(extensions: [AppTokens.light]),
        home: const OrganisationDetailScreen(organisation: organisation),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(find.text('Members'),
        find.byType(ListView).first, const Offset(0, -250));
    expect(find.text('Asha Menon'), findsOneWidget);
    final membersHeader = find.text('View all  >>').first;
    await tester.tap(membersHeader);
    await tester.pumpAndSettle();
    expect(find.byType(OrganisationMembersScreen), findsOneWidget);
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('President'), findsWidgets);
    expect(find.text('Secretary'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(OrganisationMembersScreen), findsNothing);
  });
}
