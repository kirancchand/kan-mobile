import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../models/organisation_content.dart';
import '../models/organisation_draft.dart';
import '../models/shop_org.dart';
import '../repositories/auth_repository.dart';

enum ProductSaveResult { confirmed, unconfirmed }

class ProductSaveException implements Exception {
  const ProductSaveException(this.message);
  final String message;
}

/// Requests match the product and village folders in the Postman collection.
class OrganisationContentApi {
  OrganisationContentApi(
      {http.Client? client,
      this.authRepository,
      this.kanUrl = ApiConfig.kanUrl,
      this.villageUrl = ApiConfig.villageUrl,
      this.appId = ApiConfig.villageAppId})
      : _client = client ?? http.Client();
  final http.Client _client;
  final AuthRepository? authRepository;
  final String kanUrl, villageUrl, appId;

  void _authorize(ShopOrg organisation) {
    if (!organisation.canEditOrganisation) {
      throw StateError('You cannot manage this organisation.');
    }
    if ((int.tryParse(organisation.id) ?? 0) <= 0) {
      throw ArgumentError('Invalid organisation.');
    }
  }

  Future<http.Response> _send(http.BaseRequest Function() request) async {
    final auth = authRepository;
    if (auth == null) throw StateError('Sign in again.');
    final token = await auth.validAccessToken();
    Future<http.Response> send(String token) async {
      final message = request();
      message.headers.addAll(
          {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
      return (() async =>
              http.Response.fromStream(await _client.send(message)))()
          .timeout(const Duration(seconds: 30));
    }

    var response = await send(token);
    if (response.statusCode == 401) {
      response = await send(await auth.refreshAccessToken(token));
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
          'Organisation content request failed (HTTP ${response.statusCode}).');
    }
    return response;
  }

  Future<Object?> _json(String base, String path,
      {String method = 'POST',
      Map<String, Object?>? body,
      bool allowText = false,
      bool village = false}) async {
    final response = await _send(() {
      final request =
          http.Request(method, ApiConfig.kanUri(path, baseUrl: base));
      request.headers['Content-Type'] = 'application/json';
      if (village) request.headers['X-App-Id'] = appId;
      if (body != null) request.body = jsonEncode(body);
      return request;
    });
    if (response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } on FormatException {
      if (allowText) return response.body.trim();
      rethrow;
    }
  }

  List<Map<String, dynamic>> _rows(Object? data, {String? singleKey}) {
    Object? rows = data;
    for (var depth = 0; depth < 4 && rows is Map; depth++) {
      if (singleKey != null && rows.containsKey(singleKey)) {
        return [Map<String, dynamic>.from(rows)];
      }
      rows = rows['result'] ?? rows['data'];
    }
    if (rows is! List) {
      throw const FormatException('Expected an organisation content list.');
    }
    return rows.map((row) {
      if (row is! Map) {
        throw const FormatException('Invalid organisation content.');
      }
      return Map<String, dynamic>.from(row);
    }).toList();
  }

  Future<List<OrganisationMember>> members(ShopOrg organisation) async {
    final organisationId = int.tryParse(organisation.id);
    if (organisationId == null || organisationId <= 0) {
      throw ArgumentError('Invalid organisation.');
    }
    const pageSize = 20;
    final members = <OrganisationMember>[];
    var start = 0;
    while (true) {
      final data = await _json(
          kanUrl, '/master/organisationmember/listOrganisationMember',
          body: {
            'start': start,
            'numberOfRows': pageSize,
            'sort': [
              {'columnName': 'slno', 'sortOrder': 'desc'}
            ],
            'filters': [
              {'columnName': 'f_organisation_id', 'value': organisationId}
            ],
          });
      final pageRows = _rows(data);
      final matchingRows = pageRows
          .where((row) =>
              row['f_organisation_id'] == null ||
              '${row['f_organisation_id']}' == organisation.id)
          .toList();
      members.addAll(matchingRows.map(OrganisationMember.fromJson));
      final total = data is Map ? int.tryParse('${data['totalCount']}') : null;
      if (total != null && start + pageRows.length >= total) break;
      if (pageRows.isEmpty || pageRows.length < pageSize) break;
      start += pageRows.length;
    }
    return members;
  }

  Future<List<OrganisationOption>> productOptions(ShopOrg organisation) async {
    _authorize(organisation);
    return _rows(await _json(kanUrl, '/keyValue',
            body: {'requestName': 'getAll_Product'}))
        .map(OrganisationOption.fromJson)
        .toList();
  }

  /// Home search across products, organisations and organisation types.
  /// [column] is `product`, `organisation` or `organisation_type`.
  Future<List<Map<String, dynamic>>> searchProducts(String query,
          {String column = 'product', int numberOfRows = 10}) async =>
      _rows(await _json(kanUrl, '/common/searchProduct', body: {
        'start': 0,
        'numberOfRows': numberOfRows,
        'sort': [
          {'columnName': 'slno', 'sortOrder': 'desc'}
        ],
        'filters': [
          {'columnName': column, 'value': query.trim()}
        ]
      }));

  Future<List<OrganisationOption>> advertisementTypes() async =>
      _rows(await _json(villageUrl, '/api/keyValue',
              body: {'requestName': 'getAll_AdvType'}, village: true))
          .map(OrganisationOption.fromJson)
          .toList();

  Future<List<OrganisationProduct>> products(ShopOrg organisation) async {
    _authorize(organisation);
    final rows = _rows(
        await _json(kanUrl,
            '/master/organisationproduct/getByOrganisation/${Uri.encodeComponent(organisation.id)}',
            method: 'GET'),
        singleKey: 'f_product_id');
    return rows
        .where((row) =>
            row['f_organisation_id'] == null ||
            '${row['f_organisation_id']}' == organisation.id)
        .map(OrganisationProduct.fromJson)
        .toList();
  }

  Future<ProductSaveResult> addProduct(ShopOrg organisation,
      {required String productId,
      required num price,
      required int quantity,
      required String description}) async {
    _authorize(organisation);
    final id = int.tryParse(productId);
    if (id == null ||
        id <= 0 ||
        !price.isFinite ||
        price < 0 ||
        quantity < 0 ||
        description.trim().isEmpty) {
      throw ArgumentError('Provide valid product details.');
    }
    final trimmedDescription = description.trim();
    // Compare before and after: an already-existing identical product must not
    // make a rejected/no-op insert look successful.
    int matchingCount(List<OrganisationProduct> products) => products
        .where((p) =>
            p.productId == '$id' &&
            p.price == price &&
            p.quantity == quantity &&
            p.description.trim() == trimmedDescription)
        .length;
    final before = matchingCount(await products(organisation));
    final response = await _json(kanUrl, '/master/organisationproduct/add',
        allowText: true,
        body: {
          'f_organisation_id': int.parse(organisation.id),
          'f_product_id': id,
          'product_price': price,
          'product_qty': quantity,
          'product_desc': trimmedDescription,
        });
    print(response);
    _checkProductSaveResponse(response);
    try {
      final after = matchingCount(await products(organisation));
      return after > before
          ? ProductSaveResult.confirmed
          : ProductSaveResult.unconfirmed;
    } catch (_) {
      // The write may have succeeded. Do not encourage another POST merely
      // because the read-back failed or the server has not exposed the row yet.
      return ProductSaveResult.unconfirmed;
    }
  }

  void _checkProductSaveResponse(Object? response) {
    const fallback =
        'The server rejected the product. It was not confirmed saved.';
    bool failedFlag(Object? value) =>
        value == false ||
        const ['false', 'error', 'failed', 'failure', 'fail']
            .contains('$value'.toLowerCase());
    bool failedMessage(Object? value) =>
        value is String &&
        RegExp(r'\b(error|failed|failure|unsuccessful|unable|cannot|denied|invalid|duplicate)\b|\bnot\s+(added|saved|inserted|successful)\b',
                caseSensitive: false)
            .hasMatch(value);
    void inspect(Object? value, [String? parentMessage]) {
      if (value == false || value == 0 || failedFlag(value)) {
        throw ProductSaveException(parentMessage ?? fallback);
      }
      if (value is String && failedMessage(value)) {
        throw ProductSaveException(value);
      }
      if (value is! Map) return;
      final rawMessage = value['message'] ?? value['error'];
      final message = rawMessage is String && rawMessage.trim().isNotEmpty
          ? rawMessage.trim()
          : parentMessage;
      final status = int.tryParse('${value['statusCode'] ?? value['status']}');
      final error = value['error'] ?? value['errors'];
      final hasError = error != null &&
          error != false &&
          (error is String
              ? error.trim().isNotEmpty
              : error is Iterable
                  ? error.isNotEmpty
                  : error is Map
                      ? error.isNotEmpty
                      : true);
      final affected = value['affectedRows'] ?? value['rowsAffected'];
      if (failedFlag(value['success']) ||
          failedFlag(value['status']) ||
          (status != null && (status < 200 || status >= 300)) ||
          hasError ||
          (affected != null && num.tryParse('$affected') == 0) ||
          failedMessage(message)) {
        throw ProductSaveException(message ?? fallback);
      }
      for (final key in ['data', 'result']) {
        if (value.containsKey(key)) inspect(value[key], message);
      }
    }

    inspect(response);
  }

  Future<List<OrganisationAdvertisement>> advertisements(
      ShopOrg organisation) async {
    _authorize(organisation);
    final rows = _rows(await _json(villageUrl,
        '/api/advertisements/getAdvertisementByOrganisation/${Uri.encodeComponent(organisation.id)}',
        method: 'GET', village: true));
    return rows
        .where((row) {
          final id = row['f_villageorganisation_id'] ??
              row['f_organisation_id'] ??
              row['organisation_id'];
          return id == null || '$id' == organisation.id;
        })
        .map(OrganisationAdvertisement.fromJson)
        .toList();
  }

  Future<void> addAdvertisement(
      ShopOrg organisation, OrganisationAdvertisementDraft draft) async {
    _authorize(organisation);
    final fields = draft.fields(organisation.id);
    await _send(() {
      final request = http.MultipartRequest(
          'POST', ApiConfig.kanUri('/api/advertisements', baseUrl: villageUrl));
      request.headers['X-App-Id'] = '1';
      request.fields.addAll(fields);
      final extension = draft.image.name.split('.').last.toLowerCase();
      final subtype = extension == 'jpg' ? 'jpeg' : extension;
      request.files.add(http.MultipartFile.fromBytes(
          'advertisement_image', draft.image.bytes,
          filename: draft.image.name,
          contentType: http.MediaType('image', subtype)));
      return request;
    });
  }

  void dispose() => _client.close();
}
