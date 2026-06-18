import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_badge.dart';
import '../../widgets/app_card.dart';
import 'edit_product_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const m = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  Map<String, dynamic>? _getStatus(Product p) {
    if (p.expiryDate != null) {
      final expiry = DateTime.tryParse(p.expiryDate!);
      if (expiry != null) {
        final days = expiry.difference(DateTime.now()).inDays;
        if (days < 0)  return {'label': 'EXPIRED',     'color': AppColors.red};
        if (days <= 3) return {'label': 'NEAR EXPIRY', 'color': AppColors.orange};
      }
    }
    if (p.quantity == 0)
      return {'label': 'OUT OF STOCK', 'color': AppColors.red};
    if (p.quantity <= p.lowStockThreshold)
      return {'label': 'LOW STOCK', 'color': AppColors.orange};
    return null;
  }

  double get _margin {
    final p = widget.product;
    if (p.costPrice == 0) return 0;
    return ((p.sellingPrice - p.costPrice) / p.costPrice) * 100;
  }

  void _confirmDelete(BuildContext context, Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete "${p.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(p.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.darkRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // SECTION CARD

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>().allProducts
        .firstWhere((p) => p.id == widget.product.id,
            orElse: () => widget.product);

    final hasImage = product.imagePath != null && product.imagePath!.isNotEmpty;
    final status   = _getStatus(product);
    final margin   = _margin;
    final profit   = product.sellingPrice - product.costPrice;
    final isLowStock = product.quantity <= product.lowStockThreshold;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // HERO IMAGE
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 260,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.4),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(28)),
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(28)),
                            child: Image.file(
                              File(product.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholderIcon(),
                            ),
                          )
                        : _placeholderIcon(),
                  ),

                  // Gradient overlay at bottom of hero
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(28)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.black.withOpacity(0.35),
                            AppColors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Back button
                  Positioned(
                    top: 12,
                    left: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: AppColors.black),
                      ),
                    ),
                  ),

                  // Edit button top-right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  EditProductScreen(product: product))),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.goldDark,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldDark.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 16, color: AppColors.white),
                      ),
                    ),
                  ),

                  // Status badge bottom-left of hero
                  if (status != null)
                    Positioned(
                      bottom: 14,
                      left: 14,
                      child: StatusBadge(
                        label: status['label'] as String,
                        color: status['color'] as Color,
                      ),
                    ),

                  // Category badge bottom-right of hero
                  if (product.category.isNotEmpty)
                    Positioned(
                      bottom: 14,
                      right: 14,
                      child: CategoryBadge(category: product.category),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // NAME + BRAND
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            letterSpacing: -0.3)),
                    if (product.brand != null && product.brand!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.storefront_rounded,
                              size: 13, color: AppColors.grey),
                          const SizedBox(width: 4),
                          Text(product.brand!,
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.grey)),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // PRICING CARD
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppCardTitle('PRICING', icon: Icons.currency_rupee_rounded),
                          Row(
                            children: [
                              Expanded(
                                child: _PriceCell(
                                  label: 'COST PRICE',
                                  value: '₹${product.costPrice.toStringAsFixed(2)}',
                                  valueColor: AppColors.grey,
                                ),
                              ),
                              _verticalDivider(),
                              Expanded(
                                child: _PriceCell(
                                  label: 'SELLING PRICE',
                                  value: '₹${product.sellingPrice.toStringAsFixed(2)}',
                                  valueColor: AppColors.goldDark,
                                  bold: true,
                                ),
                              ),
                              _verticalDivider(),
                              Expanded(
                                child: _PriceCell(
                                  label: 'MARGIN',
                                  value: '${margin.toStringAsFixed(1)}%',
                                  valueColor: profit >= 0
                                      ? AppColors.darkGreen
                                      : AppColors.darkRed,
                                  subLabel: profit >= 0
                                      ? '+₹${profit.toStringAsFixed(2)}'
                                      : '-₹${profit.abs().toStringAsFixed(2)}',
                                  subColor: profit >= 0
                                      ? AppColors.darkGreen
                                      : AppColors.darkRed,
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
                          AppCardTitle('STOCK', icon: Icons.inventory_2_rounded),
                          Row(
                            children: [
                              Expanded(
                                child: _StockCell(
                                  label: 'CURRENT',
                                  value: '${product.quantity}',
                                  unit: 'units',
                                  color: isLowStock
                                      ? AppColors.darkRed
                                      : AppColors.darkGreen,
                                  icon: isLowStock
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_rounded,
                                ),
                              ),
                              _verticalDivider(),
                              Expanded(
                                child: _StockCell(
                                  label: 'MIN THRESHOLD',
                                  value: '${product.lowStockThreshold}',
                                  unit: 'units',
                                  color: AppColors.grey,
                                  icon: Icons.rotate_left_rounded,
                                ),
                              ),
                              if (product.unit != null &&
                                  product.unit!.isNotEmpty) ...[
                                _verticalDivider(),
                                Expanded(
                                  child: _StockCell(
                                    label: 'PACK SIZE',
                                    value: product.unit!,
                                    color: AppColors.grey,
                                    icon: Icons.straighten_rounded,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Stock progress bar
                          const SizedBox(height: 14),
                          _StockBar(
                            current: product.quantity,
                            threshold: product.lowStockThreshold,
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
                          AppCardTitle('DETAILS', icon: Icons.info_outline_rounded),
                          if (product.barcode != null &&
                              product.barcode!.isNotEmpty)
                            _DetailRow(
                                icon: Icons.qr_code_rounded,
                                label: 'Barcode',
                                value: product.barcode!),
                          _DetailRow(
                              icon: Icons.category_rounded,
                              label: 'Category',
                              value: product.category),
                          if (product.expiryDate != null)
                            _DetailRow(
                                icon: Icons.calendar_today_rounded,
                                label: 'Expiry Date',
                                value: _formatDate(product.expiryDate!),
                                valueColor: _expiryColor(product.expiryDate!)),
                          _DetailRow(
                              icon: Icons.access_time_rounded,
                              label: 'Added On',
                              value: _formatDate(
                                  product.createdAt.toIso8601String())),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    //  EDIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldDark,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    EditProductScreen(product: product))),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Edit Product',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // DELETE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.darkRed, width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          backgroundColor:
                              AppColors.lightRed.withOpacity(0.3),
                        ),
                        onPressed: () => _confirmDelete(context, product),
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.darkRed, size: 18),
                        label: const Text('Delete Product',
                            style: TextStyle(
                                color: AppColors.darkRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderIcon() => Center(
        child: Icon(Icons.inventory_2_rounded,
            color: AppColors.grey.withOpacity(0.4), size: 80),
      );

  Widget _verticalDivider() => Container(
        width: 1,
        height: 44,
        color: AppColors.lightGrey.withOpacity(0.8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );

  Color _expiryColor(String iso) {
    try {
      final days = DateTime.parse(iso).difference(DateTime.now()).inDays;
      if (days < 0) return AppColors.darkRed;
      if (days <= 7) return AppColors.orange;
    } catch (_) {}
    return AppColors.black;
  }
}

//  PRICE CELL 

class _PriceCell extends StatelessWidget {
  final String label;
  final String value;
  final Color  valueColor;
  final bool   bold;
  final String? subLabel;
  final Color?  subColor;

  const _PriceCell({
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
    this.subLabel,
    this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: AppColors.grey,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                  color: valueColor)),
          if (subLabel != null) ...[
            const SizedBox(height: 2),
            Text(subLabel!,
                style: TextStyle(
                    fontSize: 10,
                    color: subColor ?? AppColors.grey,
                    fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

// STOCK CELL 

class _StockCell extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color  color;
  final IconData icon;

  const _StockCell({
    required this.label,
    required this.value,
    this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: AppColors.grey,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(value,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color)),
              ),
            ],
          ),
          if (unit != null)
            Text(unit!,
                style: TextStyle(fontSize: 10, color: AppColors.grey)),
        ],
      ),
    );
  }
}

//STOCK PROGRESS BAR 

class _StockBar extends StatelessWidget {
  final int current;
  final int threshold;

  const _StockBar({required this.current, required this.threshold});

  @override
  Widget build(BuildContext context) {
    // max display = 2× threshold or current, whichever bigger
    final max    = (threshold * 2).clamp(1, 9999);
    final filled = (current / max).clamp(0.0, 1.0);
    final thresh = (threshold / max).clamp(0.0, 1.0);
    final isLow  = current <= threshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STOCK LEVEL',
            style: TextStyle(
                fontSize: 9,
                color: AppColors.grey,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          return Stack(
            children: [
              // Background track
              Container(
                height: 8,
                width: w,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Fill
              Container(
                height: 8,
                width: w * filled,
                decoration: BoxDecoration(
                  color: isLow ? AppColors.darkRed : AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Threshold marker
              Positioned(
                left: w * thresh - 1,
                child: Container(
                  width: 2,
                  height: 8,
                  color: AppColors.goldDark,
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0',
                style:
                    TextStyle(fontSize: 9, color: AppColors.grey)),
            Text('Min: $threshold',
                style: TextStyle(
                    fontSize: 9,
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w600)),
            Text('$current / ${threshold * 2}+',
                style:
                    TextStyle(fontSize: 9, color: AppColors.grey)),
          ],
        ),
      ],
    );
  }
}

// DETAIL ROW 

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color?   valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.grey.withOpacity(0.7)),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.black)),
        ],
      ),
    );
  }
}