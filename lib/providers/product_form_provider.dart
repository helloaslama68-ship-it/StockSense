import 'package:flutter/material.dart';
import '../models/product.dart';

/// Transient form state for Add + Edit product screens.
/// Register as non-persistent provider (do NOT use keepAlive).
/// Call [initFromProduct] when editing, [reset] when adding.
class ProductFormProvider extends ChangeNotifier {
  // FIELDS 
  String? imagePath;
  String? selectedCategory;
  String? selectedBrand;
  DateTime? expiry;
  bool loading = false;

  // INIT

  /// Load existing product data (Edit flow).
  void initFromProduct(Product p) {
    imagePath        = p.imagePath;
    selectedCategory = p.category;
    selectedBrand    = p.brand; // ← CHANGED
    expiry           = p.expiryDate != null
        ? DateTime.tryParse(p.expiryDate!)
        : null;
    loading          = false;
    // No notifyListeners — called in initState before first build
  }

  /// Clear all state.
  void reset() {
    imagePath        = null;
    selectedCategory = null;
    selectedBrand    = null;
    expiry           = null;
    loading          = false;
    notifyListeners();
  }

  // SETTERS
  void setImagePath(String? path) {
    imagePath = path;
    notifyListeners();
  }

  void setCategory(String? cat) {
    selectedCategory = cat;
    notifyListeners();
  }

  void setBrand(String? brand) {
    selectedBrand = brand;
    notifyListeners();
  }

  void setExpiry(DateTime? date) {
    expiry = date;
    notifyListeners();
  }

  void setLoading(bool val) {
    loading = val;
    notifyListeners();
  }

  /// Guard stale selections after returning from Manage screens.
  void guardSelections({
    required List<String> categories,
    required List<String> brands,
  }) {
    bool changed = false;
    if (selectedCategory != null && !categories.contains(selectedCategory)) {
      selectedCategory = null;
      changed = true;
    }
    if (selectedBrand != null && !brands.contains(selectedBrand)) {
      selectedBrand = null;
      changed = true;
    }
    if (changed) notifyListeners();
  }
}