import 'dart:convert';
import 'map_location.dart';

class GeoPolygon {
  const GeoPolygon({required this.outer, this.holes = const []});
  final List<MapLocation> outer;
  final List<List<MapLocation>> holes;
}

/// State records containing GeoJSON in geometry (object or JSON string).
class StateGeometry {
  const StateGeometry({required this.name, required this.polygons});
  final String name;
  final List<GeoPolygon> polygons;

  static StateGeometry forState(Object? response, String stateName) {
    return allStates(response, stateName: stateName).values.single;
  }

  static Map<String, StateGeometry> allStates(Object? response,
      {String? stateName}) {
    Object? decoded(Object? value) =>
        value is String ? jsonDecode(value) : value;
    final root = decoded(response);
    final Object? rows = root is Map
        ? root['data'] ??
            (root['type'] == 'FeatureCollection' ? root['features'] : [root])
        : root;
    if (rows is! List) {
      throw const FormatException('Expected state geometry records');
    }
    final states = <String, List<GeoPolygon>>{};
    for (final row in rows) {
      if (row is! Map) continue;
      final properties =
          row['properties'] is Map ? row['properties'] as Map : const {};
      final name = row['state'] ??
          row['stateName'] ??
          row['state_name'] ??
          row['name'] ??
          row['label'] ??
          properties['state'] ??
          properties['STATE'] ??
          properties['ST_NM'] ??
          properties['name'];
      if (name is! String ||
          name.trim().isEmpty ||
          (stateName != null &&
              name.trim().toLowerCase() != stateName.toLowerCase())) {
        continue;
      }
      states
          .putIfAbsent(stateName ?? name.trim(), () => [])
          .addAll(_geometry(decoded(row['geometry'])));
    }
    if (states.isEmpty || states.values.every((polygons) => polygons.isEmpty)) {
      throw FormatException('No $stateName boundary geometry returned.');
    }
    return {
      for (final entry in states.entries)
        entry.key: StateGeometry(
            name: entry.key, polygons: List.unmodifiable(entry.value)),
    };
  }

  /// Parses district records belonging to [stateName], preserving each
  /// district as a separately labelled layer.
  static Map<String, StateGeometry> forDistricts(
      Object? response, String stateName) {
    Object? decoded(Object? value) =>
        value is String ? jsonDecode(value) : value;
    final root = decoded(response);
    final Object? records = root is Map
        ? root['data'] ??
            (root['type'] == 'FeatureCollection' ? root['features'] : [root])
        : root;
    final rows = records is Map ? [records] : records;
    if (rows is! List) {
      throw const FormatException('Expected district geometry records');
    }
    final result = <String, List<GeoPolygon>>{};
    for (final row in rows) {
      if (row is! Map) continue;
      final properties =
          row['properties'] is Map ? row['properties'] as Map : const {};
      final state = row['state'] ??
          row['stateName'] ??
          row['state_name'] ??
          properties['state'] ??
          properties['STATE'] ??
          properties['ST_NM'];
      if (state is String &&
          state.trim().isNotEmpty &&
          state.trim().toLowerCase() != stateName.toLowerCase()) {
        continue;
      }
      final district = row['district'] ??
          row['districtName'] ??
          row['district_name'] ??
          row['name'] ??
          row['label'] ??
          properties['district'] ??
          properties['DISTRICT'] ??
          properties['DT_NAME'] ??
          properties['name'];
      if (district is! String || district.trim().isEmpty) continue;
      result
          .putIfAbsent(district.trim(), () => [])
          .addAll(_geometry(decoded(row['geometry'])));
    }
    if (result.isEmpty) {
      throw FormatException('No $stateName district geometry returned.');
    }
    return {
      for (final entry in result.entries)
        entry.key: StateGeometry(
            name: entry.key, polygons: List.unmodifiable(entry.value)),
    };
  }

  /// Parses area geometry records returned for one district. Area services
  /// commonly return GeoJSON Features with the area name in their properties.
  static Map<String, StateGeometry> forAreas(Object? response) {
    Object? decoded(Object? value) =>
        value is String ? jsonDecode(value) : value;
    final root = decoded(response);
    final Object? records = root is Map
        ? root['data'] ??
            (root['type'] == 'FeatureCollection' ? root['features'] : [root])
        : root;
    final rows = records is Map ? [records] : records;
    if (rows is! List) {
      throw const FormatException('Expected area geometry records');
    }
    final result = <String, List<GeoPolygon>>{};
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row is! Map) continue;
      final properties =
          row['properties'] is Map ? row['properties'] as Map : const {};
      final rawName = row['area'] ??
          row['areaName'] ??
          row['area_name'] ??
          row['name'] ??
          row['label'] ??
          properties['area'] ??
          properties['AREA'] ??
          properties['area_name'] ??
          properties['name'] ??
          properties['NAME'];
      final name = rawName is String && rawName.trim().isNotEmpty
          ? rawName.trim()
          : 'Area ${i + 1}';
      final geometry = row['geometry'] ?? row;
      result.putIfAbsent(name, () => []).addAll(_geometry(decoded(geometry)));
    }
    if (result.isEmpty) {
      throw const FormatException('No area geometry returned.');
    }
    return {
      for (final entry in result.entries)
        entry.key: StateGeometry(
            name: entry.key, polygons: List.unmodifiable(entry.value)),
    };
  }

  /// Parses branch geometry records returned for an area.
  static Map<String, StateGeometry> forBranches(Object? response) {
    Object? decoded(Object? value) =>
        value is String ? jsonDecode(value) : value;
    final root = decoded(response);
    final Object? records = root is Map
        ? root['data'] ??
            root['result'] ??
            (root['type'] == 'FeatureCollection' ? root['features'] : [root])
        : root;
    final rows = records is Map ? [records] : records;
    if (rows is! List) {
      throw const FormatException('Expected branch geometry records');
    }
    final result = <String, List<GeoPolygon>>{};
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row is! Map) continue;
      final properties =
          row['properties'] is Map ? row['properties'] as Map : const {};
      final rawName = row['branch'] ??
          row['branchName'] ??
          row['branch_name'] ??
          row['branch_name_en'] ??
          row['name'] ??
          row['label'] ??
          properties['branch'] ??
          properties['branchName'] ??
          properties['branch_name'] ??
          properties['name'] ??
          properties['NAME'];
      final name = rawName is String && rawName.trim().isNotEmpty
          ? rawName.trim()
          : 'Branch ${i + 1}';
      final geometry = row['geometry'] ?? row;
      result.putIfAbsent(name, () => []).addAll(_geometry(decoded(geometry)));
    }
    if (result.isEmpty) {
      throw const FormatException('No branch geometry returned.');
    }
    return {
      for (final entry in result.entries)
        entry.key: StateGeometry(
            name: entry.key, polygons: List.unmodifiable(entry.value)),
    };
  }

  static List<GeoPolygon> _geometry(Object? json) {
    if (json is String) return _geometry(jsonDecode(json));
    if (json is! Map) throw const FormatException('Missing GeoJSON geometry');
    switch (json['type']) {
      case 'Polygon':
        return [_polygon(json['coordinates'])];
      case 'MultiPolygon':
        final coordinates = json['coordinates'];
        if (coordinates is! List || coordinates.isEmpty) {
          throw const FormatException('Invalid MultiPolygon');
        }
        return coordinates.map(_polygon).toList();
      case 'Feature':
        return _geometry(json['geometry']);
      case 'FeatureCollection':
      case 'GeometryCollection':
        final parts = json[
            json['type'] == 'FeatureCollection' ? 'features' : 'geometries'];
        if (parts is! List) {
          throw const FormatException('Invalid GeoJSON collection');
        }
        return parts.expand(_geometry).toList();
      default:
        throw const FormatException(
            'Expected Polygon or MultiPolygon geometry');
    }
  }

  static GeoPolygon _polygon(Object? coordinates) {
    if (coordinates is! List || coordinates.isEmpty) {
      throw const FormatException('Invalid polygon rings');
    }
    final rings = coordinates.map(_ring).toList();
    return GeoPolygon(outer: rings.first, holes: rings.skip(1).toList());
  }

  static List<MapLocation> _ring(Object? coordinates) {
    if (coordinates is! List || coordinates.length < 4) {
      throw const FormatException('Invalid polygon ring');
    }
    final points = coordinates.map((pair) {
      if (pair is! List ||
          pair.length < 2 ||
          pair[0] is! num ||
          pair[1] is! num) {
        throw const FormatException('Invalid GeoJSON coordinate');
      }
      // GeoJSON is longitude, latitude; map widgets use latitude, longitude.
      return MapLocation(
          latitude: (pair[1] as num).toDouble(),
          longitude: (pair[0] as num).toDouble());
    }).toList();
    if (points.first.latitude != points.last.latitude ||
        points.first.longitude != points.last.longitude) {
      throw const FormatException('Polygon ring must be closed');
    }
    return List.unmodifiable(points);
  }
}
