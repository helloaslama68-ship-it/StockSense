import 'package:flutter/material.dart';
import '../../core/colors.dart';
import 'package:provider/provider.dart';
import '../../providers/sale_filter_provider.dart';
import '../../providers/sale_provider.dart';
import 'sales_report_screen.dart';
import 'purchase_report_screen.dart';
import 'loss_report_screen.dart';
import 'stock_report_screen.dart';
import 'credit_report_screen.dart';
import '../../providers/customer_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                'Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'ANALYTICS HUB',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Reports',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Curated insights for your inventory performance.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // FEATURED SALES REPORT CARD
              _FeaturedReportCard(
                icon: Icons.point_of_sale_rounded,
                title: 'Sales Report',
                lastUpdated: '2h ago',
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider.value(value: context.read<SaleProvider>()),
                        ChangeNotifierProvider(create: (_) => SaleFilterProvider()),
                      ],
                      child: const SalesReportScreen(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // REPORT GRID
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [

                  _GridReportCard(
                    icon: Icons.shopping_bag_rounded,
                    iconColor: AppColors.goldDark,
                    bgColor: AppColors.goldDark.withOpacity(0.08),
                    title: 'Purchase Report',
                    subtitle: 'Vendor transactions and incoming stock cycles.',
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PurchaseReportScreen(),
                      ),
                    ),
                  ),

                  _GridReportCard(
                    icon: Icons.inventory_2_rounded,
                    iconColor: AppColors.blue,
                    bgColor: AppColors.blue.withOpacity(0.08),
                    title: 'Stock Report',
                    subtitle: 'Real-time availability and warehouse mapping.',
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StockReportScreen(),
                      ),
                    ),
                  ),

                  _GridReportCard(
                    icon: Icons.credit_card_rounded,
                    iconColor: AppColors.purple,
                    bgColor: AppColors.purple.withOpacity(0.08),
                    title: 'Credit Report',
                    subtitle: 'Outstanding balances and payment aging.',
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: context.read<CustomerProvider>(),
                          child: const CreditReportScreen(),
                        ),
                      ),
                    ),
                  ),

                  _GridReportCard(
                    icon: Icons.trending_down_rounded,
                    iconColor: AppColors.darkRed,
                    bgColor: AppColors.darkRed.withOpacity(0.08),
                    title: 'Loss Report',
                    subtitle: 'Shrinkage, spoilage, and operational waste.',
                    isDark: isDark,
                    highlight: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LossReportScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String lastUpdated;
  final VoidCallback onTap;
  final bool isDark;

  const _FeaturedReportCard({
    required this.icon,
    required this.title,
    required this.lastUpdated,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(isDark ? 0.0 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.goldDark.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.goldDark, size: 26),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LAST UPDATED: $lastUpdated',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'View Details →',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GridReportCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;
  final bool isDark;

  const _GridReportCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlight
              ? iconColor.withOpacity(isDark ? 0.12 : 0.06)
              : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: highlight
              ? Border.all(color: iconColor.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(isDark ? 0.0 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}