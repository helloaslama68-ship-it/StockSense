import 'package:flutter/material.dart';
import '../repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository _repo;
  InventoryProvider(this._repo);

  // BRANDS 
  List<String> get brands => _repo.getBrands();

  void addBrand(String brand) {
    _repo.saveBrand(brand);
    notifyListeners();
  }

  void removeBrand(String brand) {
    _repo.deleteBrand(brand);
    notifyListeners();
  }

  void renameBrand(String oldName, String newName) {
    _repo.deleteBrand(oldName);
    _repo.saveBrand(newName);
    notifyListeners();
  }

  // CATEGORIES 
  List<String> get categories => _repo.getCategories();

  void addCategory(String category) {
    _repo.saveCategory(category);
    notifyListeners();
  }

  void removeCategory(String category) {
    _repo.deleteCategory(category);
    notifyListeners();
  }

  void renameCategory(String oldName, String newName) {
    _repo.deleteCategory(oldName);
    _repo.saveCategory(newName);
    notifyListeners();
  }
}