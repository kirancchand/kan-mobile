import '../models/kan_registration.dart';
import '../services/kan_auth_api.dart';
import '../models/map_location.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import 'whatsapp_group_repository.dart';

/// API authentication. Failed requests never create a local session.
class AuthRepository {
  AuthRepository(WhatsAppGroupRepository whatsAppGroupRepository,
      {KanAuthApi? api})
      : _api = api ?? KanAuthApi();

  final KanAuthApi _api;
  Future<String>? _refreshing;

  Future<String> validAccessToken() async {
    final current = _tokens;
    if (current == null) throw StateError('Sign in again.');
    return current.accessToken;
  }

  Future<String> refreshAccessToken(String rejectedToken) {
    final current = _tokens;
    if (current == null) return Future.error(StateError('Sign in again.'));
    // Another request may already have replaced the rejected access token.
    if (current.accessToken != rejectedToken) return validAccessToken();
    return _refreshing ??= _refreshSession(current, _sessionRevision);
  }

  Future<String> _refreshSession(KanLoginTokens current, int revision) async {
    try {
      final refreshToken = current.refreshToken;
      if (refreshToken == null || refreshToken.trim().isEmpty) {
        throw StateError('No refresh token. Sign in again.');
      }
      final refreshed = await _api.refreshAccessToken(refreshToken);
      if (revision != _sessionRevision) throw StateError('Session changed.');
      _tokens = KanLoginTokens(
        accessToken: refreshed.accessToken,
        refreshToken: refreshed.refreshToken,
        userId: current.userId,
        mobileNumber: current.mobileNumber,
        email: current.email,
      );
      _changes.value++;
      return refreshed.accessToken;
    } catch (_) {
      if (revision == _sessionRevision) clearSession();
      rethrow;
    } finally {
      if (revision == _sessionRevision) _refreshing = null;
    }
  }

  final _registering = <String>{};
  final _usernames = <String, String>{};
  final _loginProfiles = <String, AppUser>{};
  KanLoginTokens? _tokens;
  KanLoginTokens? get tokens => _tokens;
  bool _loggingIn = false;
  int _sessionRevision = 0;

  void clearSession({bool notify = true}) {
    _sessionRevision++;
    _tokens = null;
    _refreshing = null;
    if (notify) _changes.value++;
  }

  final Map<String, AppUser> _users = {};
  final _changes = ValueNotifier<int>(0);
  Listenable get changes => _changes;
  List<AppUser> get registeredUsers => List.unmodifiable(_users.values);
  void dispose() {
    clearSession(notify: false);
    _api.dispose();
    _changes.dispose();
  }

  Future<AppUser> login(String username, {required String password}) async {
    final loginName = username.trim();
    if (loginName.isEmpty || password.isEmpty) {
      throw ArgumentError('Enter a username and password.');
    }
    if (_loggingIn) throw StateError('Login is already in progress.');
    clearSession();
    final revision = _sessionRevision;
    _loggingIn = true;
    try {
      final receivedTokens =
          await _api.login(username: loginName, password: password);
      if (revision != _sessionRevision) throw StateError('Login cancelled.');
      // The collection defines tokens, but no profile or village response schema.
      // Reuse a registered profile or only the identity supplied at login.
      final user = _users[_usernames[loginName] ?? loginName] ??
          _loginProfiles.putIfAbsent(
              loginName,
              () => AppUser(
                    id: receivedTokens.userId?.toString() ??
                        'login_${Uri.encodeComponent(loginName)}',
                    name: loginName,
                    phone: RegExp(r'^\+?[0-9]{7,15}$').hasMatch(loginName)
                        ? loginName
                        : '',
                    locationId: '',
                  ));
      _tokens = receivedTokens;
      _changes.value++;
      return user;
    } finally {
      _loggingIn = false;
    }
  }

  Future<AppUser> register({
    required String name,
    required String phone,
    required String locationId,
    UserType userType = UserType.resident,
    MapLocation? mapLocation,
    KanRegistration? registration,
  }) async {
    if (_users.containsKey(phone.trim()) ||
        _registering.contains(phone.trim())) {
      throw StateError('This phone already has an account. Please log in.');
    }
    _registering.add(phone.trim());
    try {
      if (registration == null) {
        throw StateError(
            'Complete the registration form before creating an account.');
      }
      await _api.register(registration);

      final user = AppUser(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phone: phone.trim(),
        locationId: locationId,
        userType: userType,
        apiRegistered: true,
        mapLocation: mapLocation,
      );
      _users[phone.trim()] = user;
      _usernames[registration.username] = phone.trim();
      _changes.value++;
      return user;
    } finally {
      _registering.remove(phone.trim());
    }
  }
}
