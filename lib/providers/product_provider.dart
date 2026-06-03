import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../screens/inventory/inventory_filter_sheet.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo;
  ProductProvider(this._repo);

  String _searchQuery = '';
  String _selectedCategory = 'All';
  InventoryFilter _filter = const InventoryFilter();

  // GETTERS
  List<Product> get allProducts => _repo.getAll();

  List<Product> get filteredProducts => _repo.getAll().where((p) {
        final matchSearch =
            p.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchCat =
            _selectedCategory == 'All' || p.category == _selectedCategory;
        return matchSearch && matchCat;
      }).toList();

  List<Product> get filteredAndSorted {
    var list = List<Product>.from(filteredProducts);

    // STATUS
    if (_filter.statuses.isNotEmpty) {
      list = list.where((p) {
        if (_filter.statuses.contains('outOfStock') && p.quantity == 0)
          return true;
        if (_filter.statuses.contains('lowStock') &&
            p.quantity > 0 &&
            p.quantity <= p.lowStockThreshold) return true;
        if (p.expiryDate != null) {
          final exp = DateTime.tryParse(p.expiryDate!);
          if (exp != null) {
            final days = exp.difference(DateTime.now()).inDays;
            if (_filter.statuses.contains('expired') && days < 0) return true;
            if (_filter.statuses.contains('nearExpiry') &&
                days >= 0 &&
                days <= 3) return true;
          }
        }
        return false;
      }).toList();
    }

    // CATEGORY
    if (_filter.categories.isNotEmpty) {
      list = list
          .where((p) => _filter.categories.contains(p.category))
          .toList();
    }

    // BRAND
    if (_filter.brands.isNotEmpty) {
      list = list
          .where((p) => _filter.brands.contains(p.brand))
          .toList();
    }

    // PRICE
    list = list
        .where((p) =>
            p.sellingPrice >= _filter.minPrice &&
            p.sellingPrice <= _filter.maxPrice)
        .toList();

    // SORT
    switch (_filter.sortBy) {
      case SortOption.newlyAdded:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.qtyLowHigh:
        list.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case SortOption.qtyHighLow:
        list.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case SortOption.expirySoonest:
        list.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return DateTime.parse(a.expiryDate!)
              .compareTo(DateTime.parse(b.expiryDate!));
        });
        break;
      case SortOption.priceLowHigh:
        list.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
      case SortOption.priceHighLow:
        list.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
    }

    return list;
  }

  List<Product> get lowStockProducts =>
      _repo.getAll().where((p) => p.quantity <= p.lowStockThreshold).toList();

  List<Product> get expiringProducts {
    final threshold = DateTime.now().add(const Duration(days: 30));
    return _repo.getAll().where((p) {
      if (p.expiryDate == null) return false;
      final expiry = DateTime.tryParse(p.expiryDate!);
      return expiry != null && expiry.isBefore(threshold);
    }).toList();
  }

  Product? getByBarcode(String barcode) => _repo.getByBarcode(barcode);

  List<String> get categories =>
      ['All', ..._repo.getAll().map((p) => p.category).toSet()];

  int get totalProducts => _repo.getAll().length;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  InventoryFilter get filter => _filter;

  // ACTIONS
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
    String? brand,
  }) async {
    await _repo.add(
      name: name,
      category: category,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      quantity: quantity,
      lowStockThreshold: lowStockThreshold,
      expiryDate: expiryDate,
      barcode: barcode,
      unit: unit,
      imagePath: imagePath,
      brand: brand,
    );
    notifyListeners();
  }

  Future<void> updateProduct(Product p) async {
    await _repo.update(p);
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await _repo.delete(id);
    notifyListeners();
  }

  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setCategory(String c) { _selectedCategory = c; notifyListeners(); }
  void setFilter(InventoryFilter f) { _filter = f; notifyListeners(); }
  void clearFilter() { _filter = const InventoryFilter(); notifyListeners(); }
  void refresh() => notifyListeners();
}