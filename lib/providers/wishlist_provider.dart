import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProvider with ChangeNotifier {
  static const String _keyWishlist = 'user_wishlist_ids';
  final Set<String> _wishlistIds = {};
  bool _isInitialized = false;

  Set<String> get wishlistIds => {..._wishlistIds};

  WishlistProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyWishlist);
    if (list != null) {
      _wishlistIds.addAll(list);
    } else {
      // Default initial favorites
      _wishlistIds.addAll(['p1', 'p2']);
    }
    _isInitialized = true;
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _wishlistIds.contains(productId);
  }

  Future<void> toggleFavorite(String productId) async {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyWishlist, _wishlistIds.toList());
  }
}

