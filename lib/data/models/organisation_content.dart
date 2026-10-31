import 'media_attachment.dart';

class OrganisationMember {
  const OrganisationMember({required this.name, required this.role});

  final String name;
  final String role;

  factory OrganisationMember.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] ??
        json['member_name'] ??
        json['user_name'] ??
        json['user'];
    final name = rawName is Map
        ? rawName['label']?.toString().trim() ?? ''
        : rawName?.toString().trim() ?? '';
    final rawRole = json['role'] ?? json['usertype'];
    final role = rawRole is Map
        ? rawRole['label']?.toString().trim() ?? ''
        : rawRole?.toString().trim() ?? '';
    return OrganisationMember(name: name.isEmpty ? 'Member' : name, role: role);
  }
}

class OrganisationProduct {
  const OrganisationProduct(
      {required this.productId,
      required this.name,
      required this.price,
      required this.quantity,
      required this.description});
  final String productId, name, description;
  final num price, quantity;

  factory OrganisationProduct.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final id =
        json['f_product_id'] ?? (product is Map ? product['value'] : null);
    final name =
        json['product_name'] ?? (product is Map ? product['label'] : product);
    final price = num.tryParse('${json['product_price']}');
    final quantity = num.tryParse('${json['product_qty']}');
    if (id == null ||
        price == null ||
        quantity == null ||
        !price.isFinite ||
        !quantity.isFinite) {
      throw const FormatException('Invalid organisation product.');
    }
    return OrganisationProduct(
        productId: '$id',
        name: name?.toString() ?? '',
        price: price,
        quantity: quantity,
        description: '${json['product_desc'] ?? ''}');
  }
}

class OrganisationAdvertisement {
  const OrganisationAdvertisement(
      {required this.name,
      required this.description,
      required this.startDate,
      required this.endDate});
  final String name, description, startDate, endDate;

  factory OrganisationAdvertisement.fromJson(Map<String, dynamic> json) {
    final name = json['advertisement_name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid advertisement.');
    }
    return OrganisationAdvertisement(
        name: name,
        description: '${json['advertisement_desc'] ?? ''}',
        startDate: '${json['start_date'] ?? ''}'.split('T').first,
        endDate: '${json['end_date'] ?? ''}'.split('T').first);
  }
}

class OrganisationAdvertisementDraft {
  const OrganisationAdvertisementDraft(
      {required this.name,
      required this.description,
      required this.advertisementTypeId,
      required this.startDate,
      required this.endDate,
      required this.image});
  final String name, description, advertisementTypeId;
  final DateTime startDate, endDate;
  final MediaAttachment image;

  Map<String, String> fields(String organisationId) {
    final typeId = int.tryParse(advertisementTypeId);
    if (name.trim().isEmpty ||
        description.trim().isEmpty ||
        typeId == null ||
        typeId <= 0 ||
        endDate.isBefore(startDate) ||
        image.kind != MediaKind.image ||
        image.bytes.isEmpty) {
      throw ArgumentError(
          'Provide advertisement details, valid dates and an image.');
    }
    String date(DateTime value) =>
        '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    return {
      'advertisement_name': name.trim(),
      'advertisement_desc': description.trim(),
      'start_date': date(startDate),
      'end_date': date(endDate),
      'f_villageapp_id': '1',
      'f_villageorganisation_id': organisationId,
      'isexclusive': 'false',
      'f_adv_type_id': '$typeId',
    };
  }
}
