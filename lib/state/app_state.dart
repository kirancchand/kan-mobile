import '../data/models/kan_registration.dart';
import 'package:flutter/material.dart';
import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/whatsapp_group_repository.dart';

/// Top-level app state: who's logged in and whether onboarding is done.
/// Deliberately small — each feature owns its own data-fetching state
/// instead of piling everything into one global provider.
class AppState extends ChangeNotifier {
  AppState(
      {required WhatsAppGroupRepository whatsAppGroupRepository,
      required AuthRepository authRepository})
      : _whatsAppGroupRepository = whatsAppGroupRepository,
        _authRepository = authRepository;

  final WhatsAppGroupRepository _whatsAppGroupRepository;
  final AuthRepository _authRepository;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isRegistered => _currentUser != null;

  WhatsAppGroupRepository get whatsAppGroupRepository =>
      _whatsAppGroupRepository;

  Future<AppUser> register({
    required String name,
    required String phone,
    required String locationId,
    KanRegistration? registration,
  }) async {
    final user = await _authRepository.register(
        name: name,
        phone: phone,
        locationId: locationId,
        registration: registration);
    // Registration does not issue tokens; the user must sign in afterwards.
    return user;
  }

  Future<void> login(String username, {required String password}) async {
    _currentUser = null;
    notifyListeners();
    _currentUser = await _authRepository.login(username, password: password);
    notifyListeners();
  }

  void signOut() {
    _authRepository.clearSession();
    _currentUser = null;
    notifyListeners();
  }
}
