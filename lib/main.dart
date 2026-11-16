import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/splash_screen.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize simulated/persisted Firestore Database
  final firestoreService = FirestoreService();
  await firestoreService.init();

  runApp(
    FloraMarketApp(firestoreService: firestoreService),
  );
}

class FloraMarketApp extends StatelessWidget {
  final FirestoreService firestoreService;

  const FloraMarketApp({
    super.key,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(firestoreService: firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopProvider(firestoreService: firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(firestoreService: firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(firestoreService: firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

