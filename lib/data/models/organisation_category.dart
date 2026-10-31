/// Organisation type returned by the master API.
class OrganisationCategory {
  const OrganisationCategory({required this.id, required this.name});
  final String id;
  final String name;

  factory OrganisationCategory.fromJson(Map<String, dynamic> json) {
    final id = json['organisation_type_id'];
    final name = json['organisation_type'];
    if (id == null || name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid organisation type.');
    }
    return OrganisationCategory(id: '$id', name: name.trim());
  }
}
