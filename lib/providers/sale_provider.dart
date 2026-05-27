import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/sale.dart';


// SALE PROVIDER
// Handles all sale-related operations using Hive
// and updates UI with ChangeNotifier.

class SaleProvider extends ChangeNotifier {

  // Hive box used to store sales locally
  final Box<Sale> _box = Hive.box<Sale>('sales');

  // UUID generator for unique sale IDs
  final _uuid = const Uuid();

  
  // GET ALL SALES
  // Returns all sales sorted by latest first
  
  List<Sale> get allSales => _box.values.toList()
    ..sort((a, b) => b.saleDate.compareTo(a.saleDate));

  
  // TODAY SALES TOTAL
  // Calculates total sales amount for today
  
  double get todaySalesTotal {
    final today = DateTime.now();
    return _box.values
        .where((s) =>
            s.saleDate.year == today.year &&
            s.saleDate.month == today.month &&
            s.saleDate.day == today.day)
        .fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  
  // YESTERDAY SALES TOTAL
  // Calculates total sales amount for yesterday
  
  double get yesterdaySalesTotal {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _box.values
        .where((s) =>
            s.saleDate.year == yesterday.year &&
            s.saleDate.month == yesterday.month &&
            s.saleDate.day == yesterday.day)
        .fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  
  // SALES CHANGE LABEL
  // Returns % change vs yesterday as display string
  // e.g. "+12% vs yesterday" or "-5% vs yesterday"
  
  String get salesChangeLabel {
    final yesterday = yesterdaySalesTotal;
    if (yesterday == 0) return '+0% vs yesterday';
    final change = ((todaySalesTotal - yesterday) / yesterday) * 100;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(0)}% vs yesterday';
  }

  
  // PENDING CREDIT TOTAL
  
  double get pendingCreditTotal => 1450.0;

  
  // RECORD SALE
  // Creates and saves a new sale record
  Future<void> recordSale({
    required String productId,
    required String productName,
    required int quantity,
    required double salePrice,
  }) async {
    final sale = Sale()
      ..id = _uuid.v4()
      ..productId = productId
      ..productName = productName
      ..quantitySold = quantity
      ..salePrice = salePrice
      ..totalAmount = quantity * salePrice
      ..saleDate = DateTime.now();

    await _box.put(sale.id, sale);
    notifyListeners();
  }

  
  // REFRESH PROVIDER
  // Forces UI rebuild manually
  
  void refresh() => notifyListeners();
}