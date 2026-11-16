import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productTitle': product.title,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'shopId': product.shopId,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product(
        id: map['productId'] ?? '',
        title: map['productTitle'] ?? '',
        price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
        imageUrl: map['imageUrl'] ?? '',
        shopId: map['shopId'] ?? '',
        careInstructions: '',
      ),
      quantity: map['quantity'] ?? 1,
    );
  }
}

