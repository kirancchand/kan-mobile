import '../models/delivery_user.dart';

/// Delivery authentication requires a backend-issued regional account.
class DeliveryAuthRepository {
  Future<DeliveryUser> login(String phone, String pin) async {
    throw StateError(
        'Delivery sign-in is not available. Contact your administrator.');
  }
}
