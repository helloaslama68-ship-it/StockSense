import '../services/storage_service.dart';


// PROFILE REPOSITORY
// All profile-related DB reads/writes in one place.

class ProfileRepository {
  final StorageService _storage;

  ProfileRepository(this._storage);

  // READ 
  String  getOwnerName()   => _storage.getOwnerName();
  String  getStoreName()   => _storage.getStoreName();
  String  getPhone()       => _storage.getPhone();
  String  getAddress()     => _storage.getAddress();
  String? getProfileImage()=> _storage.getProfileImage();

  // WRITE 
  void saveProfileImage(String path) => _storage.saveProfileImage(path);
}