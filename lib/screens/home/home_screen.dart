import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../inventory/inventory_screen.dart';
import '../inventory/add_product_screen.dart';
import '../alerts/alerts_screen.dart';
import '../../services/storage_service.dart';
import '../profile/profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../reports/reports_screen.dart';
import '../purchase/purchase_list_screen.dart';
import '../sales/sales_list_screen.dart';
import '../credit/customers_screen.dart';
import '../scanner/scanner_screen.dart';
import '../notifications/notifications_screen.dart';
import '../insights/smart_insights_screen.dart';

// ----------------------------------------------------------
//  HOME SCREEN
//  Root shell. Owns the bottom nav and swaps between
//  Dashboard, Inventory, Alerts, and Reports tabs.
// --------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0; // Active bottom-nav tab index

  /// Called by child widgets (e.g. dashboard cards) to switch tabs programmatically.
  void switchTab(int index) {
    setState(() => currentIndex = index);
  }

  /// Tab screens; lazily constructed once via `late final`.
  late final List<Widget> _screens = [
    _DashboardBody(),
    const InventoryScreen(),
    const AlertsScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      bottomNavigationBar: _bottomNav(),
      body: _screens[currentIndex],
    );
  }

  /// Floating pill-shaped bottom navigation bar.
  Widget _bottomNav() {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.black, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.dashboard, "Dashboard", 0),
          _navItem(Icons.inventory_2, "Inventory", 1),
          _navItem(Icons.warning, "Alerts", 2),
          _navItem(Icons.bar_chart, "Reports", 3),
        ],
      ),
    );
  }

  /// Single nav tab: icon + label, gold when active, grey otherwise.
  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.goldDark : AppColors.grey),
          SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.goldDark : AppColors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------
//  DASHBOARD BODY
//  Main scrollable dashboard shown on the Home tab.
//  Handles profile image, greeting, quick actions, and KPI cards.
// ------------------------------------------------------------
class _DashboardBody extends StatefulWidget {
  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  final _storage = StorageService();
  String? _imagePath; // Local file path for the owner's profile photo

  @override
  void initState() {
    super.initState();
    _imagePath = _storage.getProfileImage(); // Load saved photo on first build
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh providers after frame completes to avoid setState-during-build errors.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().refresh();
      context.read<SaleProvider>().refresh();
    });
    // Sync profile image in case it changed in another screen.
    final fresh = _storage.getProfileImage();
    if (fresh != _imagePath) {
      setState(() => _imagePath = fresh);
    }
  }

  /// Traverses the widget tree to call [_HomeScreenState.switchTab].
  void switchTab(int index) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?.switchTab(index);
  }

  // ── Profile image picker 

  /// Shows bottom sheet with Camera / Gallery / Remove options.
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 16),
            Text("Change Profile Photo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _photoOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  color: AppColors.goldDark,
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(fromCamera: true);
                  },
                ),
                _photoOption(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  color: AppColors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(fromCamera: false);
                  },
                ),
                // Show Remove option only when a photo exists
                if (_imagePath != null && _imagePath!.isNotEmpty)
                  _photoOption(
                    icon: Icons.delete_rounded,
                    label: "Remove",
                    color: AppColors.darkRed,
                    onTap: () {
                      Navigator.pop(context);
                      _storage.saveProfileImage('');
                      setState(() => _imagePath = null);
                    },
                  ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Launches the image picker (camera or gallery), saves the result.
  Future<void> _getImage({required bool fromCamera}) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,  // Compress to reduce storage size
        maxWidth: 400,     // Downscale large photos
      );
      if (picked != null) {
        _storage.saveProfileImage(picked.path);
        setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      // Show error snackbar if picker fails (e.g. permission denied)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image'),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Circular icon + label button used inside the photo picker sheet.
  Widget _photoOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 28,
            child: Icon(icon, color: color, size: 26),
          ),
          SizedBox(height: 8),
          Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownerName = _storage.getOwnerName();
    final hasPhoto = _imagePath != null && _imagePath!.isNotEmpty;

    /// Returns time-appropriate greeting string.
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return "Good Morning";
      if (hour < 17) return "Good Afternoon";
      if (hour < 21) return "Good Evening";
      return "Good Night";
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HEADER: logo + notification bell + avatar ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // App logo + name
                Row(
                  children: [
                    Image.asset('assets/images/logo.png', width: 30),
                    SizedBox(width: 8),
                    Text("StockSense",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Row(
                  children: [
                    // Notification bell with red dot badge when alerts exist
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      ),
                      child: Stack(
                        children: [
                          const Icon(Icons.notifications_none_rounded),
                          Consumer<ProductProvider>(
                            builder: (_, p, __) {
                              final count = p.lowStockProducts.length + p.expiringProducts.length;
                              if (count == 0) return const SizedBox.shrink(); // No badge when clean
                              return Positioned(
                                right: 0, top: 0,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.darkRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),

                    // Profile avatar — navigates to ProfileScreen on tap
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        );
                        // Refresh image in case it was changed inside ProfileScreen
                        setState(() {
                          _imagePath = _storage.getProfileImage();
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: AppColors.goldDark,
                        radius: 18,
                        backgroundImage: hasPhoto
                            ? FileImage(File(_imagePath!))
                            : null,
                        child: !hasPhoto
                            ? Icon(Icons.person_rounded,
                                size: 20, color: AppColors.white)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),

            // ── GREETING 
            Text(
              "${getGreeting()}, $ownerName 👋",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("Here's your inventory snapshot.",
                style: TextStyle(color: AppColors.grey)),

            SizedBox(height: 20),

            // ── QUICK ACTIONS ROW 
            // Five shortcut icons: Add Item, Purchase, Sales, Credit, Scan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickImageIcon(
                  context,
                  'assets/icons/addicon.png',
                  "ADD ITEM",
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddProductScreen())),
                ),
                _quickImageIcon(
                  context,
                  'assets/icons/purchaseicon.png',
                  "PURCHASE",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PurchaseListScreen()),
                  ),
                ),
                _quickImageIcon(
                  context,
                  'assets/icons/saleicon.png',
                  "SALES",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalesListScreen()),
                  ),
                ),
                _quickImageIcon(
                  context,
                  'assets/icons/crediticon.png',
                  "CREDIT",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomersScreen()),
                  ),
                ),
                _quickImageIcon(
                  context,
                  'assets/icons/barcodeicon .png',
                  "SCAN",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScannerScreen()),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // ── TOTAL PRODUCTS CARD 
            // Tapping navigates to Inventory tab (index 1).
            Consumer<ProductProvider>(
              builder: (_, p, __) => GestureDetector(
                onTap: () => switchTab(1),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Products",
                              style: TextStyle(color: AppColors.grey)),
                          SizedBox(height: 5),
                          Text(p.totalProducts.toString(),
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Icon(Icons.grid_view_rounded,
                          color: AppColors.lightGrey, size: 28),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 15),

            // ── LOW STOCK + EXPIRY ALERT CARDS 
            // Side-by-side; both tap to Alerts tab (index 2).
            Consumer<ProductProvider>(
              builder: (_, p, __) => Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => switchTab(2),
                    child: _alertStat(
                      "LOW STOCK",
              p.lowStockProducts.length.toString(),
                "items need\nimmediate restock",
                AppColors.darkRed,
                 AppColors.lightRed,
              icon: Icons.warning_amber_rounded,
                subtitleColor: AppColors.darkRed,
                   ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => switchTab(2),
                     child: _alertStat(
                    "EXPIRY",
                p.expiringProducts.length.toString(),
                "items in\nnext 30 days",
               AppColors.goldDark,
               AppColors.white,
         subtitleColor: AppColors.grey,
                    ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // ── TODAY SALES CARD 
            // Dark card; total sourced live from SaleProvider.
            // NOTE: "+12% vs yesterday" is currently a static placeholder.
            Consumer<SaleProvider>(
              builder: (_, s, __) => Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TODAY SALES",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                        SizedBox(height: 6),
                        Text(
                          "₹${s.todaySalesTotal.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                color: AppColors.darkGreen, size: 13),
                            Text("+12% vs yesterday", // TODO: compute dynamically
                                style: TextStyle(
                                    color: AppColors.darkGreen,
                                    fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    Icon(Icons.bar_chart_rounded,
                        color: AppColors.goldDark, size: 40),
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            // ── PENDING CREDIT CARD 
            // TODO: source ₹1,450.00 dynamically from a CreditProvider.
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.lightGrey.withOpacity(0.5),
                    child: Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.grey, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("PENDING CREDIT",
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.grey,
                                letterSpacing: 0.5)),
                        SizedBox(height: 2),
                        Text("₹1,450.00", // TODO: replace with live value
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // "View All" navigates to CustomersScreen
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomersScreen()),
                    ),
                    child: Text("View All",
                        style: TextStyle(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // ── SMART DEMAND PREDICTION CARD 
            // Gold promo card; content is currently hardcoded.
            // CTA opens SmartInsightsScreen to create a purchase order.
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.goldDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text("SMART DEMAND PREDICTION",
                          style: TextStyle(
                              color: AppColors.white.withOpacity(0.9),
                              fontSize: 10,
                              letterSpacing: 1)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("Artisan Bread predicted to run\nout in 6 hours.", // TODO: dynamic prediction
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                      "Based on your Friday evening sales velocity,\nconsider restocking now.",
                      style: TextStyle(
                          color: AppColors.white.withOpacity(0.85),
                          fontSize: 12)),
                  SizedBox(height: 14),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SmartInsightsScreen()),
                      ),
                      child: Text("Create Purchase Order",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ── RECENT ACTIVITY 
            // Header row; "See History" is non-functional placeholder.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Activity",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text("See History", // TODO: wire to a full activity log screen
                    style: TextStyle(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w500)),
              ],
            ),

            SizedBox(height: 12),

            // Hardcoded sample activity tiles — replace with live feed
            _activityTile(
              icon: Icons.add_circle_rounded,
              color: AppColors.darkGreen,
              title: "Stock Added",
              subtitle: "+50 Whole Milk",
              time: "10:45 AM",
              timeColor: AppColors.darkGreen,
            ),
            _activityTile(
              icon: Icons.receipt_rounded,
              color: AppColors.blue,
              title: "Sales Transaction",
              subtitle: "Order #SL0923 — 4 items",
              time: "09:12 AM",
              timeColor: AppColors.grey,
            ),
            _activityTile(
              icon: Icons.delete_rounded,
              color: AppColors.darkRed,
              title: "Waste Logged",
              subtitle: "10x Green Yogurt (Expired)",
              time: "Yesterday",
              timeColor: AppColors.darkRed,
              badge: "-₹165", // Monetary loss badge
            ),

            SizedBox(height: 16),

            // ── WASTED ITEMS 
            // TODO: wire onTap to a waste details screen
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text("SEE DETAILS OF",
                        style: TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 9,
                            letterSpacing: 2)),
                    SizedBox(height: 2),
                    Text("WASTED ITEMS →",
                        style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  
  //  HELPER WIDGETS
  

  /// Quick-action icon button backed by an asset image.
  Widget _quickImageIcon(BuildContext context, String iconPath, String label,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.lightGrey,
            radius: 24,
            child: Image.asset(iconPath, width: 20, height: 20),
          ),
          SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 9, color: AppColors.grey, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  /// Quick-action icon button backed by a Material [IconData].
  /// Currently unused — kept for future use or migration.
  Widget _quickIconTap(IconData icon, String label,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.white,
            radius: 24,
            child: Icon(icon, size: 20),
          ),
          SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 9, color: AppColors.grey, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  /// Colored stat card used for Low Stock and Expiry alerts.
  /// [valueColor] tints both the count and the title label.
Widget _alertStat(
  String title,
  String value,
  String subtitle,
  Color valueColor,
  Color bgColor, {
  IconData? icon,
  Color? subtitleColor,
}) {
  return Container(
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Top row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: valueColor,
                letterSpacing: 0.5,
              ),
            ),

            // Show icon only if provided
            if (icon != null)
              Icon(
                icon,
                color: valueColor,
                size: 20,
              ),
          ],
        ),

        SizedBox(height: 6),

        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),

        SizedBox(height: 4),

      Text(
  subtitle,
  style: TextStyle(
    fontSize: 10,
    color: subtitleColor ?? AppColors.grey,
    fontWeight: FontWeight.w500,
  ),
),
      ],
    ),
  );
}

  /// Activity feed tile with a colored left border and optional monetary badge.
  Widget _activityTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    required Color timeColor,
    String? badge, // Optional red monetary-loss label (e.g. "-₹165")
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)), // Accent stripe
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle,
                    style:
                        TextStyle(color: AppColors.grey, fontSize: 11)),
              ],
            ),
          ),
          // Timestamp + optional loss badge aligned to the right
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time,
                  style: TextStyle(fontSize: 10, color: timeColor)),
              if (badge != null)
                Text(badge,
                    style: TextStyle(
                        fontSize: 10,
                        color:AppColors.darkRed,
                        fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}