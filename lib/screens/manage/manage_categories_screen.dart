import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../widgets/app_back_button.dart';
import '../../providers/category_search_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/manage_add_card.dart';
import '../../widgets/manage_count_label.dart';
import '../../widgets/manage_empty_state.dart';
import '../../widgets/manage_search_bar.dart';
import '../../widgets/manage_widgets.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  void _add(BuildContext context, CategorySearchProvider search) {
    final val = search.addController.text.trim();
    if (val.isEmpty) return;
    final inventory = context.read<InventoryProvider>();
    if (inventory.categories.contains(val)) {
      AppSnackBar.error(context, 'Category "$val" already exists');
      return;
    }
    inventory.addCategory(val);
    search.addController.clear();
    AppSnackBar.success(context, 'Category "$val" added');
  }

  void _rename(BuildContext context, String old) {
    final ctrl = TextEditingController(text: old);
    showDialog(
      context: context,
      builder: (_) => ManageInputDialog(
        title: 'Rename Category',
        hint: 'Category name',
        ctrl: ctrl,
        confirmLabel: 'Save',
        onConfirm: () {
          final val = ctrl.text.trim();
          if (val.isNotEmpty && val != old) {
            context.read<InventoryProvider>().renameCategory(old, val);
            AppSnackBar.success(context, 'Renamed to "$val"');
          }
        },
      ),
    );
  }

  void _delete(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (dialogContext) => ManageConfirmDialog(
        title: 'Delete Category?',
        message: 'Remove "$category" from your categories?',
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.read<InventoryProvider>().removeCategory(category);
          AppSnackBar.success(context, 'Category "$category" deleted');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategorySearchProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
          title: const Text(
            'Manage Categories',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: Consumer<CategorySearchProvider>(
          builder: (context, search, _) {
            final allCategories = context.watch<InventoryProvider>().categories;
            final filtered = search.filter(allCategories);

            return Column(
              children: [
                ManageAddCard(
                  controller: search.addController,
                  sectionLabel: 'ADD NEW CATEGORY',
                  hintText: 'e.g. Spices, Baby Products',
                  onAdd: () => _add(context, search),
                ),
                ManageSearchBar(
                  controller: search.controller,
                  hintText: 'Search categories…',
                  query: search.query,
                  onChanged: search.onChanged,
                  onClear: search.clear,
                ),
                ManageCountLabel(
                  total: allCategories.length,
                  filtered: filtered.length,
                  label: 'CATEGORIES',
                  isFiltering: search.query.isNotEmpty,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildList(context, search, allCategories, filtered),
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
    CategorySearchProvider search,
    List<String> all,
    List<String> filtered,
  ) {
    if (all.isEmpty) {
      return const ManageEmptyState(
        icon: Icons.category_outlined,
        title: 'No categories yet',
        subtitle: 'Add your first category above',
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
        final cat = filtered[i];
        final icon = search.iconFor(cat);
        return ManageItemTile(
          name: cat,
          color: AppColors.goldDark,
          leadingWidget: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.goldDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.goldDark, size: 18),
          ),
          onEdit: () => _rename(context, cat),
          onDelete: () => _delete(context, cat),
        );
      },
    );
  }
}