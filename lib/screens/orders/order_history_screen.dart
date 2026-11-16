import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/empty_state.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(locale: 'sr_RS', symbol: 'RSD', decimalDigits: 0);
    final dateFormatter = DateFormat('dd.MM.yyyy HH:mm');

    final userOrders = orderProvider.getOrdersForUser(auth.currentUser?.userId ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje porudžbine'),
      ),
      body: userOrders.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Nemate prethodnih porudžbina',
              message: 'Kada poručite cveće ili aranžmane, ovde možete pratiti status isporuke i detalje.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userOrders.length,
              itemBuilder: (ctx, idx) {
                final order = userOrders[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderId,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            _buildStatusBadge(order.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dateFormatter.format(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                          ),
                        ),
                        const Divider(height: 20),
                        Column(
                          children: order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '${item.quantity}x ',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.product.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(item.totalPrice),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plaćanje: ${order.paymentMethod}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              'Ukupno: ${currencyFormatter.format(order.totalAmount)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    switch (status) {
      case 'Isporučeno':
        bg = Colors.green.shade100;
        text = Colors.green.shade900;
        break;
      case 'Poslato':
        bg = Colors.blue.shade100;
        text = Colors.blue.shade900;
        break;
      case 'U pripremi':
        bg = Colors.orange.shade100;
        text = Colors.orange.shade900;
        break;
      case 'Otkazano':
        bg = Colors.red.shade100;
        text = Colors.red.shade900;
        break;
      default: // Na čekanju
        bg = Colors.purple.shade100;
        text = Colors.purple.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

