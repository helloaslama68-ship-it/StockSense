import 'package:flutter/material.dart';
import '../models/product.dart';

class ScannerProvider extends ChangeNotifier {
  bool     _flashOn      = false;
  bool     _canScan      = true;
  Product? _foundProduct;

  bool     get flashOn      => _flashOn;
  bool     get canScan      => _canScan;
  Product? get foundProduct => _foundProduct;

  void toggleFlash() { _flashOn = !_flashOn; notifyListeners(); }

  void onProductFound(Product product) {
    _canScan = false; _foundProduct = product; notifyListeners();
  }

  void lockScan() { _canScan = false; notifyListeners(); }

  void reset() { _canScan = true; _foundProduct = null; notifyListeners(); }
}