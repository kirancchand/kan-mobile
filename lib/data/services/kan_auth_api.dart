import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/kan_registration.dart';

class KanAuthApi {
  KanAuthApi(
      {http.Client? client,
      this.baseUrl = ApiConfig.kanAuthUrl,
      this.timeout = const Duration(seconds: 8)})
      : _client = client ?? http.Client();
  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Future<void> register(KanRegistration registration) async {
    final response = await _client
        .post(
          ApiConfig.registrationUri(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode(registration.toJson()),
        )
        .timeout(timeout);
    // The collection has no response schema. Do not assume a token or user ID.
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Registration service rejected the request.');
    }
  }

  Future<KanLoginTokens> login(
      {required String username, required String password}) async {
    final response = await _client
        .post(
          ApiConfig.loginUri(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Login service rejected the request.');
    }
    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic> ||
        json['access_token'] is! String ||
        (json['access_token'] as String).trim().isEmpty ||
        (json['refresh_token'] != null && json['refresh_token'] is! String)) {
      throw const FormatException('Invalid login response');
    }
    final userInfo = json['userInfo'];
    final userData = userInfo is Map<String, dynamic> ? userInfo['data'] : null;
    final userId =
        (userData is Map<String, dynamic> ? userData['user_id'] : null) ??
            (userInfo is Map<String, dynamic> ? userInfo['user_id'] : null);
    return KanLoginTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        mobileNumber: userData is Map<String, dynamic>
            ? userData['mobno']?.toString()
            : null,
        email: userData is Map<String, dynamic>
            ? userData['email_id'] as String?
            : null,
        userId: int.tryParse((userId ??
                json['userid'] ??
                json['user_id'] ??
                json['userId'] ??
                '')
            .toString()));
  }

  Future<KanLoginTokens> refreshAccessToken(String refreshToken) async {
    final response = await _client
        .post(
          ApiConfig.refreshAccessTokenUri(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'refresh_token': refreshToken}),
        )
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Session refresh failed. Sign in again.');
    }
    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic> ||
        json['access_token'] is! String ||
        (json['access_token'] as String).trim().isEmpty ||
        (json['refresh_token'] != null &&
            (json['refresh_token'] is! String ||
                (json['refresh_token'] as String).trim().isEmpty))) {
      throw const FormatException('Invalid refresh response');
    }
    return KanLoginTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String? ?? refreshToken,
    );
  }

  void dispose() => _client.close();
}

/// Session-only credentials from the Postman auth/login response script.
class KanLoginTokens {
  const KanLoginTokens(
      {required this.accessToken,
      this.refreshToken,
      this.userId,
      this.mobileNumber,
      this.email});
  final String accessToken;
  final String? refreshToken;
  final int? userId;
  final String? mobileNumber;
  final String? email;
}
