import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/weather_tip_card.dart';
import '../../widgets/florist_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/role_badge.dart';
import '../admin/admin_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_florist, color: AppColors.primary, size: 20),
                const SizedBox(width: 6),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 8),
                RoleBadge(role: auth.currentUser?.role ?? 'guest'),
              ],
            ),
            Text(
              auth.isGuest
                  ? 'Dobrodošli! Pregledajte cvećare u Novom Sadu'
                  : 'Zdravo, ${auth.currentUser?.fullName.split(' ').first ?? 'korisniče'} 👋',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Role switcher pop-up for project defense/demo
          PopupMenuButton<String>(
            tooltip: 'Brza promena uloge za testiranje',
            icon: const Icon(Icons.swap_horiz_rounded),
            onSelected: (role) {
              auth.switchRoleForDemo(role);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Uloga promenjena na: ${role.toUpperCase()}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'guest',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Uloga 1: Gost (Neulogovan)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'user',
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Uloga 2: Registrovani kupac'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings_outlined, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Uloga 3: Administrator'),
                  ],
                ),
              ),
            ],
          ),
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.red),
              tooltip: 'Admin panel',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const AdminDashboardScreen()),
                );
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await shopProvider.loadFlorists();
          await productProvider.loadProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (val) => productProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Pretraži cveće, sobne biljke, savete...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: productProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => productProvider.setSearchQuery(''),
                          )
                        : null,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // OpenWeather Dynamic plant care advice card
              const WeatherTipCard(),

              // Categories Carousel
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text(
                  'Kategorije',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: AppConstants.categories.length,
                  itemBuilder: (context, idx) {
                    final cat = AppConstants.categories[idx];
                    final isSelected = productProvider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => productProvider.setCategory(cat),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Preporučene Cvećare (Shops from Firestore - Read operation)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preporučene cvećare',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${shopProvider.florists.length} radnji',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 195,
                child: shopProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: shopProvider.florists.length,
                        itemBuilder: (ctx, idx) {
                          final florist = shopProvider.florists[idx];
                          return FloristCard(florist: florist, compact: true);
                        },
                      ),
              ),

              const SizedBox(height: 20),

              // Flowers / Plants Grid (Read operation from Firestore)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ponuda cveća i biljaka',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${productProvider.filteredProducts.length} artikala',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              if (productProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (productProvider.filteredProducts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Nema proizvoda koji odgovaraju pretrazi.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: productProvider.filteredProducts.length,
                    itemBuilder: (ctx, idx) {
                      final product = productProvider.filteredProducts[idx];
                      return ProductCard(product: product);
                    },
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

