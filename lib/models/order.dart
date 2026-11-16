import 'cart_item.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String address;
  final String city;
  final String? postalCode;
  final String? deliveryNotes;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String status; // 'Na čekanju', 'U pripremi', 'Poslato', 'Isporučeno', 'Otkazano'
  final String paymentMethod; // 'Stripe Kartica', 'Plaćanje pouzećem'
  final String? paymentIntentId;
  final DateTime createdAt;

  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.address,
    required this.city,
    this.postalCode,
    this.deliveryNotes,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    this.status = 'Na čekanju',
    this.paymentMethod = 'Stripe Kartica',
    this.paymentIntentId,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    var rawItems = map['items'] as List<dynamic>? ?? [];
    List<CartItem> parsedItems = rawItems
        .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return OrderModel(
      orderId: id,
      userId: map['userId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? 'Novi Sad',
      postalCode: map['postalCode'],
      deliveryNotes: map['deliveryNotes'],
      items: parsedItems,
      subtotal: (map['subtotal'] is num) ? (map['subtotal'] as num).toDouble() : 0.0,
      deliveryFee: (map['deliveryFee'] is num) ? (map['deliveryFee'] as num).toDouble() : 0.0,
      totalAmount: (map['totalAmount'] is num) ? (map['totalAmount'] as num).toDouble() : 0.0,
      status: map['status'] ?? 'Na čekanju',
      paymentMethod: map['paymentMethod'] ?? 'Stripe Kartica',
      paymentIntentId: map['paymentIntentId'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'deliveryNotes': deliveryNotes,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentIntentId': paymentIntentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? status,
  }) {
    return OrderModel(
      orderId: orderId,
      userId: userId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      address: address,
      city: city,
      postalCode: postalCode,
      deliveryNotes: deliveryNotes,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      paymentIntentId: paymentIntentId,
      createdAt: createdAt,
    );
  }
}

