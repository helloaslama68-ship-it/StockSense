import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/colors.dart';
import '../providers/navigation_provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<NavigationProvider>().currentIndex;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.09),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.grid_view_rounded,   label: 'Dashboard', index: 0, current: current),
          _NavItem(icon: Icons.inventory_2_rounded, label: 'Inventory',  index: 1, current: current),
          _NavItem(icon: Icons.warning_rounded,     label: 'Alerts',     index: 2, current: current),
          _NavItem(icon: Icons.bar_chart_rounded,   label: 'Reports',    index: 3, current: current),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final int      index;
  final int      current;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final active = current == index;
    return GestureDetector(
      onTap: () => context.read<NavigationProvider>().switchTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.goldDark.withOpacity(0.1) : AppColors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
              color: active ? AppColors.goldDark : AppColors.mutedGrey,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize:      10,
                color:         active ? AppColors.goldDark : AppColors.mutedGrey,
                fontWeight:    active ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}