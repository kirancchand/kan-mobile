import 'package:provider/provider.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/widgets/location_map.dart';
import '../../data/models/state_geometry.dart';
import '../../data/services/kan_master_api.dart';

/// Authenticated state geometry layers for the main admin or one state.
class KeralaStateMap extends StatefulWidget {
  const KeralaStateMap(
      {super.key,
      required this.accessToken,
      required this.pins,
      this.allStates = false,
      this.stateName = 'Kerala',
      this.territoryActions = const {},
      this.childBoundaries = const [],
      this.tileProvider,
      this.api});
  final bool allStates;
  final String stateName;
  final String? accessToken;
  final List<MapPin> pins;
  final TileProvider? tileProvider;
  final Map<String, VoidCallback> territoryActions;
  final List<MapBoundary> childBoundaries;
  final KanMasterApi? api;

  @override
  State<KeralaStateMap> createState() => _KeralaStateMapState();
}

class _KeralaStateMapState extends State<KeralaStateMap> {
  late final KanMasterApi _api;
  Future<Map<String, StateGeometry>>? _geometry;

  @override
  void initState() {
    super.initState();
    _api = widget.api ??
        KanMasterApi(authRepository: context.read<AuthRepository?>());
    _load();
  }

  void _load() {
    _geometry = widget.accessToken == null || widget.accessToken!.isEmpty
        ? null
        : widget.allStates
            ? _api.getAllStateGeometry(accessToken: widget.accessToken!)
            : _api
                .getStateGeometry(
                    accessToken: widget.accessToken!,
                    stateName: widget.stateName)
                .then((geometry) => {geometry.name: geometry});
  }

  @override
  void didUpdateWidget(covariant KeralaStateMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accessToken != widget.accessToken ||
        oldWidget.allStates != widget.allStates ||
        oldWidget.stateName != widget.stateName) {
      _load();
    }
  }

  @override
  void dispose() {
    if (widget.api == null) _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_geometry == null) {
      return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
              '${widget.allStates ? 'State' : widget.stateName} boundaries require API login. Sign in with your backend credentials on the main login screen. '));
    }
    return FutureBuilder<Map<String, StateGeometry>>(
        future: _geometry,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  const CircularProgressIndicator(),
                  Text(
                      'Loading ${widget.allStates ? 'state boundaries' : '${widget.stateName} boundary'}…'),
                ]));
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            return Column(children: [
              Text(error is StateError
                  ? error.message.toString()
                  : 'Could not load valid state geometry. Check the connection and state data.'),
              TextButton(
                  onPressed: () => setState(_load),
                  child: const Text('Retry state boundary')),
            ]);
          }
          final states = snapshot.data!;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.allStates
                    ? 'States • ${states.length} boundary layers'
                    : '${widget.stateName} boundary • State API geometry'),
                LocationMap(
                  tileProvider: widget.tileProvider,
                  pins: widget.pins,
                  boundaries: [
                    for (final geometry in states.values)
                      for (final polygon in geometry.polygons)
                        MapBoundary(
                            points: polygon.outer,
                            holes: polygon.holes,
                            label: geometry.name,
                            onTap: widget.territoryActions[
                                geometry.name.trim().toLowerCase()],
                            color: Colors.teal),
                    ...widget.childBoundaries,
                  ],
                ),
              ]);
        });
  }
}
