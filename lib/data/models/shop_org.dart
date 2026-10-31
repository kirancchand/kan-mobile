import 'map_location.dart';
import 'organisation_draft.dart';

enum ShopCategory {
  grocery,
  pharmacy,
  restaurant,
  hardware,
  electronics,
  clothing,
  organization,
  other,
}

extension ShopCategoryLabel on ShopCategory {
  String get label {
    switch (this) {
      case ShopCategory.grocery:
        return 'Grocery';
      case ShopCategory.pharmacy:
        return 'Pharmacy';
      case ShopCategory.restaurant:
        return 'Restaurant';
      case ShopCategory.hardware:
        return 'Hardware';
      case ShopCategory.electronics:
        return 'Electronics';
      case ShopCategory.clothing:
        return 'Clothing';
      case ShopCategory.organization:
        return 'Organization';
      case ShopCategory.other:
        return 'Other';
    }
  }
}

class ShopOrg {
  final int? membershipUserTypeId;
  final OrganisationOption? typeOption, branchOption, statusOption;
  bool get canEditOrganisation =>
      membershipUserTypeId == 5 || membershipUserTypeId == 6;
  bool get isBusiness {
    if (category != ShopCategory.organization &&
        category != ShopCategory.other) {
      return true;
    }
    final type = (organisationType ?? '').trim().toLowerCase();
    return const {
      'business',
      'businesses',
      'shop',
      'shops',
      'business shop',
      'business shops',
      'retail',
      'store',
      'stores',
    }.contains(type);
  }

  final String? organisationType;
  final String? photoUrl;
  final String id;
  final String name;
  final ShopCategory category;
  final String phone;
  final String email;
  final String branch;
  final String status;
  final String address;
  final String timings;
  final String? ownerId;
  final String? locationId;
  final MapLocation? mapLocation;

  const ShopOrg({
    this.membershipUserTypeId,
    this.typeOption,
    this.branchOption,
    this.statusOption,
    this.organisationType,
    this.photoUrl,
    required this.id,
    required this.name,
    required this.category,
    required this.phone,
    this.email = '',
    this.branch = '',
    this.status = '',
    required this.address,
    required this.timings,
    this.ownerId,
    this.mapLocation,
    this.locationId,
  });

  factory ShopOrg.fromJson(Map<String, dynamic> json) {
    final id = json['organisation_id'];
    final name = json['organisation'];
    if (id == null || name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid organisation record.');
    }
    final rawType = json['organisation_type'];
    final type =
        (rawType is Map ? rawType['label'] : rawType)?.toString().trim() ?? '';
    final category = ShopCategory.values.firstWhere(
      (category) => category.label.toLowerCase() == type.toLowerCase(),
      orElse: () => ShopCategory.organization,
    );
    String label(Object? value) =>
        (value is Map ? value['label'] : value)?.toString().trim() ?? '';
    final latitude = double.tryParse('${json['latitude']}');
    final longitude = double.tryParse('${json['longitude']}');
    final hasLocation = latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
    OrganisationOption? option(Object? raw, Object? id) {
      if (raw is Map && raw['value'] != null && label(raw).isNotEmpty) {
        return OrganisationOption(value: '${raw['value']}', label: label(raw));
      }
      return id == null
          ? null
          : OrganisationOption(value: '$id', label: label(raw));
    }

    return ShopOrg(
      membershipUserTypeId: int.tryParse('${json['f_usertype_id']}'),
      ownerId: (json['f_owner_id'] ?? json['ownerId'])?.toString(),
      typeOption: option(rawType, json['f_organisation_type_id']),
      branchOption: option(json['branch'], json['f_branch_id']),
      statusOption: option(json['status'], json['f_status_id']),
      id: '$id',
      name: name.trim(),
      category: category,
      organisationType: type,
      photoUrl: '',
      phone: '${json['organisation_contact'] ?? ''}'.trim(),
      email: '${json['organisation_email'] ?? ''}'.trim(),
      branch: label(json['branch']),
      status: label(json['status']),
      mapLocation: hasLocation
          ? MapLocation(latitude: latitude, longitude: longitude)
          : null,
      address: '${json['organisation_address'] ?? ''}'.trim(),
      timings: '${json['timings'] ?? ''}'.trim(),
    );
  }

  /// Only real media is shown; missing media uses a neutral placeholder.
  String get imageUrl => photoUrl ?? '';
}
