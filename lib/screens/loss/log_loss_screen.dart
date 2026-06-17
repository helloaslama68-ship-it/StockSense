import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_styles.dart';
import '../../core/colors.dart';
import '../../providers/log_loss_form_provider.dart';
import '../../providers/loss_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_snack_bar.dart';

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
    final picked = await appShowDatePicker(
      context,
      lastDate: DateTime.now(),
    );
    if (picked != null && context.mounted) {
      context.read<LogLossFormProvider>().setIncidentDate(picked);
    }
  }

  void _save(BuildContext context) {
    final p   = context.read<LogLossFormProvider>();
    if (p.selectedProduct == null)  { _snack('Select a product'); return; }
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    if (qty <= 0)                   { _snack('Enter a valid quantity'); return; }
    if (p.incidentDate == null)     { _snack('Select date of incident'); return; }

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

  void _snack(String msg) => AppSnackBar.error(context, msg);

  @override
  Widget build(BuildContext context) {
    final products = context.read<ProductProvider>().allProducts;

    return Consumer<LogLossFormProvider>(
      builder: (context, p, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: const AppBackButton(),
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

                // HEADER
                const Text('INVENTORY MANAGEMENT', style: appPageCategoryStyle),
                const SizedBox(height: 4),
                const Text('Record Discrepancy', style: appPageTitleStyle),

                const SizedBox(height: 28),

                // PRODUCT NAME
                const Text('Product Name', style: appFieldLabelStyle),
                const SizedBox(height: 8),
                Container(
                  decoration: appOutlineBoxDecoration(),
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

                // QUANTITY + DATE ROW
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quantity Lost', style: appFieldLabelStyle),
                          const SizedBox(height: 8),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _qtyCtrl,
                            builder: (_, __, ___) => TextField(
                              controller: _qtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: appInputDeco('0'),
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
                          const Text('Date of Incident', style: appFieldLabelStyle),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _pickDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: appOutlineBoxDecoration(),
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

                // LOSS TYPE
                const Text('Loss Type', style: appFieldLabelStyle),
                const SizedBox(height: 10),
                Row(
                  children: _types.map((t) => AppFilterChip(
                    label: t,
                    active: p.lossType == t,
                    onTap: () => context.read<LogLossFormProvider>().setLossType(t),
                    margin: const EdgeInsets.only(right: 10),
                  )).toList(),
                ),

                const SizedBox(height: 20),

                // NOTES
                const Text('Notes', style: appFieldLabelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: appInputDeco('Describe the reason for loss...'),
                ),

                const SizedBox(height: 24),

                // FINANCIAL IMPACT
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _qtyCtrl,
                  builder: (_, __, ___) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: appOutlineBoxDecoration(radius: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('FINANCIAL IMPACT', style: appPageCategoryStyle),
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

                // SAVE BUTTON
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
}