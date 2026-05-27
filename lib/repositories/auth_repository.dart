import '../services/storage_service.dart';


// AUTH REPOSITORY
// Single place for all auth/session DB operations.

class AuthRepository {
  final StorageService _storage;

  AuthRepository(this._storage);

  //  READ 
  bool isLoggedIn()  => _storage.isLoggedIn();
  bool hasAccount()  => _storage.hasAccount();
  String getPhone()  => _storage.getPhone();

  //  WRITE
  void logout() => _storage.logout();

  void saveUserData({
    required String storeName,
    required String ownerName,
    required String phone,
    required String address,
  }) => _storage.saveUserData(
        storeName: storeName,
        ownerName: ownerName,
        phone: phone,
        address: address,
      );

  Future<void> clearAllUserData() => _storage.clearAllUserData();
}