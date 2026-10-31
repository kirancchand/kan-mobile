import 'map_location.dart';

class OrganisationOption {
  const OrganisationOption({required this.value, required this.label});
  final String value;
  final String label;
  Map<String, String> toJson() => {'value': value, 'label': label};
  factory OrganisationOption.fromJson(Map<String, dynamic> json) {
    final value = json['value'];
    final label = json['label'];
    if (value == null ||
        '$value'.isEmpty ||
        label is! String ||
        label.trim().isEmpty) {
      throw const FormatException('Invalid organisation option.');
    }
    return OrganisationOption(value: '$value', label: label.trim());
  }
}

class OrganisationFormOptions {
  const OrganisationFormOptions(this.types, this.branches, this.statuses);
  final List<OrganisationOption> types;
  final List<OrganisationOption> branches;
  final List<OrganisationOption> statuses;
}

class OrganisationDraft {
  const OrganisationDraft(
      {required this.name,
      required this.address,
      this.contact,
      this.email,
      required this.type,
      required this.branch,
      required this.status,
      required this.ownerId,
      this.mapLocation});
  final String name;
  final String address;
  final String? contact, email;
  final OrganisationOption type, branch, status;
  final int ownerId;
  final MapLocation? mapLocation;

  Map<String, Object?> toJson() {
    if (name.trim().isEmpty || address.trim().isEmpty || ownerId <= 0) {
      throw ArgumentError(
          'Organisation details and a valid owner ID are required.');
    }
    return {
      'organisation': name.trim(),
      'organisation_address': address.trim(),
      'organisation_contact': contact?.trim(),
      'organisation_email': email?.trim(),
      'organisation_type': type.toJson(),
      'branch': branch.toJson(),
      'status': status.toJson(),
      'ownerId': ownerId,
      'latitude': mapLocation?.latitude,
      'longitude': mapLocation?.longitude,
    };
  }
}
