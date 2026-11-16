import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    _currentUser = UserProfile.guest();
  }

  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null && !_currentUser!.isGuest;
  bool get isGuest => _currentUser == null || _currentUser!.isGuest;
  bool get isAdmin => _currentUser != null && _currentUser!.isAdmin;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      // Simple demo credentials validation or database lookup
      final cleanEmail = email.trim().toLowerCase();

      if (cleanEmail == 'admin@floramarket.rs' || cleanEmail == 'admin') {
        _currentUser = await _firestoreService.getUserProfile('admin_user') ??
            const UserProfile(
              userId: 'admin_user',
              email: 'admin@floramarket.rs',
              fullName: 'Atina Vučković (Administrator)',
              role: 'admin',
            );
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Check if user exists in database
      final user = await _firestoreService.getUserProfile(cleanEmail);
      if (user != null) {
        _currentUser = user;
      } else {
        // Log in as standard customer
        _currentUser = UserProfile(
          userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: cleanEmail,
          fullName: cleanEmail.split('@').first,
          role: 'user',
        );
        await _firestoreService.saveUserProfile(_currentUser!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Greška pri prijavi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String phone = '',
    String address = '',
    String city = 'Novi Sad',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 700));

      final cleanEmail = email.trim().toLowerCase();
      final newUser = UserProfile(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: cleanEmail,
        fullName: fullName.trim(),
        phone: phone.trim(),
        address: address.trim(),
        city: city.trim(),
        role: 'user',
      );

      await _firestoreService.saveUserProfile(newUser);
      _currentUser = newUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Greška pri registraciji: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String address,
    required String city,
  }) async {
    if (_currentUser == null || _currentUser!.isGuest) return;

    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      phone: phone,
      address: address,
      city: city,
    );

    await _firestoreService.saveUserProfile(_currentUser!);
    notifyListeners();
  }

  void continueAsGuest() {
    _currentUser = UserProfile.guest();
    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _currentUser = UserProfile.guest();
    _errorMessage = null;
    notifyListeners();
  }

  // Quick switcher for testing / presentation to show 3 roles (Guest, Customer, Admin)
  void switchRoleForDemo(String role) async {
    if (role == 'admin') {
      _currentUser = await _firestoreService.getUserProfile('admin_user') ??
          const UserProfile(
            userId: 'admin_user',
            email: 'admin@floramarket.rs',
            fullName: 'Atina Vučković (Administrator)',
            role: 'admin',
          );
    } else if (role == 'user') {
      _currentUser = await _firestoreService.getUserProfile('buyer_user') ??
          const UserProfile(
            userId: 'buyer_user',
            email: 'kupac@floramarket.rs',
            fullName: 'Marko Petrović (Kupac)',
            phone: '+381 60 987 6543',
            address: 'Bulevar Oslobođenja 102',
            city: 'Novi Sad',
            role: 'user',
          );
    } else {
      _currentUser = UserProfile.guest();
    }
    notifyListeners();
  }
}

