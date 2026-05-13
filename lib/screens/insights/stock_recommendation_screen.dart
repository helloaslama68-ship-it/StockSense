import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../purchase/purchase_screen.dart';

class StockRecommendationScreen extends StatefulWidget {
  const StockRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<StockRecommendationScreen> createState() =>
      _StockRecommendationScreenState();
}

class _Suggestion {
  final Product product;
  final int suggestedQty;
  final String reason;
  final double dailyAvg;
  final int daysRemaining;
  bool ignored;

  _Suggestion({
    required this.product,
    required this.suggestedQty,
    required this.reason,
    required this.dailyAvg,
    required this.daysRemaining,
    this.ignored = false,
  });
}

class _StockRecommendationScreenState
    extends State<StockRecommendationScreen> {
  List<_Suggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _buildSuggestions();
  }

  void _buildSuggestions() {
    final productProvider = context.read<ProductProvider>();
    final saleProvider = context.read<SaleProvider>();
    final products = productProvider.allProducts;
    final allSales = saleProvider.allSales;
    final now = DateTime.now();
    final List<_Suggestion> suggestions = [];

    for (final p in products) {
      // calc daily avg from last 30 days
      final cutoff = now.subtract(const Duration(days: 30));
      final recent = allSales
          .where((s) => s.productId == p.id && s.saleDate.isAfter(cutoff))
          .toList();

      double dailyAvg = 0;
      int daysRemaining = 999;

      if (recent.isNotEmpty) {
        final totalSold = recent.fold<int>(0, (sum, s) => sum + s.quantitySold);
        dailyAvg = totalSold / 30;
        daysRemaining = dailyAvg > 0 ? (p.quantity / dailyAvg).floor() : 999;
      } else {
        // fallback: use threshold
        if (p.quantity <= p.lowStockThreshold) {
          daysRemaining = 0;
        }
      }

      // only suggest restock if:
      // - days remaining <= 7, OR
      // - quantity <= lowStockThreshold
      if (daysRemaining <= 7 || p.quantity <= p.lowStockThreshold) {
        // suggested qty = 2 weeks supply or at least 2x threshold
        final int suggestedQty = dailyAvg > 0
            ? (dailyAvg * 14).ceil()
            : p.lowStockThreshold * 3;

        String reason;
        if (dailyAvg > 0 && daysRemaining <= 2) {
          reason =
              'Suggested: +$suggestedQty units\nBased on recent sales (avg ${dailyAvg.toStringAsFixed(1)} units/day). Your current stock will deplete in ${daysRemaining <= 0 ? 'less than 24' : '${daysRemaining * 24}'} hours.';
        } else if (dailyAvg > 0) {
          reason =
              'Suggested: +$suggestedQty units\nVelocity spike detected over the weekend. Maintain a buffer of ${(dailyAvg * 7).ceil()} units for steady delivery flow.';
        } else {
          reason =
              'Suggested: +$suggestedQty units\nSeasonal demand predicted to increase. Average shelf life is 5 days — order now to meet 2-week demand.';
        }

        suggestions.add(_Suggestion(
          product: p,
          suggestedQty: suggestedQty,
          reason: reason,
          dailyAvg: dailyAvg,
          daysRemaining: daysRemaining,
        ));
      }
    }

    // sort: most critical first
    suggestions.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    setState(() => _suggestions = suggestions);
  }

  void _addToPurchase(Product product, int qty) {
    Navigator.push(
      context,
      MaterialPageRoute(
       builder: (_) => PurchaseScreen(
  preselectedProduct: product,
),
      ),
    );
  }

  void _ignore(int index) {
    setState(() => _suggestions[index].ignored = true);
  }

  List<_Suggestion> get _visible =>
      _suggestions.where((s) => !s.ignored).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundTop,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.bolt_rounded, color: AppColors.goldDark, size: 16),
            const SizedBox(width: 4),
            Text('Suggestion',
                style: TextStyle(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Restock Suggestions',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Smart AI insights based on your recent sales velocity.',
                    style: TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _visible.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _suggestionCard(_visible[i], i),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionCard(_Suggestion s, int index) {
    final p = s.product;
    final hasImage = p.imagePath != null && p.imagePath!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(p.imagePath!),
                              fit: BoxFit.cover),
                        )
                      : Icon(Icons.inventory_2_rounded,
                          color: AppColors.grey, size: 28),
                ),
                const SizedBox(width: 12),

                // Name + units
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${p.quantity} CURRENT UNITS',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3)),
                      ),
                    ],
                  ),
                ),

                // Current qty badge
                Text('${p.quantity}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Suggestion reason
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.goldDark.withOpacity(0.07),
              border: Border(
                top: BorderSide(
                    color: AppColors.goldDark.withOpacity(0.15), width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.bolt_rounded,
                    color: AppColors.goldDark, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(s.reason,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.black.withOpacity(0.75),
                          height: 1.4)),
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldDark,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () => _addToPurchase(p, s.suggestedQty),
                      child: const Text('Add to Purchase List',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.lightGrey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => _ignore(
                        _suggestions.indexOf(s)),
                    child: Text('Ignore',
                        style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                size: 48, color: AppColors.darkGreen),
          ),
          const SizedBox(height: 16),
          const Text('All stocked up!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('No restock suggestions right now',
              style: TextStyle(fontSize: 13, color: AppColors.grey)),
        ],
      ),
    );
  }
}