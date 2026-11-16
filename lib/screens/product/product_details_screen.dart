import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../auth/login_screen.dart';
import '../../widgets/custom_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final wishlist = Provider.of<WishlistProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final florist = shopProvider.findById(widget.product.shopId);
    final isFav = wishlist.isFavorite(widget.product.id);
    final currencyFormatter = NumberFormat.currency(locale: 'sr_RS', symbol: 'RSD', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? AppColors.accent : null,
            ),
            onPressed: () {
              wishlist.toggleFavorite(widget.product.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Velika fotografija cveća
            Hero(
              tag: 'product_image_${widget.product.id}',
              child: Image.network(
                widget.product.imageUrl,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 280,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.local_florist, size: 80, color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategorija i cvećara
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.product.category,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (florist != null)
                        Text(
                          'Cvećara: ${florist.name}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Naziv i Cena
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(widget.product.price),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (widget.product.description.isNotEmpty) ...[
                    Text(
                      widget.product.description,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Box: Saveti za održavanje i negu
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2D22) : const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.eco, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Uputstvo i saveti za održavanje:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.careInstructions,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: isDark ? Colors.white90 : const Color(0xFF2E5936),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Količina
                  Row(
                    children: [
                      const Text(
                        'Količina:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Dugme za korpu (ili prijavu za gosta)
                  if (auth.isGuest)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.amber, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Prijavite se kako biste mogli da dodate proizvod u korpu i poručite.',
                                  style: TextStyle(fontSize: 12.5, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Prijavi se za kupovinu',
                          icon: Icons.login,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                            );
                          },
                        ),
                      ],
                    )
                  else
                    CustomButton(
                      text: 'Dodaj u korpu (${currencyFormatter.format(widget.product.price * _quantity)})',
                      icon: Icons.add_shopping_cart,
                      onPressed: () {
                        cart.addItem(widget.product, quantity: _quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Dodato $_quantity kom. (${widget.product.title}) u korpu',
                            ),
                            backgroundColor: AppColors.primary,
                            action: SnackBarAction(
                              label: 'KORPA',
                              textColor: Colors.white,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

