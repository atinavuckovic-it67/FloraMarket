import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<Product> _products = [];
  bool _isLoading = false;
  String _selectedCategory = 'Sve';
  String _searchQuery = '';

  ProductProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    loadProducts();
  }

  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == 'Sve' || p.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.careInstructions.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<Product> get featuredProducts {
    return _products.where((p) => p.featured).toList();
  }

  List<Product> getProductsForShop(String shopId) {
    return _products.where((p) => p.shopId == shopId).toList();
  }

  Product? findById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await _firestoreService.getProducts();

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // --- CRUD (Admin operations) ---
  Future<void> addProduct(Product product) async {
    await _firestoreService.addProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _firestoreService.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(String productId) async {
    await _firestoreService.deleteProduct(productId);
    await loadProducts();
  }
}

