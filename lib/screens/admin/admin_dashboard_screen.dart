import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/shop_provider.dart';
import 'manage_products_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_shops_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'sr_RS', symbol: 'RSD', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalRevenue = orderProvider.allOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administratorski Panel'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FloraMarket Kontrolna Tabla',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pristup zaštićenim administratorskim funkcijama i bazi',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _buildMetricCard(
                  title: 'Proizvodi na stanju',
                  value: '${productProvider.allProducts.length}',
                  icon: Icons.local_florist_rounded,
                  color: Colors.green,
                  isDark: isDark,
                ),
                _buildMetricCard(
                  title: 'Lokalne cvećare',
                  value: '${shopProvider.florists.length}',
                  icon: Icons.storefront_rounded,
                  color: Colors.blue,
                  isDark: isDark,
                ),
                _buildMetricCard(
                  title: 'Broj porudžbina',
                  value: '${orderProvider.allOrders.length}',
                  icon: Icons.shopping_bag_rounded,
                  color: Colors.orange,
                  isDark: isDark,
                ),
                _buildMetricCard(
                  title: 'Ukupan prihod',
                  value: currencyFormatter.format(totalRevenue),
                  icon: Icons.payments_rounded,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Upravljanje sistemom (CRUD & Baza)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Action 1: Proizvodi CRUD
            _buildAdminMenuTile(
              context: context,
              title: 'Upravljanje artiklima (Cveće & Biljke)',
              subtitle: 'Dodavanje novih, izmena postojećih i brisanje (CRUD)',
              icon: Icons.inventory_2_outlined,
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ManageProductsScreen()),
                );
              },
            ),

            const SizedBox(height: 10),

            // Action 2: Cvećare
            _buildAdminMenuTile(
              context: context,
              title: 'Upravljanje cvećarama',
              subtitle: 'Dodavanje i brisanje partnerskih radnji iz sistema',
              icon: Icons.store_mall_directory_outlined,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ManageShopsScreen()),
                );
              },
            ),

            const SizedBox(height: 10),

            // Action 3: Porudžbine
            _buildAdminMenuTile(
              context: context,
              title: 'Sve generisane porudžbine',
              subtitle: 'Praćenje statusa isporuke i uplata u realnom vremenu',
              icon: Icons.receipt_long,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ManageOrdersScreen()),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required MaterialColor color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenuTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

