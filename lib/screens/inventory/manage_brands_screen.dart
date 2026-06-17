import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_styles.dart';
import '../../core/colors.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/manage_widgets.dart';

class ManageBrandsScreen extends StatefulWidget {
  const ManageBrandsScreen({super.key});

  @override
  State<ManageBrandsScreen> createState() => _ManageBrandsScreenState();
}

class _ManageBrandsScreenState extends State<ManageBrandsScreen> {
  final _ctrl = TextEditingController();

  void _add() {
    final val = _ctrl.text.trim();
    if (val.isEmpty) return;
    final provider = context.read<InventoryProvider>();
    if (provider.brands.contains(val)) {
      AppSnackBar.error(context, 'Brand "$val" already exists');
      return;
    }
    provider.addBrand(val);
    _ctrl.clear();
    AppSnackBar.success(context, 'Brand "$val" added');
  }

  void _rename(String old) {
    final ctrl = TextEditingController(text: old);
    showDialog(
      context: context,
      builder: (_) => ManageInputDialog(
        title: 'Rename Brand',
        hint: 'Brand name',
        ctrl: ctrl,
        confirmLabel: 'Save',
        onConfirm: () {
          final val = ctrl.text.trim();
          if (val.isNotEmpty && val != old) {
            context.read<InventoryProvider>().renameBrand(old, val);
            AppSnackBar.success(context, 'Renamed to "$val"');
          }
        },
      ),
    );
  }

  void _delete(String brand) {
    final products = context.read<ProductProvider>().allProducts;
    final inUse = products.where((p) => p.brand == brand).toList();
    if (inUse.isNotEmpty) {
      AppSnackBar.error(
        context,
        'Cannot delete "$brand" — ${inUse.length} product${inUse.length > 1 ? "s" : ""} still use it.',
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => ManageConfirmDialog(
        title: 'Delete Brand?',
        message: 'Remove "$brand" from your brands list?',
        onConfirm: () {
          context.read<InventoryProvider>().removeBrand(brand);
          AppSnackBar.success(context, 'Brand "$brand" deleted');
        },
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: const Text('Manage Brands',
            style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: appCardDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionLabel(label: 'ADD NEW BRAND'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _add(),
                        decoration: appInputDeco('e.g. Amul, Nestlé, Britannia'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _add,
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.goldDark, AppColors.goldLight],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (_, provider, __) {
                final brands = provider.brands;
                if (brands.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.label_off_rounded, size: 48, color: AppColors.lightGrey),
                        SizedBox(height: 12),
                        Text('No brands yet',
                            style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Add your first brand above',
                            style: TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: brands.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final brand = brands[i];
                    return ManageItemTile(
                      name: brand,
                      color: AppColors.goldDark,
                      onEdit: () => _rename(brand),
                      onDelete: () => _delete(brand),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}