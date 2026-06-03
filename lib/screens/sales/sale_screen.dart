import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_form_provider.dart';
import '../../providers/sale_provider.dart';
import '../../models/product.dart';
import '../scanner/scanner_screen.dart';
import '../sales/sale_details_screen.dart';
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

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month-1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickDate(BuildContext context, SaleFormProvider p) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: p.saleDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.goldDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) p.setSaleDate(picked);
  }

  void _addItem(BuildContext context, SaleFormProvider p) {
    final products = context.read<ProductProvider>().allProducts;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SaleFormProvider>();
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: AppColors.black, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('New Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (v) => p.setCustomerName(v),
                            decoration: InputDecoration(
                              hintText: 'Customer Name (Optional)',
                              hintStyle: TextStyle(color: AppColors.grey, fontSize: 13),
                              filled: true,
                              fillColor: AppColors.lightGrey.withOpacity(0.3),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.goldDark, width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _pickDate(context, p),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(color: AppColors.lightGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.grey),
                                  const SizedBox(width: 10),
                                  Text(_formatDate(p.saleDate), style: TextStyle(fontSize: 13, color: AppColors.black)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        label: const Text('ADD ITEM', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (p.cart.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cart Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.goldDark.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text('${p.cart.length} ITEM${p.cart.length > 1 ? 'S' : ''}',
                                style: TextStyle(fontSize: 10, color: AppColors.goldDark, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...p.cart.asMap().entries.map((e) => _CartTile(index: e.key, item: e.value)),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        children: [
                          _TotalRow(label: 'Subtotal', value: '₹${p.subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Text('Tax', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _editTax(context, p),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: AppColors.goldDark.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: Text('${p.taxPercent.toStringAsFixed(0)}%',
                                        style: TextStyle(fontSize: 11, color: AppColors.goldDark, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ]),
                              Text('₹${p.taxAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppColors.lightGrey),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('TOTAL AMOUNT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.black)),
                                Text('INCLUSIVE OF ALL TAXES', style: TextStyle(fontSize: 9, color: AppColors.grey, letterSpacing: 0.5)),
                              ]),
                              Text('₹${p.totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          children: const [
                            Text('COMPLETE SALE', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final int index;
  final CartItem item;
  const _CartTile({required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    final p = context.read<SaleFormProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text('AVAILABLE: ${item.product.quantity} UNITS', style: TextStyle(fontSize: 10, color: AppColors.grey)),
                const SizedBox(height: 4),
                Row(children: [
                  Text('₹${item.product.sellingPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12, color: AppColors.black, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text('₹${item.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12, color: AppColors.black, fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(onTap: () => p.removeAt(index),
                  child: const Icon(Icons.delete_rounded, color: AppColors.darkRed, size: 18)),
              const SizedBox(height: 8),
              Row(children: [
                _QtyBtn(icon: Icons.remove, onTap: () => p.decrementAt(index)),
                Container(width: 32, alignment: Alignment.center,
                    child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
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

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: AppColors.lightGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 16, color: AppColors.black),
    ),
  );
}

class _TotalRow extends StatelessWidget {
  final String label, value;
  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: 13, color: AppColors.grey)),
      Text(value, style: TextStyle(fontSize: 13, color: AppColors.grey)),
    ],
  );
}

// StatefulWidget kept for: TextEditingController lifecycle + mounted check only
// All reactive state (searchQuery, selectedProduct) lives in provider
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

  List<Product> _filtered(String q) =>
      widget.products
          .where((p) => p.name.toLowerCase().contains(q.toLowerCase()) && p.quantity > 0)
          .toList();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SaleFormProvider>();

    // Sync controller text with provider (e.g. after scan fills it)
    if (searchCtrl.text != p.searchQuery) {
      searchCtrl.text = p.searchQuery;
      searchCtrl.selection = TextSelection.collapsed(offset: p.searchQuery.length);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Add Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Add product to current transaction', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                  ]),
                  GestureDetector(
                    onTap: () { p.resetPicker(); Navigator.pop(context); },
                    child: Container(padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.grey[100], shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, size: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── BARCODE SCAN SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: AppColors.goldDark, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.white, size: 28),
                    ),
                    const SizedBox(height: 10),
                    const Text('Scan Barcode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('Quick item entry via camera', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                    const SizedBox(height: 12),
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
                            style: TextStyle(fontSize: 13, color: AppColors.goldDark, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Text('SELECT PRODUCT',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: searchCtrl,
                onChanged: (val) {
                  final match = widget.products
                      .where((prod) =>
                          prod.name.toLowerCase() == val.trim().toLowerCase() &&
                          prod.quantity > 0)
                      .firstOrNull;
                  if (match != null) {
                    // Update query text and select product (don't clear selection)
                    p.setSearchQueryOnly(val);
                    p.selectProduct(match);
                  } else {
                    // Update query and clear any stale selection
                    p.setSearchQuery(val);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter product name',
                  hintStyle: TextStyle(color: AppColors.grey, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.grey[100],
                  prefixIcon: const Icon(Icons.edit_outlined, size: 20),
                  suffixIcon: p.selectedProduct != null
                      ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.goldDark, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                ),
              ),
              if (p.searchQuery.isNotEmpty && p.selectedProduct == null) ...[
                const SizedBox(height: 4),
                Text(
                  'No matching product found',
                  style: TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QUANTITY', style: TextStyle(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(color: AppColors.grey[100], borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        IconButton(onPressed: p.decrementPickerQty, icon: const Icon(Icons.remove, size: 18), padding: EdgeInsets.zero),
                        Expanded(child: Text('${p.pickerQuantity}', textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        IconButton(onPressed: p.incrementPickerQty, icon: const Icon(Icons.add, size: 18), padding: EdgeInsets.zero),
                      ]),
                    ),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UNIT PRICE', style: TextStyle(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(color: AppColors.grey[100], borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        p.selectedProduct != null ? '₹ ${p.selectedProduct!.sellingPrice.toStringAsFixed(2)}' : '₹ 0.00',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                            color: p.selectedProduct != null ? AppColors.black : AppColors.grey),
                      ),
                    ),
                  ],
                )),
              ]),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('CALCULATED TOTAL', style: TextStyle(fontSize: 9, color: AppColors.white, letterSpacing: 1)),
                      Text('inclusive of all taxes', style: TextStyle(fontSize: 9, color: AppColors.white)),
                    ]),
                    Text('₹${p.calculatedTotal.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                  child: const Text('Add to Sale', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              TextButton(
                onPressed: () { p.resetPicker(); Navigator.pop(context); },
                child: Text('Cancel', style: TextStyle(color: AppColors.grey, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}