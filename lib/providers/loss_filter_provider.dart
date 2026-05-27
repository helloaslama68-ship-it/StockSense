import 'package:flutter/material.dart';

class LossFilterProvider extends ChangeNotifier {
  String _filter = 'All';
  static const filters = ['All', 'Damaged', 'Spoiled', 'Expired'];

  String get filter => _filter;
  void setFilter(String f) { _filter = f; notifyListeners(); }

  // edit-sheet state
  String? _selectedProductId;
  String? _selectedProductName;
  String  _reason = 'damaged';

  String? get selectedProductId   => _selectedProductId;
  String? get selectedProductName => _selectedProductName;
  String  get reason              => _reason;

  void setSelectedProduct(String id, String name) {
    _selectedProductId = id; _selectedProductName = name; notifyListeners();
  }

  void setReason(String r) { _reason = r; notifyListeners(); }

  void resetSheet() {
    _selectedProductId = null; _selectedProductName = null; _reason = 'damaged';
    notifyListeners();
  }
}