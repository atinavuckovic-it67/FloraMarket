class Product {
  final String id;
  final String title;
  final double price;
  final String careInstructions;
  final String shopId;
  final String imageUrl;
  final String category;
  final String description;
  final bool inStock;
  final bool featured;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.careInstructions,
    required this.shopId,
    required this.imageUrl,
    this.category = 'Buketi',
    this.description = '',
    this.inStock = true,
    this.featured = false,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      title: map['title'] ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
      careInstructions: map['careInstructions'] ?? 'Držati na svetlom mestu i umereno zalivati.',
      shopId: map['shopId'] ?? '',
      imageUrl: map['imageUrl'] ?? 'https://images.unsplash.com/photo-1561181286-d3fee7d55364',
      category: map['category'] ?? 'Buketi',
      description: map['description'] ?? '',
      inStock: map['inStock'] ?? true,
      featured: map['featured'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'careInstructions': careInstructions,
      'shopId': shopId,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'inStock': inStock,
      'featured': featured,
    };
  }

  Product copyWith({
    String? id,
    String? title,
    double? price,
    String? careInstructions,
    String? shopId,
    String? imageUrl,
    String? category,
    String? description,
    bool? inStock,
    bool? featured,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      careInstructions: careInstructions ?? this.careInstructions,
      shopId: shopId ?? this.shopId,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      description: description ?? this.description,
      inStock: inStock ?? this.inStock,
      featured: featured ?? this.featured,
    );
  }
}

