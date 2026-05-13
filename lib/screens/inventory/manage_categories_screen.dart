import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/storage_service.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _storage = StorageService();
  final _ctrl = TextEditingController();
  List<String> _categories = [];

  // Icon map for known categories
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _categories = _storage.getCategories());

  void _add() {
    final val = _ctrl.text.trim();
    if (val.isEmpty) return;
    if (_categories.contains(val)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$val" already exists'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    _storage.saveCategory(val);
    _ctrl.clear();
    _load();
  }

  void _delete(String category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Remove "$category" from your categories?',
            style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _storage.deleteCategory(category);
              _load();
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.darkRed, fontWeight: FontWeight.bold)),
          ),
        ],
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
        title: Text(
          'Manage Categories',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [

          // ADD CATEGORY INPUT 
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ADD NEW CATEGORY',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (_) => _add(),
                          decoration: InputDecoration(
                            hintText: 'e.g. Spices, Baby Products',
                            hintStyle: TextStyle(
                                color: AppColors.grey, fontSize: 14),
                            filled: true,
                            fillColor: AppColors.backgroundTop,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: AppColors.goldDark, width: 1.5),
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
                              colors: [
                                AppColors.goldDark,
                                AppColors.goldLight
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // COUNT BADGE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_categories.length} CATEGORIES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          //  LIST 
          Expanded(
            child: _categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.category_outlined,
                            size: 48, color: AppColors.lightGrey),
                        const SizedBox(height: 12),
                        Text('No categories yet',
                            style: TextStyle(
                                color: AppColors.grey,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Add your first category above',
                            style: TextStyle(
                                color: AppColors.lightGrey, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final icon =
                          _iconMap[cat] ?? Icons.category_rounded;
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.goldDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon,
                                color: AppColors.goldDark, size: 18),
                          ),
                          title: Text(cat,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                color: AppColors.darkRed, size: 20),
                            onPressed: () => _delete(cat),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}