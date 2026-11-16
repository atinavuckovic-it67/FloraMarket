import 'package:flutter/material.dart';
import '../models/florist.dart';
import '../services/firestore_service.dart';

class ShopProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<Florist> _florists = [];
  bool _isLoading = false;
  String _searchQuery = '';

  ShopProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    loadFlorists();
  }

  List<Florist> get florists => _florists;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Florist> get filteredFlorists {
    if (_searchQuery.isEmpty) return _florists;
    return _florists.where((f) {
      return f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Florist? findById(String id) {
    try {
      return _florists.firstWhere((f) => f.shopId == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadFlorists() async {
    _isLoading = true;
    notifyListeners();

    _florists = await _firestoreService.getFlorists();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addFlorist(Florist florist) async {
    await _firestoreService.addFlorist(florist);
    await loadFlorists();
  }

  Future<void> deleteFlorist(String shopId) async {
    await _firestoreService.deleteFlorist(shopId);
    await loadFlorists();
  }
}

