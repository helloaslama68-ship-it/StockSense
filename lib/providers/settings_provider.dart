import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  Box get _box => Hive.box('settings');

  bool get lowStockAlerts =>
      _box.get('lowStockAlerts', defaultValue: true) as bool;

  bool get expiryAlerts =>
      _box.get('expiryAlerts', defaultValue: true) as bool;

  bool get creditDueAlerts =>
      _box.get('creditDueAlerts', defaultValue: false) as bool;

  
  String get _themeModeKey =>
      _box.get('themeMode', defaultValue: 'system') as String;

  ThemeMode get themeMode {
    switch (_themeModeKey) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  
  bool get darkMode => _themeModeKey == 'dark';

  void setThemeMode(ThemeMode mode) {
    final key = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    _box.put('themeMode', key);
    notifyListeners();
  }

  void setLowStockAlerts(bool value) {
    _box.put('lowStockAlerts', value);
    notifyListeners();
  }

  void setExpiryAlerts(bool value) {
    _box.put('expiryAlerts', value);
    notifyListeners();
  }

  void setCreditDueAlerts(bool value) {
    _box.put('creditDueAlerts', value);
    notifyListeners();
  }

  /// Legacy compat
  void setDarkMode(bool value) => setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
}