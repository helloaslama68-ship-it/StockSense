import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../core/utils/responsive.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/stock_recommendation_provider.dart';
import '../../providers/loss_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../widgets/activity_row.dart';
import '../../providers/activity_log_provider.dart';
import '../../models/activity_log_entry.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/photo_option.dart';
import '../../widgets/quick_action_button.dart';
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
import '../reports/sales_report_screen.dart';
import '../sales/sales_list_screen.dart';
import '../scanner/scanner_screen.dart';
import '../loss/loss_log_screen.dart';
import 'all_activity_screen.dart';

//  NAV DESTINATIONS 

const _kDests = [
  _Dest(icon: Icons.grid_view_rounded,   label: 'Dashboard'),
  _Dest(icon: Icons.inventory_2_rounded, label: 'Inventory'),
  _Dest(icon: Icons.warning_rounded,     label: 'Alerts'),
  _Dest(icon: Icons.bar_chart_rounded,   label: 'Reports'),
];

class _Dest {
  final IconData icon;
  final String label;
  const _Dest({required this.icon, required this.label});
}

//  ROOT SHELL 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Widget> _screens = [
    _DashboardBody(),
    InventoryScreen(),
    AlertsScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final navIdx = context.watch<NavigationProvider>().currentIndex;

    if (r.isDesktop) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            _SideRail(current: navIdx),
            VerticalDivider(
              width: 1, thickness: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.dividerDark
                  : AppColors.warmWhite,
            ),
            Expanded(child: _screens[navIdx]),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _BottomNav(current: navIdx),
      body: _screens[navIdx],
    );
  }
}

// SIDE RAIL (desktop) 

class _SideRail extends StatelessWidget {
  final int current;
  const _SideRail({required this.current});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 220,
      color: isDark ? AppColors.surfaceDark : AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.vXxl,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.goldDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.white, size: 20),
                ),
                AppSpacing.hSm,
                Text('StockSense', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.white : AppColors.nearBlack,
                  letterSpacing: -0.5,
                )),
              ]),
            ),
            AppSpacing.vXxl,
            ...List.generate(_kDests.length, (i) {
              final d = _kDests[i];
              final active = current == i;
              return GestureDetector(
                onTap: () => context.read<NavigationProvider>().switchTab(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.goldDark.withOpacity(0.1) : AppColors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(d.icon, size: 20,
                      color: active ? AppColors.goldDark : (isDark ? AppColors.white38 : AppColors.charcoalGrey)),
                    AppSpacing.hMd,
                    Text(d.label, style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppColors.goldDark : (isDark ? AppColors.warmGrey : AppColors.darkGrey),
                    )),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// BOTTOM NAV 

class _BottomNav extends StatelessWidget {
  final int current;
  const _BottomNav({required this.current});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ?  AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(isDark ? 0.0 : 0.09),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_kDests.length, (i) {
          final d = _kDests[i];
          final active = current == i;
          return GestureDetector(
            onTap: () => context.read<NavigationProvider>().switchTab(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active ? AppColors.goldDark.withOpacity(0.1) : AppColors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(d.icon,
                    color: active
                        ? AppColors.goldDark
                        : (isDark ? AppColors.white38 : AppColors.mutedGrey),
                    size: 22),
                  AppSpacing.vXs,
                  Text(d.label, style: TextStyle(
                    fontSize: 10,
                    color: active
                        ? AppColors.goldDark
                        : (isDark ? AppColors.white38 : AppColors.mutedGrey),
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    letterSpacing: 0.2,
                  )),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// DASHBOARD BODY 

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                color: AppColors.warmGrey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AppSpacing.vXl,
            const Text('Change profile photo',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            AppSpacing.vXl,
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
    final r = Responsive.of(context);
    final profile = context.watch<ProfileProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: r.pagePadding.copyWith(top: 12, bottom: 24),
        child: r.constrain(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //  TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Image.asset('assets/images/logo.png', width: r.sp(36)),
                    AppSpacing.hSm,
                    Text(
                      'StockSense',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: r.sp(18),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ]),
                  Row(children: [
                    if (!r.isDesktop) ...[
                      _IconBtn(
                        color: isDark ? AppColors.dividerDark : AppColors.white,
                        shadow: !isDark,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ManageScreen())),
                        child: Icon(Icons.menu_rounded, size: 20,
                            color: isDark ? AppColors.white : AppColors.black),
                      ),
                      AppSpacing.hSm,
                    ],
                    _IconBtn(
                      color: AppColors.black,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_none_rounded, color: AppColors.white, size: 20),
                          Consumer<ProductProvider>(
                            builder: (_, p, __) {
                              final count = p.lowStockProducts.length + p.expiringProducts.length;
                              if (count == 0) return const SizedBox.shrink();
                              return Positioned(
                                right: 7, top: 7,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hSm,
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        if (context.mounted) context.read<ProfileProvider>().reload();
                      },
                      onLongPress: () => _showPhotoPicker(context),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.goldDark.withOpacity(0.4), width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundColor: AppColors.goldDark,
                          radius: r.sp(17),
                          backgroundImage: profile.hasPhoto ? FileImage(File(profile.imagePath!)) : null,
                          child: profile.hasPhoto
                              ? null
                              : const Icon(Icons.person_rounded, size: 18, color: AppColors.white),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),

              AppSpacing.vXl,

              //GREETING 
              Consumer<ProfileProvider>(
                builder: (_, p, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, ${p.ownerName} 👋',
                      style: TextStyle(
                        fontSize: r.sp(22),
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? AppColors.white : AppColors.nearBlack,
                      ),
                    ),
                    AppSpacing.vXs,
                    Text(
                      "Here's your inventory snapshot.",
                      style: TextStyle(
                          color: isDark
                              ? AppColors.white38
                              : AppColors.black.withOpacity(0.4),
                          fontSize: r.sp(13)),
                    ),
                  ],
                ),
              ),

              AppSpacing.vLg,

              //  HERO & STAT GRID
              r.isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _RevenueCard(r: r)),
                        AppSpacing.hLg,
                        Expanded(flex: 2, child: _StatGrid(r: r)),
                      ],
                    )
                  : Column(children: [
                      _RevenueCard(r: r),
                      AppSpacing.vLg,
                      _StatGrid(r: r),
                    ]),

              AppSpacing.vLg,

              //  QUICK ACTIONS 
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6, bottom: 12),
                      child: Text(
                        'QUICK ACTIONS',
                        style: TextStyle(
                          fontSize: r.sp(10),
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
                          iconColor: AppColors.white,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => AddProductScreen())),
                        ),
                        QuickActionButton(
                          iconPath: 'assets/icons/purchaseicon.png',
                          label: 'Purchase',
                          bgColor: isDark ? AppColors.dividerDark : AppColors.creamBg,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const PurchaseListScreen())),
                        ),
                        QuickActionButton(
                          iconPath: 'assets/icons/saleicon.png',
                          label: 'Sales',
                          bgColor: isDark ? AppColors.dividerDark : AppColors.creamBg,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SalesListScreen())),
                        ),
                        QuickActionButton(
                          iconPath: 'assets/icons/crediticon.png',
                          label: 'Credit',
                          bgColor: isDark ? AppColors.dividerDark : AppColors.creamBg,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const CustomersScreen())),
                        ),
                        QuickActionButton(
                          iconPath: 'assets/icons/barcodeicon .png',
                          label: 'Scan',
                          bgColor: isDark ? AppColors.dividerDark : AppColors.creamBg,
                          iconColor: isDark ? AppColors.white : AppColors.black,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ScannerScreen())),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.vLg,

              //  PENDING CREDIT 
              Consumer<CustomerProvider>(
                builder: (_, c, __) => GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CustomersScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [AppColors.warmDarkBrown, AppColors.deepBrownBlack],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [AppColors.warmOrange, AppColors.creamWhite],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.goldDark.withOpacity(0.2), width: 1),
                      boxShadow: [
                        BoxShadow(color: AppColors.goldDark.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
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
                      AppSpacing.hLg,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PENDING CREDIT', style: TextStyle(
                              fontSize: r.sp(10), color: AppColors.charcoalGrey,
                              letterSpacing: 1.0, fontWeight: FontWeight.w600,
                            )),
                            AppSpacing.vXs,
                            Text('₹${c.totalDue.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: r.sp(20), fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.white : AppColors.nearBlack,
                                letterSpacing: -0.5,
                              )),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.goldDark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('View all', style: TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.w700, fontSize: r.sp(12),
                        )),
                      ),
                    ]),
                  ),
                ),
              ),

              AppSpacing.vLg,

              // SMART PREDICTION
              Consumer<StockRecommendationProvider>(
                builder: (_, rec, __) {
                  final top = rec.visible.isNotEmpty ? rec.visible.first : null;
                  final productName = top?.product.name ?? 'No urgent items';
                  final hoursLeft = top != null
                      ? (top.daysRemaining * 24).clamp(1, 999)
                      : null;
                  final predictionText = top != null
                      ? '$productName predicted to\nrun out in $hoursLeft hours.'
                      : 'All products are sufficiently\nstocked right now.';
                  final subText = top != null
                      ? 'Based on recent sales velocity,\nconsider restocking now.'
                      : 'Check back later for restocking\nrecommendations.';
                  return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.goldDark,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: AppColors.goldDark.withOpacity(0.28), blurRadius: 14, offset: const Offset(0, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(children: [
                            Icon(Icons.bolt_rounded, color: AppColors.white, size: 12),
                            SizedBox(width: 3),
                            Text('SMART PREDICTION', style: TextStyle(
                              color: AppColors.white, fontSize: 9,
                              letterSpacing: 1.0, fontWeight: FontWeight.w700,
                            )),
                          ]),
                        ),
                        Icon(Icons.trending_up_rounded, color: AppColors.white.withOpacity(0.5), size: 20),
                      ],
                    ),
                    AppSpacing.vLg,
                    Text(
                      predictionText,
                      style: TextStyle(
                        color: AppColors.white, fontSize: r.sp(18),
                        fontWeight: FontWeight.w800, letterSpacing: -0.3, height: 1.3,
                      ),
                    ),
                    AppSpacing.vSm,
                    Text(
                      subText,
                      style: TextStyle(color: AppColors.white70, fontSize: r.sp(12), height: 1.5),
                    ),
                    AppSpacing.vLg,
                    GoldButton(
                      label: 'Create purchase order',
                      outlined: false,
                      height: 44,
                      icon: Icons.add_shopping_cart_rounded,
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SmartInsightsScreen())),
                    ),
                  ],
                ),
              );
                },
              ),

              AppSpacing.vXl,
              AppSectionLabel(
                label: 'RECENT ACTIVITY',
                actionLabel: 'View all activity',
                onAction: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AllActivityScreen())),
              ),
              AppSpacing.vMd,

              Consumer5<SaleProvider, LossProvider, PurchaseProvider, ProductProvider, ActivityLogProvider>(
                builder: (_, sales, losses, purchases, products, activityLog, __) {
                  
                  final List<_RecentItem> recent = [];
                  for (final s in sales.allSales) {
                    recent.add(_RecentItem(
                      icon: Icons.receipt_rounded,
                      iconBg: AppColors.creamBg,
                      iconColor: AppColors.blue,
                      title: 'Sales Transaction',
                      subtitle: 'Order #SL${s.receiptNumber} · ${s.items.length} ${s.items.length == 1 ? 'item' : 'items'}',
                      time: formatRelativeTime(s.saleDate),
                      timeColor: AppColors.warmGrey,
                      date: s.saleDate,
                    ));
                  }
                  for (final l in losses.allLosses) {
                    final reason = l.reason.isEmpty ? '' : l.reason[0].toUpperCase() + l.reason.substring(1);
                    recent.add(_RecentItem(
                      icon: Icons.delete_rounded,
                      iconBg: AppColors.lightRed,
                      iconColor: AppColors.darkRed,
                      title: 'Waste Logged',
                      subtitle: '${l.quantity}x ${l.productName} ($reason)',
                      time: formatRelativeTime(l.loggedAt),
                      timeColor: AppColors.darkRed,
                      badge: '-₹${l.valuationLoss.toStringAsFixed(0)}',
                      date: l.loggedAt,
                    ));
                  }
                  for (final p in purchases.allPurchases) {
                    recent.add(_RecentItem(
                      icon: Icons.shopping_cart_rounded,
                      iconBg: AppColors.paleBlue,
                      iconColor: AppColors.royalBlue,
                      title: 'Purchase Recorded',
                      subtitle: '${p.productName} · ${p.supplierName}',
                      time: formatRelativeTime(p.purchaseDate),
                      timeColor: AppColors.warmGrey,
                      date: p.purchaseDate,
                    ));
                  }
                  for (final p in products.allProducts) {
                    recent.add(_RecentItem(
                      icon: Icons.inventory_2_rounded,
                      iconBg: AppColors.lightGreen,
                      iconColor: AppColors.darkGreen,
                      title: 'Product Added',
                      subtitle: p.brand != null && p.brand!.isNotEmpty
                          ? '${p.name} · ${p.brand}'
                          : p.name,
                      time: formatRelativeTime(p.createdAt),
                      timeColor: AppColors.warmGrey,
                      date: p.createdAt,
                    ));
                  }
                  
                  for (final e in activityLog.allEntries) {
                    recent.add(_RecentItem(
                      icon: Icons.delete_forever_rounded,
                      iconBg: AppColors.lightRed,
                      iconColor: AppColors.darkRed,
                      title: e.title,
                      subtitle: e.subtitle,
                      time: formatRelativeTime(e.timestamp),
                      timeColor: AppColors.darkRed,
                      badge: e.badge,
                      date: e.timestamp,
                    ));
                  }
                  recent.sort((a, b) => b.date.compareTo(a.date));
                  final top = recent.take(3).toList();

                  if (top.isEmpty) {
                    return AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text('No activity yet',
                          style: TextStyle(color: AppColors.warmGrey, fontSize: r.sp(13))),
                      ),
                    );
                  }

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: List.generate(top.length, (i) {
                      final it = top[i];
                      return ActivityRow(
                        icon: it.icon,
                        iconBg: it.iconBg,
                        iconColor: it.iconColor,
                        title: it.title,
                        subtitle: it.subtitle,
                        time: it.time,
                        timeColor: it.timeColor,
                        badge: it.badge,
                        isLast: i == top.length - 1,
                      );
                    })),
                  );
                },
              ),

              AppSpacing.vMd,

              //  WASTED ITEMS 
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LossLogScreen())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.nearBlack,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Column(children: [
                    Text('SEE DETAILS OF', style: TextStyle(
                      color: AppColors.charcoalGrey, fontSize: r.sp(9),
                      letterSpacing: 2, fontWeight: FontWeight.w500,
                    )),
                    AppSpacing.vXs,
                    Text('WASTED ITEMS →', style: TextStyle(
                      color: AppColors.white, fontWeight: FontWeight.w800,
                      fontSize: r.sp(14), letterSpacing: 0.8,
                    )),
                  ]),
                ),
              ),

              AppSpacing.vXl,
            ],
          ),
        ),
      ),
    );
  }
}

// REVENUE CARD

class _RevenueCard extends StatelessWidget {
  final Responsive r;
  const _RevenueCard({required this.r});

  @override
  Widget build(BuildContext context) {
    return Consumer<SaleProvider>(
      builder: (_, s, __) => GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SalesReportScreen())),
        child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TODAY'S REVENUE", style: TextStyle(
                    color: AppColors.charcoalGrey, fontSize: r.sp(10),
                    letterSpacing: 1.2, fontWeight: FontWeight.w600,
                  )),
                  AppSpacing.vSm,
                  Text('₹${s.todaySalesTotal.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: AppColors.white, fontSize: r.sp(34),
                      fontWeight: FontWeight.w800, letterSpacing: -1.0,
                    )),
                  AppSpacing.vSm,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: AppColors.successGreen, size: 12),
                        AppSpacing.hXs,
                        Text(s.salesChangeLabel, style: TextStyle(
                          color: AppColors.successGreen, fontSize: r.sp(11), fontWeight: FontWeight.w600,
                        )),
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
              child: Icon(Icons.bar_chart_rounded, color: AppColors.goldLight, size: r.sp(32)),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

//STAT GRID 

class _StatGrid extends StatelessWidget {
  final Responsive r;
  const _StatGrid({required this.r});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ProductProvider>(
      builder: (_, p, __) => Column(
        children: [
          GestureDetector(
            onTap: () => context.read<NavigationProvider>().switchTab(1),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dividerDark : AppColors.creamBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.inventory_2_rounded,
                      color: isDark ? AppColors.white54 : AppColors.mutedGrey, size: 20),
                ),
                AppSpacing.hLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL PRODUCTS', style: TextStyle(
                        fontSize: r.sp(10), letterSpacing: 1.0,
                        color: AppColors.charcoalGrey, fontWeight: FontWeight.w600,
                      )),
                      AppSpacing.vXs,
                      Text(p.totalProducts.toString(), style: TextStyle(
                        fontSize: r.sp(22), fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? AppColors.white : AppColors.nearBlack,
                      )),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.goldDark.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View all', style: TextStyle(
                        fontSize: r.sp(11), color: AppColors.goldDark, fontWeight: FontWeight.w700,
                      )),
                      AppSpacing.hXs,
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.goldDark),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          AppSpacing.vSm,

          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => context.read<NavigationProvider>().switchTab(2),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ?  AppColors.backgroundDark: AppColors.lightRed,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkRed.withOpacity(0.2), width: 1),
                ),
                child: Stack(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.darkRed, borderRadius: BorderRadius.circular(6)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.warning_rounded, size: 10, color: AppColors.white),
                          SizedBox(width: 3),
                          Text('LOW STOCK', style: TextStyle(
                            fontSize: 9, color: AppColors.white,
                            fontWeight: FontWeight.w800, letterSpacing: 0.5,
                          )),
                        ]),
                      ),
                      AppSpacing.vSm,
                      Text(p.lowStockProducts.length.toString(), style: TextStyle(
                        fontSize: r.sp(32), fontWeight: FontWeight.w800,
                        color: AppColors.darkRed, letterSpacing: -1,
                      )),
                      Text('items need\nrestock now', style: TextStyle(
                        fontSize: r.sp(11), color: AppColors.redAccent, height: 1.3,
                      )),
                    ],
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Icon(Icons.inventory_2_rounded, size: 44,
                        color: AppColors.darkRed.withOpacity(0.08)),
                  ),
                ]),
              ),
            )),

            AppSpacing.hSm,

            Expanded(child: GestureDetector(
              onTap: () => context.read<NavigationProvider>().switchTab(2),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.deepBrownBlack :  AppColors.creamWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.goldDark.withOpacity(0.2), width: 1),
                ),
                child: Stack(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.goldDark, borderRadius: BorderRadius.circular(6)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.hourglass_bottom_rounded, size: 10, color: AppColors.white),
                          SizedBox(width: 3),
                          Text('EXPIRING', style: TextStyle(
                            fontSize: 9, color: AppColors.white,
                            fontWeight: FontWeight.w800, letterSpacing: 0.5,
                          )),
                        ]),
                      ),
                      AppSpacing.vSm,
                      Text(p.expiringProducts.length.toString(), style: TextStyle(
                        fontSize: r.sp(32), fontWeight: FontWeight.w800,
                        color: AppColors.goldDark, letterSpacing: -1,
                      )),
                      Builder(builder: (_) {
                        final expiring = p.expiringProducts;
                        if (expiring.isEmpty) {
                          return Text('no items\nexpiring soon', style: TextStyle(
                            fontSize: r.sp(11), color: AppColors.goldDark.withOpacity(0.7), height: 1.3,
                          ));
                        }
                        final now = DateTime.now();
                        int? minDays;
                        for (final prod in expiring) {
                          if (prod.expiryDate == null) continue;
                          final exp = DateTime.tryParse(prod.expiryDate!);
                          if (exp == null) continue;
                          final d = exp.difference(now).inDays;
                          if (minDays == null || d < minDays) minDays = d;
                        }
                        final label = minDays == null
                            ? 'expiring soon'
                            : minDays <= 0
                                ? 'already expired'
                                : minDays == 1
                                    ? 'soonest expires\nin 1 day'
                                    : 'soonest expires\nin $minDays days';
                        return Text(label, style: TextStyle(
                          fontSize: r.sp(11), color: AppColors.goldDark.withOpacity(0.7), height: 1.3,
                        ));
                      }),
                    ],
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Icon(Icons.access_time_rounded, size: 44,
                        color: AppColors.goldDark.withOpacity(0.08)),
                  ),
                ]),
              ),
            )),
          ]),
        ],
      ),
    );
  }
}

// SHARED ICON BUTTON 

class _IconBtn extends StatelessWidget {
  final Color color;
  final Widget child;
  final VoidCallback onTap;
  final bool shadow;
  const _IconBtn({required this.color, required this.child, required this.onTap, this.shadow = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: shadow
              ? [BoxShadow(color: AppColors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))]
              : null,
        ),
        child: child,
      ),
    );
  }
}

// RECENT ACTIVITY HELPERS — time formatting through formatRelativeTime in app_styles.dart

class _RecentItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final Color timeColor;
  final String? badge;
  final DateTime date;

  const _RecentItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.timeColor,
    required this.date,
    this.badge,
  });
}