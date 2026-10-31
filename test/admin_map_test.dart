import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mv_app/core/widgets/location_map.dart';
import 'package:mv_app/data/models/admin_hierarchy.dart';
import 'package:mv_app/data/models/map_location.dart';
import 'package:mv_app/data/repositories/admin_repository.dart';

class _Tiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII='));
}

void main() {
  test('Assigned territories have no fabricated boundary or record pins', () {
    final repo = AdminRepository(assignedAccounts: const [
      AdminAccount(
          id: 'main',
          name: 'Admin',
          level: AdminLevel.main,
          territory: 'Assigned territory'),
    ]);
    expect(repo.getBoundary(viewerId: 'main', targetId: 'main'), isEmpty);
    expect(repo.getUsers(viewerId: 'main', targetId: 'main'), isEmpty);
    expect(repo.getOverview(viewerId: 'main', targetId: 'main').businesses,
        isEmpty);
    expect(() => repo.getBoundary(viewerId: 'main', targetId: 'unknown'),
        throwsArgumentError);
  });
  testWidgets('Polygon holes and outside taps preserve coordinate picking',
      (tester) async {
    List<MapLocation> ring(double low, double high) => [
          MapLocation(latitude: low, longitude: low),
          MapLocation(latitude: low, longitude: high),
          MapLocation(latitude: high, longitude: high),
          MapLocation(latitude: high, longitude: low),
        ];
    var boundaryTaps = 0;
    var coordinateTaps = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LocationMap(
      pins: const [],
      tileProvider: _Tiles(),
      onTap: (_) => coordinateTaps++,
      boundaries: [
        MapBoundary(
            points: ring(0, 10),
            holes: [ring(4, 6)],
            label: 'Territory',
            color: Colors.teal,
            onTap: () => boundaryTaps++)
      ],
    ))));
    await tester.pumpAndSettle();
    for (final point in [
      const LatLng(2, 2),
      const LatLng(5, 5),
      const LatLng(11, 5)
    ]) {
      final camera =
          MapCamera.of(tester.element(find.byType(PolygonLayer<MapBoundary>)));
      await tester.tapAt(tester.getTopLeft(find.byType(FlutterMap)) +
          camera.latLngToScreenOffset(point));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
    }
    expect(boundaryTaps, 1);
    expect(coordinateTaps, 2);
  });
}
