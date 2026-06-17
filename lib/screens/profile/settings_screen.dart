import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../widgets/app_section_label.dart';
import '../../core/app_styles.dart';
import '../../widgets/app_back_button.dart';
import '../../providers/settings_provider.dart';
import 'help_support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = isDark ? Colors.white : AppColors.black;
    final textSecondary = isDark ? const Color(0xFF9E9E9E) : AppColors.grey;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
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
                    color: textPrimary)),
            const SizedBox(height: 4),
            Text('Manage your shop and preferences',
                style: TextStyle(fontSize: 13, color: textSecondary)),

            const SizedBox(height: 24),

            // NOTIFICATIONS
            const AppSectionLabel(label: 'NOTIFICATIONS'),
            const SizedBox(height: 10),
            _buildCard(context: context, children: [
              _toggleTile(
                context: context,
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.orange,
                title: 'Low Stock Alerts',
                subtitle: 'Alert when products run low',
                value: settings.lowStockAlerts,
                onChanged: (v) => context.read<SettingsProvider>().setLowStockAlerts(v),
              ),
              _divider(context),
              _toggleTile(
                context: context,
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.blue,
                title: 'Expiry Alerts',
                subtitle: 'Alert for products expiring within 30 days',
                value: settings.expiryAlerts,
                onChanged: (v) => context.read<SettingsProvider>().setExpiryAlerts(v),
              ),
              _divider(context),
              _toggleTile(
                context: context,
                icon: Icons.credit_card_rounded,
                iconColor: AppColors.purple,
                title: 'Credit Due Alerts',
                subtitle: 'Remind about pending customer dues',
                value: settings.creditDueAlerts,
                onChanged: (v) => context.read<SettingsProvider>().setCreditDueAlerts(v),
              ),
            ]),

            const SizedBox(height: 20),

            // PREFERENCES
            const AppSectionLabel(label: 'PREFERENCES'),
            const SizedBox(height: 10),
            _buildCard(context: context, children: [
              _toggleTile(
                context: context,
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF5C6BC0),
                title: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: settings.darkMode,
                onChanged: (v) => context.read<SettingsProvider>().setDarkMode(v),
              ),
            ]),

            const SizedBox(height: 20),

            // ABOUT
            const AppSectionLabel(label: 'ABOUT'),
            const SizedBox(height: 10),
            _buildCard(context: context, children: [
              _infoTile(
                context: context,
                title: 'App Version',
                trailing: 'v2.4.12-pro',
              ),
              _divider(context),
              _tapTile(
                context: context,
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
               onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
  );
},
              ),
            ]),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required BuildContext context, required List<Widget> children}) =>
      Container(
        width: double.infinity,
        decoration: appCardDecoration(context: context),
        child: Column(children: children),
      );

  Widget _toggleTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 11, color: AppColors.warmGrey)),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.goldDark,
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required BuildContext context,
    required String title,
    required String trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.black)),
          Text(trailing,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _tapTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.black)),
            Icon(Icons.open_in_new_rounded,
                color: AppColors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: isDark
          ? const Color(0xFF2C2C2C)
          : AppColors.lightGrey.withOpacity(0.5),
    );
  }
}