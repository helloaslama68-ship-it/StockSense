import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../providers/log_loss_form_provider.dart';
import '../../providers/loss_provider.dart';
import '../../providers/product_provider.dart';

class LogLossScreen extends StatefulWidget {
  const LogLossScreen({super.key});

  @override
  State<LogLossScreen> createState() => _LogLossScreenState();
}

class _LogLossScreenState extends State<LogLossScreen> {
  final _qtyCtrl   = TextEditingController();
  final _notesCtrl = TextEditingController();

  static const _types = ['Damaged', 'Spoiled', 'Expired'];

  @override
  void initState() {
    super.initState();
    // Reset form state when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogLossFormProvider>().reset();
    });
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _totalLoss(LogLossFormProvider p) {
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    return (p.selectedProduct?.costPrice ?? 0) * qty;
  }

  void _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.goldDark),
        ),
        child: child!,
      ),
    );
    if (picked != null && context.mounted) {
      context.read<LogLossFormProvider>().setIncidentDate(picked);
    }
  }

  void _save(BuildContext context) {
    final p   = context.read<LogLossFormProvider>();
    if (p.selectedProduct == null) { _snack('Select a product'); return; }
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    if (qty <= 0)           { _snack('Enter a valid quantity'); return; }
    if (p.incidentDate == null) { _snack('Select date of incident'); return; }

    context.read<LossProvider>().addLoss(
      productId:     p.selectedProduct!.id,
      productName:   p.selectedProduct!.name,
      quantity:      qty,
      valuationLoss: _totalLoss(p),
      reason:        p.lossType.toLowerCase(),
      unit:          p.selectedProduct!.unit,
    );

    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.read<ProductProvider>().allProducts;

    return Consumer<LogLossFormProvider>(
      builder: (context, p, _) {
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
              'Log Loss',
              style: TextStyle(
                color: AppColors.goldDark,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── HEADER ────────────────────────────────────────
                const Text(
                  'INVENTORY MANAGEMENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF888780),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Record Discrepancy',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 28),

                // PRODUCT NAME 
                _label('Product Name'),
                const SizedBox(height: 8),
                Container(
                  decoration: _boxDecor(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: p.selectedProduct,
                      isExpanded: true,
                      hint: const Text(
                        'Select an item...',
                        style: TextStyle(color: Color(0xFF888780), fontSize: 14),
                      ),
                      items: products.map((prod) => DropdownMenuItem(
                        value: prod,
                        child: Text(prod.name),
                      )).toList(),
                      onChanged: (prod) => context.read<LogLossFormProvider>().setProduct(prod),
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.goldDark),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //  QUANTITY + DATE ROW 
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Quantity Lost'),
                          const SizedBox(height: 8),
                          // ValueListenableBuilder avoids full rebuild on qty typing
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _qtyCtrl,
                            builder: (_, __, ___) => TextField(
                              controller: _qtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: const TextStyle(
                                    color: Color(0xFFBBB9B4), fontSize: 20),
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE0DDD8), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE0DDD8), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColors.goldDark, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Date of Incident'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _pickDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFE0DDD8), width: 1),
                              ),
                              child: Text(
                                p.incidentDate == null
                                    ? 'mm/dd/yyyy'
                                    : '${p.incidentDate!.month.toString().padLeft(2, '0')}/${p.incidentDate!.day.toString().padLeft(2, '0')}/${p.incidentDate!.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: p.incidentDate == null
                                      ? const Color(0xFFBBB9B4)
                                      : const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                //  LOSS TYPE
                _label('Loss Type'),
                const SizedBox(height: 10),
                Row(
                  children: _types.map((t) {
                    final active = p.lossType == t;
                    return GestureDetector(
                      onTap: () => context.read<LogLossFormProvider>().setLossType(t),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? AppColors.goldDark : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active
                                ? AppColors.goldDark
                                : const Color(0xFFE0DDD8),
                          ),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                //  NOTES 
                _label('Notes'),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe the reason for loss...',
                    hintStyle: const TextStyle(
                        color: Color(0xFF888780), fontSize: 13),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFE0DDD8), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFE0DDD8), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.goldDark, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),

                const SizedBox(height: 24),

                // FINANCIAL IMPACT 
                // ValueListenableBuilder: reacts to qty changes without full rebuild
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _qtyCtrl,
                  builder: (_, __, ___) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFFE0DDD8), width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FINANCIAL IMPACT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF888780),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Total Loss Amount: ₹${_totalLoss(p).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.goldDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.account_balance_wallet_outlined,
                            color: Color(0xFFE0DDD8), size: 36),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                //  SAVE BUTTON 
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => _save(context),
                    icon: const Icon(Icons.save_rounded,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Save Loss Record',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      );

  BoxDecoration _boxDecor() => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0DDD8), width: 1),
      );
}