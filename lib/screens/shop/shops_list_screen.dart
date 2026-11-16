import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/florist_card.dart';

class ShopsListScreen extends StatelessWidget {
  const ShopsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokalne cvećare'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => shopProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Pretraži cvećare po nazivu ili lokaciji...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: shopProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => shopProvider.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: shopProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : shopProvider.filteredFlorists.isEmpty
                    ? Center(
                        child: Text(
                          'Nije pronađena nijedna cvećara.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        itemCount: shopProvider.filteredFlorists.length,
                        itemBuilder: (ctx, idx) {
                          final florist = shopProvider.filteredFlorists[idx];
                          return FloristCard(florist: florist);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

