import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/firestore_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<OrderModel> _allOrders = [];
  bool _isLoading = false;

  OrderProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    loadOrders();
  }

  List<OrderModel> get allOrders => _allOrders;
  bool get isLoading => _isLoading;

  List<OrderModel> getOrdersForUser(String userId) {
    return _allOrders.where((o) => o.userId == userId).toList();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    _allOrders = await _firestoreService.getAllOrders();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> placeOrder(OrderModel order) async {
    await _firestoreService.createOrder(order);
    await loadOrders();
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    await _firestoreService.updateOrderStatus(orderId, newStatus);
    await loadOrders();
  }
}

