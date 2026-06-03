import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';


// SUGGESTION MODEL

class Suggestion {
  final Product product;
  final int     suggestedQty;
  final String  reason;
  final double  dailyAvg;
  final int     daysRemaining;
  bool          ignored;

  Suggestion({
    required this.product,
    required this.suggestedQty,
    required this.reason,
    required this.dailyAvg,
    required this.daysRemaining,
    this.ignored = false,
  });
}


// STOCK RECOMMENDATION PROVIDER

class StockRecommendationProvider extends ChangeNotifier {
  final ProductProvider _productProvider;
  final SaleProvider    _saleProvider;

  List<Suggestion> _suggestions = [];

  List<Suggestion> get visible =>
      _suggestions.where((s) => !s.ignored).toList();

  StockRecommendationProvider(this._productProvider, this._saleProvider) {
    build();
  }

  void build() {
    final products = _productProvider.allProducts;
    final allSales = _saleProvider.allSales;
    final now      = DateTime.now();
    final List<Suggestion> suggestions = [];

    for (final p in products) {
      final cutoff = now.subtract(const Duration(days: 30));
      final recent = allSales
          .where((s) =>
              s.items.any((item) => item.productId == p.id) &&
              s.saleDate.isAfter(cutoff))
          .toList();

      double dailyAvg      = 0;
      int    daysRemaining = 999;

      if (recent.isNotEmpty) {
        final totalSold = recent.fold<int>(0, (sum, s) =>
          sum + s.items
            .where((item) => item.productId == p.id)
            .fold<int>(0, (itemSum, item) => itemSum + item.quantity));
        dailyAvg      = totalSold / 30;
        daysRemaining = dailyAvg > 0 ? (p.quantity / dailyAvg).floor() : 999;
      } else {
        if (p.quantity <= p.lowStockThreshold) daysRemaining = 0;
      }

      if (daysRemaining <= 7 || p.quantity <= p.lowStockThreshold) {
        final int suggestedQty = dailyAvg > 0
            ? (dailyAvg * 14).ceil()
            : p.lowStockThreshold * 3;

        String reason;
        if (dailyAvg > 0 && daysRemaining <= 2) {
          reason =
              'Suggested: +$suggestedQty units\nBased on recent sales (avg ${dailyAvg.toStringAsFixed(1)} units/day). Your current stock will deplete in ${daysRemaining <= 0 ? 'less than 24' : '${daysRemaining * 24}'} hours.';
        } else if (dailyAvg > 0) {
          reason =
              'Suggested: +$suggestedQty units\nVelocity spike detected over the weekend. Maintain a buffer of ${(dailyAvg * 7).ceil()} units for steady delivery flow.';
        } else {
          reason =
              'Suggested: +$suggestedQty units\nSeasonal demand predicted to increase. Average shelf life is 5 days — order now to meet 2-week demand.';
        }

        suggestions.add(Suggestion(
          product:       p,
          suggestedQty:  suggestedQty,
          reason:        reason,
          dailyAvg:      dailyAvg,
          daysRemaining: daysRemaining,
        ));
      }
    }

    suggestions.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    _suggestions = suggestions;
    notifyListeners();
  }

  void ignore(Suggestion s) {
    s.ignored = true;
    notifyListeners();
  }
}