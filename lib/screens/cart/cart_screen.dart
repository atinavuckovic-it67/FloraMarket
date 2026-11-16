import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/cart_item_tile.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../auth/login_screen.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(locale: 'sr_RS', symbol: 'RSD', decimalDigits: 0);

    // Guest cannot access cart per spec:
    // "1. Gost: Nema pristup korpi niti mogućnost poručivanja."
    if (auth.isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vaša korpa')),
        body: EmptyStateWidget(
          icon: Icons.lock_outline_rounded,
          title: 'Pristup korpi je zaključan',
          message:
              'Kao gost možete pregledati cvećare i katalog cveća. Za korišćenje korpe i online poručivanje neophodno je da se prijavite na svoj nalog.',
          buttonText: 'Prijavi se na nalog',
          onButtonPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const LoginScreen()),
            );
          },
        ),
      );
    }

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vaša korpa')),
        body: const EmptyStateWidget(
          icon: Icons.shopping_basket_outlined,
          title: 'Vaša korpa je prazna',
          message: 'Dodajte omiljeno cveće, raskošne bukete ili sobne biljke iz ponude lokalnih cvećara.',
        ),
      );
    }

    final cartItems = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Korpa (${cart.itemCount})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Isprazni korpu',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Isprazni korpu?'),
                  content: const Text('Da li ste sigurni da želite da uklonite sve artikle iz korpe?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Odustani'),
                    ),
                    TextButton(
                      onPressed: () {
                        cart.clearCart();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Isprazni', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (ctx, idx) => CartItemTile(item: cartItems[idx]),
            ),
          ),

          // Total and Checkout Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Iznos korpe:', style: TextStyle(fontSize: 14)),
                      Text(
                        currencyFormatter.format(cart.subtotal),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                            ? 'Besplatna dostava'
                            : currencyFormatter.format(cart.deliveryFee),
                        style: TextStyle(
                          fontSize: 14,
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
                        'Za naplatu:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currencyFormatter.format(cart.totalAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Nastavi na poručivanje (Checkout)',
                    icon: Icons.payment,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const CheckoutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

