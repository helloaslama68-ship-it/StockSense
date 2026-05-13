import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../scanner/scanner_screen.dart';

// -------------------------------------------------------------------
//  CART ITEM MODEL
//  Wraps a Product with a mutable quantity for the current sale.
//------------------------------------------------------------------
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// Selling price × quantity for this line item.
  double get subtotal => product.sellingPrice * quantity;
}

// ----------------------------------------------------------------
//  SALE SCREEN
//  Main screen for creating a new sale transaction.
//  Accepts an optional pre-selected product (e.g. from barcode scan).
// ------------------------------------------------------------------
class SaleScreen extends StatefulWidget {
  final Product? preselectedProduct;
  const SaleScreen({super.key, this.preselectedProduct});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final _customerCtrl = TextEditingController(); // Optional customer name input
  DateTime _saleDate = DateTime.now();           // Defaults to today
  final List<CartItem> _cart = [];               // In-memory cart for this transaction
  double _taxPercent = 0;                        // Tax rate; editable by user

  @override
  void initState() {
    super.initState();
    // If launched with a pre-selected product, seed the cart immediately.
    if (widget.preselectedProduct != null) {
      _cart.add(CartItem(product: widget.preselectedProduct!, quantity: 1));
    }
  }

  // ── Computed totals 
  double get _subtotal   => _cart.fold(0, (s, i) => s + i.subtotal);
  double get _taxAmount  => _subtotal * _taxPercent / 100;
  double get _totalAmount => _subtotal + _taxAmount;

  /// Formats a DateTime as "Mon DD, YYYY" for display.
  String _formatDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month-1]} ${d.day}, ${d.year}';
  }

  /// Opens the native date picker; updates [_saleDate] on selection.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.goldDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _saleDate = picked);
  }

  /// Shows the product picker bottom sheet.
  /// Increments quantity if product already in cart, else adds new CartItem.
  void _addItem() {
    final products = context.read<ProductProvider>().allProducts;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductPickerSheet(
        products: products,
        alreadyAdded: _cart.map((c) => c.product.id).toList(),
        onPick: (product) {
          setState(() {
            final existing = _cart.indexWhere((c) => c.product.id == product.id);
            if (existing >= 0) {
              _cart[existing].quantity++; // Bump quantity if already in cart
            } else {
              _cart.add(CartItem(product: product, quantity: 1));
            }
          });
        },
      ),
    );
  }

  /// Validates the cart and submits the sale.
  /// TODO: wire to SaleProvider.recordSale() + ProductProvider.updateQuantity()
  void _completeSale() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add at least one item'),
        backgroundColor: AppColors.darkRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    // Placeholder success feedback; replace with real persistence logic.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Sale completed successfully!'),
      backgroundColor: AppColors.darkGreen,
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.pop(context);
  }

  /// Prompts the user to enter a custom tax percentage (0–100).
  void _editTax() {
    final ctrl = TextEditingController(text: _taxPercent.toStringAsFixed(0));
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
              final val = double.tryParse(ctrl.text) ?? 0;
              setState(() => _taxPercent = val.clamp(0, 100)); // Clamp to valid range
              Navigator.pop(context);
            },
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar 
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  // Back button
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
                  Text('New Sale',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Scrollable body 
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Customer & date card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        children: [
                          // Optional customer name
                          TextField(
                            controller: _customerCtrl,
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
                          // Tappable date selector
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(color: AppColors.lightGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.grey),
                                  const SizedBox(width: 10),
                                  Text(_formatDate(_saleDate), style: TextStyle(fontSize: 13, color: AppColors.black)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Add Item button ──────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.white),
                        label: const Text('ADD ITEM', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Cart list (shown only when cart non-empty) ──
                    if (_cart.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cart Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black)),
                          // Item count badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.goldDark.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text('${_cart.length} ITEM${_cart.length > 1 ? 'S' : ''}',
                                style: TextStyle(fontSize: 10, color: AppColors.goldDark, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Render each cart item as a tile
                      ..._cart.asMap().entries.map((e) => _cartTile(e.key, e.value)),
                    ],
                    const SizedBox(height: 16),

                    // ── Order summary card ───────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        children: [
                          _totalRow('Subtotal', '₹${_subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 10),
                          // Tax row with inline editable percentage badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text('Tax', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  // Tapping opens _editTax dialog
                                  GestureDetector(
                                    onTap: _editTax,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: AppColors.goldDark.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                      child: Text('${_taxPercent.toStringAsFixed(0)}%',
                                          style: TextStyle(fontSize: 11, color: AppColors.goldDark, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                              Text('₹${_taxAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppColors.lightGrey),
                          const SizedBox(height: 8),
                          // Grand total row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL AMOUNT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.black)),
                                  Text('INCLUSIVE OF ALL TAXES', style: TextStyle(fontSize: 9, color: AppColors.grey, letterSpacing: 0.5)),
                                ],
                              ),
                              Text('₹${_totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Complete Sale CTA ────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _completeSale,
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

  // ── Cart tile ──────────────────────────────────────────────
  /// Renders a single cart item row with product info,
  /// quantity stepper, and delete button.
  Widget _cartTile(int index, CartItem item) {
    final stock = item.product.quantity; // Max available stock
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
          // Left: product name, stock, price info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text('AVAILABLE: $stock UNITS', style: TextStyle(fontSize: 10, color: AppColors.grey, letterSpacing: 0.3)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('UNIT PRICE', style: TextStyle(fontSize: 9, color: AppColors.grey)),
                    const SizedBox(width: 8),
                    Text('SUBTOTAL', style: TextStyle(fontSize: 9, color: AppColors.grey)),
                  ],
                ),
                Row(
                  children: [
                    Text('₹${item.product.sellingPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: AppColors.black, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text('₹${item.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: AppColors.black, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          // Right: delete icon + quantity stepper
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Remove item entirely
              GestureDetector(
                onTap: () => setState(() => _cart.removeAt(index)),
                child: const Icon(Icons.delete_rounded, color: AppColors.darkRed, size: 18),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Decrement: removes item when quantity reaches 0
                  _qtyBtn(
                    icon: Icons.remove,
                    onTap: () => setState(() {
                      if (item.quantity > 1) item.quantity--;
                      else _cart.removeAt(index);
                    }),
                  ),
                  Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  // Increment: capped at available stock
                  _qtyBtn(
                    icon: Icons.add,
                    onTap: () {
                      if (item.quantity < item.product.quantity) {
                        setState(() => item.quantity++);
                      } else {
                        // Notify user when stock limit reached
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Only ${item.product.quantity} units available'),
                          backgroundColor: AppColors.darkRed,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('UNITS', style: TextStyle(fontSize: 9, color: AppColors.grey, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  /// Small square icon button used in the quantity stepper.
  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: AppColors.lightGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: AppColors.black),
      ),
    );
  }

  /// Simple label/value row used in the order summary section.
  Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.grey)),
        Text(value, style: TextStyle(fontSize: 13, color: AppColors.grey)),
      ],
    );
  }
}

// ---------------------------------------------------------
//  PRODUCT PICKER SHEET
//  Bottom sheet for selecting a product to add to the cart.
//  Supports text search, barcode scan, and quantity selection.
// -------------------------------------------------------------
class _ProductPickerSheet extends StatefulWidget {
  final List<Product> products;
  final List<String> alreadyAdded; // IDs already in cart (reserved for future filtering)
  final ValueChanged<Product> onPick;

  const _ProductPickerSheet({
    required this.products,
    required this.alreadyAdded,
    required this.onPick,
  });

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final _searchCtrl = TextEditingController();
  Product? _selected; // Currently highlighted product
  int _quantity = 1;

  /// Products matching current search query with stock > 0.
  List<Product> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return widget.products
        .where((p) => p.name.toLowerCase().contains(q) && p.quantity > 0)
        .toList();
  }

  /// Preview total for the selected product × chosen quantity.
  double get _calculatedTotal => (_selected?.sellingPrice ?? 0) * _quantity;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lift sheet above keyboard when open
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle indicator
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color:AppColors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header row 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Add product to current transaction', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.grey[100], shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Barcode scanner card 
              // Launches ScannerScreen and pre-fills search with returned barcode.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey[50],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.goldDark.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.qr_code_scanner_rounded, color: AppColors.goldDark, size: 30),
                    ),
                    const SizedBox(height: 8),
                    const Text('Scan Barcode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('Quick item entry via camera', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        // Open scanner; receive barcode string back
                        final code = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScannerScreen(returnBarcodeOnly: true),
                          ),
                        );
                        if (code != null) {
                          // Pre-fill search with scanned barcode and reset selection
                          setState(() {
                            _searchCtrl.text = code;
                            _selected = null;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.goldDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      ),
                      child: Text('Open Scanner', style: TextStyle(color: AppColors.goldDark, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Product search 
              Text('SELECT PRODUCT', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() => _selected = null), // Reset selection on new query
                decoration: InputDecoration(
                  hintText: 'Search product name or SKU',
                  hintStyle: TextStyle(color: AppColors.grey, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.grey[100],
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              // Dropdown results: shown while typing and no product selected yet
              if (_searchCtrl.text.isNotEmpty && _selected == null) ...[
                const SizedBox(height: 4),
                Container(
                  constraints: const BoxConstraints(maxHeight: 160),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.grey[200]!),
                    boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final p = _filtered[i];
                      return ListTile(
                        dense: true,
                        onTap: () => setState(() {
                          _selected = p;          // Confirm selection
                          _searchCtrl.text = p.name; // Show name in field
                          _quantity = 1;          // Reset quantity
                        }),
                        title: Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text('₹${p.sellingPrice.toStringAsFixed(2)} · ${p.quantity} in stock',
                            style: TextStyle(fontSize: 11, color: AppColors.grey)),
                        trailing: Icon(Icons.add_circle_outline_rounded, color: AppColors.goldDark, size: 20),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // ── Quantity & unit price row 
              Row(
                children: [
                  // Quantity stepper
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('QUANTITY', style: TextStyle(fontSize: 10, letterSpacing: 1, color: AppColors.grey, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(color: AppColors.grey[100], borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () { if (_quantity > 1) setState(() => _quantity--); },
                                icon: const Icon(Icons.remove, size: 18),
                                padding: EdgeInsets.zero,
                              ),
                              Expanded(
                                child: Text('$_quantity', textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                              // Increment capped at selected product's stock
                              IconButton(
                                onPressed: () {
                                  final max = _selected?.quantity ?? 999;
                                  if (_quantity < max) setState(() => _quantity++);
                                },
                                icon: const Icon(Icons.add, size: 18),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Read-only unit price display
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UNIT PRICE', style: TextStyle(fontSize: 10, letterSpacing: 1, color: AppColors.grey, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(color:AppColors.grey[100], borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            _selected != null ? '₹ ${_selected!.sellingPrice.toStringAsFixed(2)}' : '₹ 0.00',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                color: _selected != null ? AppColors.black : AppColors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Calculated total banner 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CALCULATED TOTAL', style: TextStyle(fontSize: 9, color: AppColors.white, letterSpacing: 1)),
                        Text('inclusive of all taxes', style: TextStyle(fontSize: 9, color: AppColors.white)),
                      ],
                    ),
                    Text('₹${_calculatedTotal.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Confirm add button (disabled until product selected) 
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _selected == null
                      ? null // Greyed out when no product chosen
                      : () {
                          widget.onPick(_selected!);
                          Navigator.pop(context);
                        },
                  child: const Text('Add to Sale',
                      style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}