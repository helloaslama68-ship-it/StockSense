import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/colors.dart';
import 'screens/splash.dart';

// Models
import 'models/product.dart';
import 'models/sale.dart';
import 'models/purchase.dart';

// Providers
import 'providers/product_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/alert_provider.dart';

void main() async {

  // Ensures Flutter engine is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local database
  await Hive.initFlutter();

  // Open general-purpose local storage boxes
  await Hive.openBox('appBox');
  await Hive.openBox('settings');

  // Register Hive adapters
  // Adapters convert Dart objects into storable binary data
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(PurchaseAdapter());

  // Open typed Hive boxes for storing app data locally
  await Hive.openBox<Product>('products');
  await Hive.openBox<Sale>('sales');
  await Hive.openBox<Purchase>('purchases');

  // Start the app with Provider state management
  runApp(

    // MultiProvider allows multiple providers across the app
    MultiProvider(
      providers: [

        // Handles product CRUD operations and inventory logic
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),

        // Handles sales-related operations
        ChangeNotifierProvider(
          create: (_) => SaleProvider(),
        ),

        // Handles stock alerts and notifications
        ChangeNotifierProvider(
          create: (_) => AlertProvider(),
        ),
      ],

      // Main application widget
      child: StockSenseApp(),
    ),
  );
}

// Root widget of the application
class StockSenseApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      // Removes debug banner
      debugShowCheckedModeBanner: false,

      // Application title
      title: 'StockSense',

      // Global app theme
      theme: ThemeData(

        // Default screen background color
        scaffoldBackgroundColor: AppColors.white,

        // Main theme color
        primaryColor: AppColors.primary,
      ),

      // First screen shown when app starts
      home: Splash(),
    );
  }
}