import 'package:flutter/material.dart';

class StockSortProvider extends ChangeNotifier {
  int _sortIndex = 0;
  int get sortIndex => _sortIndex;

  static const labels = ['BY NAME', 'STOCK ↑', 'STOCK ↓', 'VALUE ↓'];
  String get currentLabel => labels[_sortIndex];

  void next() {
    _sortIndex = (_sortIndex + 1) % labels.length;
    notifyListeners();
  }

  void reset() {
    _sortIndex = 0;
    notifyListeners();
  }
}