import 'package:mv_app/data/models/admin_hierarchy.dart';
import 'mock_locations.dart';

/// Demo reporting assignments. Regions and areas are sample territories;
/// state, district and branch names come from the existing locations.
final List<AdminAccount> mockAdminAccounts = _buildAccounts();

List<AdminAccount> _buildAccounts() {
  final accounts = <String, AdminAccount>{
    'main': const AdminAccount(
        isDemo: true,
        id: 'main',
        name: 'Main Administrator',
        level: AdminLevel.main,
        territory: 'All locations'),
  };
  for (final location in mockLocations) {
    final stateId = 'state_${location.state}';
    final districtId = '${stateId}_${location.district}';
    final regionId = '${districtId}_region';
    final areaId = '${regionId}_${location.id}_area';
    final nodes = [
      AdminAccount(
          isDemo: true,
          id: stateId,
          name: '${location.state} Administrator',
          level: AdminLevel.state,
          territory: location.state,
          parentId: 'main'),
      AdminAccount(
          isDemo: true,
          id: districtId,
          name: '${location.district} Administrator',
          level: AdminLevel.district,
          territory: location.district,
          parentId: stateId),
      AdminAccount(
          isDemo: true,
          id: regionId,
          name: '${location.district} Region Administrator',
          level: AdminLevel.region,
          territory: '${location.district} Region',
          parentId: districtId),
      AdminAccount(
          isDemo: true,
          id: areaId,
          name: '${location.name} Area Administrator',
          level: AdminLevel.area,
          territory: '${location.name} Area',
          parentId: regionId),
      AdminAccount(
          isDemo: true,
          id: 'branch_${location.id}',
          name: '${location.name} Branch Administrator',
          level: AdminLevel.branch,
          territory: location.name,
          parentId: areaId,
          locationId: location.id),
    ];
    for (final node in nodes) {
      accounts.putIfAbsent(node.id, () => node);
    }
  }
  accounts['state_Kerala'] = const AdminAccount(
    isDemo: true,
    id: 'state_Kerala',
    name: 'Kerala Administrator',
    level: AdminLevel.state,
    territory: 'Kerala',
    parentId: 'main',
  );
  return List.unmodifiable(accounts.values);
}

/// Explicit demo ownership for directory entries previously shown globally.
const mockShopBranches = {
  'shop_1': 'branch_loc_1',
  'shop_2': 'branch_loc_1',
  'shop_3': 'branch_loc_2',
  'shop_4': 'branch_loc_1',
  'shop_5': 'branch_loc_4',
  'shop_6': 'branch_loc_5',
  'shop_7': 'branch_loc_3',
};
