import 'dart:async';
import 'package:uuid/uuid.dart';

class StripePaymentResult {
  final bool isSuccess;
  final String? paymentIntentId;
  final String? errorMessage;
  final DateTime timestamp;

  StripePaymentResult({
    required this.isSuccess,
    this.paymentIntentId,
    this.errorMessage,
    required this.timestamp,
  });
}

class StripeService {
  final Uuid _uuid = const Uuid();

  /// Simulates / processes Stripe PaymentIntent checkout
  /// In live mode with backend, this initiates a client-secret call to Stripe API.
  Future<StripePaymentResult> processPayment({
    required double amount,
    required String currency,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) async {
    // Artificial latency for realistic network processing
    await Future.delayed(const Duration(milliseconds: 1400));

    // Basic card validation
    final cleanCardNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanCardNumber.length < 15) {
      return StripePaymentResult(
        isSuccess: false,
        errorMessage: 'Broj kartice je nevažeći. Molimo proverite unete cifre.',
        timestamp: DateTime.now(),
      );
    }

    if (cvv.length < 3) {
      return StripePaymentResult(
        isSuccess: false,
        errorMessage: 'CVV/CVC kod mora sadržati najmanje 3 cifre.',
        timestamp: DateTime.now(),
      );
    }

    // Success response with generated Stripe payment intent ID
    final paymentIntentId = 'pi_${_uuid.v4().replaceAll('-', '')}';

    return StripePaymentResult(
      isSuccess: true,
      paymentIntentId: paymentIntentId,
      timestamp: DateTime.now(),
    );
  }
}

