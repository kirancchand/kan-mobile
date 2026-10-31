import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/core/theme/app_tokens.dart';
import 'package:mv_app/data/repositories/home_repository.dart';
import 'package:mv_app/data/services/advertisements_api.dart';
import 'package:mv_app/features/home/widgets/events_feed.dart';

Map<String, Object?> row(int id, String type, int typeId) => {
      'villageadvertisement_id': id,
      'advertisement_name': 'Entry $id',
      'advertisement_desc': 'Description $id',
      'advertisement_image': '',
      'start_date': '2026-10-13T09:00:00',
      'organisation_name': 'Village Club',
      'adv_type': type,
      'f_adv_type_id': typeId,
    };

void main() {
  test('Loads all pages and lookup types; only Advertisment goes to carousel',
      () async {
    var pages = 0;
    var lookups = 0;
    final api = AdvertisementsApi(
        baseUrl: 'http://village.example:5001',
        appId: '7',
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.headers['X-App-Id'], '7');
          final body = jsonDecode(request.body);
          if (request.url.path == '/api/keyValue') {
            lookups++;
            expect(body, {'requestName': 'getAll_AdvType'});
            return http.Response(
                jsonEncode([
                  {'value': 1, 'label': 'Event'},
                  {'value': 2, 'label': 'Advertisment'},
                  {'value': 3, 'label': 'Community notice'},
                ]),
                200);
          }
          expect(request.url.path, '/api/advertisements/list');
          expect(body, {
            'start': pages,
            'numberofRows': 50,
            'filter': [
              {'columnName': 'f_villageapp_id', 'value': 7}
            ],
            'sort': [
              {'columnName': 'villageadvertisement_id', 'sortOrder': 'DESC'}
            ],
          });
          final rows = [
            row(3, 'Event', 1),
            {
              ...row(2, 'Advertisment', 2),
              'advertisement_image': 'http://localhost:5001/uploads/banner.jpg'
            },
            {...row(1, '', 3), 'start_date': null},
          ];
          return http.Response(
              jsonEncode({
                'totalCount': 3,
                'result': [rows[pages++]]
              }),
              200);
        }));
    final repository = HomeRepository(advertisementsApi: api);
    addTearDown(repository.dispose);
    final feed = await repository.getAdvertisementFeed();
    expect(pages, 3);
    expect(lookups, 1);
    expect(feed.types.map((type) => type.label),
        ['Event', 'Advertisment', 'Community notice']);
    expect(feed.events.map((event) => event.title),
        ['Entry 3', 'Entry 2', 'Entry 1']);
    expect(feed.events.last.typeLabel, 'Community notice');
    expect(feed.events.last.dateTime, isNull);
    expect(feed.ads.single.id, '2');
    expect(feed.ads.single.bannerImageUrl,
        'http://village.example:5001/uploads/banner.jpg');
    expect(feed.ads.single.subtitle, 'Description 2');
    expect(feed.ads.single.sponsor, 'Village Club');
  });

  test('API failure is reported without returning mock content', () async {
    final api = AdvertisementsApi(
        client: MockClient((_) async => http.Response('', 503)));
    addTearDown(api.dispose);
    await expectLater(api.fetch(), throwsStateError);
  });

  test('Repeated pages are rejected instead of looping', () async {
    final api = AdvertisementsApi(
        client: MockClient((request) async => http.Response(
            jsonEncode(request.url.path == '/api/keyValue'
                ? []
                : {
                    'totalCount': 2,
                    'result': [row(1, 'Event', 1)]
                  }),
            200)));
    addTearDown(api.dispose);
    await expectLater(api.fetch(), throwsFormatException);
  });

  testWidgets(
      'API types filter before the Home preview limit, including empty types',
      (tester) async {
    final api = AdvertisementsApi(
        client: MockClient((request) async => http.Response(
            jsonEncode(request.url.path == '/api/keyValue'
                ? [
                    {'value': 1, 'label': 'Event'},
                    {'value': 2, 'label': 'Advertisment'},
                    {'value': 3, 'label': 'Community notice'},
                  ]
                : {
                    'totalCount': 2,
                    'result': [row(1, 'Event', 1), row(2, 'Advertisment', 2)]
                  }),
            200)));
    addTearDown(api.dispose);
    final feed = await api.fetch();
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [AppTokens.light]),
      home: Scaffold(
          body: ListView(children: [
        EventsFeed(events: feed.events, types: feed.types, maxItems: 1),
      ])),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Entry 1'), findsOneWidget);
    expect(find.text('Entry 2'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Advertisment'));
    await tester.pumpAndSettle();
    expect(find.text('Entry 1'), findsNothing);
    expect(find.text('Entry 2'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Community notice'));
    await tester.pumpAndSettle();
    expect(find.text('No events or updates in this category.'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.text('Entry 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
