import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../models/product.dart';
import '../../models/purchase_line_item.dart';
import '../../models/purchase_record.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/purchase_form_provider.dart';
import '../../providers/purchase_filter_provider.dart';
import '../../widgets/product_image_picker.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/manage_empty_state.dart';

class PurchaseScreen extends StatelessWidget {
  final Product? preselectedProduct;
  final PurchaseRecord? existingRecord;
  const PurchaseScreen(
      {super.key, this.preselectedProduct, this.existingRecord});

  Future<void> _pickDate(BuildContext context) async {
    final form = context.read<PurchaseFormProvider>();
    final existing = form.purchaseDate;
    final picked = await appShowDatePicker(context);
    if (picked != null) {
      final base = existing ?? DateTime.now();
      form.setDate(DateTime(
        picked.year, picked.month, picked.day,
        base.hour, base.minute, base.second,
      ));
    }
  }

  void _addItem(BuildContext context) {
    context.read<PurchaseFormProvider>().initTempForNew();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PurchaseFormProvider>(),
        child: _AddItemSheet(
          onAdd: (item) => context.read<PurchaseFormProvider>().addItem(item),
        ),
      ),
    );
  }

  void _editItem(BuildContext context, int index) {
    final form = context.read<PurchaseFormProvider>();
    form.initTempForEdit(form.items[index]);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: form,
        child: _AddItemSheet(
          existing: form.items[index],
          onAdd: (item) => form.updateItem(index, item),
        ),
      ),
    );
  }

  void _savePurchase(BuildContext context) {
    final form = context.read<PurchaseFormProvider>();
    if (form.supplierName.trim().isEmpty) {
      AppSnackBar.error(context, 'Please enter supplier name');
      return;
    }
    if (form.purchaseDate == null) {
      AppSnackBar.error(context, 'Please select a purchase date');
      return;
    }
    if (form.items.isEmpty) {
      AppSnackBar.error(context, 'Add at least one item');
      return;
    }
    final record = form.toRecord();
    final provider = context.read<PurchaseProvider>();
    if (existingRecord != null) {
      provider.updatePurchase(PurchaseRecord(
        id: existingRecord!.id,
        productName: record.productName,
        supplierName: record.supplierName,
        quantityPurchased: record.quantityPurchased,
        totalAmount: record.totalAmount,
        purchaseDate: record.purchaseDate,
        imagePath: record.imagePath,
      ));
    } else {
      provider.addPurchase(record);
    }
    form.reset();
    existingRecord != null
        ? AppSnackBar.success(context, 'Purchase updated!')
        : AppSnackBar.success(context, 'Purchase recorded successfully!');
    Navigator.pop(context);
  }

  void _editTax(BuildContext context) {
    final form = context.read<PurchaseFormProvider>();
    final ctrl = TextEditingController(text: form.taxPercent.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Tax %'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 7', suffixText: '%'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldDark),
            onPressed: () {
              form.setTax(double.tryParse(ctrl.text) ?? 0);
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
    return ChangeNotifierProvider(
      create: (_) {
        final form = PurchaseFormProvider();
        if (existingRecord != null) {
          final r = existingRecord!;
          form.setSupplier(r.supplierName);
          form.setDate(r.purchaseDate);
          form.addItem(PurchaseLineItem(
            productName: r.productName,
            imagePath: r.imagePath,
            costPrice: r.totalAmount / (r.quantityPurchased == 0 ? 1 : r.quantityPurchased),
            quantity: r.quantityPurchased,
            unit: 'units',
          ));
        } else if (preselectedProduct != null) {
          final p = preselectedProduct!;
          form.addItem(PurchaseLineItem(
            productName: p.name,
            imagePath: p.imagePath,
            costPrice: p.costPrice,
            quantity: p.lowStockThreshold * 2,
            unit: p.unit ?? 'units',
          ));
        }
        return form;
      },
      child: Consumer<PurchaseFormProvider>(
        builder: (context, form, _) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppBackButton(),
                        Text(
                          existingRecord != null ? 'Edit Purchase' : 'New Purchase',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldDark),
                        ),
                        GestureDetector(
                          onTap: () => _savePurchase(context),
                          child: const Text('Save',
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
                          // ACQUISITION DETAILS
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: appCardDecoration(context: context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppSectionLabel(label: 'ACQUISITION DETAILS'),
                                const SizedBox(height: 14),
                                const AppSectionLabel(label: 'SUPPLIER NAME'),
                                const SizedBox(height: 6),
                                TextFormField(
                                  initialValue: form.supplierName,
                                  onChanged: form.setSupplier,
                                  decoration: appInputDeco('Enter supplier'),
                                ),
                                const SizedBox(height: 14),
                                const AppSectionLabel(label: 'PURCHASE DATE'),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () => _pickDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          form.purchaseDate != null
                                              ? formatDate(form.purchaseDate!)
                                              : 'Select date',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: form.purchaseDate != null
                                                ? Theme.of(context).colorScheme.onSurface
                                                : AppColors.grey,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_today_rounded,
                                            size: 18, color: AppColors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ADD ITEM BUTTON
                          if (form.items.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
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
                                    onTap: () => _addItem(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.goldDark,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        children: [
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
                                onPressed: () => _addItem(context),
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

                          // ITEMS LIST
                          if (form.items.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const AppSectionLabel(label: 'PURCHASED ITEMS'),
                                Text('${form.items.length} Items',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.goldDark,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...form.items.asMap().entries.map(
                                (e) => _itemTile(context, e.key, e.value, form)),
                          ] else
                            EmptyState(
                              icon: Icons.inventory_2_outlined,
                              title: 'No items added yet',
                              subtitle: 'Tap the button above to add\nproducts to this purchase.',
                            ),

                          const SizedBox(height: 16),

                          // TOTALS
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: appCardDecoration(context: context),
                            child: Column(
                              children: [
                                appTotalRow('Subtotal',
                                    '₹${form.subtotal.toStringAsFixed(2)}'),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('Tax',
                                            style: TextStyle(
                                                color: AppColors.grey, fontSize: 13)),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => _editTax(context),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.goldDark.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${form.taxPercent.toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.goldDark,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('₹${form.taxAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 13, color: AppColors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(color: AppColors.lightGrey),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('TOTAL AMOUNT',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.nearBlack,
                                            letterSpacing: 0.5)),
                                    Text(
                                      '₹${form.finalTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
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

                          // SAVE BUTTON
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
                              onPressed: () => _savePurchase(context),
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
        },
      ),
    );
  }

  Widget _itemTile(BuildContext context, int index,
      PurchaseLineItem item, PurchaseFormProvider form) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imagePath != null
                ? Image.file(File(item.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.grey, size: 24))
                : const Icon(Icons.shopping_bag_outlined,
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
                    style: TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${item.costPrice.toStringAsFixed(2)}/${item.unit}',
                  style: TextStyle(fontSize: 10, color: AppColors.grey)),
              Text('₹${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.goldDark)),
              const SizedBox(height: 4),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _editItem(context, index),
                    child: const Icon(Icons.edit_rounded,
                        size: 16, color: AppColors.grey),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => form.removeItem(index),
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
}

class PurchaseListSection extends StatelessWidget {
  const PurchaseListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PurchaseFilterProvider(),
      child: const _PurchaseListBody(),
    );
  }
}

class _PurchaseListBody extends StatelessWidget {
  const _PurchaseListBody();

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PurchaseFilterProvider>(),
        child: const _PurchaseFilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterProv = context.watch<PurchaseFilterProvider>();
    final purchaseProv = context.watch<PurchaseProvider>();
    final records = filterProv.apply(purchaseProv.allPurchases.toList());

    return Column(
      children: [
        // SEARCH + FILTER BAR
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.black.withOpacity(0.04),
                          blurRadius: 6)
                    ],
                  ),
                  child: TextField(
                    onChanged: context.read<PurchaseFilterProvider>().setSupplierQuery,
                    decoration: InputDecoration(
                      hintText: 'Search supplier…',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.grey),
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 18, color: AppColors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showFilterSheet(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: filterProv.isActive
                            ? AppColors.goldDark
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.black.withOpacity(0.04),
                              blurRadius: 6)
                        ],
                      ),
                      child: Icon(Icons.tune_rounded,
                          size: 20,
                          color: filterProv.isActive
                              ? AppColors.white
                              : AppColors.grey),
                    ),
                    if (filterProv.activeFilterCount > 0)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(
                              color: AppColors.darkRed,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text('${filterProv.activeFilterCount}',
                                style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ACTIVE SORT CHIP
        if (filterProv.sortBy != PurchaseSortOption.newest)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.goldDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sort_rounded,
                          size: 14, color: AppColors.goldDark),
                      const SizedBox(width: 4),
                      Text(filterProv.sortBy.label,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context
                            .read<PurchaseFilterProvider>()
                            .setSortBy(PurchaseSortOption.newest),
                        child: const Icon(Icons.close_rounded,
                            size: 14, color: AppColors.goldDark),
                      ),
                    ],
                  ),
                ),
                if (filterProv.dateRange != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.goldDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range_rounded,
                            size: 14, color: AppColors.goldDark),
                        const SizedBox(width: 4),
                        Text(
                          '${formatDate(filterProv.dateRange!.start)} – ${formatDate(filterProv.dateRange!.end)}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => context
                              .read<PurchaseFilterProvider>()
                              .setDateRange(null),
                          child: const Icon(Icons.close_rounded,
                              size: 14, color: AppColors.goldDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

        // RESULTS COUNT
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${records.length} purchases',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500)),
              if (filterProv.isActive)
                GestureDetector(
                  onTap: () => context.read<PurchaseFilterProvider>().reset(),
                  child: const Text('Clear all',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),

        // LIST
        Expanded(
          child: records.isEmpty
              ? ManageEmptyState(
                  icon: Icons.filter_list_off_rounded,
                  title: filterProv.isActive
                      ? 'No purchases match your filters'
                      : 'No purchases yet',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: records.length,
                  itemBuilder: (_, i) => _PurchaseRecordTile(record: records[i]),
                ),
        ),
      ],
    );
  }
}

class _PurchaseRecordTile extends StatelessWidget {
  final PurchaseRecord record;
  const _PurchaseRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: record.imagePath != null
                ? Image.file(File(record.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.grey, size: 22))
                : const Icon(Icons.shopping_bag_outlined,
                    color: AppColors.grey, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(record.supplierName,
                    style: TextStyle(fontSize: 11, color: AppColors.grey)),
                const SizedBox(height: 2),
                Text(formatDate(record.purchaseDate),
                    style: TextStyle(fontSize: 11, color: AppColors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${record.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.goldDark)),
              const SizedBox(height: 4),
              Text('${record.quantityPurchased} units',
                  style: TextStyle(fontSize: 11, color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PurchaseFilterSheet extends StatelessWidget {
  const _PurchaseFilterSheet();

  Future<void> _pickDateRange(BuildContext context) async {
    final prov = context.read<PurchaseFilterProvider>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: prov.dateRange,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.goldDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) prov.setDateRange(picked);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PurchaseFilterProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // DRAG HANDLE
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sort & Filter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.read<PurchaseFilterProvider>().reset(),
                  child: const Text('Reset',
                      style: TextStyle(color: AppColors.goldDark)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const AppSectionLabel(label: 'SORT BY'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PurchaseSortOption.values.map((opt) {
                final selected = prov.sortBy == opt;
                return GestureDetector(
                  onTap: () => context
                      .read<PurchaseFilterProvider>()
                      .setSortBy(opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.goldDark
                          : AppColors.lightGrey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(opt.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.white : Theme.of(context).colorScheme.onSurface)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const AppSectionLabel(label: 'DATE RANGE'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _pickDateRange(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: prov.dateRange != null
                      ? Border.all(color: AppColors.goldDark, width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range_rounded,
                        size: 18,
                        color: prov.dateRange != null
                            ? AppColors.goldDark
                            : AppColors.grey),
                    const SizedBox(width: 10),
                    Text(
                      prov.dateRange != null
                          ? '${formatDate(prov.dateRange!.start)}  →  ${formatDate(prov.dateRange!.end)}'
                          : 'Select date range',
                      style: TextStyle(
                          fontSize: 13,
                          color: prov.dateRange != null
                              ? Theme.of(context).colorScheme.onSurface
                              : AppColors.grey),
                    ),
                    const Spacer(),
                    if (prov.dateRange != null)
                      GestureDetector(
                        onTap: () => context
                            .read<PurchaseFilterProvider>()
                            .setDateRange(null),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters',
                    style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  final PurchaseLineItem? existing;
  final ValueChanged<PurchaseLineItem> onAdd;
  const _AddItemSheet({this.existing, required this.onAdd});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.productName ?? '');
    _priceCtrl = TextEditingController(
        text: widget.existing?.costPrice.toString() ?? '');
    _qtyCtrl = TextEditingController(
        text: widget.existing?.quantity.toString() ?? '');
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
    return Scaffold(
      backgroundColor: AppColors.transparent,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  widget.existing != null ? 'Edit Item' : 'Add Item',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Consumer<PurchaseFormProvider>(
                  builder: (ctx, form, _) => ProductImagePicker(
                    imagePath: form.tempImagePath,
                    onChanged: (path) => form.setTempImage(path),
                    height: 130,
                  ),
                ),
                const SizedBox(height: 16),

                _sheetField('Product Name', 'e.g. Fresh Milk', _nameCtrl),
                Row(
                  children: [
                    Expanded(
                        child: _sheetField('Cost Price (₹)', '0.00', _priceCtrl,
                            isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _sheetField('Quantity', '0', _qtyCtrl,
                            isNumber: true)),
                  ],
                ),

                const AppSectionLabel(label: 'UNIT'),
                const SizedBox(height: 6),
                Consumer<PurchaseFormProvider>(
                  builder: (ctx, form, _) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: form.tempUnit,
                        isExpanded: true,
                        items: kPurchaseUnits
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) form.setTempUnit(v);
                        },
                      ),
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
                        final form = context.read<PurchaseFormProvider>();
                        widget.onAdd(PurchaseLineItem(
                          productName: _nameCtrl.text.trim(),
                          imagePath: form.tempImagePath,
                          costPrice: double.tryParse(_priceCtrl.text) ?? 0,
                          quantity: int.tryParse(_qtyCtrl.text) ?? 0,
                          unit: form.tempUnit,
                        ));
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      widget.existing != null ? 'Update Item' : 'Add to Purchase',
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
      ),
    );
  }

  Widget _sheetField(String label, String hint, TextEditingController ctrl,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionLabel(label: label.toUpperCase()),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (isNumber) {
                final n = double.tryParse(v.trim());
                if (n == null) return 'Enter a valid number';
                if (n <= 0) return 'Must be greater than 0';
              }
              return null;
            },
            decoration: appInputDeco(hint),
          ),
        ],
      ),
    );
  }
}