import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'FloraMarket';
  static const String appTagline = 'Digitalna platforma za lokalne cvećare';

  // API Config
  static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY_HERE';
  static const String defaultCity = 'Novi Sad';
  static const String stripePublishableKey = 'pk_test_florapaymentmockkey12345';

  // Firestore Collections
  static const String colUsers = 'users';
  static const String colFlorists = 'florists';
  static const String colProducts = 'products';
  static const String colOrders = 'orders';

  // Categories
  static const List<String> categories = [
    'Sve',
    'Buketi',
    'Sobno cveće',
    'Aranžmani',
    'Egzotične biljke',
    'Sukulenti',
  ];

  // Currency
  static const String currency = 'RSD';
  static const double standardDeliveryFee = 350.0;
  static const double freeDeliveryThreshold = 4000.0;
}

class AppColors {
  // Primary Botanical Green
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF81C784);

  // Accent Floral Pink / Rose
  static const Color accent = Color(0xFFE91E63);
  static const Color accentLight = Color(0xFFF48FB1);

  // Secondary Warm Sand / Gold
  static const Color secondary = Color(0xFFFFA000);

  // Neutral Backgrounds
  static const Color bgLight = Color(0xFFF9FBF9);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Dark Theme Colors
  static const Color bgDark = Color(0xFF121814);
  static const Color surfaceDark = Color(0xFF1B241E);
  static const Color cardDark = Color(0xFF233027);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);
}

