import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/sale.dart';

// ---------------------------------------------------------
// SALE PROVIDER
// Handles all sale-related operations using Hive
// and updates UI with ChangeNotifier.
// --------------------------------------------------------------
class SaleProvider extends ChangeNotifier {

  // Hive box used to store sales locally
  final Box<Sale> _box = Hive.box<Sale>('sales');

  // UUID generator for unique sale IDs
  final _uuid = const Uuid();

  // -------------------------------------------------------------
  // GET ALL SALES
  // Returns all sales sorted by latest first
  // ------------------------------------------------------------
  List<Sale> get allSales => _box.values.toList()
    ..sort((a, b) => b.saleDate.compareTo(a.saleDate));

  // ----------------------------------------------------------
  // TODAY SALES TOTAL
  // Calculates total sales amount for today
  // ------------------------------------------------------
  double get todaySalesTotal {

    // Current date
    final today = DateTime.now();

    // Filter today's sales and sum total amount
    return _box.values
        .where((s) =>
            s.saleDate.year == today.year &&
            s.saleDate.month == today.month &&
            s.saleDate.day == today.day)
        .fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  // -----------------------------------------------------------
  // RECORD SALE
  // Creates and saves a new sale record
  // ---------------------------------------------------
  Future<void> recordSale({

    // Product ID
    required String productId,

    // Product name
    required String productName,

    // Quantity sold
    required int quantity,

    // Selling price per unit
    required double salePrice,

  }) async {

    // Create sale object
    final sale = Sale()

      // Generate unique sale ID
      ..id = _uuid.v4()

      // Save product details
      ..productId = productId
      ..productName = productName

      // Save quantity sold
      ..quantitySold = quantity

      // Save single item price
      ..salePrice = salePrice

      // Calculate total amount
      ..totalAmount = quantity * salePrice

      // Save current date and time
      ..saleDate = DateTime.now();

    // Store sale in Hive database
    await _box.put(sale.id, sale);

    // Notify UI listeners
    notifyListeners();
  }

  // --------------------------------------------------------
  // REFRESH PROVIDER
  // Forces UI rebuild manually
  // ---------------------------------------------------
  void refresh() => notifyListeners();
}