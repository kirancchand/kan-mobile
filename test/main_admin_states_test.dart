import 'fixtures/mock_admin_hierarchy.dart';
import 'package:mv_app/data/models/admin_hierarchy.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/features/admin/admin_map_screen.dart';
import 'package:mv_app/features/admin/kerala_district_map.dart';
import 'package:mv_app/state/admin_state.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/core/widgets/location_map.dart';
import 'package:mv_app/data/repositories/admin_repository.dart';
import 'package:mv_app/data/services/kan_master_api.dart';
import 'package:mv_app/features/admin/kerala_state_map.dart';

const polygon = {
  'type': 'Polygon',
  'coordinates': [
    [
      [76, 8],
      [77, 8],
      [77, 12],
      [76, 8]
    ]
  ]
};

void main() {
  test('Main admin loads API states alongside removable dummy hierarchy',
      () async {
    var fail = false;
    final api = KanMasterApi(
        baseUrl: 'https://example.test/kan',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(),
              'https://example.test/kan/master/state/getAll');
          expect(request.headers['Authorization'], 'Bearer token');
          return fail
              ? http.Response('', 503)
              : http.Response(
                  jsonEncode({
                    'data': [
                      {'state_id': 42, 'state': 'Kerala'},
                      {'value': '7', 'label': 'Tamil Nadu'},
                    ]
                  }),
                  200);
        }));
    addTearDown(api.dispose);
    final repo =
        AdminRepository(assignedAccounts: mockAdminAccounts, masterApi: api);
    final dummyIds = repo.accounts.map((a) => a.id).toSet();
    await repo.loadStatesForMain(mainAccountId: 'main', accessToken: 'token');
    await repo.loadStatesForMain(mainAccountId: 'main', accessToken: 'token');
    final main = repo.getOverview(viewerId: 'main', targetId: 'main');
    expect(main.children.length, 8);
    expect(repo.accounts.map((a) => a.id), containsAll(dummyIds));
    expect(repo.accountById('state_Kerala').isDemo, isTrue);
    final live = repo.accountById('state_api_42');
    expect(live.isDemo, isFalse);
    expect(live.masterStateId, 42);
    expect(repo.canView('main', live.id), isTrue);
    expect(repo.canView('state_Kerala', live.id), isFalse);
    fail = true;
    await expectLater(
        repo.loadStatesForMain(mainAccountId: 'main', accessToken: 'token'),
        throwsStateError);
    expect(repo.accountById(live.id), same(live));
  });

  test(
      'Every state loads its own real districts without replacing dummy entries',
      () async {
    final requested = <String>[];
    var emptyDistricts = false;
    final api = KanMasterApi(
        baseUrl: 'https://example.test/kan',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], 'Bearer token');
          requested.add(request.url.path);
          if (request.url.path.endsWith('/master/state/getAll')) {
            return http.Response(
                jsonEncode({
                  'data': [
                    {'state_id': 42, 'state': 'Kerala'},
                    {'state_id': 7, 'state': 'Tamil Nadu'},
                  ]
                }),
                200);
          }
          expect(request.url.path,
              matches(r'/kan/master/district/getByState/(7|42)$'));
          return http.Response(
              jsonEncode({
                'data': emptyDistricts
                    ? []
                    : [
                        {'district_id': 101, 'district': 'District A'},
                        {'district_id': 102, 'district': 'District B'},
                      ]
              }),
              200);
        }));
    addTearDown(api.dispose);
    final repo =
        AdminRepository(assignedAccounts: mockAdminAccounts, masterApi: api);
    await repo.loadStatesForMain(mainAccountId: 'main', accessToken: 'token');
    for (final id in [7, 42]) {
      await repo.loadDistrictsForState(
          stateAccountId: 'state_api_$id', accessToken: 'token');
      await repo.loadDistrictsForState(
          stateAccountId: 'state_api_$id', accessToken: 'token');
      final children = repo
          .getOverview(viewerId: 'main', targetId: 'state_api_$id')
          .children;
      expect(children.map((a) => a.territory), ['District A', 'District B']);
      expect(children.every((a) => !a.isDemo), isTrue);
      expect(children.map((a) => a.masterDistrictId), ['101', '102']);
      expect(repo.canView('state_api_${id == 7 ? 42 : 7}', children.first.id),
          isFalse);
    }
    expect(requested.where((p) => p.endsWith('/getAll')), hasLength(1));
    await repo.loadDistrictsForState(
        stateAccountId: 'state_Kerala', accessToken: 'token');
    expect(requested.last, '/kan/master/district/getByState/42');
    expect(repo.accountById('state_Kerala').isDemo, isTrue);
    emptyDistricts = true;
    await repo.loadDistrictsForState(
        stateAccountId: 'state_api_7', accessToken: 'token');
    expect(repo.getOverview(viewerId: 'main', targetId: 'state_api_7').children,
        isEmpty);
    expect(
        repo.getOverview(viewerId: 'main', targetId: 'state_api_42').children,
        hasLength(2));
    await expectLater(
        repo.loadDistrictsForState(
            stateAccountId: 'main', accessToken: 'token'),
        throwsStateError);
  });

  test('District areas load from getByDistrict and branches from getByArea',
      () async {
    final api = KanMasterApi(
        baseUrl: 'https://example.test/kan',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          final path = request.url.path;
          if (path.endsWith('/master/state/getAll')) {
            return http.Response(
                jsonEncode([
                  {'state_id': 42, 'state': 'Kerala'}
                ]),
                200);
          }
          if (path.endsWith('/master/district/getByState/42')) {
            return http.Response(
                jsonEncode([
                  {'district_id': 1, 'district': 'Thiruvananthapuram'}
                ]),
                200);
          }
          if (path.endsWith('/master/branch/getByArea/3')) {
            return http.Response(
                jsonEncode({
                  'message': 'Listed Successfully!!',
                  'status': 200,
                  'data': [
                    {'branch_id': 19, 'branch': 'pavachakuzhi', 'f_area_id': 3},
                    {'branch_id': 20, 'branch': 'peyad', 'f_area_id': 3},
                  ]
                }),
                200);
          }
          expect(path, '/kan/master/area/getByDistrict/1');
          return http.Response(
              jsonEncode([
                {'area_id': 3, 'area_name': 'Nanniyode'},
                {'area_id': 4, 'area_name': 'Palode'},
              ]),
              200);
        }));
    addTearDown(api.dispose);
    final repo =
        AdminRepository(assignedAccounts: mockAdminAccounts, masterApi: api);
    await repo.loadStatesForMain(mainAccountId: 'main', accessToken: 'token');
    await repo.loadDistrictsForState(
        stateAccountId: 'state_api_42', accessToken: 'token');
    const districtId = 'state_api_42_district_api_1';
    await repo.loadAreasForDistrict(
        districtAccountId: districtId, accessToken: 'token');
    await repo.loadAreasForDistrict(
        districtAccountId: districtId, accessToken: 'token');
    final children =
        repo.getOverview(viewerId: 'main', targetId: districtId).children;
    expect(children.map((a) => a.territory), ['Nanniyode', 'Palode']);
    expect(children.every((a) => a.level == AdminLevel.area), isTrue);
    expect(repo.canView(districtId, children.first.id), isTrue);
    await repo.loadDistrictsForState(
        stateAccountId: 'state_api_42', accessToken: 'token');
    expect(repo.getOverview(viewerId: 'main', targetId: districtId).children,
        hasLength(2));
    await expectLater(
        repo.loadAreasForDistrict(
            districtAccountId: 'state_api_42', accessToken: 'token'),
        throwsStateError);

    final area = children.first;
    expect(area.masterAreaId, '3');
    await repo.loadBranchesForArea(
        areaAccountId: area.id, accessToken: 'token');
    await repo.loadBranchesForArea(
        areaAccountId: area.id, accessToken: 'token');
    final branches =
        repo.getOverview(viewerId: 'main', targetId: area.id).children;
    expect(branches.map((a) => a.territory), ['pavachakuzhi', 'peyad']);
    expect(branches.map((a) => a.id),
        ['${area.id}_branch_api_19', '${area.id}_branch_api_20']);
    expect(branches.every((a) => a.level == AdminLevel.branch), isTrue);
    expect(branches.map((a) => a.masterBranchId), ['19', '20']);
    expect(repo.canView(districtId, branches.first.id), isTrue);
    await expectLater(
        repo.loadBranchesForArea(
            areaAccountId: districtId, accessToken: 'token'),
        throwsStateError);
  });

  test('State list handles empty data and rejects unauthenticated requests',
      () async {
    var calls = 0;
    final api = KanMasterApi(client: MockClient((_) async {
      calls++;
      return http.Response('{"data": []}', 200);
    }));
    addTearDown(api.dispose);
    await expectLater(api.getStates(accessToken: ''), throwsStateError);
    expect(calls, 0);
    expect(await api.getStates(accessToken: 'token'), isEmpty);
  });

  testWidgets(
      'Main admin map requests all state geometry and renders each state',
      (tester) async {
    String? tappedState;
    final api = KanMasterApi(client: MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/master/state/getAllGeo');
      expect(request.headers['Authorization'], 'Bearer token');
      return http.Response(
          jsonEncode({
            'data': [
              {'state': 'Kerala', 'geometry': polygon},
              {'state': 'Tamil Nadu', 'geometry': jsonEncode(polygon)},
            ]
          }),
          200);
    }));
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: KeralaStateMap(
          allStates: true,
          accessToken: 'token',
          pins: const [],
          api: api,
          territoryActions: {'tamil nadu': () => tappedState = 'Tamil Nadu'}),
    ))));
    await tester.pumpAndSettle();
    final map = tester.widget<LocationMap>(find.byType(LocationMap));
    expect(map.boundaries.map((b) => b.label), ['Kerala', 'Tamil Nadu']);
    expect(find.text('States • 2 boundary layers'), findsOneWidget);
    final camera =
        MapCamera.of(tester.element(find.byType(PolygonLayer<MapBoundary>)));
    await tester.tapAt(tester.getTopLeft(find.byType(FlutterMap)) +
        camera.latLngToScreenOffset(const LatLng(9, 76.5)));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(tappedState, 'Tamil Nadu');
    expect(tester.takeException(), isNull);
  });

  testWidgets('District maps fetch selected ID and reload when it changes',
      (tester) async {
    final paths = <String>[];
    final tappedDistricts = <String>[];
    final api = KanMasterApi(
        baseUrl: 'https://example.test/kan',
        client: MockClient((request) async {
          paths.add(request.url.path);
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], 'Bearer token');
          final id = request.url.pathSegments.last;
          return http.Response(
              jsonEncode({
                'data': {
                  'district_id': id,
                  'district': 'District $id',
                  'state': 'Tamil Nadu',
                  'geometry': polygon,
                }
              }),
              200);
        }));
    addTearDown(api.dispose);
    Widget app(String districtId) => MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: KeralaDistrictMap(
            api: api,
            accessToken: 'token',
            districtId: districtId,
            districtName: 'District $districtId',
            territoryActions: {
              'district $districtId': () => tappedDistricts.add(districtId)
            },
            stateId: 7,
            stateName: 'Tamil Nadu',
            pins: const [],
          ))),
        );
    for (final id in ['101', '102']) {
      await tester.pumpWidget(app(id));
      await tester.pumpAndSettle();
      final map = tester.widget<LocationMap>(find.byType(LocationMap));
      expect(map.boundaries.map((b) => b.label), ['District $id']);
      expect(find.text('District $id • 1 geometry layers'), findsOneWidget);
      final camera =
          MapCamera.of(tester.element(find.byType(PolygonLayer<MapBoundary>)));
      await tester.tapAt(tester.getTopLeft(find.byType(FlutterMap)) +
          camera.latLngToScreenOffset(const LatLng(9, 76.5)));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
    }
    expect(tappedDistricts, ['101', '102']);
    expect(paths, [
      '/kan/master/district/getDistrictGeoById/101',
      '/kan/master/district/getDistrictGeoById/102',
    ]);
    expect(tester.takeException(), isNull);
  });

  for (final stateName in ['Kerala', 'Tamil Nadu']) {
    testWidgets(
        'Clicking a $stateName district admin selects its API district map',
        (tester) async {
      final api = KanMasterApi(client: MockClient((request) async {
        if (request.url.path.endsWith('/state/getAll')) {
          return http.Response(
              jsonEncode([
                {'state_id': 7, 'state': stateName}
              ]),
              200);
        }
        return http.Response(
            '[{"district_id":101,"district":"District A"}]', 200);
      }));
      addTearDown(api.dispose);
      final repo =
          AdminRepository(assignedAccounts: mockAdminAccounts, masterApi: api);
      await repo.loadStatesForMain(mainAccountId: 'main', accessToken: 'token');
      await repo.loadDistrictsForState(
          stateAccountId: 'state_api_7', accessToken: 'token');
      final session = AdminState()..login(repo.accountById('main'));
      addTearDown(session.dispose);
      await tester.pumpWidget(MultiProvider(
          providers: [
            Provider<AdminRepository>.value(value: repo),
            ChangeNotifierProvider<AdminState>.value(value: session),
          ],
          child: const MaterialApp(
              home: AdminMapScreen(targetId: 'state_api_7'))));
      final district = find
          .byKey(const ValueKey('map-hierarchy-state_api_7_district_api_101'));
      await tester.scrollUntilVisible(district, 200);
      await tester.tap(district);
      await tester.pumpAndSettle();
      final map =
          tester.widget<KeralaDistrictMap>(find.byType(KeralaDistrictMap));
      expect(map.districtId, '101');
      expect(map.districtName, 'District A');
      expect(map.stateName, stateName);
      expect(tester.takeException(), isNull);
    });
  }
}
