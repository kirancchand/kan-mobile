/// A village/area served by the app. Users pick one of these at
/// registration time (see [WhatsAppGroup] for the group auto-assignment
/// that follows from that choice).
class VillageLocation {
  final String id;
  final String name;
  final String district;
  final String state;
  final int registeredUsers;

  const VillageLocation({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
    this.registeredUsers = 0,
  });

  String get displayName => '$name, $district';
}
