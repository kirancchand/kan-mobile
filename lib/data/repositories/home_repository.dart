import '../models/service_definition.dart';
import '../services/organisation_content_api.dart';
import '../services/service_api.dart';
import '../models/map_location.dart';
import '../models/organisation_draft.dart';
import '../models/organisation_category.dart';
import '../services/organisation_api.dart';
import '../services/emergency_organisation_api.dart';
import 'package:flutter/foundation.dart';

import '../services/advertisements_api.dart';
import '../models/advertisement.dart';
import '../models/emergency_contact.dart';
import '../models/shop_org.dart';
import '../models/village_event.dart';

/// Home data from the configured API services.
class HomeRepository {
  HomeRepository(
      {ServiceApi? serviceApi,
      AdvertisementsApi? advertisementsApi,
      EmergencyOrganisationApi? emergencyApi,
      OrganisationApi? organisationApi,
      OrganisationContentApi? organisationContentApi})
      : _serviceApi = serviceApi ?? ServiceApi(),
        _advertisementsApi = advertisementsApi ?? AdvertisementsApi(),
        _emergencyApi = emergencyApi ?? EmergencyOrganisationApi(),
        _organisationApi = organisationApi ?? OrganisationApi(),
        organisationContent =
            organisationContentApi ?? OrganisationContentApi();

  final OrganisationContentApi organisationContent;

  final ServiceApi _serviceApi;

  Future<List<ServiceDefinition>> getServices() => _serviceApi.fetchAll();

  final AdvertisementsApi _advertisementsApi;
  final EmergencyOrganisationApi _emergencyApi;
  final OrganisationApi _organisationApi;
  final List<ShopOrg> _localOrganisations = [];

  final _changes = ValueNotifier<int>(0);
  Listenable get changes => _changes;
  final List<ShopOrg> _shops = [];
  bool _disposed = false;
  List<ShopOrg> get shops => List.unmodifiable(_shops);

  void dispose() {
    _disposed = true;
    _serviceApi.dispose();
    _emergencyApi.dispose();
    _advertisementsApi.dispose();
    _organisationApi.dispose();
    organisationContent.dispose();
    _changes.dispose();
  }

  Future<ShopOrg> addOrganisation({
    required String name,
    ShopCategory category = ShopCategory.organization,
    required String phone,
    required String address,
    required String timings,
    required String ownerId,
    required String locationId,
    MapLocation? mapLocation,
  }) async {
    if ([name, phone, address, timings, ownerId, locationId]
        .any((value) => value.trim().isEmpty)) {
      throw ArgumentError('Organisation details are required.');
    }
    final organisation = ShopOrg(
      id: 'org_${DateTime.now().microsecondsSinceEpoch}_${_shops.length}',
      name: name.trim(),
      category: category,
      phone: phone.trim(),
      address: address.trim(),
      timings: timings.trim(),
      ownerId: ownerId,
      locationId: locationId,
      mapLocation: mapLocation,
    );
    _shops.insert(0, organisation);
    _localOrganisations.insert(0, organisation);
    _changes.value++;
    return organisation;
  }

  Future<AdvertisementFeed> getAdvertisementFeed() =>
      _advertisementsApi.fetch();

  Future<List<Advertisement>> getAds() async =>
      (await getAdvertisementFeed()).ads;

  Future<List<VillageEvent>> getEvents() async =>
      (await getAdvertisementFeed()).events;

  Future<List<EmergencyContact>> getEmergencyContacts() =>
      _emergencyApi.fetch();

  Future<OrganisationFormOptions> getOrganisationFormOptions() =>
      _organisationApi.fetchFormOptions();

  Future<List<ShopOrg>> getMyOrganisations(int userId) =>
      _organisationApi.fetchByUserId(userId);

  Future<bool> updateOrganisation(
      ShopOrg organisation, OrganisationDraft draft) async {
    await _organisationApi.update(organisation, draft);
    try {
      await getOrganisationDirectory();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// A successful create must not be reported as failed if its refresh fails.
  Future<bool> createOrganisation(OrganisationDraft draft) async {
    await _organisationApi.add(draft);
    try {
      await getOrganisationDirectory();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<OrganisationCategory>> getOrganisationCategories() =>
      _organisationApi.fetchCategories();

  /// Refresh the shared cache used by both Home and the full directory.
  Future<List<ShopOrg>> getOrganisationDirectory() async {
    final remoteShops = await _organisationApi.fetchAll();
    if (_disposed) return [..._localOrganisations, ...remoteShops];
    _shops
      ..clear()
      ..addAll([..._localOrganisations, ...remoteShops]);
    _changes.value++;
    return shops;
  }

  Future<List<ShopOrg>> getShops() => getOrganisationDirectory();

  /// [type] is `product`, `organisation` or `organisationType`; all three use
  /// the kan_url `/common/searchProduct` service.
  Future<HomeSearchResults> searchHome(String query, String type) async {
    final column = switch (type) {
      'organisation' => 'organisation',
      'organisationType' => 'organisation_type',
      _ => 'product',
    };
    final rows = await organisationContent
        .searchProducts(query, column: column)
        .timeout(const Duration(seconds: 12));
    return HomeSearchResults(
      items: rows
          .map(HomeSearchItem.fromJson)
          .where((item) => item.title.isNotEmpty)
          .toList(),
    );
  }
}

class HomeSearchResults {
  const HomeSearchResults({this.items = const []});

  final List<HomeSearchItem> items;
}

/// One `/common/searchProduct` row: a product and the organisation selling it.
class HomeSearchItem {
  const HomeSearchItem(
      {this.product = '', this.organisation = '', this.organisationType = ''});

  factory HomeSearchItem.fromJson(Map<String, dynamic> json) {
    String text(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && '$value'.trim().isNotEmpty) {
          return '$value'.trim();
        }
      }
      return '';
    }

    return HomeSearchItem(
      product: text(const ['product', 'product_name', 'productName']),
      organisation: text(const [
        'organisation',
        'organisation_name',
        'organisationName',
        'organization',
        'organization_name'
      ]),
      organisationType: text(const [
        'organisation_type',
        'organisationType',
        'organisation_type_name',
        'organization_type',
        'category'
      ]),
    );
  }

  final String product;
  final String organisation;
  final String organisationType;

  String get title => product.isNotEmpty
      ? product
      : organisation.isNotEmpty
          ? organisation
          : organisationType;

  String get subtitle => [
        if (product.isNotEmpty) organisation,
        organisationType,
      ].where((part) => part.isNotEmpty && part != title).join(' • ');
}
