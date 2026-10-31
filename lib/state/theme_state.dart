import 'package:flutter/material.dart';

/// Drives light/dark mode (design guidelines §2 — "support dark mode from
/// day one"). Defaults to light mode; the Settings screen lets the user
/// turn dark mode on or off.
class ThemeState extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void setDark(bool dark) {
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void useSystemTheme() {
    _mode = ThemeMode.system;
    notifyListeners();
  }
}
