import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/gold_button.dart';
import 'manage_brands_screen.dart';
import 'manage_categories_screen.dart';
import '../scanner/scanner_screen.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _storage  = StorageService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _sellCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _thresholdCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _barcodeCtrl;

  String? _selectedCategory;
  String? _selectedBrand;
  DateTime? _expiry;
  bool _loading = false;
  String? _imagePath;

  List<String> _categories = [];
  List<String> _brands     = [];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl      = TextEditingController(text: p.name);
    _descCtrl      = TextEditingController();
    _costCtrl      = TextEditingController(text: p.costPrice.toString());
    _sellCtrl      = TextEditingController(text: p.sellingPrice.toString());
    _qtyCtrl       = TextEditingController(text: p.quantity.toString());
    _thresholdCtrl = TextEditingController(text: p.lowStockThreshold.toString());
    _unitCtrl      = TextEditingController(text: p.unit ?? '');
    _barcodeCtrl   = TextEditingController(text: p.barcode ?? '');
    _expiry = p.expiryDate != null ? DateTime.tryParse(p.expiryDate!) : null;
    _loadLists(initialCategory: p.category);
  }

  void _loadLists({String? initialCategory}) {
    final cats   = _storage.getCategories();
    final brands = _storage.getBrands();
    setState(() {
      _categories = cats;
      _brands     = brands;
      if (_selectedCategory == null) {
        _selectedCategory = cats.contains(initialCategory ?? widget.product.category)
            ? (initialCategory ?? widget.product.category)
            : null;
      } else if (!cats.contains(_selectedCategory)) {
        _selectedCategory = null;
      }
      if (!brands.contains(_selectedBrand)) _selectedBrand = null;
    });
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _descCtrl, _costCtrl, _sellCtrl,
        _qtyCtrl, _thresholdCtrl, _unitCtrl, _barcodeCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 600,
      );
      if (picked != null) setState(() => _imagePath = picked.path);
    } catch (_) {}
  }

  Future<void> _goManageCategories() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()));
    _loadLists();
  }

  Future<void> _goManageBrands() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ManageBrandsScreen()));
    _loadLists();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final p = widget.product;
    p.name              = _nameCtrl.text.trim();
    p.category          = _selectedCategory ?? p.category;
    p.costPrice         = double.parse(_costCtrl.text);
    p.sellingPrice      = double.parse(_sellCtrl.text);
    p.quantity          = int.parse(_qtyCtrl.text);
    p.lowStockThreshold = int.parse(_thresholdCtrl.text);
    p.expiryDate        = _expiry?.toIso8601String();
    p.barcode           = _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim();
    p.unit              = _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim();
    p.imagePath         = _imagePath ?? p.imagePath;

    await context.read<ProductProvider>().updateProduct(p);
    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Product updated!'),
          ]),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Remove "${widget.product.name}" permanently? This cannot be undone.',
            style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<ProductProvider>().deleteProduct(widget.product.id);
      if (mounted) Navigator.pop(context, true);
    }
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
        title: Text('Edit Product',
            style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
            onPressed: _confirmDelete,
            tooltip: 'Delete product',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            Text('Update product details below.',
                style: TextStyle(fontSize: 13, color: AppColors.grey)),
            const SizedBox(height: 20),

            // PRODUCT IMAGE
            const AppSectionLabel(label: 'PRODUCT IMAGE'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.goldDark.withOpacity(0.4), width: 1.5),
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.goldDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.add_photo_alternate_rounded,
                                color: AppColors.goldDark, size: 28),
                          ),
                          const SizedBox(height: 10),
                          Text('Change Product Photo',
                              style: TextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('PNG, JPG up to 10MB',
                              style: TextStyle(color: AppColors.grey, fontSize: 11)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // PRODUCT NAME
            const AppSectionLabel(label: 'PRODUCT NAME'),
            const SizedBox(height: 8),
            AppInputField(
              controller: _nameCtrl,
              hint: 'e.g. Organic Almond Milk',
              validator: (v) =>
                  v!.trim().isEmpty ? 'Product name required' : null,
            ),
            const SizedBox(height: 16),

            // BRAND 
            AppSectionLabel(
              label: 'BRAND',
              actionLabel: '+ Manage',
              onAction: _goManageBrands,
            ),
            const SizedBox(height: 8),
            _brands.isEmpty
                ? _emptyDropdownHint('No brands yet — tap Manage to add',
                    onTap: _goManageBrands)
                : _dropdown(
                    value: _selectedBrand,
                    hint: 'Select brand',
                    items: _brands,
                    onChanged: (v) => setState(() => _selectedBrand = v),
                  ),
            const SizedBox(height: 16),

            //  CATEGORY 
            AppSectionLabel(
              label: 'CATEGORY',
              actionLabel: '+ Manage',
              onAction: _goManageCategories,
            ),
            const SizedBox(height: 8),
            _categories.isEmpty
                ? _emptyDropdownHint('No categories yet — tap Manage to add',
                    onTap: _goManageCategories)
                : _dropdown(
                    value: _selectedCategory,
                    hint: 'Select category',
                    items: _categories,
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
            const SizedBox(height: 16),

            // DESCRIPTION 
            const AppSectionLabel(label: 'PRODUCT DESCRIPTION'),
            const SizedBox(height: 8),
            AppInputField(
              controller: _descCtrl,
              hint: 'Enter detailed product description...',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            //  PURCHASE + SELLING PRICE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSectionLabel(label: 'PURCHASE PRICE'),
                      const SizedBox(height: 8),
                      AppInputField(
                        controller: _costCtrl,
                        hint: '0.00',
                        prefix: Text('₹ ',
                            style: TextStyle(
                                color: AppColors.grey,
                                fontWeight: FontWeight.w500)),
                        keyboard: TextInputType.number,
                        validator: (v) {
                          if (v!.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSectionLabel(label: 'SELLING PRICE'),
                      const SizedBox(height: 8),
                      AppInputField(
                        controller: _sellCtrl,
                        hint: '0.00',
                        prefix: Text('₹ ',
                            style: TextStyle(
                                color: AppColors.grey,
                                fontWeight: FontWeight.w500)),
                        keyboard: TextInputType.number,
                        validator: (v) {
                          if (v!.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // STOCK 
            const AppSectionLabel(label: 'STOCK'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('QUANTITY',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 6),
                      AppInputField(
                        controller: _qtyCtrl,
                        keyboard: TextInputType.number,
                        validator: (v) {
                          if (v!.isEmpty) return 'Required';
                          if (int.tryParse(v) == null) return 'Whole number';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MIN. STOCK',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 6),
                      AppInputField(
                        controller: _thresholdCtrl,
                        keyboard: TextInputType.number,
                        validator: (v) {
                          if (v!.isEmpty) return 'Required';
                          if (int.tryParse(v) == null) return 'Whole number';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            //  UNIT
            const AppSectionLabel(label: 'UNIT'),
            const SizedBox(height: 8),
            AppInputField(
              controller: _unitCtrl,
              hint: 'kg / pcs / litre / box',
            ),
            const SizedBox(height: 16),

            // EXPIRY DATE 
            const AppSectionLabel(label: 'EXPIRY DATE'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _expiry ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: ColorScheme.light(primary: AppColors.goldDark),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _expiry = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        color: AppColors.goldDark, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      _expiry == null
                          ? 'mm/dd/yyyy'
                          : '${_expiry!.month.toString().padLeft(2, '0')}/'
                              '${_expiry!.day.toString().padLeft(2, '0')}/'
                              '${_expiry!.year}',
                      style: TextStyle(
                        color: _expiry == null ? AppColors.grey : AppColors.black,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_expiry != null)
                      GestureDetector(
                        onTap: () => setState(() => _expiry = null),
                        child: const Icon(Icons.close, size: 16, color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // BARCODE 
            const AppSectionLabel(label: 'BARCODE NUMBER'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeCtrl,
                      decoration: InputDecoration(
                        hintText: 'Scan or enter manual code',
                        hintStyle: TextStyle(color: AppColors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final code = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ScannerScreen(returnBarcodeOnly: true),
                        ),
                      );
                      if (code != null) setState(() => _barcodeCtrl.text = code);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(Icons.qr_code_scanner_rounded,
                          color: AppColors.goldDark, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            //SAVE BUTTON 
            GoldButton(
              label: 'Save Changes',
              onPressed: _submit,
              loading: _loading,
            ),
            const SizedBox(height: 12),

            // DELETE BUTTON 
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade300, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 18),
                label: const Text('Delete Product',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                onPressed: _confirmDelete,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // HELPERS (dropdown only — not extractable to widget easily) 

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
            color: AppColors.white, borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: TextStyle(color: AppColors.grey, fontSize: 14)),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey),
            items: items
                .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14))))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _emptyDropdownHint(String msg, {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.goldDark.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.goldDark, size: 16),
              const SizedBox(width: 8),
              Text(msg, style: TextStyle(color: AppColors.grey, fontSize: 13)),
            ],
          ),
        ),
      );
}