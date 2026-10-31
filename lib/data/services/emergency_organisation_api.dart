import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/emergency_contact.dart';

class EmergencyOrganisationApi {
  EmergencyOrganisationApi(
      {http.Client? client,
      this.baseUrl = ApiConfig.villageUrl,
      this.appId = ApiConfig.villageAppId,
      this.timeout = const Duration(seconds: 8)})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String appId;
  final Duration timeout;

  Future<List<EmergencyContact>> fetch() async {
    final response = await _client.get(
      ApiConfig.kanUri('/api/organisations/getEmergencyOrganisation',
          baseUrl: baseUrl),
      headers: {'Accept': 'application/json', 'X-App-Id': appId},
    ).timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException('Emergency organisation request failed.');
    }
    final rows = jsonDecode(response.body);
    if (rows is! List) {
      throw const FormatException('Expected an emergency organisation list.');
    }
    // Preserve the server's priority order.
    return rows
        .cast<Map<String, dynamic>>()
        .map(EmergencyContact.fromJson)
        .toList();
  }

  void dispose() => _client.close();
}
