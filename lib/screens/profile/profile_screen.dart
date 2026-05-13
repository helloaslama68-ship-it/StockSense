import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/colors.dart';
import '../../services/storage_service.dart';
import '../onboarding/onboarding_main.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = StorageService();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = _storage.getProfileImage();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 16),
            Text("Change Profile Photo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _photoOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  color: AppColors.goldDark,
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(fromCamera: true);
                  },
                ),
                _photoOption(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  color: AppColors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(fromCamera: false);
                  },
                ),
                if (_imagePath != null && _imagePath!.isNotEmpty)
                  _photoOption(
                    icon: Icons.delete_rounded,
                    label: "Remove",
                    color: AppColors.darkRed,
                    onTap: () {
                      Navigator.pop(context);
                      _storage.saveProfileImage('');
                      setState(() => _imagePath = null);
                    },
                  ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage({required bool fromCamera}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 400,
      );
      if (picked != null) {
        _storage.saveProfileImage(picked.path);
        setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image'),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _photoOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 28,
            child: Icon(icon, color: color, size: 26),
          ),
          SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.black,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownerName = _storage.getOwnerName();
    final storeName = _storage.getStoreName();
    final phone = _storage.getPhone();
    final address = _storage.getAddress();

    final hasPhoto = _imagePath != null && _imagePath!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundTop,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.goldDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Profile',
            style: TextStyle(
                color: AppColors.goldDark,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: AppColors.black),
            onPressed: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SettingsScreen()),
),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            // ── PROFILE HERO CARD ────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [

                  // ── TAPPABLE AVATAR ──────────────────
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: AppColors.lightGrey,
                            border: Border.all(
                                color: AppColors.goldDark, width: 2.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            // REPLACE:
child: hasPhoto
    ? Image.file(
        File(_imagePath!),
        fit: BoxFit.cover,
      )
    : Icon(
        Icons.person_rounded,
        size: 48,
        color: AppColors.goldDark,
      ),
                          ),
                        ),
                        // Gold verified badge
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.goldDark,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.white, width: 2),
                            ),
                            child: Icon(Icons.verified_rounded,
                                color: AppColors.white, size: 14),
                          ),
                        ),
                        // Camera overlay hint
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: AppColors.black.withOpacity(0.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 6),

                  // Tap to change hint
                  GestureDetector(
                    onTap: _pickImage,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_rounded,
                            size: 12, color: AppColors.goldDark),
                        SizedBox(width: 4),
                        Text("Change photo",
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),

                  SizedBox(height: 14),

                  // Name
                  Text(
                    ownerName.isEmpty ? 'Owner Name' : ownerName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3),
                  ),

                  SizedBox(height: 6),

                  // Store name pill
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.goldDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.storefront_rounded,
                            size: 13, color: AppColors.goldDark),
                        SizedBox(width: 5),
                        Text(
                          storeName.isEmpty ? 'Store Name' : storeName,
                          style: TextStyle(
                              color: AppColors.goldDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // ── CONTACT CARD ─────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.goldDark,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('CONTACT INFORMATION',
                            style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.5,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),

                  _contactRow(
                    icon: Icons.phone_rounded,
                    label: 'PHONE NUMBER',
                    value: phone.isEmpty ? '+91 00000 00000' : phone,
                    iconColor: AppColors.darkGreen,
                  ),

                  _divider(),

                  _contactRow(
                    icon: Icons.location_on_rounded,
                    label: 'SHOP ADDRESS',
                    value: address.isEmpty ? 'Shop Address' : address,
                    iconColor: AppColors.darkRed,
                  ),

                  SizedBox(height: 8),
                ],
              ),
            ),

            SizedBox(height: 24),

            // ── EDIT PROFILE BUTTON ──────────────────────
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                    colors: [AppColors.goldDark, AppColors.goldLight]),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldDark.withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.edit_rounded, color: AppColors.white, size: 18),
                label: Text('Edit Profile',
                    style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
               onPressed: () async {
  final updated = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => EditProfileScreen()),
  );
  if (updated == true) {
    setState(() {}); // refresh name/store/phone/address
  }
},
              ),
            ),

            SizedBox(height: 12),

            // ── LOGOUT BUTTON ────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.darkRed, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.logout_rounded, color: AppColors.darkRed, size: 18),
                label: Text('Logout',
                    style: TextStyle(
                        color: AppColors.darkRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Text('Logout?',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Text('Are you sure you want to logout?',
                          style: TextStyle(color: AppColors.grey)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel',
                              style: TextStyle(color: AppColors.grey)),
                        ),
                        TextButton(
                          onPressed: () {
                            StorageService().logout();
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => OnboardingMain()),
                              (route) => false,
                            );
                          },
                          child: Text('Logout',
                              style: TextStyle(
                                  color: AppColors.darkRed,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 12),

            // ── VERSION TAG ──────────────────────────────
            Text(
              "© 2025 StockSense · Offline Inventory System",
              style: TextStyle(fontSize: 10, color: AppColors.grey),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 3),
                Text(value,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.lightGrey, size: 20),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        indent: 70,
        endIndent: 16,
        color: AppColors.lightGrey.withOpacity(0.5),
      );
}