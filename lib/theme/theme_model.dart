import 'package:flutter/material.dart';
import 'package:novacole/theme/theme_preference.dart';

enum ThemeType { light, dark }

class ThemeModel extends ChangeNotifier {
  bool _isDark = false;
  final ThemePreferences _preferences = ThemePreferences();

  bool get isDark => _isDark;

  ThemeModel() {
    getPreferences();
  }

//Switching themes in the flutter apps - Flutterant
  set isDark(bool value) {
    _isDark = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preferences.getTheme();
    notifyListeners();
  }
}
