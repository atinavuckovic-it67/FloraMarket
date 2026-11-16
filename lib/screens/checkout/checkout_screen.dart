import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/stripe_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../order_success/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stripeService = StripeService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _notesController;

  // Stripe card fields
  final _cardNumberController = TextEditingController(text: '4242 4242 4242 4242');
  final _expiryController = TextEditingController(text: '12/28');
  final _cvvController = TextEditingController(text: '123');
  final _cardholderController = TextEditingController();

  String _paymentMethod = 'Stripe Kartica'; // or 'Plaćanje pouzećem'
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city.isNotEmpty == true ? user!.city : 'Novi Sad');
    _notesController = TextEditingController();
    _cardholderController.text = user?.fullName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vaša korpa je prazna.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    String? paymentIntentId;

    if (_paymentMethod == 'Stripe Kartica') {
      final paymentResult = await _stripeService.processPayment(
        amount: cart.totalAmount,
        currency: 'rsd',
        cardNumber: _cardNumberController.text,
        expiryDate: _expiryController.text,
        cvv: _cvvController.text,
        cardholderName: _cardholderController.text,
      );

      if (!paymentResult.isSuccess) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(paymentResult.errorMessage ?? 'Transakcija odbijena'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      paymentIntentId = paymentResult.paymentIntentId;
    }

    // Create Order object in Firestore
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final newOrder = OrderModel(
      orderId: orderId,
      userId: auth.currentUser?.userId ?? 'anonymous',
      customerName: _nameController.text.trim(),
      customerEmail: auth.currentUser?.email ?? '',
      customerPhone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      deliveryNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      items: cart.items.values.toList(),
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      totalAmount: cart.totalAmount,
      status: 'Na čekanju',
      paymentMethod: _paymentMethod,
      paymentIntentId: paymentIntentId,
      createdAt: DateTime.now(),
    );

    await orderProvider.placeOrder(newOrder);

    // Empty cart per documentation
    cart.clearCart();

    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => OrderSuccessScreen(order: newOrder),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(locale: 'sr_RS', symbol: 'RSD', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Poručivanje i Plaćanje'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sekcija 1: Podaci za dostavu
                Text(
                  '1. Podaci za dostavu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _nameController,
                  label: 'Ime i prezime primaoca',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite ime i prezime' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Kontakt telefon',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().length < 6) ? 'Unesite ispravan broj telefona' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _addressController,
                        label: 'Ulica i kućni broj',
                        prefixIcon: Icons.home_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite adresu' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _cityController,
                        label: 'Grad',
                        prefixIcon: Icons.location_city_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Grad' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _notesController,
                  label: 'Poruka za posvetu ili napomena kuriru (opciono)',
                  prefixIcon: Icons.note_alt_outlined,
                  maxLines: 2,
                ),

                const Divider(height: 36),

                // Sekcija 2: Način plaćanja
                Text(
                  '2. Način plaćanja',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Radio: Stripe Card
                Card(
                  elevation: 0,
                  color: _paymentMethod == 'Stripe Kartica'
                      ? AppColors.primary.withOpacity(0.08)
                      : (isDark ? AppColors.cardDark : Colors.grey.shade50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: _paymentMethod == 'Stripe Kartica'
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: _paymentMethod == 'Stripe Kartica' ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: 'Stripe Kartica',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                    title: const Row(
                      children: [
                        Icon(Icons.credit_card, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Platna kartica (Stripe PaymentIntent)', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    subtitle: const Text('Brzo, sigurno i šifrovano online plaćanje'),
                  ),
                ),

                const SizedBox(height: 8),

                // Radio: Cash on delivery
                Card(
                  elevation: 0,
                  color: _paymentMethod == 'Plaćanje pouzećem'
                      ? AppColors.primary.withOpacity(0.08)
                      : (isDark ? AppColors.cardDark : Colors.grey.shade50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: _paymentMethod == 'Plaćanje pouzećem'
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: _paymentMethod == 'Plaćanje pouzećem' ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: 'Plaćanje pouzećem',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                    title: const Row(
                      children: [
                        Icon(Icons.money, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Plaćanje pouzećem', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    subtitle: const Text('Platite kuriru u gotovini pri preuzimanju buketa'),
                  ),
                ),

                // Stripe Card Input Subform
                if (_paymentMethod == 'Stripe Kartica') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock_outline, size: 16, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              'Stripe Secure 256-bit enkripcija',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _cardNumberController,
                          label: 'Broj kartice',
                          prefixIcon: Icons.credit_card,
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.trim().length < 15) ? 'Unesite broj kartice' : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _expiryController,
                                label: 'Važi do (MM/GG)',
                                prefixIcon: Icons.date_range,
                                validator: (v) => (v == null || !v.contains('/')) ? 'MM/GG' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _cvvController,
                                label: 'CVC / CVV',
                                prefixIcon: Icons.security,
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.trim().length < 3) ? 'CVC kod' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _cardholderController,
                          label: 'Ime vlasnika kartice',
                          prefixIcon: Icons.person_pin_outlined,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Ime vlasnika' : null,
                        ),
                      ],
                    ),
                  ),
                ],

                const Divider(height: 36),

                // Sekcija 3: Pregled iznosa
                Text(
                  '3. Pregled narudžbine',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Iznos cveća:', style: TextStyle(fontSize: 14)),
                    Text(
                      currencyFormatter.format(cart.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dostava (Novi Sad):', style: TextStyle(fontSize: 14)),
                    Text(
                      cart.deliveryFee == 0
                          ? 'Besplatno'
                          : currencyFormatter.format(cart.deliveryFee),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: cart.deliveryFee == 0 ? AppColors.primary : null,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ukupno za uplatu:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currencyFormatter.format(cart.totalAmount),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                CustomButton(
                  text: _isProcessing
                      ? 'Obrada plaćanja preko Stripe-a...'
                      : 'Potvrdi i plati (${currencyFormatter.format(cart.totalAmount)})',
                  isLoading: _isProcessing,
                  icon: Icons.check_circle_outline,
                  onPressed: _isProcessing ? null : _processCheckout,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

