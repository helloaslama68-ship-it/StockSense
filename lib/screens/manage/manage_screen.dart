import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/manage_nav_widgets.dart';
import 'manage_brands_screen.dart';
import 'manage_categories_screen.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inv        = context.watch<InventoryProvider>();
    final catCount   = inv.categories.length;
    final brandCount = inv.brands.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundTop,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage',
          style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(children: [
              Expanded(
                child: ManageStatCard(
                  label: 'CATEGORIES',
                  count: catCount,
                  subtitle: catCount == 0
                      ? 'add your first'
                      : 'across all products',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ManageStatCard(
                  label: 'BRANDS',
                  count: brandCount,
                  subtitle: brandCount == 0
                      ? 'add your first brand'
                      : 'tracked brands',
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'CATALOG SETTINGS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey,
                  letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ManageNavTile(
              icon: Icons.category_rounded,
              color: AppColors.goldDark,
              title: 'Categories',
              description: 'Organise products by type',
              count: catCount,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageCategoriesScreen()),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ManageNavTile(
              icon: Icons.storefront_rounded,
              color: AppColors.blue,
              title: 'Brands',
              description: 'Track products by brand',
              count: brandCount,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageBrandsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Tap a section to add, rename, or delete items',
              style:
                  const TextStyle(fontSize: 12, color: AppColors.lightGrey),
            ),
          ),
        ],
      ),
    );
  }
}