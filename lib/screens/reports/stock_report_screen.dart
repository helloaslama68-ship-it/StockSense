import 'dart:io' as dart_io;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../models/product.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/product_badge.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  final Box<Product> _box = Hive.box<Product>('products');

  // 0 = by name, 1 = by stock asc, 2 = by stock desc, 3 = by value desc
  int _sortIndex = 0;

  static const _sortLabels = ['BY NAME', 'STOCK ↑', 'STOCK ↓', 'VALUE ↓'];

  List<Product> get _sorted {
    final all = _box.values.toList();
    switch (_sortIndex) {
      case 1:
        all.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 2:
        all.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 3:
        all.sort((a, b) =>
            (b.quantity * b.sellingPrice)
                .compareTo(a.quantity * a.sellingPrice));
        break;
      default:
        all.sort((a, b) => a.name.compareTo(b.name));
    }
    return all;
  }

  double get _totalValuation => _box.values
      .fold(0.0, (sum, p) => sum + p.quantity * p.sellingPrice);

  int get _lowStockCount => _box.values
      .where((p) => p.quantity > 0 && p.quantity <= p.lowStockThreshold)
      .length;

  int get _outOfStockCount =>
      _box.values.where((p) => p.quantity == 0).length;

  String get _topCategory {
    final Map<String, double> totals = {};
    for (final p in _box.values) {
      totals[p.category] =
          (totals[p.category] ?? 0) + p.quantity * p.sellingPrice;
    }
    if (totals.isEmpty) return '—';
    return totals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String get _growthLabel => '12%';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : AppColors.white;
    final products = _sorted;
    final alerts = _lowStockCount + _outOfStockCount;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text(
                    'Stock Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER SECTION
                    _HeaderSection(
                      totalValuation: _totalValuation,
                      alerts: alerts,
                    ),

                    const SizedBox(height: 16),

                    // INFO CARDS ROW
                    Row(
                      children: [
                        Expanded(
                          child: _AssetDistributionCard(
                            topCategory: _topCategory,
                            isDark: isDark,
                            cardColor: cardColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _ReceivableLedgerCard(
                          growthLabel: _growthLabel,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ACTIVE ASSETS SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ACTIVE ASSETS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey,
                            letterSpacing: 1.5,
                          ),
                        ),
                        // SORT BUTTON
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _sortIndex = (_sortIndex + 1) % _sortLabels.length;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.0 : 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'SORT ${_sortLabels[_sortIndex]}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (products.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No products yet.',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ),
                      )
                    else
                      ...products.map((p) => _ProductRow(
                            product: p,
                            isDark: isDark,
                            cardColor: cardColor,
                          )),
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

// HEADER SECTION
class _HeaderSection extends StatelessWidget {
  final double totalValuation;
  final int alerts;

  const _HeaderSection({
    required this.totalValuation,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MONTHLY OVERVIEW',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stock Report',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // TOTAL VALUATION
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'TOTAL VALUATION',
              style: TextStyle(
                fontSize: 8,
                color: AppColors.grey,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '₹${totalValuation.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.goldDark,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        // ALERTS
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'ALERTS',
              style: TextStyle(
                fontSize: 8,
                color: AppColors.grey,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              alerts.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkRed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ASSET DISTRIBUTION CARD
class _AssetDistributionCard extends StatelessWidget {
  final String topCategory;
  final bool isDark;
  final Color cardColor;

  const _AssetDistributionCard({
    required this.topCategory,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Distribution',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$topCategory produces your highest turnover category this quarter.',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          _MiniBarChart(),
        ],
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart();

  @override
  Widget build(BuildContext context) {
    final heights = [0.5, 0.8, 0.6, 1.0, 0.7, 0.4, 0.9];
    return SizedBox(
      height: 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: heights.map((h) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                height: 32 * h,
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// RECEIVABLE LEDGER CARD — intentionally dark card, no change needed
class _ReceivableLedgerCard extends StatelessWidget {
  final String growthLabel;

  const _ReceivableLedgerCard({required this.growthLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.goldLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: AppColors.goldLight,
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            growthLabel,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'GROWTH VS\nLAST\nMONTH',
            style: TextStyle(
              fontSize: 8,
              color: AppColors.white54,
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Receivable\nLedger',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.goldLight,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// PRODUCT ROW
class _ProductRow extends StatelessWidget {
  final Product product;
  final bool isDark;
  final Color cardColor;

  const _ProductRow({
    required this.product,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final stockValue = product.quantity * product.sellingPrice;
    final isLowStock =
        product.quantity > 0 && product.quantity <= product.lowStockThreshold;
    final isOut = product.quantity == 0;
    final iconBg = isDark ? const Color(0xFF2C2C2C) : AppColors.creamBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // PRODUCT ICON
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: product.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      dart_io.File(product.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.inventory_2_rounded,
                          size: 18,
                          color: AppColors.grey),
                    ),
                  )
                : Icon(Icons.inventory_2_rounded,
                    size: 18, color: AppColors.grey),
          ),

          const SizedBox(width: 12),

          // NAME + CATEGORY + BADGE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.grey,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // CURRENT STOCK
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'CURRENT STOCK',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.grey,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '${product.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isLowStock || isOut) ...[
                    const SizedBox(width: 4),
                    StatusBadge(
                      label: isOut ? 'OUT' : 'LOW',
                      color: isOut ? AppColors.darkRed : AppColors.orange,
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(width: 14),

          // STOCK VALUE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'STOCK VALUE',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.grey,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${stockValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}