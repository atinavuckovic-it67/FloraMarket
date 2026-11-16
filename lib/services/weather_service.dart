import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/weather_data.dart';

class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherData> fetchWeather({String city = AppConstants.defaultCity}) async {
    final apiKey = AppConstants.openWeatherApiKey;

    // Check if user has set a real API key
    if (apiKey != 'YOUR_OPENWEATHER_API_KEY_HERE' && apiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&lang=sr&appid=$apiKey',
        );
        final response = await _client.get(url).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return WeatherData.fromJson(data);
        }
      } catch (e) {
        // Fallback on connection error
      }
    }

    // Dynamic realistic simulation for demonstration purposes:
    // Weather fluctuates realistically based on current hour to showcase the dynamic widget
    final currentHour = DateTime.now().hour;
    double dynamicTemp = 24.0;
    int dynamicHumidity = 55;

    if (currentHour >= 12 && currentHour <= 16) {
      dynamicTemp = 32.0; // Hot afternoon - triggers summer hydration tip
      dynamicHumidity = 42;
    } else if (currentHour >= 20 || currentHour <= 6) {
      dynamicTemp = 14.0; // Cool night/morning
      dynamicHumidity = 78;
    } else {
      dynamicTemp = 23.5;
      dynamicHumidity = 50;
    }

    return WeatherData.fallback(
      temp: dynamicTemp,
      humidity: dynamicHumidity,
    );
  }
}

