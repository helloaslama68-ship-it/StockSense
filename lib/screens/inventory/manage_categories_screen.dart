import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_styles.dart';
import '../../core/colors.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/manage_widgets.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _ctrl = TextEditingController();

  static const _iconMap = <String, IconData>{
    'Dairy':               Icons.egg_alt_rounded,
    'Beverages':           Icons.local_drink_rounded,
    'Snacks':              Icons.cookie_rounded,
    'Bakery':              Icons.breakfast_dining_rounded,
    'Meat & Seafood':      Icons.set_meal_rounded,
    'Fruits & Vegetables': Icons.eco_rounded,
    'Frozen':              Icons.ac_unit_rounded,
    'Personal Care':       Icons.face_rounded,
    'Household':           Icons.home_rounded,
    'Other':               Icons.category_rounded,
  };

  void _add() {
    final val = _ctrl.text.trim();
    if (val.isEmpty) return;
    final provider = context.read<InventoryProvider>();
    if (provider.categories.contains(val)) {
      AppSnackBar.error(context, 'Category "$val" already exists');
      return;
    }
    provider.addCategory(val);
    _ctrl.clear();
    AppSnackBar.success(context, 'Category "$val" added');
  }

  void _rename(String old) {
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

  void _delete(String category) {
    showDialog(
      context: context,
      builder: (_) => ManageConfirmDialog(
        title: 'Delete Category?',
        message: 'Remove "$category" from your categories?',
        onConfirm: () {
          context.read<InventoryProvider>().removeCategory(category);
          AppSnackBar.success(context, 'Category "$category" deleted');
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
        title: const Text('Manage Categories',
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
                  const AppSectionLabel(label: 'ADD NEW CATEGORY'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _add(),
                        decoration: appInputDeco('e.g. Spices, Baby Products'),
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
          Consumer<InventoryProvider>(
            builder: (_, provider, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text(
                  '${provider.categories.length} CATEGORIES',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey,
                      letterSpacing: 1.2),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (_, provider, __) {
                final categories = provider.categories;
                if (categories.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.category_outlined, size: 48, color: AppColors.lightGrey),
                        SizedBox(height: 12),
                        Text('No categories yet',
                            style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Add your first category above',
                            style: TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final icon = _iconMap[cat] ?? Icons.category_rounded;
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
                      onEdit: () => _rename(cat),
                      onDelete: () => _delete(cat),
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