import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/activity_row.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_decorations.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/photo_option.dart';
import '../../widgets/quick_action_button.dart';
import '../../widgets/stat_box.dart';
import '../alerts/alerts_screen.dart';
import '../credit/customers_screen.dart';
import '../insights/smart_insights_screen.dart';
import '../inventory/add_product_screen.dart';
import '../inventory/inventory_screen.dart';
import '../manage/manage_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../purchase/purchase_list_screen.dart';
import '../reports/reports_screen.dart';
import '../sales/sales_list_screen.dart';
import '../scanner/scanner_screen.dart';
import '../loss/loss_log_screen.dart';

//  ROOT SHELL 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> _screens = [
    _DashboardBody(),
    InventoryScreen(),
    AlertsScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = context.watch<NavigationProvider>().currentIndex;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F2),
      bottomNavigationBar: const BottomNavBar(),
      body: _screens[idx],
    );
  }
}

//  DASHBOARD BODY 

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  void _showPhotoPicker(BuildContext context) {
    final profile = context.read<ProfileProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0DDD8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Change profile photo',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PhotoOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: AppColors.goldDark,
                  onTap: () {
                    Navigator.pop(context);
                    profile.pickImage(fromCamera: true, context: context);
                  },
                ),
                PhotoOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: AppColors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    profile.pickImage(fromCamera: false, context: context);
                  },
                ),
                if (profile.hasPhoto)
                  PhotoOption(
                    icon: Icons.delete_rounded,
                    label: 'Remove',
                    color: AppColors.darkRed,
                    onTap: () {
                      Navigator.pop(context);
                      profile.removeImage();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TOP BAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo + App name
                Row(children: [
                  Image.asset('assets/images/logo.png', width: 36),
                  const SizedBox(width: 8),
                  const Text(
                    'StockSense',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                ]),
                // Actions
                Row(children: [
                  // Menu
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ManageScreen())),
                    child: Container(
                      width: 38, height: 38,
                      decoration: appCard(radius: 12),
                      child: const Icon(Icons.menu_rounded,
                          size: 20, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Notifications
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen())),
                    child: Container(
                      width: 38, height: 38,
                      decoration: appDarkCard(radius: 12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_none_rounded,
                              color: Colors.white, size: 20),
                          Consumer<ProductProvider>(
                            builder: (_, p, __) {
                              final count = p.lowStockProducts.length +
                                  p.expiringProducts.length;
                              if (count == 0) return const SizedBox.shrink();
                              return Positioned(
                                right: 7, top: 7,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE04545),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Avatar
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()));
                      if (context.mounted) {
                        context.read<ProfileProvider>().reload();
                      }
                    },
                    onLongPress: () => _showPhotoPicker(context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.goldDark.withOpacity(0.4),
                            width: 2),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors.goldDark,
                        radius: 17,
                        backgroundImage: profile.hasPhoto
                            ? FileImage(File(profile.imagePath!))
                            : null,
                        child: profile.hasPhoto
                            ? null
                            : const Icon(Icons.person_rounded,
                                size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ]),
              ],
            ),

            const SizedBox(height: 20),

            // GREETING 
            Consumer<ProfileProvider>(
              builder: (_, p, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}, ${p.ownerName} 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Here's your inventory snapshot.",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.4), fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // TODAY'S REVENUE HERO CARD 
            Consumer<SaleProvider>(
              builder: (_, s, __) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: appDarkCard(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TODAY'S REVENUE",
                            style: TextStyle(
                              color: Color(0xFF888580),
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${s.todaySalesTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6FCF97).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_upward_rounded,
                                    color: Color(0xFF6FCF97), size: 12),
                                const SizedBox(width: 3),
                                Text(
                                  s.salesChangeLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF6FCF97),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.goldDark.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.bar_chart_rounded,
                          color: AppColors.goldLight, size: 32),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // QUICK ACTIONS 
            AppCard(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 12),
                    child: Text(
                      'QUICK ACTIONS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warmGrey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      QuickActionButton(
                        iconPath: 'assets/icons/addicon.png',
                        label: 'Add item',
                        bgColor: AppColors.goldDark,
                        iconColor: Colors.white,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => AddProductScreen())),
                      ),
                      QuickActionButton(
                        iconPath: 'assets/icons/purchaseicon.png',
                        label: 'Purchase',
                        bgColor: const Color(0xFFF1EFE8),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const PurchaseListScreen())),
                      ),
                      QuickActionButton(
                        iconPath: 'assets/icons/saleicon.png',
                        label: 'Sales',
                        bgColor: const Color(0xFFF1EFE8),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const SalesListScreen())),
                      ),
                      QuickActionButton(
                        iconPath: 'assets/icons/crediticon.png',
                        label: 'Credit',
                        bgColor: const Color(0xFFF1EFE8),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const CustomersScreen())),
                      ),
                      QuickActionButton(
                        iconPath: 'assets/icons/barcodeicon .png',
                        label: 'Scan',
                        bgColor: const Color(0xFFF1EFE8),
                        iconColor: Colors.black,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const ScannerScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // STAT GRID
            Consumer<ProductProvider>(
              builder: (_, p, __) => Column(
                children: [
                  // Top row: total products full-width
                  GestureDetector(
                    onTap: () =>
                        context.read<NavigationProvider>().switchTab(1),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EFE8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.inventory_2_rounded,
                              color: Color(0xFF5F5E5A), size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL PRODUCTS',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                  color: Color(0xFF888780),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.totalProducts.toString(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.goldDark.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('View all',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.w700,
                                  )),
                              const SizedBox(width: 3),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 10, color: AppColors.goldDark),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Bottom row: low stock + expiry
                  Row(children: [
                    // LOW STOCK
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            context.read<NavigationProvider>().switchTab(2),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCEBEB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFA32D2D).withOpacity(0.2),
                                width: 1),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Alert badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA32D2D),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.warning_rounded,
                                            size: 10, color: Colors.white),
                                        SizedBox(width: 3),
                                        Text('LOW STOCK',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    p.lowStockProducts.length.toString(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFA32D2D),
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const Text(
                                    'items need\nrestock now',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFD85A30),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Icon(Icons.inventory_2_rounded,
                                    size: 44,
                                    color: const Color(0xFFA32D2D)
                                        .withOpacity(0.08)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // EXPIRING 
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            context.read<NavigationProvider>().switchTab(2),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8EC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.goldDark.withOpacity(0.2),
                                width: 1),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Expiry badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldDark,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.hourglass_bottom_rounded,
                                            size: 10, color: Colors.white),
                                        SizedBox(width: 3),
                                        Text('EXPIRING',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    p.expiringProducts.length.toString(),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.goldDark,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  Text(
                                    'items expire\nnext 90 days',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.goldDark.withOpacity(0.7),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Icon(Icons.access_time_rounded,
                                    size: 44,
                                    color: AppColors.goldDark.withOpacity(0.08)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 16),

            //  PENDING CREDIT 
            Consumer<SaleProvider>(
              builder: (_, s, __) => GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const CustomersScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFAEEDA),
                        const Color(0xFFFDF6EC),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18), 
                    border: Border.all(
                        color: AppColors.goldDark.withOpacity(0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldDark.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.goldDark.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: Color(0xFF854F0B), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PENDING CREDIT',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF888780),
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${s.pendingCreditTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.goldDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // SMART DEMAND PREDICTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: appColorCard(color: AppColors.goldDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(children: [
                          Icon(Icons.bolt_rounded,
                              color: Colors.white, size: 12),
                          SizedBox(width: 3),
                          Text(
                            'SMART PREDICTION',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ]),
                      ),
                      Icon(Icons.trending_up_rounded,
                          color: Colors.white.withOpacity(0.5), size: 20),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Artisan Bread predicted to\nrun out in 6 hours.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Based on your Friday evening sales velocity,\nconsider restocking now.',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  GoldButton(
                    label: 'Create purchase order',
                    outlined: false,
                    height: 44,
                    icon: Icons.add_shopping_cart_rounded,
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const SmartInsightsScreen())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            //  RECENT ACTIVITY 
            AppSectionLabel(
              label: 'RECENT ACTIVITY',
              actionLabel: 'See history',
              onAction: () {},
            ),
            const SizedBox(height: 12),

            // Activity inside AppCard using ActivityRow
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ActivityRow(
                    icon: Icons.add_circle_rounded,
                    iconBg: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF3B6D11),
                    title: 'Stock Added',
                    subtitle: '+50 Whole Milk',
                    time: '10:45 AM',
                    timeColor: const Color(0xFF3B6D11),
                    isLast: false,
                  ),
                  ActivityRow(
                    icon: Icons.receipt_rounded,
                    iconBg: const Color(0xFFE6F1FB),
                    iconColor: const Color(0xFF185FA5),
                    title: 'Sales Transaction',
                    subtitle: 'Order #SL0923 · 4 items',
                    time: '09:12 AM',
                    timeColor: AppColors.warmGrey,
                    isLast: false,
                  ),
                  ActivityRow(
                    icon: Icons.delete_rounded,
                    iconBg: AppColors.lightRed,
                    iconColor: AppColors.darkRed,
                    title: 'Waste Logged',
                    subtitle: '10x Green Yogurt (Expired)',
                    time: 'Yesterday',
                    timeColor: AppColors.darkRed,
                    badge: '-₹165',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // WASTED ITEMS 
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LossLogScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: appDarkCard(radius: 14),
                child: const Column(children: [
                  Text(
                    'SEE DETAILS OF',
                    style: TextStyle(
                      color: Color(0xFF888580),
                      fontSize: 9,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'WASTED ITEMS →',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}