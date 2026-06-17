import '../services/storage_service.dart';


// INVENTORY REPOSITORY
// All brands + categories DB operations 
class InventoryRepository {
  final StorageService _storage;

  InventoryRepository(this._storage);

  // BRANDS 
  List<String> getBrands()          => _storage.getBrands();
  void saveBrand(String brand)      => _storage.saveBrand(brand);
  void deleteBrand(String brand)    => _storage.deleteBrand(brand);

  // CATEGORIES 
  List<String> getCategories()         => _storage.getCategories();
  void saveCategory(String category)   => _storage.saveCategory(category);
  void deleteCategory(String category) => _storage.deleteCategory(category);
}