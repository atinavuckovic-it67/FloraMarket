import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'sr_RS', symbol: 'RSD', decimalDigits: 0);
    final dateFormatter = DateFormat('dd.MM.yyyy HH:mm');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final orders = orderProvider.allOrders;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sve porudžbine (${orders.length})'),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text('Nema generisanih porudžbina u sistemu.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (ctx, idx) {
                final order = orders[idx];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            // Status change dropdown
                            DropdownButton<String>(
                              value: order.status,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'Na čekanju', child: Text('Na čekanju')),
                                DropdownMenuItem(value: 'U pripremi', child: Text('U pripremi')),
                                DropdownMenuItem(value: 'Poslato', child: Text('Poslato')),
                                DropdownMenuItem(value: 'Isporučeno', child: Text('Isporučeno')),
                                DropdownMenuItem(value: 'Otkazano', child: Text('Otkazano')),
                              ],
                              onChanged: (newStatus) {
                                if (newStatus != null) {
                                  orderProvider.updateStatus(order.orderId, newStatus);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormatter.format(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                          ),
                        ),
                        const Divider(height: 20),
                        Text(
                          'Kupac: ${order.customerName} (${order.customerPhone})',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Adresa: ${order.address}, ${order.city}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                          ),
                        ),
                        if (order.deliveryNotes != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Napomena: „${order.deliveryNotes}”',
                            style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: order.items.map((it) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${it.quantity}x ${it.product.title}', style: const TextStyle(fontSize: 12.5)),
                                    Text(currencyFormatter.format(it.totalPrice), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.paymentMethod,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Ukupno: ${currencyFormatter.format(order.totalAmount)}',
                              style: const TextStyle(
                                fontSize: 16,
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
}

