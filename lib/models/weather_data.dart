class WeatherData {
  final double temperature;
  final int humidity;
  final String condition;
  final String description;
  final String icon;
  final String cityName;
  final String plantCareTip;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.description,
    required this.icon,
    required this.cityName,
    required this.plantCareTip,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    final firstWeather = weatherList.isNotEmpty ? weatherList[0] : {};

    final temp = (main['temp'] is num) ? (main['temp'] as num).toDouble() : 22.0;
    final hum = (main['humidity'] is num) ? (main['humidity'] as num).toInt() : 50;
    final cond = firstWeather['main'] ?? 'Clear';
    final desc = firstWeather['description'] ?? 'vedro vreme';
    final iconCode = firstWeather['icon'] ?? '01d';
    final city = json['name'] ?? 'Novi Sad';

    final tip = _generateCareTip(temp, hum, cond);

    return WeatherData(
      temperature: temp,
      humidity: hum,
      condition: cond,
      description: desc,
      icon: iconCode,
      cityName: city,
      plantCareTip: tip,
    );
  }

  static String _generateCareTip(double temp, int humidity, String condition) {
    if (temp >= 28) {
      return 'Trenutno je ${temp.toStringAsFixed(0)}°C. Sobne biljke zahtevaju više vlage (orošavanje listova), a buketima u vazi češće menjajte vodu i držite ih van direktnog sunca.';
    } else if (temp <= 10) {
      return 'Temperatura je ${temp.toStringAsFixed(0)}°C. Unesite osetljive sobne biljke dalje od hladnih prozora i promaje, a zalivanje svedite na minimum.';
    } else if (humidity < 40) {
      return 'Vlažnost vazduha je niska (${humidity}%). Tropske biljke poput Monstere i Fikusa zahtevaju redovno orošavanje listova stajaćom vodom.';
    } else if (humidity > 75) {
      return 'Visoka vlažnost vazduha (${humidity}%). Pripazite na korenski sistem biljaka i izbegavajte prekomerno zalivanje da ne bi došlo do truljenja.';
    } else {
      return 'Optimalni uslovi: ${temp.toStringAsFixed(0)}°C uz vlažnost od ${humidity}%. Idealan trenutak za prihranu cveća i umereno zalivanje jutarnjim časovima.';
    }
  }

  factory WeatherData.fallback({double temp = 24.0, int humidity = 55}) {
    return WeatherData(
      temperature: temp,
      humidity: humidity,
      condition: 'Clear',
      description: 'Prijatno i sunčano',
      icon: '01d',
      cityName: 'Novi Sad',
      plantCareTip: _generateCareTip(temp, humidity, 'Clear'),
    );
  }
}

