import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/storage_service.dart';

class ManageBrandsScreen extends StatefulWidget {
  const ManageBrandsScreen({super.key});

  @override
  State<ManageBrandsScreen> createState() => _ManageBrandsScreenState();
}

class _ManageBrandsScreenState extends State<ManageBrandsScreen> {
  final _storage = StorageService();
  final _ctrl = TextEditingController();
  List<String> _brands = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _brands = _storage.getBrands());

  void _add() {
    final val = _ctrl.text.trim();
    if (val.isEmpty) return;
    if (_brands.contains(val)) {
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
    _storage.saveBrand(val);
    _ctrl.clear();
    _load();
  }

  void _delete(String brand) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Brand?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Remove "$brand" from your brands list?',
            style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _storage.deleteBrand(brand);
              _load();
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
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
          'Manage Brands',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [

          //  ADD BRAND INPUT 
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (_) => _add(),
                          decoration: InputDecoration(
                            hintText: 'e.g. Amul, Nestlé, Britannia',
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

          //  LIST 
          Expanded(
            child: _brands.isEmpty
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
                    itemCount: _brands.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final brand = _brands[i];
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
                            child: Icon(Icons.label_rounded,
                                color: AppColors.goldDark, size: 18),
                          ),
                          title: Text(brand,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                color: Colors.red.shade300, size: 20),
                            onPressed: () => _delete(brand),
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