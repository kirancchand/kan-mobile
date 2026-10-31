import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/core/config/api_config.dart';
import 'package:mv_app/core/widgets/kan_registration_fields.dart';
import 'package:mv_app/data/models/gender_option.dart';
import 'package:mv_app/data/services/kan_master_api.dart';

void main() {
  test('Master URL supports other endpoints and remains separate from auth',
      () {
    expect(ApiConfig.kanUri('/master/gender/getAll').toString(),
        'http://localhost:8070/master/gender/getAll');
    expect(
        ApiConfig.kanUri('/master/branch/getAll',
                baseUrl: 'https://example.com/api/')
            .toString(),
        'https://example.com/api/master/branch/getAll');
    expect(ApiConfig.registrationUri().port, 8084);
  });

  test('Gender lookup matches the collection request and parses string IDs',
      () async {
    late http.Request sent;
    final api = KanMasterApi(client: MockClient((request) async {
      sent = request;
      return http.Response(
          '[{"value":"1","label":"Male"},{"value":"2","label":"Female"}]', 200);
    }));
    addTearDown(api.dispose);
    final options = await api.getGenders();
    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'http://localhost:8070/master/gender/getAll');
    expect(sent.headers['Content-Type'], 'application/json');
    expect(sent.headers.containsKey('Authorization'), isFalse);
    expect(jsonDecode(sent.body), {'requestName': 'getAll_Gender'});
    expect(options.map((o) => o.toJson()).toList(), [
      {'value': '1', 'label': 'Male'},
      {'value': '2', 'label': 'Female'},
    ]);
  });

  test('District subadmins load from area getByDistrict', () async {
    late http.Request sent;
    final api = KanMasterApi(client: MockClient((request) async {
      sent = request;
      return http.Response(
          jsonEncode([
            {'area_id': 3, 'area_name': 'Nanniyode'},
            {'area_id': 4, 'area_name': 'Palode'},
          ]),
          200);
    }));
    addTearDown(api.dispose);
    final page = await api.listAreas(
        accessToken: 'token', districtId: '1', page: 0, pageSize: 1);
    expect(sent.method, 'GET');
    expect(sent.url.toString(),
        'http://localhost:8070/master/area/getByDistrict/1');
    expect(sent.headers['Authorization'], 'Bearer token');
    expect(page.items.map((a) => '${a.id}:${a.name}'), ['3:Nanniyode']);
    expect(page.hasNext, isTrue);
  });

  test('Branch boundary loads from getBranchGeoById', () async {
    late http.Request sent;
    final api = KanMasterApi(client: MockClient((request) async {
      sent = request;
      return http.Response(
          jsonEncode({
            'data': [
              {
                'branch': 'pavachakuzhi',
                'geometry': {
                  'type': 'Polygon',
                  'coordinates': [
                    [
                      [76, 8],
                      [77, 8],
                      [77, 9],
                      [76, 8]
                    ]
                  ]
                }
              }
            ]
          }),
          200);
    }));
    addTearDown(api.dispose);
    final geometry =
        await api.getBranchGeometryById(accessToken: 'token', branchId: '19');
    expect(sent.method, 'GET');
    expect(sent.url.toString(),
        'http://localhost:8070/master/branch/getBranchGeoById/19');
    expect(sent.headers['Authorization'], 'Bearer token');
    expect(geometry.keys, ['pavachakuzhi']);
    expect(geometry['pavachakuzhi']!.polygons, hasLength(1));
  });

  for (final failure in [
    'http',
    'network',
    'timeout',
    'invalid json',
    'empty',
    'invalid option',
    'duplicate'
  ]) {
    test('$failure reports unavailable master data without fabricated options',
        () async {
      final api = KanMasterApi(
          timeout: const Duration(milliseconds: 5),
          client: MockClient((_) async {
            if (failure == 'network') throw http.ClientException('offline');
            if (failure == 'timeout') {
              await Future<void>.delayed(const Duration(milliseconds: 20));
            }
            return switch (failure) {
              'http' => http.Response('unavailable', 503),
              'invalid json' => http.Response('not json', 200),
              'empty' => http.Response('[]', 200),
              'invalid option' =>
                http.Response('[{"value":"bad","label":"Bad"}]', 200),
              'duplicate' => http.Response(
                  '[{"value":"1","label":"Male"},{"value":"1","label":"Other"}]',
                  200),
              _ => http.Response('[]', 200),
            };
          }));
      addTearDown(api.dispose);
      await expectLater(api.getGenders(), throwsA(anything));
    });
  }

  testWidgets('Gender dropdown shows retry when lookup fails', (tester) async {
    final response = Completer<http.Response>();
    final api = KanMasterApi(client: MockClient((_) => response.future));
    addTearDown(api.dispose);
    final fields = GlobalKey<KanRegistrationFieldsState>();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: KanRegistrationFields(key: fields, masterApi: api)))));
    var dropdown = tester.widget<DropdownButtonFormField<GenderOption>>(
        find.byType(DropdownButtonFormField<GenderOption>));
    expect(dropdown.onChanged, isNull);
    response.complete(http.Response('', 500));
    await tester.pumpAndSettle();
    dropdown = tester.widget<DropdownButtonFormField<GenderOption>>(
        find.byType(DropdownButtonFormField<GenderOption>));
    expect(
        tester
            .widget<DropdownButton<GenderOption>>(
                find.byType(DropdownButton<GenderOption>))
            .items,
        isEmpty);
    expect(find.text('Unable to load genders. Retry'), findsOneWidget);
    expect(find.byKey(const ValueKey('register-genderValue')), findsNothing);
    expect(find.byKey(const ValueKey('register-genderLabel')), findsNothing);
  });

  testWidgets(
      'Leaving a form while lookup is pending does not update disposed state',
      (tester) async {
    final response = Completer<http.Response>();
    final api = KanMasterApi(client: MockClient((_) => response.future));
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: KanRegistrationFields(masterApi: api)))));
    await tester.pumpWidget(const SizedBox());
    response.complete(http.Response('[{"value":"1","label":"Male"}]', 200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
