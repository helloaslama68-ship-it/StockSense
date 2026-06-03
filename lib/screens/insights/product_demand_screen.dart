import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../models/product.dart';
import '../../providers/sale_provider.dart';
import '../purchase/purchase_screen.dart';
import 'stock_recommendation_screen.dart';

class ProductDemandScreen extends StatefulWidget {
  final Product product;
  const ProductDemandScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDemandScreen> createState() => _ProductDemandScreenState();
}

class _ProductDemandScreenState extends State<ProductDemandScreen> {
  List<double> _last7Days = [];
  double _dailyAvg = 0;
  int _daysRemaining = 0;
  double _trendPercent = 0;

  @override
  void initState() {
    super.initState();
    _calcDemand();
  }

  void _calcDemand() {
    final saleProvider = context.read<SaleProvider>();
    final allSales = saleProvider.allSales
        .where((s) => s.items.any((item) => item.productId == widget.product.id))
        .toList();

    final now = DateTime.now();
    final List<double> daily = [];

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final nextDay = day.add(const Duration(days: 1));
      final sold = allSales
          .where((s) =>
              s.saleDate.isAfter(day) && s.saleDate.isBefore(nextDay))
          .fold<int>(0, (sum, s) =>
              sum + s.items
                .where((item) => item.productId == widget.product.id)
                .fold<int>(0, (itemSum, item) => itemSum + item.quantity));
      daily.add(sold.toDouble());
    }

    _last7Days = daily;
    _dailyAvg = daily.isEmpty
        ? 0
        : daily.fold(0.0, (a, b) => a + b) / daily.length;

    _daysRemaining = _dailyAvg > 0
        ? (widget.product.quantity / _dailyAvg).floor()
        : 999;

    if (daily.length == 7) {
      final first4 = daily.sublist(0, 4).fold(0.0, (a, b) => a + b) / 4;
      final last3 = daily.sublist(4).fold(0.0, (a, b) => a + b) / 3;
      _trendPercent = first4 > 0 ? ((last3 - first4) / first4) * 100 : 0;
    }
  }

  String get _skuNumber {
    final name = widget.product.name
        .replaceAll(' ', '-')
        .toUpperCase();
    final short = name.length > 6 ? name.substring(0, 6) : name;
    return '$short-${widget.product.id.substring(0, 4).toUpperCase()}';
  }

  bool get _isHighDemand => _daysRemaining <= 7;

  Color get _alertColor {
    if (_daysRemaining <= 1) return AppColors.darkRed;
    if (_daysRemaining <= 3) return AppColors.goldDark;
    if (_daysRemaining <= 7) return AppColors.orange;
    return AppColors.darkGreen;
  }

  String get _alertMessage {
    if (_daysRemaining <= 1) return 'Critical: Running out today — restock immediately';
    if (_daysRemaining <= 3) {
      return 'High demand product — restock soon\nCurrent velocity suggests stockout in ${_daysRemaining * 24} hours';
    }
    if (_daysRemaining <= 7) return 'Moderate demand — consider restocking this week';
    return 'Sufficient stock — stable supply for $_daysRemaining days';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final hasImage = p.imagePath != null && p.imagePath!.isNotEmpty;
    final trendUp = _trendPercent >= 0;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          // top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(p.name,
                        style: TextStyle(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),

          // white card content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundTop,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // stats row
                    Row(
                      children: [
                        Expanded(
                          child: _statBox(
                            label: 'CURRENT STOCK',
                            value: '${p.quantity}',
                            unit: 'Units',
                            dark: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statBox(
                            label: 'DAILY AVG',
                            value: _dailyAvg.toStringAsFixed(1),
                            unit: 'Units',
                            dark: false,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // days remaining
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DAYS REMAINING',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 6),
                          Text(
                            _daysRemaining >= 999 ? '∞' : '$_daysRemaining',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldDark),
                          ),
                          Text('Days',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.grey)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // demand trend header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Demand Trend',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Text('Last 7 days performance',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.grey)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: trendUp
                                ? AppColors.darkGreen.withOpacity(0.1)
                                : AppColors.darkRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                trendUp
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: trendUp ? AppColors.darkGreen : AppColors.darkRed,
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${trendUp ? '+' : ''}${_trendPercent.toStringAsFixed(1)}%',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: trendUp ? AppColors.darkGreen : AppColors.darkRed,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // chart
                    Container(
                      height: 150,
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: _last7Days.every((v) => v == 0)
                                ? Center(
                                    child: Text('No sales data yet',
                                        style: TextStyle(
                                            color: AppColors.grey,
                                            fontSize: 12)))
                                : CustomPaint(
                                    size: Size.infinite,
                                    painter: _ChartPainter(
                                      data: _last7Days,
                                      lineColor: AppColors.goldDark,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                                .map((d) => Text(d,
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.grey,
                                        fontWeight: FontWeight.w600)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // alert banner — tappable if high demand
                    GestureDetector(
                      onTap: _isHighDemand
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const StockRecommendationScreen(),
                                ),
                              )
                          : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _alertColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isHighDemand
                                  ? Icons.bolt_rounded
                                  : Icons.check_circle_rounded,
                              color: AppColors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _alertMessage,
                                style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    height: 1.4),
                              ),
                            ),
                            if (_isHighDemand)
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  color: AppColors.white, size: 14),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // product details
                    const Text('Product Details',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          _detailRow('SKU Number', _skuNumber, last: false),
                          _detailRow('Supplier', 'N/A', last: false),
                          _detailRow('Category', p.category, last: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Add to Purchase button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldDark,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PurchaseScreen(
                              preselectedProduct: p,
                            ),
                          ),
                        ),
                        child: const Text('ADD TO PURCHASE',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1)),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required String label,
    required String value,
    required String unit,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? AppColors.black : AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: dark ? AppColors.white : AppColors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: dark ? AppColors.white : AppColors.black)),
          Text(unit,
              style: TextStyle(
                  fontSize: 11,
                  color: dark ? AppColors.white : AppColors.grey)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {required bool last}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                    color: AppColors.lightGrey.withOpacity(0.5), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: AppColors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Line Chart Painter

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  _ChartPainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.2), lineColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - (data[i] / maxVal) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * size.width / (data.length - 1);
        final prevY = size.height - (data[i - 1] / maxVal) * size.height;
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // dot at last point
    final lastX = size.width;
    final lastY = size.height - (data.last / maxVal) * size.height;
    canvas.drawCircle(
      Offset(lastX, lastY),
      5,
      Paint()..color = lineColor,
    );
    canvas.drawCircle(
      Offset(lastX, lastY),
      3,
      Paint()..color = AppColors.white,
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.data != data;
}