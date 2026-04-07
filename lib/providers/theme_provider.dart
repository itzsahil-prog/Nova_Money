import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box(AppConstants.settingsBoxName);
    _isDark = box.get(AppConstants.darkModeKey, defaultValue: false);
  }

  void toggleTheme() {
    _isDark = !_isDark;
    Hive.box(AppConstants.settingsBoxName).put(AppConstants.darkModeKey, _isDark);
    notifyListeners();
  }
}
