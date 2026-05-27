import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Brand "$val" already exists'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    provider.addBrand(val);
    _ctrl.clear();
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
          if (val.isNotEmpty && val != old)
            context.read<InventoryProvider>().renameBrand(old, val);
        },
      ),
    );
  }

  void _delete(String brand) {
    final products = context.read<ProductProvider>().allProducts;
    final inUse = products.where((p) => p.brand == brand).toList();

    if (inUse.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete "$brand" — ${inUse.length} product${inUse.length > 1 ? "s" : ""} still use this brand. Delete those products first.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => ManageConfirmDialog(
        title: 'Delete Brand?',
        message: 'Remove "$brand" from your brands list?',
        onConfirm: () =>
            context.read<InventoryProvider>().removeBrand(brand),
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
      backgroundColor: AppColors.backgroundTop,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundTop,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.goldDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Manage Brands',
            style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: Column(
        children: [
          // ADD INPUT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ADD NEW BRAND',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _add(),
                        decoration: InputDecoration(
                          hintText: 'e.g. Amul, Nestlé, Britannia',
                          hintStyle:
                              TextStyle(color: AppColors.grey, fontSize: 14),
                          filled: true,
                          fillColor: AppColors.backgroundTop,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: AppColors.goldDark, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
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

          // LIST
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (_, provider, __) {
                final brands = provider.brands;
                return brands.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.label_off_rounded,
                                size: 48, color: AppColors.lightGrey),
                            const SizedBox(height: 12),
                            Text('No brands yet',
                                style: TextStyle(
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Add your first brand above',
                                style: TextStyle(
                                    color: AppColors.lightGrey, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.separated(
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