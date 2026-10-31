import 'package:flutter/material.dart';

import '../data/models/admin_hierarchy.dart';

/// Admin session. Admin login is deliberately separate from the
/// resident login flow (Section 5, open question — kept separate here).
class AdminState extends ChangeNotifier {
  AdminAccount? _account;

  AdminAccount? get account => _account;
  String? get adminName => _account?.name;
  bool get isLoggedIn => _account != null;

  void login(AdminAccount account) {
    _account = account;
    notifyListeners();
  }

  void logout() {
    _account = null;
    notifyListeners();
  }
}
