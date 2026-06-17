import 'package:flutter/material.dart';
import '../models/purchase_line_item.dart';
import '../models/purchase_record.dart';

class PurchaseFormProvider with ChangeNotifier {
  String supplierName = '';
  DateTime? purchaseDate;
  double taxPercent = 0;
  final List<PurchaseLineItem> items = [];

  // TEMP STATE FOR ADD/EDIT SHEET
  String? _tempImagePath;
  String _tempUnit = 'units';

  String? get tempImagePath => _tempImagePath;
  String get tempUnit => _tempUnit;

  void setTempImage(String? path) {
    _tempImagePath = path;
    notifyListeners();
  }

  void setTempUnit(String unit) {
    _tempUnit = unit;
    notifyListeners();
  }

  void initTempForNew() {
    _tempImagePath = null;
    _tempUnit = 'units';
  }

  void initTempForEdit(PurchaseLineItem item) {
    _tempImagePath = item.imagePath;
    _tempUnit = item.unit;
  }

  //  TOTALS 
  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get taxAmount => subtotal * taxPercent / 100;
  double get finalTotal => subtotal + taxAmount;

  void setSupplier(String v) { supplierName = v; notifyListeners(); }

  void setDate(DateTime d) { purchaseDate = d; notifyListeners(); }

  void setTax(double v) { taxPercent = v.clamp(0, 100); notifyListeners(); }

  void addItem(PurchaseLineItem item) { items.add(item); notifyListeners(); }

  void updateItem(int index, PurchaseLineItem item) {
    items[index] = item;
    notifyListeners();
  }

  void removeItem(int index) { items.removeAt(index); notifyListeners(); }

  PurchaseRecord toRecord() => PurchaseRecord(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    productName: items.map((i) => i.productName).join(', '),
    supplierName: supplierName,
    quantityPurchased: items.fold(0, (s, i) => s + i.quantity),
    totalAmount: finalTotal,
    taxPercent: taxPercent,
    purchaseDate: purchaseDate ?? DateTime.now(),
    imagePath: items.isNotEmpty ? items.first.imagePath : null,
    lineItems: List.from(items),
  );

  void reset() {
    supplierName = '';
    purchaseDate = null;
    taxPercent = 0;
    items.clear();
    _tempImagePath = null;
    _tempUnit = 'units';
    notifyListeners();
  }
}