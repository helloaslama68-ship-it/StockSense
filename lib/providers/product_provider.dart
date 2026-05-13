import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';

// ----------------------------------------------------------
// PRODUCT PROVIDER
// Handles:
// Adding products
// Updating products
// Deleting products
// Product filtering
// Search functionality
// Category filtering
// Low stock alerts
// Expiry alerts
//
// Uses Hive local database for offline storage.
// ------------------------------------------------------------
class ProductProvider extends ChangeNotifier {

  // ── HIVE PRODUCT BOX 
  // Access local database box named "products"
  final Box<Product> _box = Hive.box<Product>('products');

  // UUID generator for unique product IDs
  final _uuid = const Uuid();

  // ── SEARCH & FILTER VARIABLES 
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // ---------------------------------------------------------
  // ALL PRODUCTS
  // Returns complete product list
  // -----------------------------------------------------------
  List<Product> get allProducts => _box.values.toList();

  // ---------------------------------------------------------------
  // FILTERED PRODUCTS
  // Filters products using:
  // Search query
  // Selected category
  // --------------------------------------------------------------
  List<Product> get filteredProducts =>

      _box.values.where((p) {

        // Match product name with search query
        final matchSearch =
            p.name.toLowerCase()
                .contains(_searchQuery.toLowerCase());

        // Match category
        final matchCat =
            _selectedCategory == 'All' ||
            p.category == _selectedCategory;

        return matchSearch && matchCat;

      }).toList();

  // ----------------------------------------------------------
  // LOW STOCK PRODUCTS
  // Returns products with low quantity
  // ----------------------------------------------------------
  List<Product> get lowStockProducts =>

      _box.values.where(
        (p) => p.quantity <= p.lowStockThreshold,
      ).toList();

  // ----------------------------------------------------------
  // EXPIRING PRODUCTS
  // Returns products expiring within 30 days
  // ---------------------------------------------------------
  List<Product> get expiringProducts {

    // Expiry threshold date
    final threshold =
        DateTime.now().add(
          const Duration(days: 30),
        );

    return _box.values.where((p) {

      // Skip if expiry date is null
      if (p.expiryDate == null) return false;

      // Convert string date to DateTime
      final expiry =
          DateTime.tryParse(p.expiryDate!);

      // Check if product expires before threshold
      return expiry != null &&
          expiry.isBefore(threshold);

    }).toList();
  }

  // ------------------------------------------------------------
  // GET PRODUCT BY BARCODE
  // Used in barcode scanner feature
  // --------------------------------------------------------------
  Product? getProductByBarcode(String barcode) {

    try {

      return _box.values.firstWhere(

        (p) =>
            p.barcode != null &&
            p.barcode == barcode,
      );

    } catch (_) {

      // Return null if barcode not found
      return null;
    }
  }

  // -----------------------------------------------------------------
  // PRODUCT CATEGORIES
  // Returns all unique categories
  // Adds "All" at beginning
  // ------------------------------------------------------------------
  List<String> get categories =>

      [
        'All',

        ..._box.values
            .map((p) => p.category)
            .toSet()
      ];

  // --------------------------------------------------------
  // SIMPLE GETTERS
  // ------------------------------------------------------

  // Total number of products
  int get totalProducts => _box.length;

  // Current search query
  String get searchQuery => _searchQuery;

  // Current selected category
  String get selectedCategory => _selectedCategory;

  // ------------------------------------------------------
  // ADD PRODUCT
  // Creates and stores a new product
  // -----------------------------------------------------
  Future<void> addProduct({

    required String name,
    required String category,
    required double costPrice,
    required double sellingPrice,
    required int quantity,
    required int lowStockThreshold,

    String? expiryDate,
    String? barcode,
    String? unit,
    String? imagePath,

  }) async {

    // Create new product object
    final p = Product()

      // Generate unique ID
      ..id = _uuid.v4()

      // Product details
      ..name = name
      ..category = category

      // Pricing
      ..costPrice = costPrice
      ..sellingPrice = sellingPrice

      // Inventory details
      ..quantity = quantity
      ..lowStockThreshold = lowStockThreshold

      // Optional details
      ..expiryDate = expiryDate
      ..barcode = barcode
      ..unit = unit
      ..imagePath = imagePath

      // Product creation date
      ..createdAt = DateTime.now();

    // Save product to Hive
    await _box.put(p.id, p);

    // Refresh UI
    notifyListeners();
  }

  // ------------------------------------------------------
  // UPDATE PRODUCT
  // Saves edited product changes
  // ------------------------------------------------------------
  Future<void> updateProduct(Product p) async {

    // Save updated product
    await p.save();

    // Refresh UI
    notifyListeners();
  }

  // --------------------------------------------------------
  // DELETE PRODUCT
  // Removes product from Hive database
  // ----------------------------------------------------
  Future<void> deleteProduct(String id) async {

    // Delete product using ID
    await _box.delete(id);

    // Refresh UI
    notifyListeners();
  }

  // --------------------------------------------------------------
  // SET SEARCH QUERY
  // Updates search text
  // --------------------------------------------------------------
  void setSearch(String q) {

    _searchQuery = q;

    notifyListeners();
  }

  // -------------------------------------------------------------------
  // SET CATEGORY FILTER
  // Updates selected category
  // -----------------------------------------------------------
  void setCategory(String c) {

    _selectedCategory = c;

    notifyListeners();
  }

  // -----------------------------------------------------------
  // REFRESH PROVIDER
  // Forces UI rebuild
  // ----------------------------------------------------------
  void refresh() => notifyListeners();
}