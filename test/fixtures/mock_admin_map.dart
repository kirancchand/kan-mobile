import 'package:mv_app/data/models/admin_hierarchy.dart';
import 'package:mv_app/data/models/map_location.dart';
import 'mock_admin_hierarchy.dart';

// Synthetic coordinates for demonstrating maps. These are not surveyed locations
// or official state/district boundaries and must be replaced by backend data.
final _centres = <String, (double, double)>{
  'loc_1': (18.0, 78.0),
  'loc_2': (16.0, 80.0),
  'loc_3': (13.0, 77.0),
  'loc_4': (11.0, 78.0),
  'loc_5': (19.0, 75.0),
};

List<MapLocation> _box(double lat, double lon, double radius) => [
      MapLocation(latitude: lat - radius, longitude: lon - radius),
      MapLocation(latitude: lat - radius, longitude: lon + radius),
      MapLocation(latitude: lat + radius, longitude: lon + radius),
      MapLocation(latitude: lat + radius, longitude: lon - radius),
    ];

final Map<String, List<MapLocation>> mockAdminBoundaries = {
  'main': _box(15, 78, 6),
  for (final branch
      in mockAdminAccounts.where((a) => a.level == AdminLevel.branch))
    ..._branchBoundaries(branch),
};

Map<String, List<MapLocation>> _branchBoundaries(AdminAccount branch) {
  final centre = _centres[branch.locationId]!;
  final result = <String, List<MapLocation>>{};
  var node = branch;
  while (node.level != AdminLevel.main) {
    final radius = switch (node.level) {
      AdminLevel.branch => 0.02,
      AdminLevel.area => 0.06,
      AdminLevel.region => 0.15,
      AdminLevel.district => 0.3,
      _ => 0.7,
    };
    result[node.id] = _box(centre.$1, centre.$2, radius);
    node = mockAdminAccounts.firstWhere((a) => a.id == node.parentId);
  }
  return result;
}

final Map<String, MapLocation> mockAdminRecordLocations = {
  're_2': MapLocation(latitude: 18.004, longitude: 78.005),
  're_4': MapLocation(latitude: 17.993, longitude: 78.002),
  're_6': MapLocation(latitude: 16.006, longitude: 80.005),
  're_5': MapLocation(latitude: 15.995, longitude: 80.003),
  're_7': MapLocation(latitude: 13.002, longitude: 77.006),
  'shop_1': MapLocation(latitude: 18.001, longitude: 78.001),
  'shop_2': MapLocation(latitude: 18.008, longitude: 77.998),
  'shop_3': MapLocation(latitude: 16.002, longitude: 79.998),
  'shop_4': MapLocation(latitude: 17.996, longitude: 77.994),
  'shop_5': MapLocation(latitude: 11.002, longitude: 78.003),
  'shop_6': MapLocation(latitude: 19.002, longitude: 75.003),
  'shop_7': MapLocation(latitude: 12.995, longitude: 76.995),
};
