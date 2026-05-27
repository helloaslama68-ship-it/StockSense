import 'package:flutter/material.dart';
import '../models/product.dart';

class LogLossFormProvider extends ChangeNotifier {
  Product?  _selectedProduct;
  String    _lossType     = 'Spoiled';
  DateTime? _incidentDate;

  Product?  get selectedProduct => _selectedProduct;
  String    get lossType        => _lossType;
  DateTime? get incidentDate    => _incidentDate;

  void setProduct(Product? p)    { _selectedProduct = p; notifyListeners(); }
  void setLossType(String t)     { _lossType = t; notifyListeners(); }
  void setIncidentDate(DateTime d) { _incidentDate = d; notifyListeners(); }

  void reset() {
    _selectedProduct = null; _lossType = 'Spoiled'; _incidentDate = null;
    notifyListeners();
  }
}