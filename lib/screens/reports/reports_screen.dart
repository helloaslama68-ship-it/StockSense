// 
// IMPORTS


// Flutter material package
import 'package:flutter/material.dart';

// App color constants
import '../../core/colors.dart';

// ─────────────────────────────────────────────────────────────
// REPORTS SCREEN
// Main analytics dashboard screen
// ─────────────────────────────────────────────────────────────
class ReportsScreen extends StatelessWidget {

  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Screen background color
      backgroundColor: AppColors.backgroundTop,

      body: SafeArea(

        child: SingleChildScrollView(

          // Screen padding
          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // 
              // APP BAR TITLE
              // ─────────────────────────────────────────
              Text(
                'Reports',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),

              const SizedBox(height: 20),

              // ─────────────────────────────────────────
              // ANALYTICS HUB LABEL
              // ─────────────────────────────────────────
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

              // Main heading
              Text(
                'Reports',

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),

              const SizedBox(height: 4),

              // Description text
              Text(
                'Curated insights for your inventory performance.',

                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // ─────────────────────────────────────────
              // FEATURED SALES REPORT CARD
              // ─────────────────────────────────────────
              _FeaturedReportCard(

                // Card icon
                icon: Icons.point_of_sale_rounded,

                // Card title
                title: 'Sales Report',

                // Last updated time
                lastUpdated: '2h ago',

                // Tap callback
                onTap: () {},
              ),

              const SizedBox(height: 16),

              // ─────────────────────────────────────────
              // REPORT GRID SECTION
              // ─────────────────────────────────────────
              GridView.count(

                // 2 columns
                crossAxisCount: 2,

                // Prevent internal scrolling
                shrinkWrap: true,

                // Disable grid scrolling
                physics:
                    const NeverScrollableScrollPhysics(),

                // Horizontal spacing
                crossAxisSpacing: 12,

                // Vertical spacing
                mainAxisSpacing: 12,

                // Card aspect ratio
                childAspectRatio: 1.15,

                children: [

                  // ───────────────────────────────────
                  // PURCHASE REPORT CARD
                  // ───────────────────────────────────
                  _GridReportCard(

                    icon:
                        Icons.shopping_bag_rounded,

                    iconColor:
                        AppColors.goldDark,

                    bgColor:
                        AppColors.goldDark
                            .withOpacity(0.08),

                    title: 'Purchase Report',

                    subtitle:
                        'Vendor transactions and incoming stock cycles.',

                    onTap: () {},
                  ),

                  // ───────────────────────────────────
                  // STOCK REPORT CARD
                  // ───────────────────────────────────
                  _GridReportCard(

                    icon:
                        Icons.inventory_2_rounded,

                    iconColor: Colors.blue,

                    bgColor:
                        Colors.blue.withOpacity(0.08),

                    title: 'Stock Report',

                    subtitle:
                        'Real-time availability and warehouse mapping.',

                    onTap: () {},
                  ),

                  // ───────────────────────────────────
                  // CREDIT REPORT CARD
                  // ───────────────────────────────────
                  _GridReportCard(

                    icon:
                        Icons.credit_card_rounded,

                    iconColor: Colors.purple,

                    bgColor:
                        Colors.purple
                            .withOpacity(0.08),

                    title: 'Credit Report',

                    subtitle:
                        'Outstanding balances and payment aging.',

                    onTap: () {},
                  ),

                  // --------------------------------------
                  // LOSS REPORT CARD
                  // -------------------------------------
                  _GridReportCard(

                    icon:
                        Icons.trending_down_rounded,

                    iconColor: AppColors.darkRed,

                    bgColor:
                        AppColors.darkRed.withOpacity(0.08),

                    title: 'Loss Report',

                    subtitle:
                        'Shrinkage, spoilage, and operational waste.',

                    onTap: () {},

                    // Highlighted card
                    highlight: true,
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

// ------------------------------------------------------------
// FEATURED REPORT CARD
// Large top card for sales analytics
// ---------------------------------------------------------------
class _FeaturedReportCard extends StatelessWidget {

  // Card icon
  final IconData icon;

  // Report title
  final String title;

  // Last updated time
  final String lastUpdated;

  // Tap callback
  final VoidCallback onTap;

  const _FeaturedReportCard({
    required this.icon,
    required this.title,
    required this.lastUpdated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      // Card tap action
      onTap: onTap,

      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          color: AppColors.white,

          borderRadius:
              BorderRadius.circular(20),

          boxShadow: [

            BoxShadow(
              color:
                  AppColors.black.withOpacity(0.05),

              blurRadius: 15,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ------------------------------------------------
            // ICON CONTAINER
            // ----------------------------------------------
            Container(

              width: 52,
              height: 52,

              decoration: BoxDecoration(

                color:
                    AppColors.goldDark
                        .withOpacity(0.12),

                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color: AppColors.goldDark,
                size: 26,
              ),
            ),

            const SizedBox(height: 16),

            // -------------------------------------------
            // REPORT TITLE
            // -------------------------------------------
            Text(
              title,

              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // ---------------------------------------------
            // FOOTER SECTION
            // ----------------------------------------------
            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                // Last updated label
                Text(
                  'LAST UPDATED: $lastUpdated',

                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey,
                    letterSpacing: 0.5,
                  ),
                ),

                // View details button
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

// --------------------------------------------
// GRID REPORT CARD
// Small analytics cards shown in grid
// -----------------------------------------
class _GridReportCard extends StatelessWidget {

  // Card icon
  final IconData icon;

  // Icon color
  final Color iconColor;

  // Background color for icon
  final Color bgColor;

  // Card title
  final String title;

  // Card subtitle
  final String subtitle;

  // Tap callback
  final VoidCallback onTap;

  // Highlight style
  final bool highlight;

  const _GridReportCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      // Card tap action
      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(

          // Highlighted background
          color: highlight
              ? iconColor.withOpacity(0.06)
              : AppColors.white,

          borderRadius:
              BorderRadius.circular(16),

          // Border for highlighted cards
          border: highlight
              ? Border.all(
                  color:
                      iconColor.withOpacity(0.3),

                  width: 1.5,
                )
              : null,

          boxShadow: [

            BoxShadow(
              color:
                  AppColors.black.withOpacity(0.04),

              blurRadius: 10,

              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ------------------------------------------
            // ICON CONTAINER
            // --------------------------------------------
            Container(

              width: 36,
              height: 36,

              decoration: BoxDecoration(
                color: bgColor,
                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),

            const SizedBox(height: 10),

            // ------------------------------------
            // TITLE
            // ------------------------------------
            Text(
              title,

              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // ---------
            // SUBTITLE
            // ----------
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