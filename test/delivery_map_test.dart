import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mv_app/core/services/location_service.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/core/widgets/map_location_field.dart';
import 'package:mv_app/data/models/map_location.dart';

class OfflineTiles extends TileProvider {
  final image = MemoryImage(base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII='));
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      image;
}

class FakeLocation extends LocationService {
  FakeLocation({this.failure});
  LocationFailure? failure;
  int calls = 0;
  @override
  Future<LocationFix> current() async {
    calls++;
    if (failure != null) throw failure!;
    return LocationFix(MapLocation(latitude: 20, longitude: 73),
        accuracyMeters: 5, measuredAt: DateTime(2026));
  }
}

MapLocation pickup() =>
    MapLocation(latitude: 20.01, longitude: 73.01, address: 'Seller shop');
MapLocation dropoff() =>
    MapLocation(latitude: 20.02, longitude: 73.02, address: 'Buyer home');
void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('Distance calculations, coordinate validation and directions URLs', () {
    final origin = MapLocation(latitude: 0, longitude: 0);
    expect(origin.distanceKmTo(origin), 0);
    expect(origin.distanceKmTo(MapLocation(latitude: 0, longitude: 1)),
        closeTo(111.195, 0.01));
    expect(
        MapLocation(latitude: 0, longitude: 179)
            .distanceKmTo(MapLocation(latitude: 0, longitude: -179)),
        closeTo(222.39, 0.01));
    for (final lat in [double.nan, double.infinity, 91.0]) {
      expect(
          () => MapLocation(latitude: lat, longitude: 0), throwsArgumentError);
    }
    expect(() => MapLocation(latitude: 0, longitude: 181), throwsArgumentError);
    final uri =
        directionsUri(origin: origin, destination: dropoff(), via: pickup());
    expect(uri.queryParameters['origin'], origin.coordinates);
    expect(uri.queryParameters['destination'], dropoff().coordinates);
    expect(uri.queryParameters['waypoints'], pickup().coordinates);
  });
  testWidgets('Coordinate picker validates and returns the saved point',
      (tester) async {
    MapLocation? saved;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Builder(
            builder: (context) => Scaffold(
                    body: TextButton(
                  child: const Text('Choose point'),
                  onPressed: () async {
                    saved = await Navigator.of(context).push<MapLocation>(
                        MaterialPageRoute(
                            builder: (_) => MapLocationPicker(
                                title: 'Pickup',
                                tileProvider: OfflineTiles())));
                  },
                )))));
    await tester.tap(find.text('Choose point'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Latitude'), '91');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Longitude'), '73.01');
    await tester.ensureVisible(find.text('Save location'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save location'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a value between -90.0 and 90.0'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Latitude'), '20.01');
    await tester.ensureVisible(find.text('Save location'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save location'));
    await tester.pumpAndSettle();
    expect(saved!.latitude, 20.01);
    expect(saved!.longitude, 73.01);
  });
}
