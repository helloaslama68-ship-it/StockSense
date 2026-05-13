import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import 'product_demand_screen.dart';

enum PredictionStatus { critical, warning, stable }

class ProductPrediction {
  final Product product;
  final PredictionStatus status;
  final String message;
  final int daysSupply;

  ProductPrediction({
    required this.product,
    required this.status,
    required this.message,
    required this.daysSupply,
  });
}

class SmartInsightsScreen extends StatefulWidget {
  const SmartInsightsScreen({Key? key}) : super(key: key);

  @override
  State<SmartInsightsScreen> createState() => _SmartInsightsScreenState();
}

class _SmartInsightsScreenState extends State<SmartInsightsScreen> {
  late List<ProductPrediction> _predictions;

  @override
  void initState() {
    super.initState();
    _buildPredictions();
  }

  void _buildPredictions() {
    final provider = context.read<ProductProvider>();
    final saleProvider = context.read<SaleProvider>();
    final products = provider.allProducts;
    final allSales = saleProvider.allSales;
    final List<ProductPrediction> preds = [];

    for (final p in products) {
      final productSales = allSales.where((s) => s.productId == p.id).toList();
      double avgDailySales = 0;

      if (productSales.isNotEmpty) {
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        final recent = productSales.where((s) => s.saleDate.isAfter(cutoff)).toList();
        if (recent.isNotEmpty) {
          final totalSold = recent.fold<int>(0, (sum, s) => sum + s.quantitySold);
          avgDailySales = totalSold / 30;
        }
      }

      PredictionStatus status;
      String message;
      int daysSupply;

      if (avgDailySales > 0) {
        daysSupply = (p.quantity / avgDailySales).floor();
        if (daysSupply <= 1) {
          status = PredictionStatus.critical;
          message = 'Critical: Running Out Today';
        } else if (daysSupply <= 3) {
          status = PredictionStatus.warning;
          message = 'Will run out in $daysSupply days';
        } else {
          status = PredictionStatus.stable;
          message = 'Stable supply for $daysSupply+ days';
        }
      } else {
        daysSupply = -1;
        if (p.quantity <= p.lowStockThreshold) {
          status = PredictionStatus.critical;
          message = 'Critical: Below threshold';
        } else if (p.quantity <= p.lowStockThreshold * 2) {
          status = PredictionStatus.warning;
          message = 'Stock getting low';
        } else {
          status = PredictionStatus.stable;
          message = 'Stable stock level';
        }
      }

      preds.add(ProductPrediction(
        product: p,
        status: status,
        message: message,
        daysSupply: daysSupply,
      ));
    }

    preds.sort((a, b) => a.status.index.compareTo(b.status.index));
    _predictions = preds;
  }

  int get _fastMoving => _predictions
      .where((p) => p.daysSupply >= 0 && p.daysSupply <= 7)
      .length;

  int get _runningOut => _predictions
      .where((p) => p.status == PredictionStatus.critical)
      .length;

  int get _slowMoving => _predictions
      .where((p) => p.status == PredictionStatus.stable && p.daysSupply > 14)
      .length;

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
            Text('SMART INSIGHTS',
                style: TextStyle(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1.2)),
          ],
        ),
      ),
      body: _predictions.isEmpty
          ? _emptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FAST MOVING',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.grey,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('$_fastMoving Items',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.goldDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('🔥', style: TextStyle(fontSize: 22)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          label: 'CRITICAL',
                          value: '$_runningOut',
                          sub: '$_runningOut item${_runningOut == 1 ? '' : 's'} below threshold',
                          color: Colors.red,
                          bg: const Color(0xFFFFF0F0),
                          icon: Icons.warning_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(
                          label: 'OPTIMIZATION',
                          value: 'Slow Moving',
                          sub: '$_slowMoving item${_slowMoving == 1 ? '' : 's'} stagnant',
                          color: AppColors.grey,
                          bg: AppColors.white,
                          icon: Icons.trending_down_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Predictions',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${_predictions.length} ITEMS',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ..._predictions.map((pred) => _predictionCard(pred)),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _predictionCard(ProductPrediction pred) {
    final config = _statusConfig(pred.status);
    final p = pred.product;
    final hasImage = p.imagePath != null && p.imagePath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(p.imagePath!), fit: BoxFit.cover),
                        )
                      : Icon(Icons.inventory_2_rounded,
                          color: AppColors.goldDark, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(p.category,
                          style: TextStyle(fontSize: 11, color: AppColors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${p.quantity}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('UNITS',
                        style: TextStyle(
                            fontSize: 9,
                            color: AppColors.grey,
                            letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: (config['color'] as Color).withOpacity(0.08),
            ),
            child: Row(
              children: [
                Icon(config['icon'] as IconData,
                    color: config['color'] as Color, size: 13),
                const SizedBox(width: 6),
                Text(pred.message,
                    style: TextStyle(
                        fontSize: 11,
                        color: config['color'] as Color,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          if (pred.status != PredictionStatus.stable)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDemandScreen(product: pred.product),
                    ),
                  ).then((_) => setState(() => _buildPredictions())),
                  child: const Text('View',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.lightGrey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDemandScreen(product: pred.product),
                    ),
                  ).then((_) => setState(() => _buildPredictions())),
                  child: Text('Sufficient Stock',
                      style: TextStyle(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 13)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String sub,
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      color: color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 10, color: AppColors.grey)),
        ],
      ),
    );
  }

  Map<String, dynamic> _statusConfig(PredictionStatus status) {
    switch (status) {
      case PredictionStatus.critical:
        return {'icon': Icons.warning_rounded, 'color': Colors.red};
      case PredictionStatus.warning:
        return {'icon': Icons.access_time_rounded, 'color': AppColors.goldDark};
      case PredictionStatus.stable:
        return {'icon': Icons.check_circle_rounded, 'color': Colors.green};
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bolt_rounded, size: 48, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          const Text('No products yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Add products to see smart predictions',
              style: TextStyle(fontSize: 13, color: AppColors.grey)),
        ],
      ),
    );
  }
}