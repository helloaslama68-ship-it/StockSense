import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/manage_widgets.dart';

class ManageBrandsScreen extends StatelessWidget {
  const ManageBrandsScreen({super.key});

  Future<void> _showAddDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => ManageInputDialog(
        title: 'Add Brand',
        hint: 'Brand name',
        ctrl: ctrl,
        onConfirm: () {
          final val = ctrl.text.trim();
          if (val.isNotEmpty) {
            context.read<InventoryProvider>().addBrand(val);
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
        title: 'Rename Brand',
        hint: 'New name',
        ctrl: ctrl,
        confirmLabel: 'Save',
        onConfirm: () {
          final val = ctrl.text.trim();
          if (val.isNotEmpty && val != current) {
            context.read<InventoryProvider>().renameBrand(current, val);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String name) async {
    final products = context.read<ProductProvider>().allProducts;
    final inUse = products.where((p) => p.brand == name).toList();

    if (inUse.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete "$name" — ${inUse.length} product${inUse.length > 1 ? "s" : ""} still use this brand. Delete those products first.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => ManageConfirmDialog(
        title: 'Delete Brand?',
        message: 'Remove "$name" from your brands list?',
        onConfirm: () =>
            context.read<InventoryProvider>().removeBrand(name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brands = context.watch<InventoryProvider>().brands;

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
          'Brands',
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
            tooltip: 'Add Brand',
          ),
        ],
      ),
      body: brands.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.branding_watermark_outlined,
                      size: 56, color: AppColors.lightGrey),
                  const SizedBox(height: 12),
                  Text('No brands yet.',
                      style:
                          TextStyle(color: AppColors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first brand'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.goldDark),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: brands.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = brands[i];
                return ManageItemTile(
                  name: item,
                  color: AppColors.blue,
                  onEdit: () => _showRenameDialog(context, item),
                  onDelete: () => _confirmDelete(context, item),
                );
              },
            ),
    );
  }
}