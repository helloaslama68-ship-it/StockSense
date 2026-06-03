import 'package:flutter/material.dart';
import '../models/purchase_record.dart';

enum PurchaseSortOption {
  newest,
  oldest,
  amountHighLow,
  amountLowHigh,
  qtyHighLow,
  qtyLowHigh,
}

extension PurchaseSortLabel on PurchaseSortOption {
  String get label {
    switch (this) {
      case PurchaseSortOption.newest:       return 'Newest First';
      case PurchaseSortOption.oldest:       return 'Oldest First';
      case PurchaseSortOption.amountHighLow: return 'Amount: High → Low';
      case PurchaseSortOption.amountLowHigh: return 'Amount: Low → High';
      case PurchaseSortOption.qtyHighLow:   return 'Qty: High → Low';
      case PurchaseSortOption.qtyLowHigh:   return 'Qty: Low → High';
    }
  }
}

class PurchaseFilterProvider extends ChangeNotifier {
  // ── sort
  PurchaseSortOption _sortBy = PurchaseSortOption.newest;
  PurchaseSortOption get sortBy => _sortBy;

  // ── supplier search
  String _supplierQuery = '';
  String get supplierQuery => _supplierQuery;

  // ── date range
  DateTimeRange? _dateRange;
  DateTimeRange? get dateRange => _dateRange;

  // ── min amount filter
  double _minAmount = 0;
  double _maxAmount = 99999;
  double get minAmount => _minAmount;
  double get maxAmount => _maxAmount;

  bool get isActive =>
      _sortBy != PurchaseSortOption.newest ||
      _supplierQuery.isNotEmpty ||
      _dateRange != null ||
      _minAmount != 0 ||
      _maxAmount != 99999;

  int get activeFilterCount {
    int c = 0;
    if (_sortBy != PurchaseSortOption.newest) c++;
    if (_supplierQuery.isNotEmpty) c++;
    if (_dateRange != null) c++;
    if (_minAmount != 0 || _maxAmount != 99999) c++;
    return c;
  }

  void setSortBy(PurchaseSortOption opt) {
    _sortBy = opt;
    notifyListeners();
  }

  void setSupplierQuery(String q) {
    _supplierQuery = q;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? r) {
    _dateRange = r;
    notifyListeners();
  }

  void setAmountRange(double min, double max) {
    _minAmount = min;
    _maxAmount = max;
    notifyListeners();
  }

  void reset() {
    _sortBy = PurchaseSortOption.newest;
    _supplierQuery = '';
    _dateRange = null;
    _minAmount = 0;
    _maxAmount = 99999;
    notifyListeners();
  }

  List<PurchaseRecord> apply(List<PurchaseRecord> all) {
    var list = all.where((p) {
      // supplier filter
      if (_supplierQuery.isNotEmpty &&
          !p.supplierName
              .toLowerCase()
              .contains(_supplierQuery.toLowerCase())) {
        return false;
      }
      // date range filter
      if (_dateRange != null) {
        final d = p.purchaseDate;
        if (d.isBefore(_dateRange!.start) ||
            d.isAfter(
                _dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      // amount filter
      if (p.totalAmount < _minAmount || p.totalAmount > _maxAmount) {
        return false;
      }
      return true;
    }).toList();

    switch (_sortBy) {
      case PurchaseSortOption.newest:
        list.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
      case PurchaseSortOption.oldest:
        list.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
        break;
      case PurchaseSortOption.amountHighLow:
        list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case PurchaseSortOption.amountLowHigh:
        list.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
      case PurchaseSortOption.qtyHighLow:
        list.sort(
            (a, b) => b.quantityPurchased.compareTo(a.quantityPurchased));
        break;
      case PurchaseSortOption.qtyLowHigh:
        list.sort(
            (a, b) => a.quantityPurchased.compareTo(b.quantityPurchased));
        break;
    }
    return list;
  }
}