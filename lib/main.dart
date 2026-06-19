import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'screens/splash.dart';

// Models
import 'models/product.dart';
import 'models/sale.dart';
import 'models/purchase.dart';
import 'models/inventory_loss.dart';
import 'models/sale_item.dart';
import 'models/customer.dart';
import 'models/credit_transaction.dart';

// Services
import 'services/storage_service.dart';

// Repositories
import 'repositories/auth_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/inventory_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/loss_repository.dart';

// Providers
import 'providers/product_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/alert_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/purchase_provider.dart';
import 'providers/purchase_form_provider.dart';
import 'providers/product_form_provider.dart';
import 'providers/loss_provider.dart';
import 'providers/sale_form_provider.dart';
import 'providers/scanner_provider.dart';
import 'providers/log_loss_form_provider.dart';
import 'providers/loss_filter_provider.dart';
import 'providers/inventory_filter_provider.dart';
import 'providers/product_unit_provider.dart';
import 'providers/brand_search_provider.dart';
import 'providers/category_search_provider.dart';
import 'providers/purchase_filter_provider.dart';
import 'providers/sale_filter_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/stock_recommendation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isBoxOpen('appBox')) await Hive.openBox('appBox');
  if (!Hive.isBoxOpen('settings')) await Hive.openBox('settings');

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SaleAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SaleItemAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(PurchaseAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(InventoryLossAdapter());
  if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(CustomerAdapter());
  if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(CreditTransactionAdapter());

  if (!Hive.isBoxOpen('products')) await Hive.openBox<Product>('products');
  if (!Hive.isBoxOpen('sales')) await Hive.openBox<Sale>('sales');
  if (!Hive.isBoxOpen('purchases')) await Hive.openBox<Purchase>('purchases');
  if (!Hive.isBoxOpen('losses')) await Hive.openBox<InventoryLoss>('losses');
  if (!Hive.isBoxOpen('customers')) await Hive.openBox<Customer>('customers');
  if (!Hive.isBoxOpen('credit_transactions')) await Hive.openBox<CreditTransaction>('credit_transactions');

  runApp(
    MultiProvider(
      providers: [

        // SERVICES
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),

        // REPOSITORIES
        ProxyProvider<StorageService, AuthRepository>(
          update: (_, storage, __) => AuthRepository(storage),
        ),
        ProxyProvider<StorageService, ProfileRepository>(
          update: (_, storage, __) => ProfileRepository(storage),
        ),
        ProxyProvider<StorageService, InventoryRepository>(
          update: (_, storage, __) => InventoryRepository(storage),
        ),
        ProxyProvider<StorageService, NotificationRepository>(
          update: (_, storage, __) => NotificationRepository(storage),
        ),
        Provider<ProductRepository>(
          create: (_) => ProductRepository(),
        ),

        // SETTINGS — must be before Alert/Notification so proxy can depend on it
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        // PROVIDERS
        ChangeNotifierProxyProvider2<AuthRepository, ProfileRepository, ProfileProvider>(
          create: (ctx) => ProfileProvider(
            ctx.read<AuthRepository>(),
            ctx.read<ProfileRepository>(),
          ),
          update: (_, authRepo, profileRepo, prev) =>
              prev ?? ProfileProvider(authRepo, profileRepo),
        ),

        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        ChangeNotifierProxyProvider<ProductRepository, ProductProvider>(
          create: (ctx) => ProductProvider(ctx.read<ProductRepository>()),
          update: (_, repo, prev) => prev ?? ProductProvider(repo),
        ),

        ChangeNotifierProxyProvider<InventoryRepository, InventoryProvider>(
          create: (ctx) => InventoryProvider(ctx.read<InventoryRepository>()),
          update: (_, repo, prev) => prev ?? InventoryProvider(repo),
        ),

        ChangeNotifierProvider(create: (_) => SaleProvider()),

        // ALERT — wired to SettingsProvider
        ChangeNotifierProxyProvider<SettingsProvider, AlertProvider>(
          create: (_) => AlertProvider(),
          update: (_, settings, prev) => (prev ?? AlertProvider())..update(settings),
        ),

        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseFormProvider()),
        ChangeNotifierProvider(create: (_) => ProductFormProvider()),
        ChangeNotifierProvider(create: (_) => LossProvider(LossRepository())),

        // NOTIFICATION — wired to ProductProvider, SaleProvider, SettingsProvider
        ChangeNotifierProxyProvider4<NotificationRepository, ProductProvider, SaleProvider, SettingsProvider, NotificationProvider>(
          create: (ctx) => NotificationProvider(
            ctx.read<NotificationRepository>(),
          ),
          update: (_, repo, pp, sp, settings, prev) =>
              (prev ?? NotificationProvider(repo))
                ..update(pp, sp)
                ..updateSettings(settings),
        ),

        ChangeNotifierProvider(create: (_) => SaleFormProvider()),
        ChangeNotifierProvider(create: (_) => ScannerProvider()),
        ChangeNotifierProvider(create: (_) => LogLossFormProvider()),
        ChangeNotifierProvider(create: (_) => LossFilterProvider()),
        ChangeNotifierProvider(create: (_) => InventoryFilterProvider()),
        ChangeNotifierProvider(create: (_) => ProductUnitProvider()),
        ChangeNotifierProvider(create: (_) => BrandSearchProvider()),
        ChangeNotifierProvider(create: (_) => CategorySearchProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseFilterProvider()),
        ChangeNotifierProvider(create: (_) => SaleFilterProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProxyProvider2<ProductProvider, SaleProvider, StockRecommendationProvider>(
          create: (ctx) => StockRecommendationProvider(
            ctx.read<ProductProvider>(),
            ctx.read<SaleProvider>(),
          ),
          update: (_, pp, sp, prev) => prev ?? StockRecommendationProvider(pp, sp),
        ),

      ],
      child: const StockSenseApp(),
    ),
  );
}

class StockSenseApp extends StatelessWidget {
  const StockSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StockSense',


      // THEME
      themeMode: settings.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Splash(),
    );
  }
}