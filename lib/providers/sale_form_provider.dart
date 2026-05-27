import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.sellingPrice * quantity;
}

class SaleFormProvider extends ChangeNotifier {
  // SaleScreen state 
  DateTime _saleDate = DateTime.now();
  final List<CartItem> _cart = [];
  double _taxPercent = 0;

  DateTime get saleDate => _saleDate;
  List<CartItem> get cart => List.unmodifiable(_cart);
  double get taxPercent => _taxPercent;

  double get subtotal    => _cart.fold(0, (s, i) => s + i.subtotal);
  double get taxAmount   => subtotal * _taxPercent / 100;
  double get totalAmount => subtotal + taxAmount;

  void setSaleDate(DateTime d) { _saleDate = d; notifyListeners(); }
  void setTaxPercent(double v) { _taxPercent = v.clamp(0, 100); notifyListeners(); }

  void addOrIncrementProduct(Product product) {
    final i = _cart.indexWhere((c) => c.product.id == product.id);
    if (i >= 0) { _cart[i].quantity++; } else { _cart.add(CartItem(product: product)); }
    notifyListeners();
  }

  void removeAt(int index) { _cart.removeAt(index); notifyListeners(); }

  void decrementAt(int index) {
    if (_cart[index].quantity > 1) { _cart[index].quantity--; } else { _cart.removeAt(index); }
    notifyListeners();
  }

  void incrementAt(int index) { _cart[index].quantity++; notifyListeners(); }

  void seedProduct(Product product) {
    if (_cart.isEmpty) { _cart.add(CartItem(product: product)); notifyListeners(); }
  }

  void reset() { _saleDate = DateTime.now(); _cart.clear(); _taxPercent = 0; notifyListeners(); }

  //  ProductPickerSheet state 
  Product? _selectedProduct;
  int _pickerQuantity = 1;

  Product? get selectedProduct => _selectedProduct;
  int      get pickerQuantity  => _pickerQuantity;
  double   get calculatedTotal => (_selectedProduct?.sellingPrice ?? 0) * _pickerQuantity;

  void selectProduct(Product p) { _selectedProduct = p; _pickerQuantity = 1; notifyListeners(); }
  void clearSelection() { _selectedProduct = null; notifyListeners(); }

  void incrementPickerQty() {
    final max = _selectedProduct?.quantity ?? 999;
    if (_pickerQuantity < max) { _pickerQuantity++; notifyListeners(); }
  }

  void decrementPickerQty() {
    if (_pickerQuantity > 1) { _pickerQuantity--; notifyListeners(); }
  }

  void resetPicker() { _selectedProduct = null; _pickerQuantity = 1; notifyListeners(); }
}