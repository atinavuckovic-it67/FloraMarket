import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/florist.dart';
import '../../providers/shop_provider.dart';

class ManageShopsScreen extends StatelessWidget {
  const ManageShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravljanje cvećarama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            tooltip: 'Dodaj novu cvećaru',
            onPressed: () => _showAddShopDialog(context, shopProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddShopDialog(context, shopProvider),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova cvećara', style: TextStyle(color: Colors.white)),
      ),
      body: shopProvider.florists.isEmpty
          ? const Center(child: Text('Nema cvećara u bazi.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: shopProvider.florists.length,
              itemBuilder: (ctx, idx) {
                final shop = shopProvider.florists[idx];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        shop.image,
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 55,
                          height: 55,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.storefront),
                        ),
                      ),
                    ),
                    title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text('${shop.location} • Ocena: ${shop.rating.toStringAsFixed(1)} ★'),
                        Text(shop.phone, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Obriši cvećaru',
                      onPressed: () => _confirmDeleteShop(context, shop, shopProvider),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddShopDialog(BuildContext context, ShopProvider provider) {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController(text: 'Novi Sad');
    final addrCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+381 21 ');
    final imgCtrl = TextEditingController(
      text: 'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?auto=format&fit=crop&w=800&q=80',
    );
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dodavanje nove cvećare'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Naziv cvećare'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: 'Naselje / Deo grada (npr. Grbavica)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(labelText: 'Ulica i broj'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Broj telefona'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Kratak opis ponude'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;

              final shopId = 'shop_${DateTime.now().millisecondsSinceEpoch}';
              final newFlorist = Florist(
                shopId: shopId,
                name: nameCtrl.text.trim(),
                location: locCtrl.text.trim(),
                address: addrCtrl.text.trim().isNotEmpty ? addrCtrl.text.trim() : locCtrl.text.trim(),
                image: imgCtrl.text.trim(),
                rating: 5.0,
                description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : 'Nova partnerska cvećara u Novom Sadu.',
                phone: phoneCtrl.text.trim(),
                openingHours: 'Pon-Sub: 08:00 - 20:00',
              );

              await provider.addFlorist(newFlorist);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cvećara „${newFlorist.name}” je uspešno dodata!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Dodaj cvećaru'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteShop(BuildContext context, Florist shop, ShopProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Brisanje cvećare'),
        content: Text('Da li ste sigurni da želite da uklonite „${shop.name}” iz sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteFlorist(shop.shopId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cvećara „${shop.name}” je uklonjena.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Obriši', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

