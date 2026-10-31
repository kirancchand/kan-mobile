import 'package:flutter/foundation.dart';
import '../data/models/delivery_user.dart';
import '../data/repositories/delivery_auth_repository.dart';

class DeliverySession extends ChangeNotifier {
  DeliverySession({DeliveryAuthRepository? repository})
      : _repository = repository ?? DeliveryAuthRepository();
  final DeliveryAuthRepository _repository;
  DeliveryUser? _user;
  int _request = 0;
  DeliveryUser? get currentUser => _user;

  Future<void> login(String phone, String pin) async {
    final request = ++_request;
    final user = await _repository.login(phone, pin);
    if (request != _request) return;
    _user = user;
    notifyListeners();
  }

  void signOut() {
    _request++;
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _request++;
    super.dispose();
  }
}
