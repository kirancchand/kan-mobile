import 'package:provider/provider.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/widgets/location_map.dart';
import '../../data/models/state_geometry.dart';
import '../../data/services/kan_master_api.dart';

/// Authenticated district layers, scoped by state or selected district ID.
class KeralaDistrictMap extends StatefulWidget {
  const KeralaDistrictMap(
      {super.key,
      required this.accessToken,
      required this.pins,
      this.stateId,
      this.districtId,
      this.districtName,
      this.showAreas = false,
      this.onAreasLoaded,
      this.stateName = 'Kerala',
      this.territoryActions = const {},
      this.childBoundaries = const [],
      this.tileProvider,
      this.api});
  final int? stateId;
  final String? districtId;
  final String? districtName;
  final bool showAreas;
  final ValueChanged<List<String>>? onAreasLoaded;
  final String stateName;
  final String? accessToken;
  final List<MapPin> pins;
  final TileProvider? tileProvider;
  final Map<String, VoidCallback> territoryActions;
  final List<MapBoundary> childBoundaries;
  final KanMasterApi? api;
  @override
  State<KeralaDistrictMap> createState() => _KeralaDistrictMapState();
}

class _KeralaDistrictMapState extends State<KeralaDistrictMap> {
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
        : widget.showAreas && widget.districtId != null
            ? _api.getAreaGeometryByDistrictId(
                accessToken: widget.accessToken!,
                districtId: widget.districtId!)
            : _api.getDistrictGeometry(
                accessToken: widget.accessToken!,
                stateId: widget.stateId,
                districtId: widget.districtId,
                stateName: widget.stateName);
  }

  @override
  void didUpdateWidget(covariant KeralaDistrictMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accessToken != widget.accessToken ||
        oldWidget.stateId != widget.stateId ||
        oldWidget.districtId != widget.districtId ||
        oldWidget.showAreas != widget.showAreas ||
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
    final layerName = widget.showAreas ? 'areas' : 'boundaries';
    final territory = widget.districtName ?? '${widget.stateName} districts';
    if (_geometry == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
            '$territory boundaries require API login. Sign in with backend credentials first. '),
      );
    }
    return FutureBuilder<Map<String, StateGeometry>>(
      future: _geometry,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const CircularProgressIndicator(),
              Text('Loading $territory boundaries…')
            ]),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          return Column(children: [
            Text(error is StateError
                ? error.message.toString()
                : 'Could not load valid $territory geometry.'),
            TextButton(
                onPressed: () => setState(_load),
                child: const Text('Retry district boundaries')),
          ]);
        }
        final districts = snapshot.data!;
        if (widget.showAreas && widget.onAreasLoaded != null) {
          final names = List<String>.unmodifiable(districts.keys);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onAreasLoaded!(names);
          });
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('$territory • ${districts.length} $layerName'),
              LocationMap(
                tileProvider: widget.tileProvider,
                pins: widget.pins,
                boundaries: [
                  for (final district in districts.values)
                    for (final polygon in district.polygons)
                      MapBoundary(
                          points: polygon.outer,
                          holes: polygon.holes,
                          label: district.name,
                          onTap: widget.territoryActions[
                              district.name.trim().toLowerCase()],
                          color:
                              widget.showAreas ? Colors.teal : Colors.indigo),
                  ...widget.childBoundaries,
                ],
              ),
              Text(widget.showAreas
                  ? 'Teal polygons are area boundaries returned by the authenticated API.'
                  : 'Indigo polygons are district boundaries returned by the authenticated API.'),
            ]);
      },
    );
  }
}
