import 'package:flutter_test/flutter_test.dart';
import 'package:flowermarket/models/product.dart';
import 'package:flowermarket/models/cart_item.dart';
import 'package:flowermarket/models/weather_data.dart';
import 'package:flowermarket/providers/cart_provider.dart';

void main() {
  group('FloraMarket Unit Tests', () {
    test('CartProvider calculates subtotal and free delivery threshold correctly', () {
      final cart = CartProvider();
      const product1 = Product(
        id: 'p1',
        title: 'Crvene Ruže',
        price: 2000.0,
        careInstructions: 'Zalivati umereno',
        shopId: 'shop1',
        imageUrl: 'https://example.com/flower.jpg',
      );

      // Add 1 item
      cart.addItem(product1);
      expect(cart.itemCount, 1);
      expect(cart.subtotal, 2000.0);
      expect(cart.deliveryFee, 350.0); // Standard delivery below 4000
      expect(cart.totalAmount, 2350.0);

      // Add another item - triggers free delivery threshold >= 4000
      cart.addItem(product1);
      expect(cart.itemCount, 2);
      expect(cart.subtotal, 4000.0);
      expect(cart.deliveryFee, 0.0); // Free delivery
      expect(cart.totalAmount, 4000.0);

      // Update quantity
      cart.updateQuantity('p1', 3);
      expect(cart.subtotal, 6000.0);

      // Remove item
      cart.removeItem('p1');
      expect(cart.isEmpty, true);
      expect(cart.totalAmount, 0.0);
    });

    test('WeatherData dynamically generates plant care advice based on temperature', () {
      final hotWeather = WeatherData.fallback(temp: 33.0, humidity: 40);
      expect(hotWeather.plantCareTip.contains('Sobne biljke zahtevaju više vlage'), true);

      final coldWeather = WeatherData.fallback(temp: 8.0, humidity: 60);
      expect(coldWeather.plantCareTip.contains('Unesite osetljive sobne biljke'), true);

      final dryWeather = WeatherData.fallback(temp: 22.0, humidity: 30);
      expect(dryWeather.plantCareTip.contains('Vlažnost vazduha je niska'), true);
    });
  });
}

