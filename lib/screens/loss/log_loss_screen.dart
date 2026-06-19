import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_styles.dart';
import '../../core/colors.dart';
import '../../models/inventory_loss.dart';
import '../../providers/log_loss_form_provider.dart';
import '../../providers/loss_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_snack_bar.dart';

class LogLossScreen extends StatefulWidget {
  
  final InventoryLoss? editLoss;
  const LogLossScreen({super.key, this.editLoss});

  bool get isEdit => editLoss != null;

  @override
  State<LogLossScreen> createState() => _LogLossScreenState();
}

class _LogLossScreenState extends State<LogLossScreen> {
  final _qtyCtrl   = TextEditingController();
  final _notesCtrl = TextEditingController();

  static const _types = ['Damaged', 'Spoiled', 'Expired', 'Other'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<LogLossFormProvider>();
      if (widget.isEdit) {
        // PRE-FILL for edit
        final loss = widget.editLoss!;
        final products = context.read<ProductProvider>().allProducts;
        final prod = products.cast<dynamic>().firstWhere(
          (p) => p.id == loss.productId,
          orElse: () => null,
        );
        p.reset();
        if (prod != null) p.setProduct(prod);
        // Capitalise first letter to match _types list
        final t = loss.reason.isEmpty ? 'Spoiled'
            : loss.reason[0].toUpperCase() + loss.reason.substring(1);
        p.setLossType(t);
        p.setIncidentDate(loss.loggedAt);
        _qtyCtrl.text = loss.qty == loss.qty.truncateToDouble()
            ? loss.qty.toInt().toString()
            : loss.qty.toStringAsFixed(2);
      } else {
        p.reset();
      }
    });
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _totalLoss(LogLossFormProvider p) {
    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
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
    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    if (qty <= 0)                   { _snack('Enter a valid quantity'); return; }
    if (p.incidentDate == null)     { _snack('Select date of incident'); return; }

    final lossProvider = context.read<LossProvider>();

    if (widget.isEdit) {
      
      final loss = widget.editLoss!
        ..productId       = p.selectedProduct!.id
        ..productName     = p.selectedProduct!.name
        ..quantity        = qty.truncate()
        ..quantityDecimal = qty
        ..valuationLoss   = _totalLoss(p)
        ..reason          = p.lossType.toLowerCase()
        ..unit            = p.selectedProduct!.unit
        ..loggedAt        = p.incidentDate!;
      lossProvider.updateLoss(loss);
    } else {
      lossProvider.addLoss(
        productId:       p.selectedProduct!.id,
        productName:     p.selectedProduct!.name,
        quantityDecimal: qty,
        valuationLoss:   _totalLoss(p),
        reason:          p.lossType.toLowerCase(),
        unit:            p.selectedProduct!.unit,
      );
    }

    Navigator.pop(context);
  }

  void _snack(String msg) => AppSnackBar.error(context, msg);

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final products = context.read<ProductProvider>().allProducts;

    return Consumer<LogLossFormProvider>(
      builder: (context, p, _) {
        // Product image
        final imgPath = p.selectedProduct?.imagePath;
        final hasImg  = imgPath != null && imgPath.isNotEmpty;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: const AppBackButton(),
            title: Text(
              widget.isEdit ? 'Edit Loss Entry' : 'Log Loss',
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
                Text(
                  widget.isEdit ? 'Edit Discrepancy' : 'Record Discrepancy',
                  style: appPageTitleStyle,
                ),

                const SizedBox(height: 28),

                // PRODUCT IMAGE PREVIEW 
                if (hasImg) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(imgPath),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // PRODUCT NAME
                Text('Product Name', style: appFieldLabelStyle),
                const SizedBox(height: 8),
                Container(
                  decoration: appOutlineBoxDecoration(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: p.selectedProduct,
                      isExpanded: true,
                      dropdownColor: isDark ? AppColors.surfaceDark : AppColors.white,
                      hint: Text(
                        'Select an item...',
                        style: TextStyle(
                          color: isDark ? AppColors.warmGrey : const Color(0xFF888780),
                          fontSize: 14,
                        ),
                      ),
                      items: products.map((prod) => DropdownMenuItem(
                        value: prod,
                        child: Text(
                          prod.name,
                          style: TextStyle(color: onSurface),
                        ),
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
                          Text(
                            p.selectedProduct?.unit != null
                                ? 'Qty Lost (${p.selectedProduct!.unit})'
                                : 'Quantity Lost',
                            style: appFieldLabelStyle,
                          ),
                          const SizedBox(height: 8),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _qtyCtrl,
                            builder: (_, __, ___) => TextField(
                              controller: _qtyCtrl,
                              // Allow decimal for weighted products
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: onSurface),
                              decoration: appInputDeco(
                                p.selectedProduct?.unit != null ? '0.25' : '0',
                              ),
                            ),
                          ),
                          if (p.selectedProduct?.unit != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Tip: enter partial amounts e.g. 0.5 for half ${p.selectedProduct!.unit}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date of Incident', style: appFieldLabelStyle),
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
                                      ? AppColors.warmGrey
                                      : onSurface,
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
                Text('Loss Type', style: appFieldLabelStyle),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _types.map((t) => AppFilterChip(
                    label: t,
                    active: p.lossType == t,
                    onTap: () => context.read<LogLossFormProvider>().setLossType(t),
                  )).toList(),
                ),

                const SizedBox(height: 20),

                // NOTES
                Text('Notes', style: appFieldLabelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  style: TextStyle(color: onSurface),
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.goldDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.account_balance_wallet_outlined,
                            color: isDark ? AppColors.warmGrey : AppColors.warmSurface,
                            size: 36),
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
                    icon: Icon(
                      widget.isEdit ? Icons.check_rounded : Icons.save_rounded,
                      color: AppColors.white,
                      size: 18,
                    ),
                    label: Text(
                      widget.isEdit ? 'Save Changes' : 'Save Loss Record',
                      style: const TextStyle(
                        color: AppColors.white,
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