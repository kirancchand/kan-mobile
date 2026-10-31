import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/data/models/media_attachment.dart';
import 'package:mv_app/data/models/organisation_content.dart';
import 'package:mv_app/data/models/shop_org.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/home_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';
import 'package:mv_app/data/services/organisation_content_api.dart';

ShopOrg organisation(int role) => ShopOrg(
    id: '2',
    name: 'Village store',
    category: ShopCategory.grocery,
    phone: '',
    address: '',
    timings: '',
    membershipUserTypeId: role);

OrganisationAdvertisementDraft advertisement({bool invalidDates = false}) =>
    OrganisationAdvertisementDraft(
        name: 'Festival offer',
        description: 'Special offer',
        advertisementTypeId: '2',
        startDate: DateTime(2026, 10, 17),
        endDate: DateTime(2026, 10, invalidDates ? 16 : 20),
        image: MediaAttachment(
            name: 'offer.png',
            kind: MediaKind.image,
            bytes: Uint8List.fromList([137, 80, 78, 71])));

void main() {
  for (final (type, column) in [
    ('product', 'product'),
    ('organisation', 'organisation'),
    ('organisationType', 'organisation_type'),
  ]) {
    test('Home $type search posts the $column filter to common/searchProduct',
        () async {
      http.Request? sent;
      final api = OrganisationContentApi(
        kanUrl: 'https://example.test',
        authRepository: _MemberTestAuth(),
        client: MockClient((request) async {
          sent = request;
          return http.Response(
              jsonEncode({
                'data': [
                  {
                    'product': 'Salt',
                    'organisation': 'Village store',
                    'organisation_type': 'Grocery'
                  },
                  {'organisation': 'Sarada Stores'},
                ]
              }),
              200);
        }),
      );
      final repo = HomeRepository(organisationContentApi: api);
      addTearDown(repo.dispose);

      final results = await repo.searchHome(' sa ', type);

      expect(sent!.method, 'POST');
      expect(sent!.url.toString(), 'https://example.test/common/searchProduct');
      expect(sent!.headers['Authorization'], 'Bearer member-test-token');
      expect(jsonDecode(sent!.body), {
        'start': 0,
        'numberOfRows': 10,
        'sort': [
          {'columnName': 'slno', 'sortOrder': 'desc'}
        ],
        'filters': [
          {'columnName': column, 'value': 'sa'}
        ]
      });
      expect(results.items.map((item) => item.title), ['Salt', 'Sarada Stores']);
      expect(results.items.first.subtitle, 'Village store • Grocery');
    });
  }

  test('Member list uses the organisation filter from the Postman request',
      () async {
    http.Request? sentRequest;
    final api = OrganisationContentApi(
      kanUrl: 'https://example.test',
      authRepository: _MemberTestAuth(),
      client: MockClient((request) async {
        sentRequest = request;
        return http.Response(
            jsonEncode({
              'totalCount': 1,
              'result': [
                {
                  'f_organisation_id': 2,
                  'name': 'Asha Menon',
                  'role': {'value': '3', 'label': 'President'},
                }
              ],
            }),
            200);
      }),
    );
    addTearDown(api.dispose);

    final members = await api.members(organisation(5));
    expect(sentRequest!.url.path,
        '/master/organisationmember/listOrganisationMember');
    expect(sentRequest!.headers['Authorization'], 'Bearer member-test-token');
    final body = jsonDecode(sentRequest!.body) as Map<String, dynamic>;
    expect(body['filters'], [
      {'columnName': 'f_organisation_id', 'value': 2}
    ]);
    expect(members.single.name, 'Asha Menon');
    expect(members.single.role, 'President');
  });

  test('Advertisements load from the organisation-specific GET endpoint',
      () async {
    http.Request? sentRequest;
    final api = OrganisationContentApi(
      villageUrl: 'http://localhost:5001',
      authRepository: _MemberTestAuth(),
      client: MockClient((request) async {
        sentRequest = request;
        return http.Response(
            jsonEncode({
              'data': [
                {
                  'f_villageorganisation_id': '2',
                  'advertisement_name': 'Harvest offer',
                  'advertisement_desc': 'Seasonal discount',
                  'start_date': '2026-10-20',
                  'end_date': '2026-10-22',
                }
              ]
            }),
            200);
      }),
    );
    addTearDown(api.dispose);

    final ads = await api.advertisements(organisation(5));
    expect(sentRequest!.method, 'GET');
    expect(sentRequest!.url.toString(),
        'http://localhost:5001/api/advertisements/getAdvertisementByOrganisation/2');
    expect(ads.single.name, 'Harvest offer');
    expect(ads.single.description, 'Seasonal discount');
  });

  test(
      'Management APIs deny members without edit privileges before any HTTP request',
      () async {
    final api = OrganisationContentApi();
    addTearDown(api.dispose);
    for (final role in [1, 3, 7, 11]) {
      final org = organisation(role);
      await expectLater(api.productOptions(org), throwsStateError);
      await expectLater(api.products(org), throwsStateError);
      await expectLater(api.advertisements(org), throwsStateError);
      await expectLater(
          api.addProduct(org,
              productId: '3', price: 20, quantity: 1, description: 'Rice'),
          throwsStateError);
      await expectLater(
          api.addAdvertisement(org, advertisement()), throwsStateError);
    }
  });

  test('Invalid product values and reversed advertisement dates are rejected',
      () async {
    final api = OrganisationContentApi();
    addTearDown(api.dispose);
    for (final price in [double.nan, double.infinity, -1]) {
      await expectLater(
          api.addProduct(organisation(5),
              productId: '3', price: price, quantity: 1, description: 'Rice'),
          throwsArgumentError);
    }
    await expectLater(
        api.addAdvertisement(
            organisation(6), advertisement(invalidDates: true)),
        throwsArgumentError);
  });

  const base = String.fromEnvironment('organisation_content_simulation_url');
  group('Postman HTTP simulation', () {
    late AuthRepository auth;
    late OrganisationContentApi api;
    setUp(() async {
      auth = AuthRepository(WhatsAppGroupRepository(),
          api: KanAuthApi(baseUrl: base));
      await auth.login('simulation-user', password: 'simulation-only');
      api = OrganisationContentApi(
          authRepository: auth, kanUrl: base, villageUrl: base);
      await api
          .productOptions(organisation(5)); // Also proves the 401 refresh path.
      final response = await http.post(Uri.parse('$base/test/reset'),
          headers: {'Authorization': 'Bearer ${auth.tokens!.accessToken}'});
      expect(response.statusCode, 200);
    });
    tearDown(() {
      api.dispose();
      auth.dispose();
    });

    test('Select, add and read back multiple organisation products', () async {
      final options = await api.productOptions(organisation(5));
      expect(options.map((p) => p.label), ['Rice', 'Tea']);
      expect(await api.products(organisation(5)), isEmpty);
      for (final option in options) {
        final result = await api.addProduct(organisation(6),
            productId: option.value,
            price: 300.5,
            quantity: 5,
            description: '${option.label} pack');
        expect(result, ProductSaveResult.confirmed);
      }
      final products = await api.products(organisation(5));
      expect(products.map((p) => p.productId), ['3', '4']);
      expect(products.first.price, 300.5);
      expect(products.first.quantity, 5);
      expect(auth.tokens!.accessToken, 'valid-content-test');
    });

    for (final scenario in [
      'reject-status',
      'reject-nested',
      'reject-rows',
      'reject-text'
    ]) {
      test('HTTP 200 $scenario is a save error, never success', () async {
        final rejecting = OrganisationContentApi(
            authRepository: auth, kanUrl: '$base/$scenario');
        addTearDown(rejecting.dispose);
        await expectLater(
            rejecting.addProduct(organisation(5),
                productId: '3', price: 300, quantity: 5, description: 'Rice'),
            throwsA(isA<ProductSaveException>().having(
                (e) => e.message, 'server message', contains('roduct'))));
        expect(await api.products(organisation(5)), isEmpty);
      });
    }

    test(
        'Success-shaped no-op is unconfirmed even with an identical existing row',
        () async {
      final noop =
          OrganisationContentApi(authRepository: auth, kanUrl: '$base/noop');
      addTearDown(noop.dispose);
      Future<ProductSaveResult> save(OrganisationContentApi client) =>
          client.addProduct(organisation(5),
              productId: '3', price: 300, quantity: 5, description: 'Rice');
      expect(await save(noop), ProductSaveResult.unconfirmed);
      expect(await save(api), ProductSaveResult.confirmed);
      expect(await save(noop), ProductSaveResult.unconfirmed);
      expect(await api.products(organisation(5)), hasLength(1));
    });

    test(
        'A successful insert with failed read-back is unconfirmed, not retried',
        () async {
      final unreadable = OrganisationContentApi(
          authRepository: auth, kanUrl: '$base/unreadable-after');
      addTearDown(unreadable.dispose);
      expect(
          await unreadable.addProduct(organisation(5),
              productId: '3', price: 300, quantity: 5, description: 'Rice'),
          ProductSaveResult.unconfirmed);
      expect(await api.products(organisation(5)), hasLength(1));
    });

    for (final scenario in ['empty-save', 'json-save']) {
      test('$scenario is confirmed by reading the newly saved product',
          () async {
        final saving = OrganisationContentApi(
            authRepository: auth, kanUrl: '$base/$scenario');
        addTearDown(saving.dispose);
        expect(
            await saving.addProduct(organisation(5),
                productId: '3', price: 300, quantity: 5, description: 'Rice'),
            ProductSaveResult.confirmed);
      });
    }

    test('Multipart advertisement creation and organisation/village isolation',
        () async {
      expect(await api.advertisements(organisation(5)), isEmpty);
      expect((await api.advertisementTypes()).map((type) => type.label),
          ['Event', 'Advertisement']);
      // Force a new expired session so the multipart request must be rebuilt on retry.
      auth.clearSession();
      await auth.login('simulation-user', password: 'simulation-only');
      await api.addAdvertisement(organisation(6), advertisement());
      final ads = await api.advertisements(organisation(5));
      expect(ads, hasLength(1));
      expect(ads.single.name, 'Festival offer');
      expect(ads.single.startDate, '2026-10-17');
      expect(ads.single.endDate, '2026-10-20');
    });

    test('Server failures and malformed lists surface for retry', () async {
      final failing = OrganisationContentApi(
          authRepository: auth,
          kanUrl: '$base/failure',
          villageUrl: '$base/failure');
      final malformed = OrganisationContentApi(
          authRepository: auth,
          kanUrl: '$base/malformed',
          villageUrl: '$base/malformed');
      addTearDown(failing.dispose);
      addTearDown(malformed.dispose);
      await expectLater(failing.products(organisation(5)),
          throwsA(isA<http.ClientException>()));
      await expectLater(
          failing.addAdvertisement(organisation(5), advertisement()),
          throwsA(isA<http.ClientException>()));
      await expectLater(
          malformed.products(organisation(5)), throwsFormatException);
      await expectLater(
          malformed.advertisements(organisation(5)), throwsFormatException);
    });
  },
      skip: base.isEmpty
          ? 'Run with organisation_content_simulation_url pointing at the local Postman simulation.'
          : false);
}

class _MemberTestAuth extends AuthRepository {
  _MemberTestAuth() : super(WhatsAppGroupRepository());

  @override
  Future<String> validAccessToken() async => 'member-test-token';
}
