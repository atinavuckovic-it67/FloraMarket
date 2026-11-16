class Florist {
  final String shopId;
  final String name;
  final String location;
  final String address;
  final String image;
  final double rating;
  final String description;
  final String phone;
  final String openingHours;

  const Florist({
    required this.shopId,
    required this.name,
    required this.location,
    required this.address,
    required this.image,
    required this.rating,
    required this.description,
    required this.phone,
    required this.openingHours,
  });

  factory Florist.fromMap(Map<String, dynamic> map, String id) {
    return Florist(
      shopId: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      address: map['address'] ?? map['location'] ?? '',
      image: map['image'] ?? 'https://images.unsplash.com/photo-1526047932273-341f2a7631f9',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 4.5,
      description: map['description'] ?? '',
      phone: map['phone'] ?? '+381 21 000 000',
      openingHours: map['openingHours'] ?? 'Pon-Sub: 08:00 - 20:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'name': name,
      'location': location,
      'address': address,
      'image': image,
      'rating': rating,
      'description': description,
      'phone': phone,
      'openingHours': openingHours,
    };
  }

  Florist copyWith({
    String? shopId,
    String? name,
    String? location,
    String? address,
    String? image,
    double? rating,
    String? description,
    String? phone,
    String? openingHours,
  }) {
    return Florist(
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      location: location ?? this.location,
      address: address ?? this.address,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
    );
  }
}

