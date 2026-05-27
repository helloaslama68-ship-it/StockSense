import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../providers/inventory_provider.dart';
import '../inventory/manage_brands_screen.dart';
import '../inventory/manage_categories_screen.dart';

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
          // STAT CARDS
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(children: [
              Expanded(
                child: _StatCard(
                  label: 'CATEGORIES',
                  count: catCount,
                  sub: catCount == 0 ? 'add your first' : 'across all products',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'BRANDS',
                  count: brandCount,
                  sub: brandCount == 0 ? 'add your first brand' : 'tracked brands',
                ),
              ),
            ]),
          ),

          // SECTION LABEL
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

          // CATEGORIES TILE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ManageTile(
              icon: Icons.category_rounded,
              color: AppColors.goldDark,
              title: 'Categories',
              description: 'Organise products by type',
              count: catCount,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const ManageCategoriesScreen())),
            ),
          ),
          const SizedBox(height: 10),

          // BRANDS TILE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ManageTile(
              icon: Icons.storefront_rounded,
              color: AppColors.blue,
              title: 'Brands',
              description: 'Track products by brand',
              count: brandCount,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const ManageBrandsScreen())),
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: Text(
              'Tap a section to add, rename, or delete items',
              style: TextStyle(fontSize: 12, color: AppColors.lightGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int    count;
  final String sub;

  const _StatCard({
    required this.label,
    required this.count,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey,
                  letterSpacing: 1.1)),
          const SizedBox(height: 6),
          Text('$count',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 2),
          Text(sub,
              style: TextStyle(fontSize: 11, color: AppColors.lightGrey)),
        ]),
      );
}

class _ManageTile extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final String       title;
  final String       description;
  final int          count;
  final VoidCallback onTap;

  const _ManageTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ],
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(description,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundTop,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey)),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: AppColors.lightGrey),
          ]),
        ),
      );
}