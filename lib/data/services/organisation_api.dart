import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/shop_org.dart';
import '../models/organisation_draft.dart';
import '../repositories/auth_repository.dart';
import '../models/organisation_category.dart';

class OrganisationApi {
  OrganisationApi(
      {http.Client? client,
      this.baseUrl = ApiConfig.kanUrl,
      this.authRepository})
      : _client = client ?? http.Client();
  final http.Client _client;
  final String baseUrl;
  final AuthRepository? authRepository;

  Future<http.Response> _post(String path, Map<String, Object?>? body,
      {bool put = false}) async {
    final auth = authRepository;
    Future<http.Response> send(String? token) =>
        (put ? _client.put : _client.post)(
          ApiConfig.kanUri(path, baseUrl: baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token'
          },
          body: body == null ? null : jsonEncode(body),
        ).timeout(const Duration(seconds: 8));
    final token = await auth?.validAccessToken();
    final response = await send(token);
    if (response.statusCode == 401 && auth != null && token != null) {
      return send(await auth.refreshAccessToken(token));
    }
    return response;
  }

  Future<List<ShopOrg>> fetchByUserId(int userId) async {
    print(userId);
    if (userId <= 0) throw ArgumentError('A signed-in user is required.');
    final response = await _post(
        '/master/organisation/listOrganisationByUserId/$userId', null);
    _checkResponse(response);
    final data = jsonDecode(response.body);
    Object? rows = data;
    // Some master endpoints wrap their payload in {message, status, data}.
    for (var depth = 0; depth < 3 && rows is Map; depth++) {
      rows = rows['result'] ?? rows['data'];
    }
    if (rows is! List) {
      throw const FormatException('Expected member organisations.');
    }
    return rows
        .map((row) => ShopOrg.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> update(ShopOrg organisation, OrganisationDraft draft) async {
    if (!organisation.canEditOrganisation) {
      throw StateError('You cannot edit this organisation.');
    }
    final body = draft.toJson()..remove('ownerId');
    body.addAll({
      'organisation_id': int.parse(organisation.id),
      'f_organisation_type_id': int.parse(draft.type.value),
      'f_branch_id': int.parse(draft.branch.value),
      'f_status_id': int.parse(draft.status.value),
    });
    final response = await _post(
        '/master/organisation/update/${Uri.encodeComponent(organisation.id)}',
        body,
        put: true);
    _checkResponse(response);
  }

  Future<OrganisationFormOptions> fetchFormOptions() async {
    final results = await Future.wait<List<OrganisationOption>>([
      fetchCategories().then((types) => types
          .map((type) => OrganisationOption(value: type.id, label: type.name))
          .toList()),
      _fetchPages(
          '/master/branch/listBranch',
          (json) => OrganisationOption.fromJson(
              {'value': json['branch_id'], 'label': json['branch']}),
          (option) => option.value),
      _fetchStatuses(),
    ]);
    return OrganisationFormOptions(results[0], results[1], results[2]);
  }

  Future<List<OrganisationOption>> _fetchStatuses() async {
    final response = await _post('/keyValue', {'requestName': 'getAll_Status'});
    _checkResponse(response);
    final rows = jsonDecode(response.body);
    if (rows is! List) throw const FormatException('Expected status options.');
    return rows
        .cast<Map<String, dynamic>>()
        .map(OrganisationOption.fromJson)
        .toList();
  }

  Future<void> add(OrganisationDraft draft) async {
    final response = await _post('/master/organisation/add', draft.toJson());
    _checkResponse(response);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
          'Organisation request failed (HTTP ${response.statusCode}).');
    }
  }

  Future<List<OrganisationCategory>> fetchCategories() => _fetchPages(
      '/master/organisationtype/listOrganisationType',
      OrganisationCategory.fromJson,
      (category) => category.id);

  Future<List<ShopOrg>> fetchAll() => _fetchPages(
      '/master/organisation/listOrganisation',
      ShopOrg.fromJson,
      (shop) => shop.id);

  Future<List<ShopOrg>> searchOrganisations(String query) => _fetchPages(
          '/master/organisation/listOrganisation',
          ShopOrg.fromJson,
          (shop) => shop.id,
          filters: [
            {'columnName': 'organisation', 'value': '%${query.trim()}%'}
          ]);

  Future<List<OrganisationCategory>> searchOrganisationTypes(String query) =>
      _fetchPages('/master/organisationtype/listOrganisationType',
          OrganisationCategory.fromJson, (category) => category.id,
          filters: [
            {'columnName': 'organisation_type', 'value': '%${query.trim()}%'}
          ]);

  Future<List<T>> _fetchPages<T>(String path,
      T Function(Map<String, dynamic>) parse, String Function(T) idOf,
      {List<Map<String, Object?>> filters = const []}) async {
    final items = <T>[];
    final ids = <String>{};
    var start = 0;
    while (true) {
      final response = await _post(path, {
        'start': start,
        'numberOfRows': 50,
        'sort': [
          {'columnName': 'slno', 'sortOrder': 'desc'}
        ],
        'filters': filters
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw http.ClientException(
            'Organisation request failed (HTTP ${response.statusCode}).');
      }
      final data = jsonDecode(response.body);
      if (data is! Map || data['result'] is! List) {
        throw const FormatException('Expected an organisation list.');
      }
      final total = int.tryParse('${data['totalCount']}');
      if (total == null || total < 0) {
        throw const FormatException('Invalid organisation count.');
      }
      final rows = data['result'] as List;
      if (rows.isEmpty) {
        if (start < total) {
          throw const FormatException('Incomplete organisation list.');
        }
        break;
      }
      for (final row in rows) {
        final item = parse(row as Map<String, dynamic>);
        if (!ids.add(idOf(item))) {
          throw const FormatException('Repeated organisation page.');
        }
        items.add(item);
      }
      start += rows.length;
      if (start >= total) break;
    }
    return items;
  }

  void dispose() => _client.close();
}
