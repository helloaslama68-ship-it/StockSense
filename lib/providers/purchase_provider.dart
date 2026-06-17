import 'package:flutter/material.dart';
import '../models/purchase_record.dart';

class PurchaseProvider with ChangeNotifier {
  final List<PurchaseRecord> _purchases = [];

  List<PurchaseRecord> get allPurchases => List.unmodifiable(_purchases);

  double get monthlyTotal =>
      _purchases.fold(0, (s, p) => s + p.totalAmount);

  int get supplierCount =>
      _purchases.map((p) => p.supplierName).toSet().length;

  void addPurchase(PurchaseRecord record) {
    _purchases.insert(0, record);
    notifyListeners();
  }

  void deletePurchase(String id) {
    _purchases.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updatePurchase(PurchaseRecord updated) {
    final i = _purchases.indexWhere((p) => p.id == updated.id);
    if (i != -1) {
      _purchases[i] = updated;
      notifyListeners();
    }
  }
}