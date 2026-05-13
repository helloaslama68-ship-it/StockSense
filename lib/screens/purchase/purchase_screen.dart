import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../models/product.dart';

// ── PURCHASE LINE ITEM ─────────────────────────────────────
class PurchaseLineItem {
  String productName;
  String? imagePath;
  double costPrice;
  int quantity;
  String unit;

  PurchaseLineItem({
    required this.productName,
    this.imagePath,
    required this.costPrice,
    required this.quantity,
    required this.unit,
  });

  double get total => costPrice * quantity;
}

// 
//  PURCHASE SCREEN
// 
class PurchaseScreen extends StatefulWidget {
  final Product? preselectedProduct;
  const PurchaseScreen({super.key, this.preselectedProduct});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final _supplierCtrl = TextEditingController();
  DateTime? _purchaseDate;
  final List<PurchaseLineItem> _items = [];
  double _taxPercent = 0;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedProduct != null) {
      final p = widget.preselectedProduct!;
      _items.add(PurchaseLineItem(
        productName: p.name,
        imagePath: p.imagePath,
        costPrice: p.costPrice,
        quantity: p.lowStockThreshold * 2,
        unit: p.unit ?? 'units',
      ));
    }
  }

  double get _subtotal => _items.fold(0, (s, i) => s + i.total);
  double get _taxAmount => _subtotal * _taxPercent / 100;
  double get _finalTotal => _subtotal + _taxAmount;

  String _formatDate(DateTime d) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.goldDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  void _addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(
        onAdd: (item) => setState(() => _items.add(item)),
      ),
    );
  }

  void _editItem(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(
        existing: _items[index],
        onAdd: (item) => setState(() => _items[index] = item),
      ),
    );
  }

  void _deleteItem(int index) => setState(() => _items.removeAt(index));

  void _savePurchase() {
    if (_supplierCtrl.text.trim().isEmpty) {
      _snack('Please enter supplier name', AppColors.darkRed);
      return;
    }
    if (_items.isEmpty) {
      _snack('Add at least one item', AppColors.darkRed);
      return;
    }
    // TODO: wire to PurchaseProvider + ProductProvider.updateQuantity()
    _snack('Purchase recorded successfully!', AppColors.darkGreen);
    Navigator.pop(context);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  void dispose() {
    _supplierCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.black.withOpacity(0.05),
                              blurRadius: 8)
                        ],
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          color: AppColors.black, size: 20),
                    ),
                  ),
                  Text('New Purchase',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark)),
                  GestureDetector(
                    onTap: _savePurchase,
                    child: Text('Save',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldDark)),
                  ),
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
                    // ── ACQUISITION DETAILS ─────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('ACQUISITION DETAILS'),
                          const SizedBox(height: 14),
                          _sectionLabel('SUPPLIER NAME'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _supplierCtrl,
                            decoration: _inputDeco('Enter supplier'),
                          ),
                          const SizedBox(height: 14),
                          _sectionLabel('PURCHASE DATE'),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _purchaseDate != null
                                        ? _formatDate(_purchaseDate!)
                                        : 'Select date',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: _purchaseDate != null
                                            ? AppColors.black
                                            : AppColors.grey),
                                  ),
                                  Icon(Icons.calendar_today_rounded,
                                      size: 18, color: AppColors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── ADD ITEM BUTTON ──────────────────
                    if (_items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.goldDark.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Need to record more stock?',
                                  style: TextStyle(
                                      fontSize: 13, color: AppColors.grey)),
                            ),
                            GestureDetector(
                              onTap: _addItem,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.goldDark,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.add_rounded,
                                        color: AppColors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text('Add Item',
                                        style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldDark,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _addItem,
                          icon: const Icon(Icons.add_circle_outline_rounded,
                              color: AppColors.white),
                          label: const Text('Add Item',
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // ── ITEMS LIST ───────────────────────
                    if (_items.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionLabel('PURCHASED ITEMS'),
                          Text('${_items.length} Items',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ..._items.asMap().entries.map(
                          (e) => _itemTile(e.key, e.value)),
                    ] else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 48, color: AppColors.lightGrey),
                            const SizedBox(height: 12),
                            Text('No items added yet',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black)),
                            const SizedBox(height: 4),
                            Text(
                              'Tap the button above to add\nproducts to this purchase.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // ── TOTALS ───────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        children: [
                          _totalRow('Subtotal',
                              '₹${_subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text('Tax',
                                      style: TextStyle(
                                          color: AppColors.grey,
                                          fontSize: 13)),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _editTax,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.goldDark
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${_taxPercent.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.goldDark,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text('₹${_taxAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.grey)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppColors.lightGrey),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TOTAL AMOUNT',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                      letterSpacing: 0.5)),
                              Text(
                                '₹${_finalTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.goldDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── SAVE BUTTON ──────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldDark,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _savePurchase,
                        child: const Text('Save Purchase',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
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

  Widget _itemTile(int index, PurchaseLineItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.shopping_bag_outlined,
                color: AppColors.grey, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text('+${item.quantity} ${item.unit}',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${item.costPrice.toStringAsFixed(2)}/${item.unit}',
                  style: TextStyle(fontSize: 10, color: AppColors.grey)),
              Text('₹${item.total.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.goldDark)),
              const SizedBox(height: 4),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _editItem(index),
                    child: Icon(Icons.edit_rounded,
                        size: 16, color: AppColors.grey),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _deleteItem(index),
                    child: const Icon(Icons.delete_rounded,
                        size: 16, color: AppColors.darkRed),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: AppColors.grey)),
        Text(value,
            style: TextStyle(fontSize: 13, color: AppColors.grey)),
      ],
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: TextStyle(
          fontSize: 10,
          letterSpacing: 1.2,
          color: AppColors.grey,
          fontWeight: FontWeight.w600));

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.lightGrey.withOpacity(0.3),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: AppColors.goldDark, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  void _editTax() {
    final ctrl =
        TextEditingController(text: _taxPercent.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Tax %'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              hintText: 'e.g. 7', suffixText: '%'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldDark),
            onPressed: () {
              final val = double.tryParse(ctrl.text) ?? 0;
              setState(() => _taxPercent = val.clamp(0, 100));
              Navigator.pop(context);
            },
            child: const Text('Apply',
                style: TextStyle(color:AppColors.white)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  ADD / EDIT ITEM SHEET
// ══════════════════════════════════════════════════════════
class _AddItemSheet extends StatefulWidget {
  final PurchaseLineItem? existing;
  final ValueChanged<PurchaseLineItem> onAdd;

  const _AddItemSheet({this.existing, required this.onAdd});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl   = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  String _unit     = 'units';

  final List<String> _units = [
    'units', 'kg', 'g', 'L', 'ml', 'pcs', 'boxes', 'bags'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text  = widget.existing!.productName;
      _priceCtrl.text = widget.existing!.costPrice.toString();
      _qtyCtrl.text   = widget.existing!.quantity.toString();
      _unit           = widget.existing!.unit;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color:AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color:AppColors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.existing != null ? 'Edit Item' : 'Add Item',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _sheetField('Product Name', 'e.g. Fresh Milk', _nameCtrl),
              Row(
                children: [
                  Expanded(
                      child: _sheetField(
                          'Cost Price (₹)', '0.00', _priceCtrl,
                          isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _sheetField('Quantity', '0', _qtyCtrl,
                          isNumber: true)),
                ],
              ),
              const Text('UNIT',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                    color: AppColors.grey[100],
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _unit,
                    isExpanded: true,
                    items: _units
                        .map((u) => DropdownMenuItem(
                            value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _unit = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onAdd(PurchaseLineItem(
                        productName: _nameCtrl.text.trim(),
                        costPrice:
                            double.tryParse(_priceCtrl.text) ?? 0,
                        quantity:
                            int.tryParse(_qtyCtrl.text) ?? 0,
                        unit: _unit,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    widget.existing != null
                        ? 'Update Item'
                        : 'Add to Purchase',
                    style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(String label, String hint,
      TextEditingController ctrl, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.grey[100],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: AppColors.goldDark, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}