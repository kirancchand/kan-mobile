import 'map_location.dart';
import 'admin_models.dart';
import 'app_user.dart';

enum AdminLevel {
  main('Main Admin'),
  state('State Admin'),
  district('District Admin'),
  region('Region Admin'),
  area('Area Admin'),
  branch('Branch Admin');

  const AdminLevel(this.label);
  final String label;
}

class AdminAccount {
  const AdminAccount(
      {required this.id,
      required this.name,
      required this.level,
      required this.territory,
      this.masterStateId,
      this.masterDistrictId,
      this.masterAreaId,
      this.masterBranchId,
      this.isDemo = false,
      this.parentId,
      this.locationId});
  final String id;
  final String name;
  final AdminLevel level;
  final String territory;
  final int? masterStateId;
  final String? masterDistrictId;
  final String? masterAreaId;
  final String? masterBranchId;
  final bool isDemo;
  final String? parentId;
  final String? locationId;
}

class AdminStateOption {
  const AdminStateOption({required this.id, required this.name});
  final int id;
  final String name;
}

class AdminDistrictOption {
  const AdminDistrictOption({required this.id, required this.name});
  final String id;
  final String name;
}

class AdminResident {
  const AdminResident({
    required this.id,
    required this.name,
    required this.branch,
    this.phone,
    this.mapLocation,
    this.isDemoLocation = false,
    this.userType = UserType.resident,
  });

  final String id;
  final String name;
  final AdminAccount branch;
  final String? phone;
  final UserType userType;
  final MapLocation? mapLocation;
  final bool isDemoLocation;
}

class AdminBusiness {
  const AdminBusiness(
      {required this.name,
      required this.category,
      required this.branch,
      this.isOrganisation = false,
      this.address,
      this.phone,
      this.mapLocation,
      this.isDemoLocation = false});
  final String name;
  final String category;
  final AdminAccount branch;
  final bool isOrganisation;
  final String? address;
  final MapLocation? mapLocation;
  final bool isDemoLocation;
  final String? phone;
}

class AdminOverview {
  AdminOverview(
      {required this.account,
      required this.children,
      required this.descendantCount,
      required this.locations,
      required this.businesses});
  final AdminAccount account;
  final List<AdminAccount> children;
  final int descendantCount;
  final List<LocationAnalytics> locations;
  final List<AdminBusiness> businesses;

  int get activeUsers => locations.fold(0, (s, l) => s + l.activeUsers);
  int get registeredBusinesses =>
      locations.fold(0, (s, l) => s + l.registeredBusinesses);
  int get groups => locations.fold(0, (s, l) => s + l.whatsAppGroupCount);
  int get members => locations.fold(0, (s, l) => s + l.totalWhatsAppMembers);
  double get transactionValue =>
      locations.fold(0, (s, l) => s + l.totalTransactionValue);
  Map<String, int> get serviceUsage {
    final result = <String, int>{};
    for (final location in locations) {
      for (final entry in location.serviceUsageCounts.entries) {
        result.update(entry.key, (count) => count + entry.value,
            ifAbsent: () => entry.value);
      }
    }
    return result;
  }
}
