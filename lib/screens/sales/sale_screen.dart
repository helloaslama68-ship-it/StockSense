import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_form_provider.dart';
import '../../models/product.dart';
import '../scanner/scanner_screen.dart';

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

  void _completeSale(BuildContext context, SaleFormProvider p) {
    if (p.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add at least one item'),
        backgroundColor: AppColors.darkRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Sale completed successfully!'),
      backgroundColor: AppColors.darkGreen,
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.pop(context);
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Only ${item.product.quantity} units available'),
                      backgroundColor: AppColors.darkRed,
                      behavior: SnackBarBehavior.floating,
                    ));
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

class _ProductPickerSheet extends StatelessWidget {
  final List<Product> products;
  const _ProductPickerSheet({required this.products});

  List<Product> _filtered(String q) =>
      products.where((p) => p.name.toLowerCase().contains(q.toLowerCase()) && p.quantity > 0).toList();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SaleFormProvider>();
    final searchCtrl = TextEditingController();
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
              TextField(
                controller: searchCtrl,
                onChanged: (_) => p.clearSelection(),
                decoration: InputDecoration(
                  hintText: 'Search product name or SKU',
                  hintStyle: TextStyle(color: AppColors.grey, fontSize: 13),
                  filled: true, fillColor: AppColors.grey[100],
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              if (searchCtrl.text.isNotEmpty && p.selectedProduct == null) ...[
                const SizedBox(height: 4),
                Container(
                  constraints: const BoxConstraints(maxHeight: 160),
                  decoration: BoxDecoration(
                    color: AppColors.white, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.grey[200]!),
                    boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filtered(searchCtrl.text).length,
                    itemBuilder: (_, i) {
                      final prod = _filtered(searchCtrl.text)[i];
                      return ListTile(
                        dense: true,
                        onTap: () { p.selectProduct(prod); searchCtrl.text = prod.name; },
                        title: Text(prod.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text('₹${prod.sellingPrice.toStringAsFixed(2)} · ${prod.quantity} in stock',
                            style: TextStyle(fontSize: 11, color: AppColors.grey)),
                        trailing: Icon(Icons.add_circle_outline_rounded, color: AppColors.goldDark, size: 20),
                      );
                    },
                  ),
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