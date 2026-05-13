import 'package:flutter/material.dart';
import '../../core/colors.dart';
import 'purchase_screen.dart';

// ── DUMMY MODEL 
class PurchaseRecord {
  final String id;
  final String productName;
  final String supplierName;
  final int quantityPurchased;
  final double totalAmount;
  final DateTime purchaseDate;

  PurchaseRecord({
    required this.id,
    required this.productName,
    required this.supplierName,
    required this.quantityPurchased,
    required this.totalAmount,
    required this.purchaseDate,
  });
}

// 
//  PURCHASE LIST SCREEN
// 
class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  // TODO: replace with context.read<PurchaseProvider>().allPurchases
  final List<PurchaseRecord> _purchases = [
    PurchaseRecord(
      id: '1',
      productName: 'Fresh Produce Restock',
      supplierName: 'Green Valley Organics',
      quantityPurchased: 120,
      totalAmount: 450.00,
      purchaseDate: DateTime(2025, 10, 25, 10, 30),
    ),
    PurchaseRecord(
      id: '2',
      productName: 'Dairy Supply',
      supplierName: 'Lakeside Creamery',
      quantityPurchased: 45,
      totalAmount: 215.00,
      purchaseDate: DateTime(2025, 10, 24, 8, 15),
    ),
    PurchaseRecord(
      id: '3',
      productName: 'Dry Goods Bulk',
      supplierName: 'Global Pantry Wholesalers',
      quantityPurchased: 300,
      totalAmount: 1120.00,
      purchaseDate: DateTime(2025, 10, 22, 14, 45),
    ),
    PurchaseRecord(
      id: '4',
      productName: 'Artisan Bakery Items',
      supplierName: 'Old Mill Flour Co.',
      quantityPurchased: 60,
      totalAmount: 380.00,
      purchaseDate: DateTime(2025, 10, 21, 9, 0),
    ),
    PurchaseRecord(
      id: '5',
      productName: 'Packaging Supplies',
      supplierName: 'EcoPack Solutions',
      quantityPurchased: 500,
      totalAmount: 89.50,
      purchaseDate: DateTime(2025, 10, 15, 11, 30),
    ),
  ];

  double get _monthlyTotal =>
      _purchases.fold(0, (s, p) => s + p.totalAmount);

  String _formatDate(DateTime d) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER 
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
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
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8)
                        ],
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          color: AppColors.black, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Purchases',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── MONTHLY TOTAL CARD 
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MONTHLY PROCUREMENT',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${_monthlyTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _statChip(
                                Icons.receipt_long_rounded,
                                '${_purchases.length} Orders',
                                AppColors.goldDark.withOpacity(0.1),
                                AppColors.goldDark,
                              ),
                              const SizedBox(width: 8),
                              _statChip(
                                Icons.local_shipping_rounded,
                                '${_purchases.map((p) => p.supplierName).toSet().length} Suppliers',
                                AppColors.blue.withOpacity(0.08),
                                AppColors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── SECTION HEADER 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Purchases',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          'This Month',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── PURCHASE TILES 
                    if (_purchases.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 48, color: AppColors.lightGrey),
                            const SizedBox(height: 12),
                            Text('No purchases yet',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black)),
                            const SizedBox(height: 4),
                            Text(
                              'Tap + to record your first purchase.',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._purchases.map((p) => _purchaseTile(p)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── FAB 
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const PurchaseScreen()),
          );
          // TODO: setState(() {}) after wiring real provider
        },
        backgroundColor: AppColors.goldDark,
        elevation: 4,
        child:
            const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _purchaseTile(PurchaseRecord p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.goldDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_bag_rounded,
                color: AppColors.goldDark, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.productName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.black)),
                const SizedBox(height: 2),
                Text(p.supplierName,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: AppColors.grey),
                    const SizedBox(width: 3),
                    Text(_formatDate(p.purchaseDate),
                        style: TextStyle(
                            fontSize: 10, color: AppColors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${p.quantityPurchased} units',
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${p.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: fg,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}