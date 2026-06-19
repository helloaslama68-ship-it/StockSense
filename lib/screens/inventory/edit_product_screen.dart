import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_form_provider.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/expiry_date_picker.dart';
import '../../widgets/barcode_field.dart';
import '../../widgets/product_image_picker.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_card.dart';
import 'manage_brands_screen.dart';
import 'manage_categories_screen.dart';

const List<String> _kUnits = [
  'kg', 'g', 'mg',
  'litre', 'ml',
  'pcs', 'box', 'dozen',
  'pack', 'bag', 'bottle',
  'strip', 'tablet',
];

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey       = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _sellCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _thresholdCtrl;
  final _unitQtyCtrl   = TextEditingController();
  late final TextEditingController _barcodeCtrl;

  String? _selectedUnit;

  @override
  void initState() {
    super.initState();
    final p        = widget.product;
    _nameCtrl      = TextEditingController(text: p.name);
    _costCtrl      = TextEditingController(text: p.costPrice.toString());
    _sellCtrl      = TextEditingController(text: p.sellingPrice.toString());
    _qtyCtrl       = TextEditingController(text: p.quantity.toString());
    _thresholdCtrl = TextEditingController(text: p.lowStockThreshold.toString());
    _barcodeCtrl   = TextEditingController(text: p.barcode ?? '');

    final parts = (p.unit ?? '').split(' ');
    _selectedUnit     = parts.length == 2 && _kUnits.contains(parts[1]) ? parts[1] : null;
    _unitQtyCtrl.text = parts.length == 2 ? parts[0] : '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductFormProvider>().initFromProduct(p);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final inv  = context.read<InventoryProvider>();
    final form = context.read<ProductFormProvider>();
    form.guardSelections(categories: inv.categories, brands: inv.brands);
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _costCtrl, _sellCtrl,
        _qtyCtrl, _thresholdCtrl, _unitQtyCtrl, _barcodeCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _goManageCategories() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()));
  }

  Future<void> _goManageBrands() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ManageBrandsScreen()));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final form = context.read<ProductFormProvider>();
    form.setLoading(true);
    try {
      final p             = widget.product;
      p.name              = _nameCtrl.text.trim();
      p.category          = form.selectedCategory ?? p.category;
      p.brand             = form.selectedBrand ?? p.brand;
      p.costPrice         = double.parse(_costCtrl.text);
      p.sellingPrice      = double.parse(_sellCtrl.text);
      p.quantity          = int.parse(_qtyCtrl.text);
      p.lowStockThreshold = int.parse(_thresholdCtrl.text);
      p.expiryDate        = form.expiry?.toIso8601String();
      p.barcode           = _barcodeCtrl.text.trim().isEmpty
                                ? null : _barcodeCtrl.text.trim();
      p.unit              = (_selectedUnit != null && _unitQtyCtrl.text.trim().isNotEmpty)
                                ? '${_unitQtyCtrl.text.trim()} $_selectedUnit'
                                : _selectedUnit;
      p.imagePath         = form.imagePath ?? p.imagePath;
      await context.read<ProductProvider>().updateProduct(p);
      if (mounted) {
        AppSnackBar.success(context, 'Product updated!');
        Navigator.pop(context, true);
      }
    } finally {
      form.setLoading(false);
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
                style: TextStyle(
                    color: AppColors.darkRed, fontWeight: FontWeight.bold)),
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
    final form       = context.watch<ProductFormProvider>();
    final inv        = context.watch<InventoryProvider>();
    final categories = inv.categories;
    final brands     = inv.brands;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.goldDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Product',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [

            // IMAGE CARD
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCardTitle('PRODUCT IMAGE', icon: Icons.image_rounded),
                  ProductImagePicker(
                    imagePath: form.imagePath ?? widget.product.imagePath,
                    onChanged: (path) =>
                        context.read<ProductFormProvider>().setImagePath(path),
                    height: 130,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // BASIC INFO CARD
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCardTitle('BASIC INFO', icon: Icons.info_outline_rounded),

                  AppFieldLabel('PRODUCT NAME'),
                  AppInputField(
                    controller: _nameCtrl,
                    hint: 'e.g. Organic Almond Milk',
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Product name required' : null,
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSectionLabel(
                              label: 'BRAND',
                              actionLabel: '+ Manage',
                              onAction: _goManageBrands,
                            ),
                            const SizedBox(height: 6),
                            brands.isEmpty
                                ? AppDropdownEmpty(
                                    message: 'No brands',
                                    onTap: _goManageBrands)
                                : AppDropdown(
                                    value: form.selectedBrand,
                                    hint: 'Select brand',
                                    items: brands,
                                    onChanged: (v) => context
                                        .read<ProductFormProvider>()
                                        .setBrand(v),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSectionLabel(
                              label: 'CATEGORY',
                              actionLabel: '+ Manage',
                              onAction: _goManageCategories,
                            ),
                            const SizedBox(height: 6),
                            categories.isEmpty
                                ? AppDropdownEmpty(
                                    message: 'No categories',
                                    onTap: _goManageCategories)
                                : AppDropdown(
                                    value: form.selectedCategory,
                                    hint: 'Select',
                                    items: categories,
                                    onChanged: (v) => context
                                        .read<ProductFormProvider>()
                                        .setCategory(v),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // PRICING CARD
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCardTitle('PRICING', icon: Icons.currency_rupee_rounded),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppFieldLabel('PURCHASE PRICE'),
                            AppInputField(
                              controller: _costCtrl,
                              hint: '0.00',
                              prefix: Text('₹',
                                  style: TextStyle(
                                      color: AppColors.goldDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
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
                            AppFieldLabel('SELLING PRICE'),
                            AppInputField(
                              controller: _sellCtrl,
                              hint: '0.00',
                              prefix: Text('₹',
                                  style: TextStyle(
                                      color: AppColors.goldDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
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
                ],
              ),
            ),
            const SizedBox(height: 12),

            // STOCK CARD
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCardTitle('STOCK & UNIT', icon: Icons.inventory_2_rounded),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppFieldLabel('QUANTITY'),
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
                            AppFieldLabel('MIN. STOCK'),
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
                  const SizedBox(height: 14),
                  AppFieldLabel('UNIT'),
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: AppInputField(
                          controller: _unitQtyCtrl,
                          hint: '500',
                          keyboard: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppDropdown(
                          value: _selectedUnit,
                          hint: 'Select unit',
                          items: _kUnits,
                          onChanged: (v) =>
                              setState(() => _selectedUnit = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            //  DETAILS CARD
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCardTitle('ADDITIONAL DETAILS',
                      icon: Icons.calendar_today_rounded),
                  AppFieldLabel('EXPIRY DATE'),
                  ExpiryDatePicker(
                    value: form.expiry,
                    onChanged: (date) =>
                        context.read<ProductFormProvider>().setExpiry(date),
                  ),
                  const SizedBox(height: 14),
                  AppFieldLabel('BARCODE NUMBER'),
                  BarcodeField(controller: _barcodeCtrl),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SAVE BUTTON
            GoldButton(
              label: 'Save Changes',
              onPressed: _submit,
              loading: form.loading,
            ),
            const SizedBox(height: 12),

            //  DELETE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.darkRed, width: 1.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  backgroundColor: AppColors.lightRed.withOpacity(0.3),
                ),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.darkRed, size: 18),
                label: const Text('Delete Product',
                    style: TextStyle(
                        color: AppColors.darkRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                onPressed: _confirmDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}