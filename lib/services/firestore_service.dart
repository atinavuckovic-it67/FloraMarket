import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/florist.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/user_profile.dart';

class FirestoreService {
  static const String _keyFlorists = 'firestore_col_florists';
  static const String _keyProducts = 'firestore_col_products';
  static const String _keyOrders = 'firestore_col_orders';
  static const String _keyUsers = 'firestore_col_users';

  bool _isInitialized = false;

  List<Florist> _florists = [];
  List<Product> _products = [];
  List<OrderModel> _orders = [];
  Map<String, UserProfile> _users = {};

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();

    // 1. Florists
    final floristsJson = prefs.getString(_keyFlorists);
    if (floristsJson != null && floristsJson.isNotEmpty) {
      final List<dynamic> list = json.decode(floristsJson);
      _florists = list.map((e) => Florist.fromMap(e, e['shopId'] ?? '')).toList();
    } else {
      _florists = _initialFlorists();
      await _saveFlorists();
    }

    // 2. Products
    final productsJson = prefs.getString(_keyProducts);
    if (productsJson != null && productsJson.isNotEmpty) {
      final List<dynamic> list = json.decode(productsJson);
      _products = list.map((e) => Product.fromMap(e, e['id'] ?? '')).toList();
    } else {
      _products = _initialProducts();
      await _saveProducts();
    }

    // 3. Orders
    final ordersJson = prefs.getString(_keyOrders);
    if (ordersJson != null && ordersJson.isNotEmpty) {
      final List<dynamic> list = json.decode(ordersJson);
      _orders = list.map((e) => OrderModel.fromMap(e, e['orderId'] ?? '')).toList();
    } else {
      _orders = [];
    }

    // 4. Users
    final usersJson = prefs.getString(_keyUsers);
    if (usersJson != null && usersJson.isNotEmpty) {
      final Map<String, dynamic> map = json.decode(usersJson);
      _users = map.map((k, v) => MapEntry(k, UserProfile.fromMap(v, k)));
    } else {
      _users = _initialUsers();
      await _saveUsers();
    }

    _isInitialized = true;
  }

  // --- Florists CRUD ---
  Future<List<Florist>> getFlorists() async {
    await init();
    return List.unmodifiable(_florists);
  }

  Future<Florist?> getFloristById(String id) async {
    await init();
    try {
      return _florists.firstWhere((f) => f.shopId == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addFlorist(Florist florist) async {
    await init();
    _florists.add(florist);
    await _saveFlorists();
  }

  Future<void> deleteFlorist(String shopId) async {
    await init();
    _florists.removeWhere((f) => f.shopId == shopId);
    // Also remove products of this shop
    _products.removeWhere((p) => p.shopId == shopId);
    await _saveFlorists();
    await _saveProducts();
  }

  // --- Products CRUD ---
  Future<List<Product>> getProducts() async {
    await init();
    return List.unmodifiable(_products);
  }

  Future<List<Product>> getProductsByShop(String shopId) async {
    await init();
    return _products.where((p) => p.shopId == shopId).toList();
  }

  Future<Product?> getProductById(String id) async {
    await init();
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    await init();
    _products.add(product);
    await _saveProducts();
  }

  Future<void> updateProduct(Product product) async {
    await init();
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      await _saveProducts();
    }
  }

  Future<void> deleteProduct(String id) async {
    await init();
    _products.removeWhere((p) => p.id == id);
    await _saveProducts();
  }

  // --- Orders CRUD ---
  Future<List<OrderModel>> getAllOrders() async {
    await init();
    return List.unmodifiable(_orders);
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    await init();
    return _orders.where((o) => o.userId == userId).toList();
  }

  Future<void> createOrder(OrderModel order) async {
    await init();
    _orders.insert(0, order);
    await _saveOrders();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await init();
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      await _saveOrders();
    }
  }

  // --- Users ---
  Future<UserProfile?> getUserProfile(String userId) async {
    await init();
    return _users[userId];
  }

  Future<void> saveUserProfile(UserProfile user) async {
    await init();
    _users[user.userId] = user;
    await _saveUsers();
  }

  // --- Persistence helpers ---
  Future<void> _saveFlorists() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _florists.map((f) => f.toMap()).toList();
    await prefs.setString(_keyFlorists, json.encode(list));
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _products.map((p) => p.toMap()).toList();
    await prefs.setString(_keyProducts, json.encode(list));
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _orders.map((o) => o.toMap()).toList();
    await prefs.setString(_keyOrders, json.encode(list));
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _users.map((k, v) => MapEntry(k, v.toMap()));
    await prefs.setString(_keyUsers, json.encode(map));
  }

  // --- Initial Seed Data (Novi Sad Florists & Floral Products) ---
  List<Florist> _initialFlorists() {
    return [
      const Florist(
        shopId: 'cvece_lotos',
        name: 'Cvećara „Lotos Liman”',
        location: 'Liman 2, Novi Sad',
        address: 'Bulevar cara Lazara 42, Novi Sad',
        image: 'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?auto=format&fit=crop&w=800&q=80',
        rating: 4.9,
        description: 'Vrhunski izbor svežeg cveća, luksuznih ruža i unikatnih aranžmana za sve prilike.',
        phone: '+381 21 456 789',
        openingHours: 'Pon-Sub: 08:00 - 21:00, Ned: 09:00 - 15:00',
      ),
      const Florist(
        shopId: 'cvece_botanika',
        name: 'Botanika Art & Plants',
        location: 'Centar, Novi Sad',
        address: 'Zmaj Jovina 14, Novi Sad',
        image: 'https://images.unsplash.com/photo-1470058869958-2a77ade41c02?auto=format&fit=crop&w=800&q=80',
        rating: 4.8,
        description: 'Specijalizovana urbana džungla - sobne biljke, terarijumi, keramika i stručni saveti o održavanju.',
        phone: '+381 21 661 223',
        openingHours: 'Pon-Pet: 09:00 - 20:00, Sub: 09:00 - 17:00',
      ),
      const Florist(
        shopId: 'cvece_dunavski',
        name: 'Cvećara „Dunavski Cvet”',
        location: 'Petrovaradin, Novi Sad',
        address: 'Preradovićeva 28, Petrovaradin',
        image: 'https://images.unsplash.com/photo-1519378058457-4c29a0a2efac?auto=format&fit=crop&w=800&q=80',
        rating: 4.7,
        description: 'Tradicionalna porodična cvećara sa tradicijom dužom od 20 godina. Sezonsko cveće i buketi po meri.',
        phone: '+381 21 432 100',
        openingHours: 'Pon-Sub: 07:30 - 20:30',
      ),
    ];
  }

  List<Product> _initialProducts() {
    return [
      const Product(
        id: 'p1',
        title: 'Buket Crvenih Ruža „Prestige”',
        price: 4500.0,
        careInstructions: 'Odrezati stabljike pod uglom od 45 stepeni pre stavljanja u čistu hladnu vodu. Menjati vodu svakog drugog dana i držati van promaje.',
        shopId: 'cvece_lotos',
        imageUrl: 'https://images.unsplash.com/photo-1582794543139-8ac9cb0f7b11?auto=format&fit=crop&w=800&q=80',
        category: 'Buketi',
        description: 'Elegantan buket od 15 pažljivo odabranih ekvadorskih crvenih ruža sa dekorativnim eukaliptusom.',
        inStock: true,
        featured: true,
      ),
      const Product(
        id: 'p2',
        title: 'Monstera Deliciosa (Sobna džungla)',
        price: 3200.0,
        careInstructions: 'Voli svetla mesta sa indirektnim sunčevim zracima. Zalivati tek kada se gornji sloj zemlje (2-3 cm) prosuši. Listove redovno brisati vlažnom krpom.',
        shopId: 'cvece_botanika',
        imageUrl: 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?auto=format&fit=crop&w=800&q=80',
        category: 'Sobno cveće',
        description: 'Popularna tropska sobna biljka sa prepoznatljivim rascepljenim listovima, idealna za ulepšavanje modernih enterijera.',
        inStock: true,
        featured: true,
      ),
      const Product(
        id: 'p3',
        title: 'Kraljevska Orhideja Phalaenopsis',
        price: 2800.0,
        careInstructions: 'Zalivati potapanjem saksije u mlaku vodu na 15 minuta jednom nedeljno. Držati na svetlom prozoru, bez direktnog podnevnog sunca.',
        shopId: 'cvece_lotos',
        imageUrl: 'https://images.unsplash.com/photo-1525310072745-f49212b5ac6d?auto=format&fit=crop&w=800&q=80',
        category: 'Sobno cveće',
        description: 'Bela orhideja sa dve cvetne grane u dekorativnoj keramičkoj saksiji. Dugotrajno cvetanje od čak 3 meseca.',
        inStock: true,
        featured: true,
      ),
      const Product(
        id: 'p4',
        title: 'Prolećni Buket Božura i Eustoma',
        price: 3800.0,
        careInstructions: 'Držati na hladnijem mestu noću. Dodati priloženu hranu za cveće u vodu radi dužeg trajanja pupoljaka.',
        shopId: 'cvece_dunavski',
        imageUrl: 'https://images.unsplash.com/photo-1561181286-d3fee7d55364?auto=format&fit=crop&w=800&q=80',
        category: 'Buketi',
        description: 'Nežna pastelna kombinacija roze božura, bele eustome i grana lavande u craft papiru.',
        inStock: true,
        featured: false,
      ),
      const Product(
        id: 'p5',
        title: 'Keramički Mix Sukulenata',
        price: 1950.0,
        careInstructions: 'Izuzetno malo vode: zaliti tek jednom u 2 do 3 nedelje. Traži što više direktnog sunčevog svetla.',
        shopId: 'cvece_botanika',
        imageUrl: 'https://images.unsplash.com/photo-1446071103084-c257b5f70672?auto=format&fit=crop&w=800&q=80',
        category: 'Sukulenti',
        description: 'Harmoničan aranžman od 4 vrste mini sukulenata u ručno rađenoj beloj keramičkoj posudi.',
        inStock: true,
        featured: false,
      ),
      const Product(
        id: 'p6',
        title: 'Buket Orijentalnih Ljiljana',
        price: 3600.0,
        careInstructions: 'Pažljivo odstraniti prašnike kada se cvetovi otvore kako biste sprečili fleke i produžili trajnost cveta.',
        shopId: 'cvece_dunavski',
        imageUrl: 'https://images.unsplash.com/photo-1589244159943-460088ed5c92?auto=format&fit=crop&w=800&q=80',
        category: 'Buketi',
        description: 'Mirisni beli orijentalni ljiljani u kombinaciji sa ukrasnim gipsofilama.',
        inStock: true,
        featured: false,
      ),
      const Product(
        id: 'p7',
        title: 'Ficus Lyrata (Lirasti Fikus)',
        price: 4900.0,
        careInstructions: 'Držati na konstantnoj temperaturi bez promaje. Umereno zalivati stajaćom vodom sobne temperature.',
        shopId: 'cvece_botanika',
        imageUrl: 'https://images.unsplash.com/photo-1598880940371-c756e015fea1?auto=format&fit=crop&w=800&q=80',
        category: 'Sobno cveće',
        description: 'Veliko drvo fikusa sa krupnim listovima u obliku violine, visine cca 90cm.',
        inStock: true,
        featured: true,
      ),
    ];
  }

  Map<String, UserProfile> _initialUsers() {
    return {
      'admin_user': const UserProfile(
        userId: 'admin_user',
        email: 'admin@floramarket.rs',
        fullName: 'Atina Vučković (Administrator)',
        phone: '+381 64 123 4567',
        address: 'Trg Dositeja Obradovića 6',
        city: 'Novi Sad',
        role: 'admin',
        wishlist: ['p1', 'p2'],
      ),
      'buyer_user': const UserProfile(
        userId: 'buyer_user',
        email: 'kupac@floramarket.rs',
        fullName: 'Marko Petrović',
        phone: '+381 60 987 6543',
        address: 'Bulevar Oslobođenja 102',
        city: 'Novi Sad',
        role: 'user',
        wishlist: ['p2', 'p3'],
      ),
    };
  }
}

