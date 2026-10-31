import 'dart:convert';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';
import 'package:mv_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/data/models/shop_org.dart';
import 'package:mv_app/data/repositories/home_repository.dart';
import 'package:mv_app/data/services/organisation_api.dart';
import 'package:mv_app/features/home/all_shops_screen.dart';
import 'package:provider/provider.dart';

Map<String, Object> row(int id) => {
      'organisation_id': id,
      'organisation': 'Organisation $id',
      'organisation_contact': '0123456789',
      'organisation_type': {'value': 1, 'label': 'School'},
    };

void main() {
  test(
      'Directory loads all pages with master request parameters and real fields',
      () async {
    var calls = 0;
    final api = OrganisationApi(client: MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/master/organisation/listOrganisation');
      expect(request.url.port, 8070);
      final body = jsonDecode(request.body);
      expect(body['start'], calls);
      expect(body['filters'], isEmpty);
      expect(body['numberOfRows'], 50);
      expect(body['sort'], [
        {'columnName': 'slno', 'sortOrder': 'desc'}
      ]);
      calls++;
      return http.Response(
          jsonEncode({
            'totalCount': 2,
            'result': [row(calls)]
          }),
          200);
    }));
    final repo = HomeRepository(organisationApi: api);
    addTearDown(repo.dispose);
    final shops = await repo.getOrganisationDirectory();
    expect(calls, 2);
    expect(
        shops.map((shop) => shop.name), ['Organisation 1', 'Organisation 2']);
    expect(shops.first.phone, '0123456789');
    expect(shops.first.category, ShopCategory.organization);
    expect(shops.first.organisationType, 'School');
    expect(shops.first.address, isEmpty);
    expect(shops.first.imageUrl, isEmpty);
  });

  test('Home and directory share API cache and notify preview listeners',
      () async {
    var rows = List.generate(5, (index) => row(index + 1));
    var fail = false;
    final repo = HomeRepository(
        organisationApi: OrganisationApi(
            client: MockClient((_) async => fail
                ? http.Response('', 503)
                : http.Response(
                    jsonEncode({'totalCount': rows.length, 'result': rows}),
                    200))));
    addTearDown(repo.dispose);
    var changes = 0;
    repo.changes.addListener(() => changes++);
    expect(repo.shops, isEmpty);
    await repo.getShops();
    expect(repo.shops.take(4).map((shop) => shop.id), ['1', '2', '3', '4']);
    expect(changes, 1);
    rows = [row(6)];
    await repo.getOrganisationDirectory();
    expect(repo.shops.single.id, '6');
    expect(changes, 2);
    fail = true;
    await expectLater(repo.getShops(), throwsA(isA<http.ClientException>()));
    expect(repo.shops.single.id, '6');
    expect(changes, 2);
    fail = false;
    rows = [];
    await repo.getShops();
    expect(repo.shops, isEmpty);
    expect(changes, 3);
  });

  test('Category API posts master pagination and parses type IDs and names',
      () async {
    final api = OrganisationApi(client: MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/master/organisationtype/listOrganisationType');
      expect(request.url.port, 8070);
      return http.Response(
          '{"totalCount":1,"result":[{"organisation_type_id":1,"organisation_type":"School"}]}',
          200);
    }));
    addTearDown(api.dispose);
    final categories = await api.fetchCategories();
    expect(categories.single.name, 'School');
    expect(categories.single.id, '1');
  });

  testWidgets('API category chips filter distinct organisation types',
      (tester) async {
    final repo = HomeRepository(
        organisationApi: OrganisationApi(client: MockClient((request) async {
      if (request.url.path.endsWith('listOrganisationType')) {
        return http.Response(
            '{"totalCount":2,"result":[{"organisation_type_id":1,"organisation_type":"School"},{"organisation_type_id":2,"organisation_type":"Police Station"}]}',
            200);
      }
      return http.Response(
          jsonEncode({
            'totalCount': 2,
            'result': [
              row(1),
              {...row(2), 'organisation_type': 'Police Station'}
            ]
          }),
          200);
    })));
    addTearDown(repo.dispose);
    await tester.pumpWidget(Provider.value(
        value: repo,
        child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.light]),
            home: const AllShopsScreen())));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ChoiceChip, 'School'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Grocery'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'School'));
    await tester.pumpAndSettle();
    expect(find.text('Organisation 1'), findsOneWidget);
    expect(find.text('Organisation 2'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Police Station'));
    await tester.pumpAndSettle();
    expect(find.text('Organisation 1'), findsNothing);
    expect(find.text('Organisation 2'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.text('Organisation 1'), findsOneWidget);
    expect(find.text('Organisation 2'), findsOneWidget);
  });

  test('Master requests refresh bearer tokens once on 401', () async {
    var refreshes = 0;
    final auth = AuthRepository(WhatsAppGroupRepository(),
        api: KanAuthApi(client: MockClient((request) async {
      if (request.url.path.endsWith('/login')) {
        return http.Response(
            '{"access_token":"old","refresh_token":"refresh"}', 200);
      }
      refreshes++;
      return http.Response('{"access_token":"new"}', 200);
    })));
    addTearDown(auth.dispose);
    await auth.login('user', password: 'password');
    var calls = 0;
    final api = OrganisationApi(
        authRepository: auth,
        client: MockClient((request) async {
          calls++;
          expect(request.headers['Authorization'],
              calls == 1 ? 'Bearer old' : 'Bearer new');
          return calls == 1
              ? http.Response('', 401)
              : http.Response('{"totalCount":0,"result":[]}', 200);
        }));
    addTearDown(api.dispose);
    expect(await api.fetchAll(), isEmpty);
    expect(await api.fetchCategories(), isEmpty);
    expect(refreshes, 1);
    expect(calls, 3);
  });

  test('Repeated pagination fails rather than looping or duplicating',
      () async {
    final api = OrganisationApi(
        client: MockClient((_) async => http.Response(
            jsonEncode({
              'totalCount': 2,
              'result': [row(1)]
            }),
            200)));
    addTearDown(api.dispose);
    await expectLater(api.fetchAll(), throwsFormatException);
  });

  testWidgets('Directory retries failed requests and shows API empty state',
      (tester) async {
    var calls = 0;
    final repo = HomeRepository(
        organisationApi: OrganisationApi(client: MockClient((request) async {
      if (request.url.path.endsWith('listOrganisationType')) {
        return http.Response('{"totalCount":0,"result":[]}', 200);
      }
      return ++calls == 1
          ? http.Response('', 503)
          : http.Response('{"totalCount":0,"result":[]}', 200);
    })));
    addTearDown(repo.dispose);
    await tester.pumpWidget(Provider.value(
        value: repo,
        child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.light]),
            home: const AllShopsScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No organisations yet'), findsOneWidget);
    expect(calls, 2);
  });
}
