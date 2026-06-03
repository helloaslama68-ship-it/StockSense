import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../providers/sale_form_provider.dart';

class SaleProvider extends ChangeNotifier {
  final Box<Sale> _box = Hive.box<Sale>('sales');
  final _uuid = const Uuid();

  // ── MIGRATION: wipe box if old schema detected (no items field)
  SaleProvider() {
    _migrateIfNeeded();
  }

  void _migrateIfNeeded() {
    try {
      // Try reading first sale — if it fails, old schema present
      if (_box.isNotEmpty) {
        _box.values.first.items; // will throw if old schema
      }
    } catch (_) {
      _box.clear(); // wipe old data, start fresh
    }
  }

  // ── QUERIES

  List<Sale> get allSales => _box.values.toList()
    ..sort((a, b) => b.saleDate.compareTo(a.saleDate));

  double get todaySalesTotal {
    final today = DateTime.now();
    return _box.values
        .where((s) =>
            s.saleDate.year == today.year &&
            s.saleDate.month == today.month &&
            s.saleDate.day == today.day)
        .fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  double get yesterdaySalesTotal {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _box.values
        .where((s) =>
            s.saleDate.year == yesterday.year &&
            s.saleDate.month == yesterday.month &&
            s.saleDate.day == yesterday.day)
        .fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  String get salesChangeLabel {
    final yesterday = yesterdaySalesTotal;
    if (yesterday == 0) return '+0% vs yesterday';
    final change = ((todaySalesTotal - yesterday) / yesterday) * 100;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(0)}% vs yesterday';
  }

  double get pendingCreditTotal => 0.0;

  // ── next receipt number (auto-increment)
  int get _nextReceiptNumber {
    if (_box.isEmpty) return 1001;
    return _box.values
            .map((s) => s.receiptNumber)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  // ── RECORD CART SALE
  // Called from SaleScreen when user taps Complete Sale
  Future<Sale> recordCartSale({
    required List<CartItem> cart,
    required double taxPercent,
    required String? customerName,
    String status = 'completed',
    String channel = 'in-store',
  }) async {
    final items = cart.map((c) {
      final item = SaleItem()
        ..productId = c.product.id
        ..productName = c.product.name
        ..sku = c.product.barcode
        ..quantity = c.quantity
        ..unitPrice = c.product.sellingPrice
        ..subtotal = c.subtotal;
      return item;
    }).toList();

    final sub = items.fold(0.0, (s, i) => s + i.subtotal);
    final taxAmt = sub * taxPercent / 100;

    final sale = Sale()
      ..id = _uuid.v4()
      ..customerName = customerName?.trim().isEmpty == true ? null : customerName?.trim()
      ..items = items
      ..subtotal = sub
      ..taxPercent = taxPercent
      ..taxAmount = taxAmt
      ..totalAmount = sub + taxAmt
      ..saleDate = DateTime.now()
      ..receiptNumber = _nextReceiptNumber
      ..status = status
      ..channel = channel;

    await _box.put(sale.id, sale);
    notifyListeners();
    return sale;
  }

  // ── DELETE SALE
  Future<void> deleteSale(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  void refresh() => notifyListeners();
}