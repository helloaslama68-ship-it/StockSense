import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_form_provider.dart';
import '../../providers/product_unit_provider.dart';
import '../../core/app_styles.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/expiry_date_picker.dart';
import '../../widgets/barcode_field.dart';
import '../../models/product.dart';
import '../scanner/scanner_screen.dart';
import '../../widgets/product_image_picker.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_card.dart';
import 'manage_brands_screen.dart';
import 'manage_categories_screen.dart';

class AddProductScreen extends StatefulWidget {
  final String? initialBarcode;
  const AddProductScreen({super.key, this.initialBarcode});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _descCtrl      = TextEditingController();
  final _costCtrl      = TextEditingController();
  final _sellCtrl      = TextEditingController();
  final _qtyCtrl       = TextEditingController(text: '0');
  final _thresholdCtrl = TextEditingController(text: '5');
  final _unitQtyCtrl   = TextEditingController();
  final _barcodeCtrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductFormProvider>().reset();
      context.read<ProductUnitProvider>().reset();
    });
    if (widget.initialBarcode != null) {
      _barcodeCtrl.text = widget.initialBarcode!;
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _descCtrl, _costCtrl, _sellCtrl,
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

  /// Open scanner in product-fill mode.
  /// If a known product is scanned → fill all fields from it.
  /// If unknown barcode → fill barcode field only.
  Future<void> _fillFromScan() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => const ScannerScreen(returnProductIfFound: true),
      ),
    );
    if (result == null || !mounted) return;

    if (result is Product) {
      // Known product — pre-fill everything
      _nameCtrl.text      = result.name;
      _costCtrl.text      = result.costPrice.toString();
      _sellCtrl.text      = result.sellingPrice.toString();
      _qtyCtrl.text       = result.quantity.toString();
      _thresholdCtrl.text = result.lowStockThreshold.toString();
      _barcodeCtrl.text   = result.barcode ?? '';

        final unitProv = context.read<ProductUnitProvider>();
        if (result.unit != null) {
          final parts = result.unit!.trim().split(' ');
          if (parts.length == 2) {
            _unitQtyCtrl.text = parts[0];
            unitProv.setUnit(kProductUnits.contains(parts[1]) ? parts[1] : null);
          } else {
            unitProv.setUnit(kProductUnits.contains(result.unit) ? result.unit : null);
          }
        }

      final form = context.read<ProductFormProvider>();
      form.setCategory(result.category);
      form.setBrand(result.brand);
      if (result.expiryDate != null) {
        form.setExpiry(DateTime.tryParse(result.expiryDate!));
      }
      if (result.imagePath != null) {
        form.setImagePath(result.imagePath);
      }
    } else if (result is String) {
      // Unknown barcode — fill barcode field only
      _barcodeCtrl.text = result;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Cross-field: selling price should not be less than cost price
    final cost = double.tryParse(_costCtrl.text) ?? 0;
    final sell = double.tryParse(_sellCtrl.text) ?? 0;
    if (sell < cost) {
      AppSnackBar.error(context, 'Selling price cannot be less than cost price');
      return;
    }
    final form = context.read<ProductFormProvider>();
    final unitProv = context.read<ProductUnitProvider>();
    form.setLoading(true);

    await context.read<ProductProvider>().addProduct(
      name:              _nameCtrl.text.trim(),
      category:          form.selectedCategory ?? 'Other',
      costPrice:         double.parse(_costCtrl.text),
      sellingPrice:      double.parse(_sellCtrl.text),
      quantity:          int.parse(_qtyCtrl.text),
      lowStockThreshold: int.parse(_thresholdCtrl.text),
      expiryDate:        form.expiry?.toIso8601String(),
      barcode:           _barcodeCtrl.text.trim().isEmpty
                             ? null : _barcodeCtrl.text.trim(),
      unit:              (unitProv.selectedUnit != null && _unitQtyCtrl.text.trim().isNotEmpty)
                             ? '${_unitQtyCtrl.text.trim()} ${unitProv.selectedUnit}'
                             : unitProv.selectedUnit,
      imagePath:         form.imagePath,
      brand:             form.selectedBrand,
    );

    form.setLoading(false);
    if (mounted) {
      AppSnackBar.success(context, 'Product saved successfully!');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form       = context.watch<ProductFormProvider>();
    final unitProv   = context.watch<ProductUnitProvider>();
    final inv        = context.watch<InventoryProvider>();
    final categories = inv.categories;
    final brands     = inv.brands;
    final isDark     = Theme.of(context).brightness == Brightness.dark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductFormProvider>()
          .guardSelections(categories: categories, brands: brands);
    });

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
        title: Text(
          'Add Product',
          style: TextStyle(
            // theme-aware: white in dark, black in light
            color: isDark ? AppColors.white : AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
                    imagePath: form.imagePath,
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
                  const SizedBox(height: 14),

                  AppFieldLabel('DESCRIPTION'),
                  AppInputField(
                    controller: _descCtrl,
                    hint: 'Enter detailed product description...',
                    maxLines: 3,
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
                                final n = double.tryParse(v);
                                if (n == null) return 'Invalid number';
                                if (n < 0) return 'Cannot be negative';
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
                                final n = double.tryParse(v);
                                if (n == null) return 'Invalid number';
                                if (n < 0) return 'Cannot be negative';
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
                                final n = int.tryParse(v);
                                if (n == null) return 'Whole number required';
                                if (n < 0) return 'Cannot be negative';
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
                                final n = int.tryParse(v);
                                if (n == null) return 'Whole number required';
                                if (n < 0) return 'Cannot be negative';
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
                          value: unitProv.selectedUnit,
                          hint: 'Select unit',
                          items: kProductUnits,
                          onChanged: (v) =>
                              context.read<ProductUnitProvider>().setUnit(v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // DETAILS CARD
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
                  // Tap the barcode icon to scan — fills ALL fields if product found
                  BarcodeField(
                    controller: _barcodeCtrl,
                    onScanTap: _fillFromScan,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SAVE BUTTON
            GoldButton(
              label: 'Save Product',
              onPressed: _submit,
              loading: form.loading,
            ),
          ],
        ),
      ),
    );
  }
}