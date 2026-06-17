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

  bool get darkMode =>
      _box.get('darkMode', defaultValue: false) as bool;

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

  void setDarkMode(bool value) {
    _box.put('darkMode', value);
    notifyListeners();
  }
}