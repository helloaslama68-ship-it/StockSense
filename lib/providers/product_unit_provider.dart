import 'package:flutter/material.dart';

class ProductUnitProvider extends ChangeNotifier {
  String? _selectedUnit;
  String? get selectedUnit => _selectedUnit;

  void setUnit(String? unit) { _selectedUnit = unit; notifyListeners(); }
  void reset()               { _selectedUnit = null; notifyListeners(); }
}