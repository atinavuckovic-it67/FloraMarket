class UserProfile {
  final String userId;
  final String email;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String role; // 'guest', 'user', 'admin'
  final List<String> wishlist;

  const UserProfile({
    required this.userId,
    required this.email,
    required this.fullName,
    this.phone = '',
    this.address = '',
    this.city = 'Novi Sad',
    this.role = 'user',
    this.wishlist = const [],
  });

  bool get isAdmin => role == 'admin';
  bool get isGuest => role == 'guest';
  bool get isUser => role == 'user';

  factory UserProfile.guest() {
    return const UserProfile(
      userId: 'guest_user',
      email: '',
      fullName: 'Gost Korisnik',
      role: 'guest',
      wishlist: [],
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      userId: id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? 'Novi Sad',
      role: map['role'] ?? 'user',
      wishlist: (map['wishlist'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'role': role,
      'wishlist': wishlist,
    };
  }

  UserProfile copyWith({
    String? email,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? role,
    List<String>? wishlist,
  }) {
    return UserProfile(
      userId: userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      role: role ?? this.role,
      wishlist: wishlist ?? this.wishlist,
    );
  }
}

