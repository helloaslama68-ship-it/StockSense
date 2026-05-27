import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundTop,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.goldDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings',
            style: TextStyle(
                color: AppColors.goldDark,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text('Settings',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black)),
            const SizedBox(height: 4),
            Text('Manage your shop and preferences',
                style: TextStyle(fontSize: 13, color: AppColors.grey)),

            const SizedBox(height: 24),

            //  NOTIFICATIONS 
            _sectionLabel('NOTIFICATIONS'),
            const SizedBox(height: 10),
            _buildCard(children: [
              _toggleTile(
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.orange,
                title: 'Low Stock Alerts',
                value: settings.lowStockAlerts,
                onChanged: (v) => context.read<SettingsProvider>().setLowStockAlerts(v),
              ),
              _divider(),
              _toggleTile(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.blue,
                title: 'Expiry Alerts',
                value: settings.expiryAlerts,
                onChanged: (v) => context.read<SettingsProvider>().setExpiryAlerts(v),
              ),
              _divider(),
              _toggleTile(
                icon: Icons.credit_card_rounded,
                iconColor: AppColors.grey,
                title: 'Credit Due Alerts',
                value: settings.creditDueAlerts,
                onChanged: (v) => context.read<SettingsProvider>().setCreditDueAlerts(v),
              ),
            ]),

            const SizedBox(height: 20),

            // PREFERENCES 
            _sectionLabel('PREFERENCES'),
            const SizedBox(height: 10),
            _buildCard(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Dark Mode
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTop,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.dark_mode_rounded,
                                color: AppColors.grey, size: 20),
                            const SizedBox(height: 8),
                            Text('Dark Mode',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black)),
                            const SizedBox(height: 6),
                            Transform.scale(
                              scale: 0.8,
                              alignment: Alignment.centerLeft,
                              child: Switch(
                                value: settings.darkMode,
                                onChanged: (v) => context.read<SettingsProvider>().setDarkMode(v),
                                activeColor: AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Language
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTop,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.language_rounded,
                                color: AppColors.grey, size: 20),
                            const SizedBox(height: 8),
                            Text('Language',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black)),
                            const SizedBox(height: 4),
                            Text(settings.language,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 20),

            //  ABOUT 
            _sectionLabel('ABOUT'),
            const SizedBox(height: 10),
            _buildCard(children: [
              _infoTile(
                title: 'App Version',
                trailing: 'v2.4.12-pro',
              ),
              _divider(),
              _tapTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  //  HELPERS 

  Widget _sectionLabel(String label) => Text(label,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.grey,
          letterSpacing: 1.2));

  Widget _buildCard({required List<Widget> children}) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(children: children),
      );

  Widget _toggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.goldDark,
            ),
          ],
        ),
      );

  Widget _infoTile({required String title, required String trailing}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            Text(trailing,
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _tapTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Icon(Icons.open_in_new_rounded,
                  color: AppColors.grey, size: 18),
            ],
          ),
        ),
      );

  Widget _divider() => Divider(
        height: 1,
        indent: 70,
        endIndent: 16,
        color: AppColors.lightGrey.withOpacity(0.5),
      );
}