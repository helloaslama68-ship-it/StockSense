import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';

// ---------------------------------------------------------------
// ALERT PROVIDER
// Handles:
// Low stock alerts
// Expiry alerts
// Refreshing UI updates
//
// Uses Hive local database to read product data.
// ----------------------------------------------------------------
class AlertProvider extends ChangeNotifier {

  // ── HIVE PRODUCT BOX 
  // Opens the local Hive storage box named "products"
  final Box<Product> _box = Hive.box<Product>('products');

  // -------------------------------------------------------
  // LOW STOCK ALERTS
  // Returns products where:
  // quantity <= lowStockThreshold
  // --------------------------------------------------
  List<Product> get lowStockAlerts =>

      _box.values

          // Filter low stock products
          .where(
            (p) => p.quantity <= p.lowStockThreshold,
          )

          // Convert to list
          .toList();

  // --------------------------------------------------------
  // EXPIRY ALERTS
  // Returns products expiring within 30 days
  // Also identifies expired products
  // --------------------------------------------------
  List<Map<String, dynamic>> get expiryAlerts {

    // Current date and time
    final now = DateTime.now();

    // Final result list
    final result = <Map<String, dynamic>>[];

    // Loop through all products
    for (final p in _box.values) {

      // Skip if expiry date is null
      if (p.expiryDate == null) continue;

      // Convert expiry string to DateTime
      final expiry = DateTime.tryParse(p.expiryDate!);

      // Skip invalid date
      if (expiry == null) continue;

      // Calculate days remaining
      final days = expiry.difference(now).inDays;

      // Add products expiring within 30 days
      if (days <= 30) {

        result.add({

          // Product object
          'product': p,

          // Remaining days
          'daysLeft': days,

          // Expired status
          'isExpired': days < 0,
        });
      }
    }

    // ── SORT ALERTS 
    // Closest expiry first
    result.sort(
      (a, b) =>
          (a['daysLeft'] as int)
              .compareTo(b['daysLeft'] as int),
    );

    return result;
  }

  // -------------------------------------------------------
  // REFRESH PROVIDER
  // Notifies listeners to rebuild UI
  // ---------------------------------------------------------
  void refresh() => notifyListeners();
}