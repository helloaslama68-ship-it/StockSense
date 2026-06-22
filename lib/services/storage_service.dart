import 'package:hive/hive.dart';

// Models used for clearing stored data
import '../models/product.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../models/credit_transaction.dart';
import '../models/inventory_loss.dart';
import '../models/purchase_record.dart';

class StorageService {

  // Main Hive box name used for app-level settings/data
  static const String boxName = 'appBox';

  // Shortcut getter for accessing Hive box
  Box get _box => Hive.box(boxName);

  
  // USER / STORE DATA
  

  // Save store and owner information locally
  void saveUserData({
    required String storeName,
    required String ownerName,
    required String phone,
    required String address,
  }) {

    // Store details inside local Hive database
    _box.put('storeName', storeName);
    _box.put('ownerName', ownerName);
    _box.put('phone', phone);
    _box.put('address', address);

    // Authentication/session flags
    _box.put('isLoggedIn', true);
    _box.put('hasAccount', true);
  }

  // Retrieve saved store information
  String getStoreName() =>
      _box.get('storeName', defaultValue: "My Store");

  String getOwnerName() =>
      _box.get('ownerName', defaultValue: "Owner");

  String getPhone() =>
      _box.get('phone', defaultValue: "");

  String getAddress() =>
      _box.get('address', defaultValue: "");

  // Check login status
  bool isLoggedIn() =>
      _box.get('isLoggedIn', defaultValue: false);

  // Check whether user account exists
  bool hasAccount() =>
      _box.get('hasAccount', defaultValue: false);

  
  // PROFILE IMAGE


  // Save profile image path locally
  void saveProfileImage(String path) =>
      _box.put('profileImage', path);

  // Get saved profile image path
  String? getProfileImage() =>
      _box.get('profileImage');


  // LOGOUT
  
  void logout() {

    // User becomes logged out
    _box.put('isLoggedIn', false);

    // hasAccount remains true
    // So next app launch opens login screen instead of onboarding
  }

  
  // CLEAR USER DATA — called when a NEW account is created on this device.
  // Wipes ALL user-specific data so the new user starts completely fresh.
  
  Future<void> clearAllUserData() async {

    // Clear inventory products
    await Hive.box<Product>('products').clear();

    // Clear sales records
    await Hive.box<Sale>('sales').clear();

    // Clear purchase records (was missing — caused new users to see old purchases)
    await Hive.box<PurchaseRecord>('purchase_records').clear();

    // Clear inventory losses (was missing — caused new users to see old losses)
    await Hive.box<InventoryLoss>('losses').clear();

    // Clear customer credit data
    await Hive.box<Customer>('customers').clear();
    await Hive.box<CreditTransaction>('credit_transactions').clear();

    // Remove profile image
    _box.delete('profileImage');

    // Remove custom brands and categories
    _box.delete('brands');
    _box.delete('categories');
  }

  
  // BRANDS MANAGEMENT
  

  // Get all saved brands
  List<String> getBrands() {

    final raw = _box.get('brands');

    // Return empty list if no brands exist
    if (raw == null) return [];

    return List<String>.from(raw);
  }

  // Add new brand
  void saveBrand(String brand) {

    final list = getBrands();

    // Prevent duplicate brands
    if (!list.contains(brand)) {

      list.add(brand);

      // Save updated list
      _box.put('brands', list);
    }
  }

  // Delete brand
  void deleteBrand(String brand) {

    final list = getBrands();

    list.remove(brand);

    _box.put('brands', list);
  }
  
  // CATEGORY MANAGEMENT
  

  // Get categories list
  List<String> getCategories() {

    final raw = _box.get('categories');

    // If categories already exist, return them
    if (raw != null) {
      return List<String>.from(raw);
    }

    // Default categories for first-time app usage
    final defaults = [
      'Dairy',
      'Beverages',
      'Snacks',
      'Bakery',
      'Meat & Seafood',
      'Fruits & Vegetables',
      'Frozen',
      'Personal Care',
      'Household',
      'Other',
    ];

    // Save default categories locally
    _box.put('categories', defaults);

    return defaults;
  }

  // Add category
  void saveCategory(String category) {

    final list = getCategories();

    // Prevent duplicates
    if (!list.contains(category)) {

      list.add(category);

      _box.put('categories', list);
    }
  }

  // Delete category
  void deleteCategory(String category) {

    final list = getCategories();

    list.remove(category);

    _box.put('categories', list);
  }

  
  // NOTIFICATION MANAGEMENT
  

  // Get IDs of already-read notifications
  List<String> getReadNotificationIds() {

    final box = Hive.box('settings');

    final List? ids = box.get('read_notif_ids');

    return ids?.cast<String>() ?? [];
  }

  // Mark notification as read
  void markNotificationRead(String id) {

    final box = Hive.box('settings');

    final List<String> ids = getReadNotificationIds();

    // Avoid duplicate IDs
    if (!ids.contains(id)) {

      ids.add(id);

      box.put('read_notif_ids', ids);
    }
  }

  // Clear all notifications
  void clearAllNotifications(List<String> ids) {

    final box = Hive.box('settings');

    box.put('read_notif_ids', ids);
  }
}