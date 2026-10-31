import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/service_definition.dart';
import '../repositories/auth_repository.dart';

class ServiceApi {
  ServiceApi(
      {http.Client? client,
      this.authRepository,
      this.baseUrl = ApiConfig.kanUrl})
      : _client = client ?? http.Client();
  final http.Client _client;
  final AuthRepository? authRepository;
  final String baseUrl;

  Future<List<ServiceDefinition>> fetchAll() async {
    final auth = authRepository;
    Future<http.Response> send(String? token) => _client.get(
          ApiConfig.kanUri('/master/service/getAll', baseUrl: baseUrl),
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token'
          },
        ).timeout(const Duration(seconds: 8));
    final token = await auth?.validAccessToken();
    var response = await send(token);
    if (response.statusCode == 401 && auth != null && token != null) {
      response = await send(await auth.refreshAccessToken(token));
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
          'Service list failed (HTTP ${response.statusCode}).');
    }
    Object? rows = jsonDecode(response.body);
    for (var depth = 0; depth < 3 && rows is Map; depth++) {
      rows = rows['data'] ?? rows['result'];
    }
    if (rows is! List) throw const FormatException('Expected a service list.');
    final services = rows.map((row) {
      if (row is! Map<String, dynamic>) {
        throw const FormatException('Invalid service.');
      }
      return ServiceDefinition.fromJson(row);
    }).toList();
    if (services.map((service) => service.id).toSet().length !=
        services.length) {
      throw const FormatException('Duplicate service IDs.');
    }
    return List.unmodifiable(services);
  }

  void dispose() => _client.close();
}
