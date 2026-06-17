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
      case PurchaseSortOption.newest:        return 'Newest First';
      case PurchaseSortOption.oldest:        return 'Oldest First';
      case PurchaseSortOption.amountHighLow: return 'Amount: High → Low';
      case PurchaseSortOption.amountLowHigh: return 'Amount: Low → High';
      case PurchaseSortOption.qtyHighLow:    return 'Qty: High → Low';
      case PurchaseSortOption.qtyLowHigh:    return 'Qty: Low → High';
    }
  }
}

class PurchaseFilterProvider extends ChangeNotifier {
  static const double kMaxAmount = 99999;

  // ── committed state (drives the list)
  PurchaseSortOption _sortBy = PurchaseSortOption.newest;
  String _supplierQuery = '';
  DateTimeRange? _dateRange;
  double _minAmount = 0;
  double _maxAmount = kMaxAmount;

  PurchaseSortOption get sortBy => _sortBy;
  String get supplierQuery => _supplierQuery;
  DateTimeRange? get dateRange => _dateRange;
  double get minAmount => _minAmount;
  double get maxAmount => _maxAmount;

  // ── draft state (lives in sheet, no setState needed)
  PurchaseSortOption draftSortBy = PurchaseSortOption.newest;
  String draftSupplierQuery = '';
  DateTimeRange? draftDateRange;
  RangeValues draftAmountRange = const RangeValues(0, kMaxAmount);
  TextEditingController draftSupplierCtrl = TextEditingController();

  void initDraft() {
    draftSortBy = _sortBy;
    draftSupplierQuery = _supplierQuery;
    draftDateRange = _dateRange;
    draftAmountRange = RangeValues(_minAmount, _maxAmount);
    draftSupplierCtrl.text = _supplierQuery;
    notifyListeners();
  }

  void setDraftSort(PurchaseSortOption opt) {
    draftSortBy = opt;
    notifyListeners();
  }

  void setDraftSupplier(String q) {
    draftSupplierQuery = q;
    notifyListeners();
  }

  void setDraftDateRange(DateTimeRange? r) {
    draftDateRange = r;
    notifyListeners();
  }

  void setDraftAmountRange(RangeValues v) {
    draftAmountRange = v;
    notifyListeners();
  }

  void resetDraft() {
    draftSortBy = PurchaseSortOption.newest;
    draftSupplierQuery = '';
    draftSupplierCtrl.clear();
    draftDateRange = null;
    draftAmountRange = const RangeValues(0, kMaxAmount);
    notifyListeners();
  }

  void applyDraft() {
    _sortBy = draftSortBy;
    _supplierQuery = draftSupplierQuery;
    _dateRange = draftDateRange;
    _minAmount = draftAmountRange.start;
    _maxAmount = draftAmountRange.end;
    notifyListeners();
  }

  int get draftActiveCount {
    int c = 0;
    if (draftSortBy != PurchaseSortOption.newest) c++;
    if (draftSupplierQuery.isNotEmpty) c++;
    if (draftDateRange != null) c++;
    if (draftAmountRange.start != 0 || draftAmountRange.end != kMaxAmount) c++;
    return c;
  }

  // ── committed helpers
  bool get isActive =>
      _sortBy != PurchaseSortOption.newest ||
      _supplierQuery.isNotEmpty ||
      _dateRange != null ||
      _minAmount != 0 ||
      _maxAmount != kMaxAmount;

  int get activeFilterCount {
    int c = 0;
    if (_sortBy != PurchaseSortOption.newest) c++;
    if (_supplierQuery.isNotEmpty) c++;
    if (_dateRange != null) c++;
    if (_minAmount != 0 || _maxAmount != kMaxAmount) c++;
    return c;
  }

  void setSortBy(PurchaseSortOption opt) { _sortBy = opt; notifyListeners(); }
  void setSupplierQuery(String q) { _supplierQuery = q; notifyListeners(); }
  void setDateRange(DateTimeRange? r) { _dateRange = r; notifyListeners(); }
  void setAmountRange(double min, double max) {
    _minAmount = min; _maxAmount = max; notifyListeners();
  }

  void reset() {
    _sortBy = PurchaseSortOption.newest;
    _supplierQuery = '';
    _dateRange = null;
    _minAmount = 0;
    _maxAmount = kMaxAmount;
    notifyListeners();
  }

  List<PurchaseRecord> apply(List<PurchaseRecord> all) {
    var list = all.where((p) {
      if (_supplierQuery.isNotEmpty &&
          !p.supplierName.toLowerCase().contains(_supplierQuery.toLowerCase())) {
        return false;
      }
      if (_dateRange != null) {
        final d = p.purchaseDate;
        if (d.isBefore(_dateRange!.start) ||
            d.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      if (p.totalAmount < _minAmount || p.totalAmount > _maxAmount) return false;
      return true;
    }).toList();

    switch (_sortBy) {
      case PurchaseSortOption.newest:
        list.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate)); break;
      case PurchaseSortOption.oldest:
        list.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate)); break;
      case PurchaseSortOption.amountHighLow:
        list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount)); break;
      case PurchaseSortOption.amountLowHigh:
        list.sort((a, b) => a.totalAmount.compareTo(b.totalAmount)); break;
      case PurchaseSortOption.qtyHighLow:
        list.sort((a, b) => b.quantityPurchased.compareTo(a.quantityPurchased)); break;
      case PurchaseSortOption.qtyLowHigh:
        list.sort((a, b) => a.quantityPurchased.compareTo(b.quantityPurchased)); break;
    }
    return list;
  }
}