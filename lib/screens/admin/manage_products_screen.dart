import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/shop_provider.dart';
import 'add_edit_product_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(locale: 'sr_RS', symbol: 'RSD', decimalDigits: 0);

    final displayedProducts = _filter.isEmpty
        ? productProvider.allProducts
        : productProvider.allProducts.where((p) {
            return p.title.toLowerCase().contains(_filter.toLowerCase()) ||
                p.category.toLowerCase().contains(_filter.toLowerCase());
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventar cveća (CRUD)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Dodaj novi artikal (Create)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AddEditProductScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const AddEditProductScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Dodaj cveće', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _filter = val),
              decoration: const InputDecoration(
                hintText: 'Pretraži proizvode u bazi...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          Expanded(
            child: displayedProducts.isEmpty
                ? const Center(child: Text('Nema artikala u inventaru.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: displayedProducts.length,
                    itemBuilder: (ctx, idx) {
                      final product = displayedProducts[idx];
                      final shop = shopProvider.findById(product.shopId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  product.imageUrl,
                                  width: 65,
                                  height: 65,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    width: 65,
                                    height: 65,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.local_florist, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${currencyFormatter.format(product.price)} • ${product.category}',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (shop != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        shop.name,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Edit button (Update)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                tooltip: 'Izmeni (Update)',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) => AddEditProductScreen(product: product),
                                    ),
                                  );
                                },
                              ),
                              // Delete button (Delete)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'Obriši (Delete)',
                                onPressed: () => _confirmDelete(context, product, productProvider),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Brisanje artikla (Delete)'),
        content: Text('Da li ste sigurni da želite trajno da obrišete „${product.title}” iz baze?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Artikal „${product.title}” je obrisan iz baze.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Obriši', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

