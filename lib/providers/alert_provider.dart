import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';
import '../providers/settings_provider.dart';

class AlertProvider extends ChangeNotifier {
  final Box<Product> _box = Hive.box<Product>('products');
  SettingsProvider? _settings;

  static const List<String> tabs = ['All', 'Low Stock', 'Expiry', 'High Due'];
  String _selectedTab = 'All';
  String get selectedTab => _selectedTab;

  void update(SettingsProvider settings) {
    _settings = settings;
    notifyListeners();
  }

  void selectTab(String tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  List<Product> get lowStockAlerts {
    if (_settings != null && !_settings!.lowStockAlerts) return [];
    return _box.values
        .where((p) => p.quantity <= p.lowStockThreshold)
        .toList();
  }

  List<Map<String, dynamic>> get expiryAlerts {
    if (_settings != null && !_settings!.expiryAlerts) return [];
    final now    = DateTime.now();
    final result = <Map<String, dynamic>>[];
    for (final p in _box.values) {
      if (p.expiryDate == null) continue;
      final expiry = DateTime.tryParse(p.expiryDate!);
      if (expiry == null) continue;
      final days = expiry.difference(now).inDays;
      if (days <= 30) {
        result.add({
          'product':   p,
          'daysLeft':  days,
          'isExpired': days < 0,
        });
      }
    }
    result.sort((a, b) =>
        (a['daysLeft'] as int).compareTo(b['daysLeft'] as int));
    return result;
  }

  void refresh() => notifyListeners();
}