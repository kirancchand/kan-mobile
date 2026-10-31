/// Shared base URLs corresponding to the Postman environment variables.
class ApiConfig {
  static const villageUrl = String.fromEnvironment(
    'village_url',
    defaultValue: 'http://localhost:5001',
  );
  static const villageAppId = String.fromEnvironment(
    'village_app_id',
    defaultValue: '1',
  );

  static const kanAuthUrl = String.fromEnvironment(
    'kan_auth_url',
    defaultValue: 'http://localhost:8084',
  );

  static const kanUrl = String.fromEnvironment(
    'kan_url',
    defaultValue: 'http://localhost:8070',
  );

  static Uri registrationUri([String baseUrl = kanAuthUrl]) =>
      _uri(baseUrl, '/auth/register');

  static Uri loginUri([String baseUrl = kanAuthUrl]) =>
      _uri(baseUrl, '/auth/login');

  static Uri refreshAccessTokenUri([String baseUrl = kanAuthUrl]) =>
      _uri(baseUrl, '/auth/refresh-accesstoken');

  static Uri kanUri(String path, {String baseUrl = kanUrl}) =>
      _uri(baseUrl, path);

  static Uri _uri(String baseUrl, String path) {
    final base = Uri.parse(baseUrl.trim());
    if (!['http', 'https'].contains(base.scheme) ||
        base.host.isEmpty ||
        base.hasQuery ||
        base.hasFragment ||
        base.userInfo.isNotEmpty) {
      throw const FormatException('API base URL must be an HTTP(S) URL.');
    }
    if (!path.startsWith('/') ||
        path.startsWith('//') ||
        path.contains('?') ||
        path.contains('#')) {
      throw const FormatException(
          'Use an absolute API path without query or fragment.');
    }
    return base.replace(
        path: '${base.path.replaceFirst(RegExp(r'/+$'), '')}$path');
  }
}
