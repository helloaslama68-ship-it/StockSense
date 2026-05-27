import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/manage_widgets.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  Future<void> _showAddDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => ManageInputDialog(
        title: 'Add Category',
        hint: 'Category name',
        ctrl: ctrl,
        onConfirm: () {
          final val = ctrl.text.trim();
          if (val.isNotEmpty) {
            context.read<InventoryProvider>().addCategory(val);
          }
        },
      ),
    );
  }

  Future<void> _showRenameDialog(
      BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    await showDialog(
      context: context,
      builder: (_) => ManageInputDialog(
        title: 'Rename Category',
        hint: 'New name',
        ctrl: ctrl,
        confirmLabel: 'Save',
        onConfirm: () {
          final val = ctrl.text.trim();
          if (val.isNotEmpty && val != current) {
            context.read<InventoryProvider>().renameCategory(current, val);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String name) async {
    await showDialog(
      context: context,
      builder: (_) => ManageConfirmDialog(
        title: 'Delete Category?',
        message:
            '"$name" will be removed. Products using it won\'t be deleted.',
        onConfirm: () =>
            context.read<InventoryProvider>().removeCategory(name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<InventoryProvider>().categories;

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
          'Categories',
          style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded,
                color: AppColors.goldDark),
            onPressed: () => _showAddDialog(context),
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: categories.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category_outlined,
                      size: 56, color: AppColors.lightGrey),
                  const SizedBox(height: 12),
                  Text('No categories yet.',
                      style:
                          TextStyle(color: AppColors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first category'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.goldDark),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = categories[i];
                return ManageItemTile(
                  name: item,
                  color: AppColors.goldDark,
                  onEdit: () => _showRenameDialog(context, item),
                  onDelete: () => _confirmDelete(context, item),
                );
              },
            ),
    );
  }
}