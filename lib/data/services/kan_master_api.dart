import '../repositories/auth_repository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/gender_option.dart';
import '../models/state_geometry.dart';
import '../models/admin_hierarchy.dart';

class AreaListPage {
  const AreaListPage(
      {required this.items, required this.page, required this.hasNext});
  final List<AreaListItem> items;
  final int page;
  final bool hasNext;
}

class AreaListItem {
  const AreaListItem({required this.id, required this.name});
  final String id;
  final String name;
}

/// Master API requests share the configurable {{kan_url}} base URL.
class KanMasterApi {
  KanMasterApi(
      {http.Client? client,
      this.authRepository,
      this.baseUrl = ApiConfig.kanUrl,
      this.timeout = const Duration(seconds: 8)})
      : _client = client ?? http.Client();
  final http.Client _client;
  final AuthRepository? authRepository;
  final String baseUrl;
  final Duration timeout;

  Future<http.Response> _authorizedGet(Uri uri,
      {required Map<String, String> headers}) async {
    final auth = authRepository;
    if (auth == null) {
      return _client.get(uri, headers: headers).timeout(timeout);
    }
    final token = await auth.validAccessToken();
    Future<http.Response> send(String value) => _client.get(uri, headers: {
          ...headers,
          'Authorization': 'Bearer $value'
        }).timeout(timeout);
    final response = await send(token);
    if (response.statusCode != 401) return response;
    final refreshed = await auth.refreshAccessToken(token);
    // Retry once only; a second rejection is surfaced to the caller.
    return send(refreshed);
  }

  /// Reusable JSON POST for other APIs hosted at kan_url.
  Future<Object?> postJson(String path, Map<String, Object?> body) async {
    final response = await _client
        .post(
          ApiConfig.kanUri(path, baseUrl: baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode(body),
        )
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Master-data request failed.');
    }
    return jsonDecode(response.body);
  }

  Future<List<GenderOption>> getGenders() async {
    final json = await postJson(
        '/master/gender/getAll', {'requestName': 'getAll_Gender'});
    if (json is! List || json.isEmpty) {
      throw const FormatException('Expected a non-empty gender list');
    }
    final options = json.map(GenderOption.fromJson).toList();
    if (options.map((option) => option.value).toSet().length !=
        options.length) {
      throw const FormatException('Duplicate gender IDs');
    }
    return List.unmodifiable(options);
  }

  Future<Object?> _getStates(String path, String accessToken) async {
    if (accessToken.trim().isEmpty) {
      throw StateError('API login is required to load states.');
    }
    final response = await _authorizedGet(
      ApiConfig.kanUri(path, baseUrl: baseUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError(
          'States require an authorised API login. Sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
          'State service returned HTTP ${response.statusCode}. Please retry.');
    }
    return jsonDecode(response.body);
  }

  Future<Map<String, StateGeometry>> getAllStateGeometry(
          {required String accessToken}) async =>
      StateGeometry.allStates(
          await _getStates('/master/state/getAllGeo', accessToken));

  Future<List<AdminStateOption>> getStates(
      {required String accessToken}) async {
    final decoded = await _getStates('/master/state/getAll', accessToken);
    final rows = _districtRows(decoded);
    final states = <int, AdminStateOption>{};
    for (final row in rows) {
      if (row is! Map) continue;
      final id = int.tryParse(
          '${_field(row, const ['state_id', 'stateId', 'id', 'value'])}');
      final name = _field(
          row, const ['state', 'stateName', 'state_name', 'name', 'label']);
      if (id == null || name is! String || name.trim().isEmpty) continue;
      states[id] = AdminStateOption(id: id, name: name.trim());
    }
    if (rows.isNotEmpty && states.isEmpty) {
      throw const FormatException(
          'State API returned no readable state records');
    }
    return List.unmodifiable(states.values);
  }

  Future<StateGeometry> getStateGeometry(
      {required String accessToken, String stateName = 'Kerala'}) async {
    if (accessToken.trim().isEmpty) {
      throw StateError('Sign in through API login to load state boundaries.');
    }
    final response = await _authorizedGet(
      ApiConfig.kanUri('/master/state/getAllGeo', baseUrl: baseUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError(
          'State boundaries require an authorised API login. Sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('State boundary service is unavailable. Please retry.');
    }
    return StateGeometry.forState(jsonDecode(response.body), stateName);
  }

  Future<List<AdminDistrictOption>> getDistrictsByState({
    required String accessToken,
    required int stateId,
  }) async {
    if (accessToken.trim().isEmpty) {
      throw StateError('Sign in through API login to load districts.');
    }
    final response = await _authorizedGet(
      ApiConfig.kanUri('/master/district/getByState/$stateId',
          baseUrl: baseUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError(
          'District list requires an authorised API login. Sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
          'District list service returned HTTP ${response.statusCode}. Please retry.');
    }
    final decoded = jsonDecode(response.body);
    final rows = _districtRows(decoded);
    if (rows.isEmpty) return const [];
    final districts = <AdminDistrictOption>[];
    for (final row in rows) {
      if (row is! Map) continue;
      final rawId = _field(row,
          const ['value', 'id', 'districtId', 'district_id', 'districtValue']);
      final rawName = _field(row, const [
        'label',
        'name',
        'district',
        'districtName',
        'district_name',
        'districtLabel'
      ]);
      if (rawId == null || rawName is! String || rawName.trim().isEmpty) {
        continue;
      }
      districts.add(AdminDistrictOption(id: '$rawId', name: rawName.trim()));
    }
    if (districts.isEmpty) throw const FormatException('No districts returned');
    return List.unmodifiable(districts);
  }

  static List<Object?> _districtRows(Object? value) {
    if (value is List) return value.cast<Object?>();
    if (value is! Map) return const [];
    for (final key in const [
      'data',
      'result',
      'rows',
      'records',
      'content',
      'districts',
      'states',
      'branches',
      'items'
    ]) {
      final nested = value[key];
      final rows = _districtRows(nested);
      if (nested is List || rows.isNotEmpty) return rows;
    }
    return [value];
  }

  static Object? _field(Map row, List<String> names) {
    for (final name in names) {
      if (row.containsKey(name)) return row[name];
      final match = row.keys.cast<Object?>().firstWhere(
          (key) => key is String && key.toLowerCase() == name.toLowerCase(),
          orElse: () => null);
      if (match != null) return row[match];
    }
    return null;
  }

  Future<Map<String, StateGeometry>> getDistrictGeometry(
      {required String accessToken,
      String stateName = 'Kerala',
      int? stateId,
      String? districtId}) async {
    if (accessToken.trim().isEmpty) {
      throw StateError(
          'Sign in through API login to load district boundaries.');
    }
    if (districtId != null && districtId.trim().isEmpty) {
      throw ArgumentError.value(
          districtId, 'districtId', 'District ID is required');
    }
    final response = await _authorizedGet(
      ApiConfig.kanUri(
          districtId != null
              ? '/master/district/getDistrictGeoById/${Uri.encodeComponent(districtId)}'
              : stateId == null
                  ? '/master/district/getAllGeo'
                  : '/master/district/getAllGeoByState/$stateId',
          baseUrl: baseUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError(
          'District boundaries require an authorised API login. Sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
          'District boundary service is unavailable. Please retry.');
    }
    return StateGeometry.forDistricts(jsonDecode(response.body), stateName);
  }

  /// Loads the area's polygon layers for a district using the authenticated
  /// area service.
  Future<Map<String, StateGeometry>> getAreaGeometryByDistrictId(
      {required String accessToken, required String districtId}) async {
    if (accessToken.trim().isEmpty) {
      throw StateError('Sign in through API login to load district areas.');
    }
    if (districtId.trim().isEmpty) {
      throw ArgumentError.value(
          districtId, 'districtId', 'District ID is required');
    }
    final response = await _authorizedGet(
      ApiConfig.kanUri(
          '/master/area/getAreaGeoByDistrictId/${Uri.encodeComponent(districtId)}',
          baseUrl: baseUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError(
          'District areas require an authorised API login. Sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('District area service is unavailable. Please retry.');
    }
    return StateGeometry.forAreas(jsonDecode(response.body));
  }

  /// Lists a district's subadmin areas from `/master/area/getByDistrict/{id}`,
  /// paginated client-side.
  Future<AreaListPage> listAreas({
    required String accessToken,
    required String districtId,
    required int page,
    int pageSize = 10,
  }) async {
    if (accessToken.trim().isEmpty) {
      throw StateError('Sign in through API login to load areas.');
    }
    if (districtId.trim().isEmpty) {
      throw ArgumentError.value(
          districtId, 'districtId', 'District ID is required');
    }
    final response = await _authorizedGet(
      ApiConfig.kanUri(
          '/master/area/getByDistrict/${Uri.encodeComponent(districtId)}',
          baseUrl: baseUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError('Areas require an authorised API login. Sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Area list service is unavailable. Please retry.');
    }
    Object? rows = jsonDecode(response.body);
    for (var depth = 0; depth < 6; depth++) {
      if (rows is String) {
        try {
          rows = jsonDecode(rows);
        } on FormatException {
          break;
        }
      }
      if (rows is List) break;
      if (rows is! Map) break;
      final nested = rows['data'] ??
          rows['result'] ??
          rows['items'] ??
          rows['areas'] ??
          rows['keyValue'] ??
          rows['keyvalue'] ??
          rows['values'] ??
          rows['records'] ??
          rows['list'] ??
          rows['rows'];
      if (nested == null) break;
      rows = nested;
    }
    if (rows is Map) {
      final rowName = rows['area_name'] ??
          rows['areaName'] ??
          rows['f_area_name'] ??
          rows['area_nm'] ??
          rows['area'] ??
          rows['name'] ??
          rows['label'] ??
          rows['areaLabel'] ??
          rows['area_label'] ??
          rows['paramLabel'];
      if (rowName != null) {
        rows = [rows];
      } else {
        rows = rows.entries
            .map((entry) => {'key': entry.key, 'value': entry.value})
            .toList();
      }
    }
    if (rows is! List) {
      throw const FormatException('Area list returned an unreadable page.');
    }
    final areas = <AreaListItem>[];
    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      final raw = row is Map
          ? row['area_name'] ??
              row['areaName'] ??
              row['f_area_name'] ??
              row['area_nm'] ??
              row['area'] ??
              row['areaLabel'] ??
              row['area_label'] ??
              row['areaDescription'] ??
              row['area_description'] ??
              row['name'] ??
              row['label'] ??
              row['paramLabel'] ??
              row['param_label'] ??
              row['display_value'] ??
              row['displayName'] ??
              row['value'] ??
              row['key']
          : row;
      final label =
          raw is Map ? raw['label'] ?? raw['name'] ?? raw['value'] : raw;
      if (label != null && '$label'.trim().isNotEmpty) {
        final idValue = row is Map
            ? row['area_id'] ??
                row['areaId'] ??
                row['f_area_id'] ??
                row['id'] ??
                row['value'] ??
                row['key']
            : index;
        final id = idValue is Map
            ? idValue['value'] ?? idValue['id'] ?? idValue['key']
            : idValue;
        if (id != null) {
          areas.add(AreaListItem(id: '$id', name: '$label'.trim()));
        }
      }
    }
    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, areas.length).toInt();
    final items = start >= areas.length
        ? const <AreaListItem>[]
        : areas.sublist(start, end);
    return AreaListPage(
        items: List.unmodifiable(items),
        page: page,
        hasNext: end < areas.length);
  }

  /// Lists an area's branches from `/master/branch/getByArea/{areaId}`.
  Future<List<AreaListItem>> getBranchesByArea({
    required String accessToken,
    required String areaId,
  }) async {
    if (accessToken.trim().isEmpty) {
      throw StateError('Sign in through API login to load branches.');
    }
    if (areaId.trim().isEmpty) {
      throw ArgumentError.value(areaId, 'areaId', 'Area ID is required');
    }
    final response = await _authorizedGet(
      ApiConfig.kanUri(
          '/master/branch/getByArea/${Uri.encodeComponent(areaId)}',
          baseUrl: baseUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError(
          'Branches require an authorised API login. Sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
          'Branch list service returned HTTP ${response.statusCode}. Please retry.');
    }
    final branches = <AreaListItem>[];
    for (final row in _districtRows(jsonDecode(response.body))) {
      if (row is! Map) continue;
      final rawId = _field(
          row, const ['branch_id', 'branchId', 'f_branch_id', 'id', 'value']);
      final rawName = _field(row, const [
        'branch_name',
        'branchName',
        'f_branch_name',
        'branch',
        'name',
        'label'
      ]);
      if (rawId == null || rawName is! String || rawName.trim().isEmpty) {
        continue;
      }
      branches.add(AreaListItem(id: '$rawId', name: rawName.trim()));
    }
    return List.unmodifiable(branches);
  }

  /// Loads one branch's boundary from `/master/branch/getBranchGeoById/{id}`.
  Future<Map<String, StateGeometry>> getBranchGeometryById({
    required String accessToken,
    required String branchId,
  }) async {
    if (accessToken.trim().isEmpty) {
      throw StateError(
          'Sign in through API login to load the branch boundary.');
    }
    if (branchId.trim().isEmpty) {
      throw ArgumentError.value(branchId, 'branchId', 'Branch ID is required');
    }
    final response = await _authorizedGet(
      ApiConfig.kanUri(
        '/master/branch/getBranchGeoById/${Uri.encodeComponent(branchId)}',
        baseUrl: baseUrl,
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError(
          'Branch boundary requires an authorised API login. Sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Branch boundary service is unavailable. Please retry.');
    }
    return StateGeometry.forBranches(jsonDecode(response.body));
  }

  Future<Map<String, StateGeometry>> getBranchGeometryByAreaId({
    required String accessToken,
    required String areaId,
  }) async {
    if (accessToken.trim().isEmpty) {
      throw StateError('Sign in through API login to load branches.');
    }
    if (areaId.trim().isEmpty) {
      throw ArgumentError.value(areaId, 'areaId', 'Area ID is required');
    }
    final response = await _authorizedGet(
      ApiConfig.kanUri(
        '/master/branch/getBranchGeoByAreaId/${Uri.encodeComponent(areaId)}',
        baseUrl: baseUrl,
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError(
          'Branches require an authorised API login. Sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Branch boundary service is unavailable. Please retry.');
    }
    return StateGeometry.forBranches(jsonDecode(response.body));
  }

  void dispose() => _client.close();
}
