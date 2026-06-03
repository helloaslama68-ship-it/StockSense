import 'package:flutter/material.dart';
import '../models/purchase_record.dart';
import '../models/purchase_line_item.dart';

class PurchaseProvider with ChangeNotifier {
  final List<PurchaseRecord> _purchases = [
    PurchaseRecord(
      id: '94021',
      productName: 'Fresh Produce Restock',
      supplierName: 'Green Valley Organics',
      quantityPurchased: 205,
      totalAmount: 1245.50,
      taxPercent: 7,
      purchaseDate: DateTime(2025, 10, 25, 10, 30),
      lineItems: [
        PurchaseLineItem(productName: 'Whole Milk 1L',  costPrice: 1.20, quantity: 50,  unit: 'units'),
        PurchaseLineItem(productName: 'Organic Oranges', costPrice: 0.85, quantity: 120, unit: 'units'),
        PurchaseLineItem(productName: 'Fresh Carrots 5kg', costPrice: 4.50, quantity: 20, unit: 'units'),
        PurchaseLineItem(productName: 'Artisan Sourdough', costPrice: 2.50, quantity: 15, unit: 'units'),
      ],
    ),
    PurchaseRecord(
      id: '2',
      productName: 'Dairy Supply',
      supplierName: 'Lakeside Creamery',
      quantityPurchased: 45,
      totalAmount: 215.00,
      taxPercent: 0,
      purchaseDate: DateTime(2025, 10, 24, 8, 15),
      lineItems: [
        PurchaseLineItem(productName: 'Full Cream Milk', costPrice: 2.80, quantity: 30, unit: 'L'),
        PurchaseLineItem(productName: 'Cheddar Cheese',  costPrice: 5.50, quantity: 15, unit: 'units'),
      ],
    ),
    PurchaseRecord(
      id: '3',
      productName: 'Dry Goods Bulk',
      supplierName: 'Global Pantry Wholesalers',
      quantityPurchased: 300,
      totalAmount: 1120.00,
      taxPercent: 5,
      purchaseDate: DateTime(2025, 10, 22, 14, 45),
    ),
    PurchaseRecord(
      id: '4',
      productName: 'Artisan Bakery Items',
      supplierName: 'Old Mill Flour Co.',
      quantityPurchased: 60,
      totalAmount: 380.00,
      taxPercent: 0,
      purchaseDate: DateTime(2025, 10, 21, 9, 0),
    ),
    PurchaseRecord(
      id: '5',
      productName: 'Packaging Supplies',
      supplierName: 'EcoPack Solutions',
      quantityPurchased: 500,
      totalAmount: 89.50,
      taxPercent: 0,
      purchaseDate: DateTime(2025, 10, 15, 11, 30),
    ),
  ];

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