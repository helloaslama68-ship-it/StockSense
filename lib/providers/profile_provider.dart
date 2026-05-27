import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthRepository   _auth;
  final ProfileRepository _profile;

  // USER STATE 
  String  _ownerName = '';
  String  _storeName = '';
  String  _phone     = '';
  String  _address   = '';
  String? _imagePath;

  //  LOGIN STATE 
  bool    _loading  = false;
  bool    _saving   = false;   
  String? _errorMsg;

  bool    get loading  => _loading;
  bool    get saving   => _saving;   
  String? get errorMsg => _errorMsg;

  // COUNTRY CODE STATE 
  String _selectedCode = '+91';
  String get selectedCode => _selectedCode;

  void selectCountryCode(String code) {
    if (_selectedCode == code) return;
    _selectedCode = code;
    notifyListeners();
  }

  static const List<Map<String, String>> countryCodes = [
    {'code': '+91',  'flag': '🇮🇳', 'name': 'India'},
    {'code': '+1',   'flag': '🇺🇸', 'name': 'USA'},
    {'code': '+44',  'flag': '🇬🇧', 'name': 'UK'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
    {'code': '+60',  'flag': '🇲🇾', 'name': 'Malaysia'},
    {'code': '+65',  'flag': '🇸🇬', 'name': 'Singapore'},
    {'code': '+92',  'flag': '🇵🇰', 'name': 'Pakistan'},
    {'code': '+880', 'flag': '🇧🇩', 'name': 'Bangladesh'},
    {'code': '+94',  'flag': '🇱🇰', 'name': 'Sri Lanka'},
    {'code': '+977', 'flag': '🇳🇵', 'name': 'Nepal'},
  ];

  ProfileProvider(this._auth, this._profile) {
    _load();
  }

  // GETTERS 
  String  get ownerName => _ownerName;
  String  get storeName => _storeName;
  String  get phone     => _phone;
  String  get address   => _address;
  String? get imagePath => _imagePath;
  bool    get hasPhoto  => _imagePath != null && _imagePath!.isNotEmpty;

  // LOAD 
  void _load() {
    _ownerName = _profile.getOwnerName();
    _storeName = _profile.getStoreName();
    _phone     = _profile.getPhone();
    _address   = _profile.getAddress();
    _imagePath = _profile.getProfileImage();
  }

  void reload() {
    _load();
    notifyListeners();
  }

  // CLEAR ERROR 
  void clearError() {
    if (_errorMsg == null) return;
    _errorMsg = null;
    notifyListeners();
  }

  // LOGIN 
  Future<bool> login(String phone) async {
    _loading  = true;
    _errorMsg = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final fullPhone = '$_selectedCode $phone';

    if (!_auth.hasAccount()) {
      _errorMsg = 'No account found. Please create one.';
      _loading  = false;
      notifyListeners();
      return false;
    }

    if (_auth.getPhone() != fullPhone) {
      _errorMsg = 'Phone number does not match.';
      _loading  = false;
      notifyListeners();
      return false;
    }

    _load();
    _loading = false;
    notifyListeners();
    return true;
  }

  //  LOGOUT 
  void logout() {
    _auth.logout();
    _ownerName = '';
    _storeName = '';
    _phone     = '';
    _address   = '';
    _imagePath = null;
    _errorMsg  = null;
    notifyListeners();
  }

  //  CREATE ACCOUNT 
  Future<String?> createAccount({
    required String storeName,
    required String ownerName,
    required String phone,
    required String address,
  }) async {
    final fullPhone = '$_selectedCode $phone';

    if (_auth.hasAccount() && _auth.getPhone() == fullPhone) {
      return 'duplicate';
    }

    if (_auth.hasAccount()) {
      await _auth.clearAllUserData();
    }

    _auth.saveUserData(
      storeName: storeName,
      ownerName: ownerName,
      phone: fullPhone,
      address: address,
    );

    _storeName = storeName;
    _ownerName = ownerName;
    _phone     = fullPhone;
    _address   = address;
    notifyListeners();

    return null;
  }

  // SAVE USER DATA (edit profile) 
  void saveUserData({
    required String storeName,
    required String ownerName,
    required String phone,
    required String address,
  }) {
    _saving = true;           
    notifyListeners();        

    _auth.saveUserData(
      storeName: storeName,
      ownerName: ownerName,
      phone: phone,
      address: address,
    );
    _storeName = storeName;
    _ownerName = ownerName;
    _phone     = phone;
    _address   = address;

    _saving = false;          
    notifyListeners();
  }

  // PICK IMAGE
  Future<void> pickImage({
    required bool fromCamera,
    required BuildContext context,
  }) async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 400,
      );
      if (picked != null) {
        _profile.saveProfileImage(picked.path);
        _imagePath = picked.path;
        notifyListeners();
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not pick image'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // REMOVE IMAGE 
  void removeImage() {
    _profile.saveProfileImage('');
    _imagePath = null;
    notifyListeners();
  }
}