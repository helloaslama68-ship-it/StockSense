// Import Flutter material design package
import 'package:flutter/material.dart';

// Import app custom colors
import '../../core/colors.dart';

// Import sale screen for adding new sales
import 'sale_screen.dart';

/// Model class used to store sale information
class SaleRecord {
  // Unique sale ID
  final String id;

  // Customer phone number
  final String customerPhone;

  // Total sale amount
  final double totalAmount;

  // Date and time of sale
  final DateTime saleDate;

  // Total number of items sold
  final int itemCount;

  // Constructor
  SaleRecord({
    required this.id,
    required this.customerPhone,
    required this.totalAmount,
    required this.saleDate,
    required this.itemCount,
  });
}

/// Main screen that displays all sales
class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {

  // Controller for search text field
  final _searchCtrl = TextEditingController();

  // Dummy sales data
  // TODO: Replace with Provider or database data
  final List<SaleRecord> _sales = [
    SaleRecord(
      id: '1',
      customerPhone: '+91 98765-01230',
      totalAmount: 85.50,
      saleDate: DateTime(2025,10,26,13,12),
      itemCount: 2,
    ),

    SaleRecord(
      id: '2',
      customerPhone: '+91 87654-06560',
      totalAmount: 12.25,
      saleDate: DateTime(2025,10,26,11,45),
      itemCount: 1,
    ),

    SaleRecord(
      id: '3',
      customerPhone: '+91 76543-07890',
      totalAmount: 142.00,
      saleDate: DateTime(2025,10,25,14,30),
      itemCount: 3,
    ),

    SaleRecord(
      id: '4',
      customerPhone: '+91 91234-01110',
      totalAmount: 67.90,
      saleDate: DateTime(2025,10,25,12,15),
      itemCount: 1,
    ),

    SaleRecord(
      id: '5',
      customerPhone: '+91 82345-02220',
      totalAmount: 210.15,
      saleDate: DateTime(2025,10,25,13,2),
      itemCount: 4,
    ),
  ];

  /// Filter sales using search text
  List<SaleRecord> get _filtered {
    final q = _searchCtrl.text.toLowerCase();

    // Return all sales if search is empty
    if (q.isEmpty) return _sales;

    // Filter using customer phone
    return _sales
        .where((s) => s.customerPhone.toLowerCase().contains(q))
        .toList();
  }

  /// Calculate today's revenue
  double get _todayRevenue {
    final today = DateTime.now();

    return _sales
        .where(
          (s) =>
              s.saleDate.year == today.year &&
              s.saleDate.month == today.month &&
              s.saleDate.day == today.day,
        )
        .fold(0, (sum, s) => sum + s.totalAmount);
  }

  /// Convert date into readable format
  String _formatDate(DateTime d) {

    // Month names
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];

    // Convert 24 hour to 12 hour format
    final h = d.hour > 12
        ? d.hour - 12
        : (d.hour == 0 ? 12 : d.hour);

    // AM / PM
    final ampm = d.hour >= 12 ? 'PM' : 'AM';

    // Add leading zero to minute
    final min = d.minute.toString().padLeft(2, '0');

    return '${months[d.month-1]} ${d.day}, ${d.year} · $h:$min $ampm';
  }

  @override
  void dispose() {

    // Dispose search controller to avoid memory leak
    _searchCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Screen background color
      backgroundColor: AppColors.backgroundTop,

      body: SafeArea(
        child: Column(
          children: [

            // ───────────────── HEADER ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

              child: Row(
                children: [

                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),

                    child: Container(
                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),

                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),

                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.black,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Screen title
                  Text(
                    'Sales',
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

                    // ───────────────── SEARCH BAR ─────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),

                      child: TextField(
                        controller: _searchCtrl,

                        // Refresh UI when typing
                        onChanged: (_) => setState(() {}),

                        decoration: InputDecoration(
                          hintText: 'Search transactions...',

                          hintStyle: TextStyle(
                            color: AppColors.grey,
                            fontSize: 13,
                          ),

                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.grey,
                            size: 20,
                          ),

                          border: InputBorder.none,

                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ───────────────── STATS CARDS ─────────────────
                    Row(
                      children: [

                        // Today's revenue card
                        Expanded(
                          child: _statCard(
                            "TODAY'S REVENUE",
                            '₹${_todayRevenue.toStringAsFixed(2)}',
                            AppColors.goldDark.withOpacity(0.08),
                            AppColors.goldDark,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Total sales count card
                        Expanded(
                          child: _statCard(
                            'TOTAL SALES',
                            '${_sales.length}',
                            Colors.blue.withOpacity(0.08),
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ───────────────── SECTION TITLE ─────────────────
                    Text(
                      'RECENT TRANSACTIONS',

                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ───────────────── EMPTY STATE ─────────────────
                    if (_filtered.isEmpty)

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),

                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Column(
                          children: [

                            Icon(
                              Icons.receipt_outlined,
                              size: 48,
                              color: AppColors.lightGrey,
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'No sales yet',

                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Tap Add Sale to record your first sale.',

                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      )

                    // ───────────────── SALES LIST ─────────────────
                    else
                      ..._filtered.map((s) => _saleTile(s)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ───────────────── FLOATING ACTION BUTTON ─────────────────
      floatingActionButton: FloatingActionButton.extended(

        // Open sale screen
        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SaleScreen(),
            ),
          );

          // Refresh UI after returning
          setState(() {});
        },

        backgroundColor: AppColors.goldDark,

        icon: const Icon(
          Icons.add_rounded,
          color: AppColors.white,
        ),

        label: const Text(
          'Add Sale',

          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Reusable statistics card widget
  Widget _statCard(
    String label,
    String value,
    Color bg,
    Color fg,
  ) {
    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // Card title
          Text(
            label,

            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1,
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          // Card value
          Text(
            value,

            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable sale item widget
  Widget _saleTile(SaleRecord s) {

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),

        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [

          // Sale icon container
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: AppColors.darkGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.receipt_rounded,
              color: AppColors.darkGreen,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Customer info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // Customer phone number
                Text(
                  s.customerPhone,

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 3),

                // Sale date
                Text(
                  _formatDate(s.saleDate),

                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Sale amount
          Text(
            '₹${s.totalAmount.toStringAsFixed(2)}',

            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}