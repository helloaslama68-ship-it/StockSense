import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';


// ALERT PROVIDER
// Handles:
// - Low stock alerts
// - Expiry alerts
// - Tab filter selection (selectedTab)
// - Refreshing UI updates
//
// Uses Hive local database to read product data.

class AlertProvider extends ChangeNotifier {

  // HIVE PRODUCT BOX
  final Box<Product> _box = Hive.box<Product>('products');

  //TAB FILTER STATE
  
  static const List<String> tabs = ['All', 'Low Stock', 'Expiry', 'High Due'];
  String _selectedTab = 'All';
  String get selectedTab => _selectedTab;

  void selectTab(String tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  // LOW STOCK ALERTS
  List<Product> get lowStockAlerts =>
      _box.values
          .where((p) => p.quantity <= p.lowStockThreshold)
          .toList();

  // EXPIRY ALERTS
  List<Map<String, dynamic>> get expiryAlerts {
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

  // REFRESH
  void refresh() => notifyListeners();
}