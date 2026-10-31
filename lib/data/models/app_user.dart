import 'map_location.dart';

enum UserType {
  resident('Resident'),
  manager('Manager'),
  owner('Owner'),
  employee('Employee'),
  member('Member');

  const UserType(this.label);
  final String label;
}

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String locationId;
  final String? whatsAppGroupId;
  final UserType userType;
  final bool apiRegistered;
  final MapLocation? mapLocation;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.locationId,
    this.whatsAppGroupId,
    this.mapLocation,
    this.apiRegistered = false,
    this.userType = UserType.resident,
  });

  AppUser copyWith({String? whatsAppGroupId}) {
    return AppUser(
      id: id,
      name: name,
      phone: phone,
      locationId: locationId,
      userType: userType,
      apiRegistered: apiRegistered,
      mapLocation: mapLocation,
      whatsAppGroupId: whatsAppGroupId ?? this.whatsAppGroupId,
    );
  }
}
