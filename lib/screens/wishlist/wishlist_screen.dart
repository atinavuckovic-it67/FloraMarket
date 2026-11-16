import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final favProducts = productProvider.allProducts
        .where((p) => wishlist.isFavorite(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Omiljeno (${favProducts.length})'),
      ),
      body: favProducts.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.favorite_border_rounded,
              title: 'Vaša lista želja je prazna',
              message: 'Dodirnite srce na bilo kom buketu ili saksijskoj biljci kako biste ih sačuvali za kasnije.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favProducts.length,
              itemBuilder: (ctx, idx) => ProductCard(product: favProducts[idx]),
            ),
    );
  }
}

