import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/manage_nav_widgets.dart';
import 'manage_brands_screen.dart';
import 'manage_categories_screen.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();
    final catCount = inv.categories.length;
    final brandCount = inv.brands.length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(
            child: AppBackButton(),
          ),
        ),
        title: Text(
          'Manage',
          style: TextStyle(
            color: isDark
                ? AppColors.white
                : AppColors.darkGold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Stats Cards
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ManageStatCard(
                      label: 'CATEGORIES',
                      count: catCount,
                      subtitle: catCount == 0
                          ? 'Add your first'
                          : 'Across all products',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ManageStatCard(
                      label: 'BRANDS',
                      count: brandCount,
                      subtitle: brandCount == 0
                          ? 'Add your first brand'
                          : 'Tracked brands',
                    ),
                  ),
                ],
              ),
            ),

            /// Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'CATALOG SETTINGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark
                      ? AppColors.white70
                      : AppColors.grey,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ManageNavTile(
                icon: Icons.category_rounded,
                color: AppColors.goldDark,
                title: 'Categories',
                description: 'Organise products by type',
                count: catCount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageCategoriesScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            /// Brands
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ManageNavTile(
                icon: Icons.storefront_rounded,
                color: AppColors.blue,
                title: 'Brands',
                description: 'Track products by brand',
                count: brandCount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageBrandsScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'Tap a section to add, rename, or delete items',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.white54
                      : AppColors.lightGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}