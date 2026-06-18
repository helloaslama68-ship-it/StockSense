import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../core/utils/responsive.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_form_provider.dart';
import '../../providers/sale_provider.dart';
import '../../models/product.dart';
import '../scanner/scanner_screen.dart';
import '../sales/sale_details_screen.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_snack_bar.dart';

class SaleScreen extends StatelessWidget {
  final Product? preselectedProduct;
  const SaleScreen({super.key, this.preselectedProduct});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = SaleFormProvider();
        if (preselectedProduct != null) p.seedProduct(preselectedProduct!);
        return p;
      },
      child: const _SaleScreenBody(),
    );
  }
}

class _SaleScreenBody extends StatelessWidget {
  const _SaleScreenBody();

  Future<void> _pickDate(BuildContext context, SaleFormProvider p) async {
    final picked = await appShowDatePicker(context, initialDate: p.saleDate);
    if (picked != null) p.setSaleDate(picked);
  }

  void _addItem(BuildContext context, SaleFormProvider p) {
    final products = context.read<ProductProvider>().allProducts;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: p,
        child: _ProductPickerSheet(products: products),
      ),
    );
  }

  Future<void> _completeSale(BuildContext context, SaleFormProvider form) async {
    if (form.cart.isEmpty) {
      AppSnackBar.error(context, 'Add at least one item');
      return;
    }
    final saleProvider = context.read<SaleProvider>();
    final customerCtrl = form.customerName;
    try {
      final sale = await saleProvider.recordCartSale(
        cart: form.cart,
        taxPercent: form.taxPercent,
        customerName: customerCtrl,
      );
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SaleDetailsScreen(sale: sale)),
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.error(context, 'Failed to save sale');
    }
  }

  void _editTax(BuildContext context, SaleFormProvider p) {
    final ctrl = TextEditingController(text: p.taxPercent.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Tax %'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 5', suffixText: '%'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldDark),
            onPressed: () {
              p.setTaxPercent(double.tryParse(ctrl.text) ?? 0);
              Navigator.pop(context);
            },
            child: const Text('Apply', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SaleFormProvider>();
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.sectionPad,
              child: Row(
                children: [
                  const AppBackButton(),
                  AppSpacing.hLg,
                  Text('New Sale', style: TextStyle(
                    fontSize: r.sp(18), fontWeight: FontWeight.bold, color: AppColors.goldDark,
                  )),
                ],
              ),
            ),
            AppSpacing.vLg,
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(r.pageHPad, 0, r.pageHPad, 24),
                child: r.constrain(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CUSTOMER + DATE 
                      Container(
                        padding: AppSpacing.cardPad,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (v) => p.setCustomerName(v),
                              decoration: InputDecoration(
                                hintText: 'Customer Name (Optional)',
                                hintStyle: TextStyle(color: AppColors.grey, fontSize: r.sp(13)),
                                filled: true,
                                fillColor: AppColors.lightGrey.withOpacity(0.3),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.goldDark, width: 1.5)),
                                contentPadding: AppSpacing.inputPad,
                              ),
                            ),
                            AppSpacing.vMd,
                            GestureDetector(
                              onTap: () => _pickDate(context, p),
                              child: Container(
                                padding: AppSpacing.inputPad,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.grey),
                                    AppSpacing.hSm,
                                    Text(formatDate(p.saleDate), style: TextStyle(fontSize: r.sp(13), color: Theme.of(context).colorScheme.onSurface)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.vLg,

                      // ADD ITEM BUTTON 
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () => _addItem(context, p),
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.white),
                          label: Text('ADD ITEM', style: TextStyle(
                            color: AppColors.white, fontWeight: FontWeight.bold,
                            fontSize: r.sp(15), letterSpacing: 1,
                          )),
                        ),
                      ),

                      AppSpacing.vLg,

                      // CART 
                      if (p.cart.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cart Items', style: TextStyle(
                              fontSize: r.sp(15), fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,
                            )),
                            Container(
                              padding: AppSpacing.chipPad,
                              decoration: BoxDecoration(
                                color: AppColors.goldDark.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${p.cart.length} ITEM${p.cart.length > 1 ? 'S' : ''}',
                                style: TextStyle(fontSize: r.sp(10), color: AppColors.goldDark, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vSm,
                        ...p.cart.asMap().entries.map((e) => _CartTile(index: e.key, item: e.value)),
                      ],

                      AppSpacing.vLg,

                      // TOTALS
                      Container(
                        padding: AppSpacing.cardPad,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          children: [
                            _TotalRow(label: 'Subtotal', value: '₹${p.subtotal.toStringAsFixed(2)}', r: r),
                            AppSpacing.vSm,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Text('Tax', style: TextStyle(color: AppColors.grey, fontSize: r.sp(13))),
                                  AppSpacing.hSm,
                                  GestureDetector(
                                    onTap: () => _editTax(context, p),
                                    child: Container(
                                      padding: AppSpacing.chipPad,
                                      decoration: BoxDecoration(
                                        color: AppColors.goldDark.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text('${p.taxPercent.toStringAsFixed(0)}%',
                                          style: TextStyle(fontSize: r.sp(11), color: AppColors.goldDark, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ]),
                                Text('₹${p.taxAmount.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: r.sp(13), color: AppColors.grey)),
                              ],
                            ),
                            AppSpacing.vMd,
                            Divider(color: AppColors.lightGrey),
                            AppSpacing.vSm,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('TOTAL AMOUNT', style: TextStyle(
                                    fontSize: r.sp(13), fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,
                                  )),
                                  Text('INCLUSIVE OF ALL TAXES', style: TextStyle(
                                    fontSize: r.sp(9), color: AppColors.grey, letterSpacing: 0.5,
                                  )),
                                ]),
                                Text('₹${p.totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: r.sp(22), fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.vXl,

                      // COMPLETE SALE
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () => _completeSale(context, p),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('COMPLETE SALE', style: TextStyle(
                                color: AppColors.white, fontWeight: FontWeight.bold,
                                fontSize: r.sp(15), letterSpacing: 1,
                              )),
                              AppSpacing.hSm,
                              const Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CART TILE 

class _CartTile extends StatelessWidget {
  final int index;
  final CartItem item;
  const _CartTile({required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    final p = context.read<SaleFormProvider>();
    final r = Responsive.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: AppSpacing.cardPad,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: r.sp(13))),
                AppSpacing.vXs,
                Text('AVAILABLE: ${item.product.quantity} UNITS',
                    style: TextStyle(fontSize: r.sp(10), color: AppColors.grey)),
                AppSpacing.vXs,
                Row(children: [
                  Text('₹${item.product.sellingPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: r.sp(12), color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                  AppSpacing.hSm,
                  Text('₹${item.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: r.sp(12), color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => p.removeAt(index),
                child: const Icon(Icons.delete_rounded, color: AppColors.darkRed, size: 18),
              ),
              AppSpacing.vSm,
              Row(children: [
                _QtyBtn(icon: Icons.remove, onTap: () => p.decrementAt(index)),
                Container(
                  width: 32, alignment: Alignment.center,
                  child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                _QtyBtn(icon: Icons.add, onTap: () {
                  if (item.quantity < item.product.quantity) {
                    p.incrementAt(index);
                  } else {
                    AppSnackBar.error(context, 'Only ${item.product.quantity} units available');
                  }
                }),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// QTY BUTTON 

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface),
    ),
  );
}

// TOTAL ROW 

class _TotalRow extends StatelessWidget {
  final String label, value;
  final Responsive r;
  const _TotalRow({required this.label, required this.value, required this.r});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: r.sp(13), color: AppColors.grey)),
      Text(value,  style: TextStyle(fontSize: r.sp(13), color: AppColors.grey)),
    ],
  );
}

// PRODUCT PICKER SHEET 

class _ProductPickerSheet extends StatefulWidget {
  final List<Product> products;
  const _ProductPickerSheet({required this.products});

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SaleFormProvider>();
    final r = Responsive.of(context);

    if (searchCtrl.text != p.searchQuery) {
      searchCtrl.text = p.searchQuery;
      searchCtrl.selection = TextSelection.collapsed(offset: p.searchQuery.length);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(10)),
              ),
              AppSpacing.vLg,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Add Item', style: TextStyle(fontSize: r.sp(18), fontWeight: FontWeight.bold)),
                    Text('Add product to current transaction',
                        style: TextStyle(fontSize: r.sp(12), color: AppColors.grey)),
                  ]),
                  GestureDetector(
                    onTap: () { p.resetPicker(); Navigator.pop(context); },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.grey, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ),
                ],
              ),

              AppSpacing.vXl,

              //BARCODE SCAN 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: AppColors.goldDark, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.white, size: 28),
                    ),
                    AppSpacing.vSm,
                    Text('Scan Barcode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: r.sp(13))),
                    AppSpacing.vXs,
                    Text('Quick item entry via camera',
                        style: TextStyle(fontSize: r.sp(11), color: AppColors.grey)),
                    AppSpacing.vMd,
                    GestureDetector(
                      onTap: () async {
                        final code = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(builder: (_) => const ScannerScreen(returnBarcodeOnly: true)),
                        );
                        if (!mounted) return;
                        if (code != null) {
                          final match = widget.products
                              .where((prod) =>
                                  (prod.barcode != null && prod.barcode == code) ||
                                  prod.name.toLowerCase().contains(code.toLowerCase()))
                              .firstOrNull;
                          if (match != null) {
                            p.selectProduct(match);
                            p.setSearchQueryOnly(match.name);
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.goldDark.withOpacity(0.3)),
                        ),
                        child: Text('Open Scanner',
                            style: TextStyle(fontSize: r.sp(13), color: AppColors.goldDark, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.vLg,

              Text('SELECT PRODUCT', style: TextStyle(
                fontSize: r.sp(10), letterSpacing: 1.2, color: AppColors.grey, fontWeight: FontWeight.w600,
              )),
              AppSpacing.vSm,

              TextField(
                controller: searchCtrl,
                onChanged: (val) {
                  final match = widget.products
                      .where((prod) =>
                          prod.name.toLowerCase() == val.trim().toLowerCase() &&
                          prod.quantity > 0)
                      .firstOrNull;
                  if (match != null) {
                    p.setSearchQueryOnly(val);
                    p.selectProduct(match);
                  } else {
                    p.setSearchQuery(val);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter product name',
                  hintStyle: TextStyle(color: AppColors.grey, fontSize: r.sp(13)),
                  filled: true,
                  fillColor: AppColors.grey,
                  prefixIcon: const Icon(Icons.edit_outlined, size: 20),
                  suffixIcon: p.selectedProduct != null
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20)
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.goldDark, width: 1.5),
                  ),
                  contentPadding: AppSpacing.inputPad,
                ),
              ),

              if (p.searchQuery.isNotEmpty && p.selectedProduct == null) ...[
                AppSpacing.vXs,
                Text('No matching product found',
                    style: TextStyle(fontSize: r.sp(11), color: AppColors.grey)),
              ],

              AppSpacing.vLg,

              //  QTY + PRICE
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QUANTITY', style: TextStyle(fontSize: r.sp(10), color: AppColors.grey, fontWeight: FontWeight.w600)),
                    AppSpacing.vSm,
                    Container(
                      decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        IconButton(onPressed: p.decrementPickerQty, icon: const Icon(Icons.remove, size: 18), padding: EdgeInsets.zero),
                        Expanded(child: Text('${p.pickerQuantity}', textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: r.sp(15)))),
                        IconButton(onPressed: p.incrementPickerQty, icon: const Icon(Icons.add, size: 18), padding: EdgeInsets.zero),
                      ]),
                    ),
                  ],
                )),
                AppSpacing.hMd,
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UNIT PRICE', style: TextStyle(fontSize: r.sp(10), color: AppColors.grey, fontWeight: FontWeight.w600)),
                    AppSpacing.vSm,
                    Container(
                      padding: AppSpacing.inputPad,
                      decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        p.selectedProduct != null ? '₹ ${p.selectedProduct!.sellingPrice.toStringAsFixed(2)}' : '₹ 0.00',
                        style: TextStyle(
                          fontSize: r.sp(14), fontWeight: FontWeight.w600,
                          color: p.selectedProduct != null ? Theme.of(context).colorScheme.onSurface : AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                )),
              ]),

              AppSpacing.vLg,

              // CALCULATED TOTAL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('CALCULATED TOTAL', style: TextStyle(fontSize: r.sp(9), color: AppColors.white, letterSpacing: 1)),
                      Text('inclusive of all taxes', style: TextStyle(fontSize: r.sp(9), color: AppColors.white)),
                    ]),
                    Text('₹${p.calculatedTotal.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: r.sp(20), fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                  ],
                ),
              ),

              AppSpacing.vLg,

              // ADD TO SALE
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: p.selectedProduct == null ? null : () {
                    p.addOrIncrementProduct(p.selectedProduct!);
                    p.resetPicker();
                    Navigator.pop(context);
                  },
                  child: Text('Add to Sale', style: TextStyle(
                    color: AppColors.white, fontWeight: FontWeight.bold, fontSize: r.sp(15),
                  )),
                ),
              ),

              TextButton(
                onPressed: () { p.resetPicker(); Navigator.pop(context); },
                child: Text('Cancel', style: TextStyle(color: AppColors.grey, fontSize: r.sp(13))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}