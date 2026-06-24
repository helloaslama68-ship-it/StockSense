import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/purchase_record.dart';

class PurchaseProvider with ChangeNotifier {
  
  Box<PurchaseRecord> get _box => Hive.box<PurchaseRecord>('purchase_records');

  List<PurchaseRecord> get allPurchases => _box.values.toList()
    ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

  double get monthlyTotal =>
      _box.values.fold(0, (s, p) => s + p.totalAmount);

  int get supplierCount =>
      _box.values.map((p) => p.supplierName).toSet().length;

  void addPurchase(PurchaseRecord record) {
    _box.put(record.id, record);
    notifyListeners();
  }

  void deletePurchase(String id) {
    _box.delete(id);
    notifyListeners();
  }

  void updatePurchase(PurchaseRecord updated) {
    _box.put(updated.id, updated);
    notifyListeners();
  }
}