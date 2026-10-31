import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/map_location.dart';

class MapPin {
  const MapPin(this.point, this.label, this.color,
      {this.onTap, this.icon = Icons.location_pin});
  final VoidCallback? onTap;
  final IconData icon;
  final MapLocation point;
  final String label;
  final Color color;
}

class MapBoundary {
  const MapBoundary(
      {required this.points,
      required this.label,
      required this.color,
      this.holes = const [],
      this.onTap});
  final VoidCallback? onTap;
  final List<List<MapLocation>> holes;
  final List<MapLocation> points;
  final String label;
  final Color color;
}

class LocationMap extends StatefulWidget {
  const LocationMap(
      {super.key,
      required this.pins,
      this.onTap,
      this.tileProvider,
      this.boundaries = const []});
  final List<MapBoundary> boundaries;
  final List<MapPin> pins;
  final ValueChanged<MapLocation>? onTap;
  final TileProvider? tileProvider;
  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  final LayerHitNotifier<MapBoundary> _boundaryHits = ValueNotifier(null);

  @override
  void dispose() {
    _boundaryHits.dispose();
    super.dispose();
  }

  bool _tileError = false;
  int _tileRevision = 0;
  void _failed() {
    if (_tileError) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_tileError) setState(() => _tileError = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final points = [
      ...widget.pins
          .map((pin) => LatLng(pin.point.latitude, pin.point.longitude)),
      for (final boundary in widget.boundaries)
        ...boundary.points
            .map((point) => LatLng(point.latitude, point.longitude)),
    ];
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
          height: 300,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                key: ValueKey(
                    '${points.map((p) => '${p.latitude},${p.longitude}').join(';')}:$_tileRevision'),
                options: MapOptions(
                  initialCenter: points.isEmpty
                      ? const LatLng(20.5937, 78.9629)
                      : points.first,
                  initialZoom: points.isEmpty ? 4 : 15,
                  initialCameraFit: points.length > 1
                      ? CameraFit.bounds(
                          bounds: LatLngBounds.fromPoints(points),
                          padding: const EdgeInsets.all(44),
                          maxZoom: 16)
                      : null,
                  onTap: widget.onTap == null &&
                          !widget.boundaries
                              .any((boundary) => boundary.onTap != null)
                      ? null
                      : (_, point) {
                          final hits = _boundaryHits.value?.hitValues;
                          if (hits != null && hits.isNotEmpty) {
                            hits.first.onTap?.call();
                            return;
                          }
                          widget.onTap?.call(MapLocation(
                              latitude: point.latitude,
                              longitude: point.longitude));
                        },
                ),
                children: [
                  TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.village.mv_app',
                      tileProvider: widget.tileProvider,
                      errorTileCallback: (_, __, ___) => _failed()),
                  PolygonLayer<
                      MapBoundary>(hitNotifier: _boundaryHits, polygons: [
                    for (final boundary in widget.boundaries)
                      if (boundary.points.length >= 3)
                        Polygon<MapBoundary>(
                          hitValue: boundary.onTap == null ? null : boundary,
                          points: boundary.points
                              .map((p) => LatLng(p.latitude, p.longitude))
                              .toList(),
                          holePointsList: boundary.holes
                              .map((ring) => ring
                                  .map((p) => LatLng(p.latitude, p.longitude))
                                  .toList())
                              .toList(),
                          color: boundary.color.withValues(alpha: 0.08),
                          borderColor: boundary.color,
                          borderStrokeWidth: 2,
                          label: boundary.label,
                          labelStyle: TextStyle(
                              color: boundary.color,
                              fontWeight: FontWeight.bold),
                        ),
                  ]),
                  MarkerLayer(markers: [
                    for (final pin in widget.pins)
                      Marker(
                        point: LatLng(pin.point.latitude, pin.point.longitude),
                        width: 44,
                        height: 44,
                        child: Tooltip(
                            message: pin.label,
                            child: Semantics(
                                label: pin.label,
                                child: pin.onTap == null
                                    ? Icon(pin.icon, color: pin.color, size: 42)
                                    : IconButton(
                                        onPressed: pin.onTap,
                                        icon: Icon(pin.icon, color: pin.color),
                                        iconSize: 32,
                                      ))),
                      )
                  ]),
                ],
              ))),
      Align(
          alignment: Alignment.centerRight,
          child: TextButton(
              onPressed: () async {
                try {
                  await launchUrl(
                      Uri.parse('https://www.openstreetmap.org/copyright'));
                } catch (_) {/* Attribution remains visible. */}
              },
              child: const Text('© OpenStreetMap contributors'))),
      if (_tileError) ...[
        const Text(
            'Map tiles could not load. Check your internet connection. Saved coordinates and distances remain available.'),
        TextButton(
            onPressed: () => setState(() {
                  _tileError = false;
                  _tileRevision++;
                }),
            child: const Text('Retry map')),
      ],
    ]);
  }
}
