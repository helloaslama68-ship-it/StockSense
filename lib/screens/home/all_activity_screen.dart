import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/activity_row.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';

class AllActivityScreen extends StatelessWidget {
  const AllActivityScreen({super.key});

  static final List<_ActivityItem> _items = [
    _ActivityItem(
      icon: Icons.add_circle_rounded,
      iconBg: AppColors.lightGreen,
      iconColor: AppColors.forestGreen,
      title: 'Stock Added',
      subtitle: '+50 Whole Milk',
      time: '10:45 AM',
      timeColor: AppColors.forestGreen,
    ),
    _ActivityItem(
      icon: Icons.receipt_rounded,
      iconBg: AppColors.creamBg,
      iconColor: AppColors.blue,
      title: 'Sales Transaction',
      subtitle: 'Order #SL0923 · 4 items',
      time: '09:12 AM',
      timeColor: AppColors.warmGrey,
    ),
    _ActivityItem(
      icon: Icons.delete_rounded,
      iconBg: AppColors.lightRed,
      iconColor: AppColors.darkRed,
      title: 'Waste Logged',
      subtitle: '10x Green Yogurt (Expired)',
      time: 'Yesterday',
      timeColor: AppColors.darkRed,
      badge: '-₹165',
    ),
    _ActivityItem(
      icon: Icons.add_circle_rounded,
      iconBg: AppColors.lightGreen,
      iconColor: AppColors.forestGreen,
      title: 'Stock Added',
      subtitle: '+20 Artisan Bread',
      time: 'Yesterday',
      timeColor: AppColors.forestGreen,
    ),
    _ActivityItem(
      icon: Icons.receipt_rounded,
      iconBg: AppColors.creamBg,
      iconColor: AppColors.blue,
      title: 'Sales Transaction',
      subtitle: 'Order #SL0922 · 2 items',
      time: 'Yesterday',
      timeColor: AppColors.warmGrey,
    ),
    _ActivityItem(
      icon: Icons.person_add_rounded,
      iconBg: AppColors.paleBlue,
      iconColor: AppColors.royalBlue,
      title: 'Customer Added',
      subtitle: 'Ravi Kumar',
      time: '2 days ago',
      timeColor: AppColors.warmGrey,
    ),
    _ActivityItem(
      icon: Icons.account_balance_wallet_rounded,
      iconBg: AppColors.warmOrange,
      iconColor: AppColors.brownGold,
      title: 'Payment Recorded',
      subtitle: 'Priya Stores · ₹500',
      time: '2 days ago',
      timeColor: AppColors.warmGrey,
    ),
    _ActivityItem(
      icon: Icons.delete_rounded,
      iconBg: AppColors.lightRed,
      iconColor: AppColors.darkRed,
      title: 'Waste Logged',
      subtitle: '5x Brown Bread (Damaged)',
      time: '3 days ago',
      timeColor: AppColors.darkRed,
      badge: '-₹80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: const AppBackButton(),
        title: Text(
          'All Activity',
          style: TextStyle(
            fontSize: r.sp(17),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: _items.isEmpty
          ? const EmptyState(
              icon: Icons.history_rounded,
              title: 'No activity yet',
              subtitle: 'Your store activity will appear here.',
            )
          : ListView(
              padding: r.pagePadding.copyWith(top: 16, bottom: 32),
              children: [
                r.constrain(
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: List.generate(_items.length, (i) {
                        final item = _items[i];
                        return ActivityRow(
                          icon: item.icon,
                          iconBg: item.iconBg,
                          iconColor: item.iconColor,
                          title: item.title,
                          subtitle: item.subtitle,
                          time: item.time,
                          timeColor: item.timeColor,
                          badge: item.badge,
                          isLast: i == _items.length - 1,
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final Color timeColor;
  final String? badge;

  const _ActivityItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.timeColor,
    this.badge,
  });
}