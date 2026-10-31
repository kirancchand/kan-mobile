import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/core/widgets/location_map.dart';
import 'package:mv_app/data/models/state_geometry.dart';
import 'package:mv_app/data/services/kan_master_api.dart';
import 'package:mv_app/features/admin/kerala_state_map.dart';
import 'package:mv_app/features/admin/kerala_district_map.dart';

const outer = [
  [76, 8],
  [77, 8],
  [77, 12],
  [76, 12],
  [76, 8]
];
const hole = [
  [76.2, 9],
  [76.4, 9],
  [76.4, 10],
  [76.2, 10],
  [76.2, 9]
];
final geometry = {
  'type': 'MultiPolygon',
  'coordinates': [
    [outer, hole],
    [outer]
  ]
};
String response() => jsonEncode([
      {
        'state': 'Other',
        'geometry': {
          'type': 'Point',
          'coordinates': [0, 0]
        }
      },
      {'state': 'Kerala', 'geometry': geometry},
    ]);

class _Tiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII='));
}

void main() {
  test('Kerala filtering preserves multipolygons, holes and coordinate order',
      () {
    final state = StateGeometry.forState(jsonDecode(response()), 'Kerala');
    expect(state.polygons, hasLength(2));
    expect(state.polygons.first.holes, hasLength(1));
    expect(state.polygons.first.outer.first.latitude, 8);
    expect(state.polygons.first.outer.first.longitude, 76);
    final encoded = StateGeometry.forState({
      'data': [
        {'name': 'KERALA', 'geometry': jsonEncode(geometry)}
      ]
    }, 'Kerala');
    expect(encoded.polygons, hasLength(2));
    final feature = StateGeometry.forState({
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {'ST_NM': 'Kerala'},
          'geometry': {
            'type': 'Polygon',
            'coordinates': [outer]
          }
        }
      ]
    }, 'Kerala');
    expect(feature.polygons, hasLength(1));
  });

  test(
      'Missing and malformed Kerala geometry fail without inventing boundaries',
      () {
    expect(() => StateGeometry.forState([], 'Kerala'), throwsFormatException);
    expect(
        () => StateGeometry.forState([
              {
                'state': 'Kerala',
                'geometry': {
                  'type': 'Polygon',
                  'coordinates': [
                    [
                      [76, 8],
                      [77, 8],
                      [77, 9]
                    ]
                  ]
                }
              }
            ], 'Kerala'),
        throwsFormatException);
  });

  test(
      'State geometry request uses GET, shared kan_url and the login bearer token',
      () async {
    late http.Request sent;
    final api = KanMasterApi(
        baseUrl: 'http://localhost:8070',
        client: MockClient((request) async {
          sent = request;
          return http.Response(response(), 200);
        }));
    addTearDown(api.dispose);
    final result = await api.getStateGeometry(accessToken: 'test-token');
    expect(sent.method, 'GET');
    expect(sent.url.toString(), 'http://localhost:8070/master/state/getAllGeo');
    expect(sent.headers['Authorization'], 'Bearer test-token');
    expect(sent.body, isEmpty);
    expect(result.name, 'Kerala');
    await expectLater(api.getStateGeometry(accessToken: ''), throwsStateError);
  });

  testWidgets(
      'Kerala map handles auth errors, retries and renders polygon holes',
      (tester) async {
    var calls = 0;
    final api = KanMasterApi(
        client: MockClient((_) async => ++calls == 1
            ? http.Response('', 401)
            : http.Response(response(), 200)));
    addTearDown(api.dispose);
    Widget app(String? token) => MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: KeralaStateMap(
                    accessToken: token,
                    pins: const [],
                    api: api,
                    tileProvider: _Tiles()))));
    await tester.pumpWidget(app(null));
    expect(find.textContaining('require API login'), findsOneWidget);
    expect(calls, 0);
    await tester.pumpWidget(app('test-token'));
    await tester.pumpAndSettle();
    expect(find.textContaining('authorised API login'), findsOneWidget);
    await tester.tap(find.text('Retry state boundary'));
    await tester.pumpAndSettle();
    final map = tester.widget<LocationMap>(find.byType(LocationMap));
    expect(map.boundaries, hasLength(2));
    expect(map.boundaries.first.holes, hasLength(1));
    final polygons = tester.widget<PolygonLayer<MapBoundary>>(
        find.byType(PolygonLayer<MapBoundary>));
    expect(polygons.polygons.first.holePointsList, hasLength(1));
    await tester.pumpWidget(app(null));
    await tester.pumpAndSettle();
    expect(find.byType(LocationMap), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('District geometry request filters Kerala and preserves district layers',
      () async {
    late http.Request sent;
    final api = KanMasterApi(client: MockClient((request) async {
      sent = request;
      return http.Response(
          jsonEncode({
            'data': [
              {
                'state': 'Kerala',
                'district': 'Ernakulam',
                'geometry': {
                  'type': 'Polygon',
                  'coordinates': [outer]
                }
              },
              {
                'state': 'Kerala',
                'district': 'Kollam',
                'geometry': {
                  'type': 'MultiPolygon',
                  'coordinates': [
                    [outer]
                  ]
                }
              },
              {
                'state': 'Other',
                'district': 'Ignored',
                'geometry': {
                  'type': 'Polygon',
                  'coordinates': [outer]
                }
              },
            ],
          }),
          200);
    }));
    addTearDown(api.dispose);
    final districts =
        await api.getDistrictGeometry(accessToken: 'district-token');
    expect(sent.method, 'GET');
    expect(
        sent.url.toString(), 'http://localhost:8070/master/district/getAllGeo');
    expect(sent.headers['Authorization'], 'Bearer district-token');
    expect(districts.keys, containsAll(<String>['Ernakulam', 'Kollam']));
    expect(districts.keys, isNot(contains('Ignored')));
    expect(districts['Kollam']!.polygons, hasLength(1));
  });

  testWidgets(
      'Real state maps fetch district geometry by state ID and reload on state changes',
      (tester) async {
    final paths = <String>[];
    var authorised = false;
    final api = KanMasterApi(
        baseUrl: 'https://example.test/kan',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], 'Bearer state-token');
          paths.add(request.url.path);
          if (!authorised) return http.Response('', 403);
          return http.Response(
              jsonEncode({
                'data': [
                  {'district': 'District A', 'geometry': geometry},
                  {'district': 'District B', 'geometry': jsonEncode(geometry)},
                ]
              }),
              200);
        }));
    addTearDown(api.dispose);
    Widget app(int stateId) => MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(
          child: KeralaDistrictMap(
              accessToken: 'state-token',
              stateId: stateId,
              stateName: 'Tamil Nadu',
              pins: const [],
              api: api,
              tileProvider: _Tiles()),
        )));
    await tester.pumpWidget(app(7));
    await tester.pumpAndSettle();
    expect(find.textContaining('authorised API login'), findsOneWidget);
    authorised = true;
    await tester.tap(find.text('Retry district boundaries'));
    await tester.pumpAndSettle();
    final map = tester.widget<LocationMap>(find.byType(LocationMap));
    expect(map.boundaries.map((b) => b.label).toSet(),
        {'District A', 'District B'});
    expect(map.boundaries.first.holes, hasLength(1));
    expect(
        find.text('Tamil Nadu districts • 2 geometry layers'), findsOneWidget);
    await tester.pumpWidget(app(42));
    await tester.pumpAndSettle();
    expect(paths, [
      '/kan/master/district/getAllGeoByState/7',
      '/kan/master/district/getAllGeoByState/7',
      '/kan/master/district/getAllGeoByState/42',
    ]);
    expect(tester.takeException(), isNull);
  });

  test('District subadmin lookup uses the authenticated Kerala state endpoint',
      () async {
    late http.Request sent;
    final api = KanMasterApi(client: MockClient((request) async {
      sent = request;
      return http.Response(
          jsonEncode({
            'data': [
              {'value': '101', 'label': 'Ernakulam'},
              {'id': 102, 'name': 'Kollam'},
            ]
          }),
          200);
    }));
    addTearDown(api.dispose);
    final districts =
        await api.getDistrictsByState(accessToken: 'state-token', stateId: 1);
    expect(sent.method, 'GET');
    expect(sent.url.toString(),
        'http://localhost:8070/master/district/getByState/1');
    expect(sent.headers['Authorization'], 'Bearer state-token');
    expect(districts.map((district) => district.name), ['Ernakulam', 'Kollam']);
    expect(districts.map((district) => district.id), ['101', '102']);
  });

  test('District lookup accepts nested API wrappers and snake-case fields',
      () async {
    final api = KanMasterApi(
        client: MockClient((_) async => http.Response(
            jsonEncode({
              'result': {
                'content': [
                  {'district_id': 201, 'district_name': 'Thiruvananthapuram'},
                ]
              }
            }),
            200)));
    addTearDown(api.dispose);
    final districts =
        await api.getDistrictsByState(accessToken: 'state-token', stateId: 1);
    expect(districts.single.id, '201');
    expect(districts.single.name, 'Thiruvananthapuram');
  });

  test('District lookup accepts the production district response shape',
      () async {
    final api = KanMasterApi(
        client: MockClient((_) async => http.Response(
            jsonEncode({
              'message': 'Listed Successfully!!',
              'status': 200,
              'data': [
                {
                  'district_id': 1,
                  'district': 'Thiruvananthapuram',
                  'f_state_id': 1,
                },
              ],
            }),
            200)));
    addTearDown(api.dispose);
    final districts =
        await api.getDistrictsByState(accessToken: 'state-token', stateId: 1);
    expect(districts.single.id, '1');
    expect(districts.single.name, 'Thiruvananthapuram');
  });
}
