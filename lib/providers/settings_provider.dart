import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool   _lowStockAlerts  = true;
  bool   _expiryAlerts    = true;
  bool   _creditDueAlerts = false;
  bool   _darkMode        = false;
  String _language        = 'English (EN)';

  bool   get lowStockAlerts  => _lowStockAlerts;
  bool   get expiryAlerts    => _expiryAlerts;
  bool   get creditDueAlerts => _creditDueAlerts;
  bool   get darkMode        => _darkMode;
  String get language        => _language;

  void setLowStockAlerts(bool v)  { _lowStockAlerts  = v; notifyListeners(); }
  void setExpiryAlerts(bool v)    { _expiryAlerts    = v; notifyListeners(); }
  void setCreditDueAlerts(bool v) { _creditDueAlerts = v; notifyListeners(); }
  void setDarkMode(bool v)        { _darkMode        = v; notifyListeners(); }
  void setLanguage(String v)      { _language        = v; notifyListeners(); }
}