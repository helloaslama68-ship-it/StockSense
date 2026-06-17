import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/app_back_button.dart';
import '../../providers/profile_provider.dart';
import '../onboarding/onboarding_main.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showImagePicker(BuildContext context) {
    final provider = context.read<ProfileProvider>();
    final hasPhoto = provider.imagePath != null && provider.imagePath!.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3A3A3A) : AppColors.lightGrey,
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
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  color: AppColors.goldDark,
                  onTap: () async {
                    Navigator.pop(context);
                    await provider.pickImage(context: context, fromCamera: true);
                  },
                ),
                _photoOption(
                  context: context,
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  color: AppColors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    await provider.pickImage(context: context, fromCamera: false);
                  },
                ),
                if (hasPhoto)
                  _photoOption(
                    context: context,
                    icon: Icons.delete_rounded,
                    label: "Remove",
                    color: AppColors.darkRed,
                    onTap: () {
                      Navigator.pop(context);
                      provider.removeImage();
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

  Widget _photoOption({
    required BuildContext context,
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
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              context.read<ProfileProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => OnboardingMain()),
                  (route) => false,
                );
              }
            },
            child: Text('Logout',
                style: TextStyle(
                    color: AppColors.darkRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : AppColors.white;
    final dividerColor = isDark ? const Color(0xFF2C2C2C) : AppColors.lightGrey.withOpacity(0.5);

    final ownerName = profile.ownerName ?? '';
    final storeName = profile.storeName ?? '';
    final phone = profile.phone ?? '';
    final address = profile.address ?? '';
    final imagePath = profile.imagePath;
    final hasPhoto = imagePath != null && imagePath.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: Text('Profile',
            style: TextStyle(
                color: AppColors.goldDark,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded,
                color: isDark ? AppColors.white : AppColors.black),
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

            // PROFILE HERO CARD
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.0 : 0.05),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [

                  // TAPPABLE AVATAR
                  GestureDetector(
                    onTap: () => _showImagePicker(context),
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: isDark ? const Color(0xFF2C2C2C) : AppColors.lightGrey,
                            border: Border.all(
                                color: AppColors.goldDark, width: 2.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: hasPhoto
                                ? Image.file(File(imagePath!), fit: BoxFit.cover)
                                : Icon(Icons.person_rounded,
                                    size: 48, color: AppColors.goldDark),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.goldDark,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: cardColor, width: 2),
                            ),
                            child: Icon(Icons.verified_rounded,
                                color: AppColors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 6),

                  GestureDetector(
                    onTap: () => _showImagePicker(context),
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

                  Text(
                    ownerName.isEmpty ? 'Owner Name' : ownerName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3),
                  ),

                  SizedBox(height: 6),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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

            // CONTACT CARD
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.0 : 0.05),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: AppSectionLabel(label: 'CONTACT INFORMATION', showBar: true),
                  ),
                  SizedBox(height: 8),
                  _contactRow(
                    icon: Icons.phone_rounded,
                    label: 'PHONE NUMBER',
                    value: phone.isEmpty ? '+91 00000 00000' : phone,
                    iconColor: AppColors.darkGreen,
                    dividerColor: dividerColor,
                  ),
                  Divider(height: 1, indent: 70, endIndent: 16, color: dividerColor),
                  _contactRow(
                    icon: Icons.location_on_rounded,
                    label: 'SHOP ADDRESS',
                    value: address.isEmpty ? 'Shop Address' : address,
                    iconColor: AppColors.darkRed,
                    dividerColor: dividerColor,
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),

            SizedBox(height: 24),

            // EDIT PROFILE BUTTON
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfileScreen()),
                ),
              ),
            ),

            SizedBox(height: 12),

            // LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.darkRed, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.logout_rounded,
                    color: AppColors.darkRed, size: 18),
                label: Text('Logout',
                    style: TextStyle(
                        color: AppColors.darkRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                onPressed: () => _showLogoutDialog(context),
              ),
            ),

            SizedBox(height: 12),

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
    required Color dividerColor,
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.grey, size: 20),
        ],
      ),
    );
  }
}