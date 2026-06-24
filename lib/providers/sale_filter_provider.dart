import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/sale.dart';

enum SaleSortOption {
  newest,
  oldest,
  amountHighLow,
  amountLowHigh,
}

extension SaleSortLabel on SaleSortOption {
  String get label {
    switch (this) {
      case SaleSortOption.newest:        return 'Newest First';
      case SaleSortOption.oldest:        return 'Oldest First';
      case SaleSortOption.amountHighLow: return 'Amount: High → Low';
      case SaleSortOption.amountLowHigh: return 'Amount: Low → High';
    }
  }
}

class SaleFilterProvider extends ChangeNotifier {
  static const double kMaxAmount = 99999;

  // committed
  SaleSortOption _sortBy = SaleSortOption.newest;
  String _customerQuery = '';
  DateTimeRange? _dateRange;
  double _minAmount = 0;
  double _maxAmount = kMaxAmount;
  SaleChannel? _channel; // null = all

  SaleSortOption get sortBy => _sortBy;
  String get customerQuery => _customerQuery;
  DateTimeRange? get dateRange => _dateRange;
  double get minAmount => _minAmount;
  double get maxAmount => _maxAmount;
  SaleChannel? get channel => _channel;

  //  draft
  SaleSortOption draftSortBy = SaleSortOption.newest;
  String draftCustomerQuery = '';
  DateTimeRange? draftDateRange;
  RangeValues draftAmountRange = const RangeValues(0, kMaxAmount);
  SaleChannel? draftChannel; // null = all
  TextEditingController draftCustomerCtrl = TextEditingController();

  void initDraft() {
    draftSortBy = _sortBy;
    draftCustomerQuery = _customerQuery;
    draftDateRange = _dateRange;
    draftAmountRange = RangeValues(_minAmount, _maxAmount);
    draftChannel = _channel;
    draftCustomerCtrl.text = _customerQuery;
    notifyListeners();
  }

  void setDraftSort(SaleSortOption opt) { draftSortBy = opt; notifyListeners(); }
  void setDraftCustomer(String q) { draftCustomerQuery = q; notifyListeners(); }
  void setDraftDateRange(DateTimeRange? r) { draftDateRange = r; notifyListeners(); }
  void setDraftAmountRange(RangeValues v) { draftAmountRange = v; notifyListeners(); }
  void setDraftChannel(SaleChannel? c) { draftChannel = c; notifyListeners(); }

  void resetDraft() {
    draftSortBy = SaleSortOption.newest;
    draftCustomerQuery = '';
    draftCustomerCtrl.clear();
    draftDateRange = null;
    draftAmountRange = const RangeValues(0, kMaxAmount);
    draftChannel = null;
    notifyListeners();
  }

  void applyDraft() {
    _sortBy = draftSortBy;
    _customerQuery = draftCustomerQuery;
    _dateRange = draftDateRange;
    _minAmount = draftAmountRange.start;
    _maxAmount = draftAmountRange.end;
    _channel = draftChannel;
    notifyListeners();
  }

  int get draftActiveCount {
    int c = 0;
    if (draftSortBy != SaleSortOption.newest) c++;
    if (draftCustomerQuery.isNotEmpty) c++;
    if (draftDateRange != null) c++;
    if (draftAmountRange.start != 0 || draftAmountRange.end != kMaxAmount) c++;
    if (draftChannel != null) c++;
    return c;
  }

  int get activeFilterCount {
    int c = 0;
    if (_sortBy != SaleSortOption.newest) c++;
    if (_customerQuery.isNotEmpty) c++;
    if (_dateRange != null) c++;
    if (_minAmount != 0 || _maxAmount != kMaxAmount) c++;
    if (_channel != null) c++;
    return c;
  }

  void setSortBy(SaleSortOption opt) { _sortBy = opt; notifyListeners(); }
  void setCustomerQuery(String q) { _customerQuery = q; notifyListeners(); }
  void setDateRange(DateTimeRange? r) { _dateRange = r; notifyListeners(); }
  void setAmountRange(double min, double max) { _minAmount = min; _maxAmount = max; notifyListeners(); }
  void setChannel(SaleChannel? c) { _channel = c; notifyListeners(); }

  void reset() {
    _sortBy = SaleSortOption.newest;
    _customerQuery = '';
    _dateRange = null;
    _minAmount = 0;
    _maxAmount = kMaxAmount;
    _channel = null;
    notifyListeners();
  }

  List<Sale> apply(List<Sale> all) {
    var list = all.where((s) {
      if (_customerQuery.isNotEmpty) {
        final name = (s.customerName ?? '').toLowerCase();
        final receipt = s.receiptNumber.toString();
        if (!name.contains(_customerQuery.toLowerCase()) &&
            !receipt.contains(_customerQuery)) return false;
      }
      if (_dateRange != null) {
        final d = s.saleDate;
        final endOfDay = DateTime(
          _dateRange!.end.year,
          _dateRange!.end.month,
          _dateRange!.end.day,
          23, 59, 59,
        );
        if (d.isBefore(_dateRange!.start) || d.isAfter(endOfDay)) return false;
      }
      if (s.totalAmount < _minAmount || s.totalAmount > _maxAmount) return false;
      if (_channel != null && s.saleChannel != _channel) return false;
      return true;
    }).toList();

    switch (_sortBy) {
      case SaleSortOption.newest:
        list.sort((a, b) => b.saleDate.compareTo(a.saleDate)); break;
      case SaleSortOption.oldest:
        list.sort((a, b) => a.saleDate.compareTo(b.saleDate)); break;
      case SaleSortOption.amountHighLow:
        list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount)); break;
      case SaleSortOption.amountLowHigh:
        list.sort((a, b) => a.totalAmount.compareTo(b.totalAmount)); break;
    }
    return list;
  }
}