import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../widgets/app_back_button.dart';
import '../../providers/brand_search_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/manage_add_card.dart';
import '../../widgets/manage_count_label.dart';
import '../../widgets/manage_empty_state.dart';
import '../../widgets/manage_search_bar.dart';
import '../../widgets/manage_widgets.dart';

class ManageBrandsScreen extends StatelessWidget {
  const ManageBrandsScreen({super.key});

  void _add(BuildContext context, BrandSearchProvider search) {
    final val = search.addController.text.trim();
    if (val.isEmpty) return;
    final inventory = context.read<InventoryProvider>();
    if (inventory.brands.contains(val)) {
      AppSnackBar.error(context, 'Brand "$val" already exists');
      return;
    }
    inventory.addBrand(val);
    search.addController.clear();
    AppSnackBar.success(context, 'Brand "$val" added');
  }

  void _rename(BuildContext context, String old) {
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

  void _delete(BuildContext context, String brand) {
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
      builder: (dialogContext) => ManageConfirmDialog(
        title: 'Delete Brand?',
        message: 'Remove "$brand" from your brands list?',
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.read<InventoryProvider>().removeBrand(brand);
          AppSnackBar.success(context, 'Brand "$brand" deleted');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrandSearchProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
          title: Text(
            'Manage Brands',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
        body: Consumer<BrandSearchProvider>(
          builder: (context, search, _) {
            final allBrands = context.watch<InventoryProvider>().brands;
            final filtered = search.filter(allBrands);

            return Column(
              children: [
                ManageAddCard(
                  controller: search.addController,
                  sectionLabel: 'ADD NEW BRAND',
                  hintText: 'e.g. Amul, Nestlé, Britannia',
                  onAdd: () => _add(context, search),
                ),
                ManageSearchBar(
                  controller: search.controller,
                  hintText: 'Search brands…',
                  query: search.query,
                  onChanged: search.onChanged,
                  onClear: search.clear,
                ),
                ManageCountLabel(
                  total: allBrands.length,
                  filtered: filtered.length,
                  label: 'BRANDS',
                  isFiltering: search.query.isNotEmpty,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildList(context, search, allBrands, filtered),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    BrandSearchProvider search,
    List<String> all,
    List<String> filtered,
  ) {
    if (all.isEmpty) {
      return const ManageEmptyState(
        icon: Icons.label_off_rounded,
        title: 'No brands yet',
        subtitle: 'Add your first brand above',
      );
    }
    if (filtered.isEmpty) {
      return ManageEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results for "${search.query}"',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final brand = filtered[i];
        return ManageItemTile(
          name: brand,
          color: AppColors.goldDark,
          onEdit: () => _rename(context, brand),
          onDelete: () => _delete(context, brand),
        );
      },
    );
  }
}