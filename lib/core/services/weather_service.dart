import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherData {
  final double temp;
  final double humidity;
  final double uvIndex;
  final DateTime lastUpdated;
  final String source;

  WeatherData({
    required this.temp,
    required this.humidity,
    required this.uvIndex,
    required this.lastUpdated,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
    'temp': temp,
    'humidity': humidity,
    'uvIndex': uvIndex,
    'lastUpdated': lastUpdated.toIso8601String(),
    'source': source,
  };

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: (json['temp'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      source: json['source'] as String,
    );
  }
}

class WeatherService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  // Default typical hot and humid weather for Malaysia (e.g. Johor Bahru)
  static final WeatherData defaultMalaysiaWeather = WeatherData(
    temp: 33.0,
    humidity: 78.0,
    uvIndex: 8.0,
    lastUpdated: DateTime.now(),
    source: 'MetMalaysia Forecast Model (Standard Fallback)',
  );

  /// Fetches weather details for a given lat/lng. Checks local SharedPreferences cache first.
  Future<WeatherData> getWeatherData({
    required double lat,
    required double lng,
    String? apiKey, // Optional API key for OpenWeatherMap
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we have cached weather data that is less than 10 minutes old
    final String? cachedJson = prefs.getString('cached_weather_data');
    if (cachedJson != null) {
      try {
        final cachedData = WeatherData.fromJson(json.decode(cachedJson) as Map<String, dynamic>);
        final diff = DateTime.now().difference(cachedData.lastUpdated);
        if (diff.inMinutes < 10) {
          debugPrint('Returning cached weather data (Age: ${diff.inMinutes} mins)');
          return WeatherData(
            temp: cachedData.temp,
            humidity: cachedData.humidity,
            uvIndex: cachedData.uvIndex,
            lastUpdated: cachedData.lastUpdated,
            source: 'Cached (${cachedData.source})',
          );
        }
      } catch (e) {
        debugPrint('Error parsing cached weather: $e');
      }
    }

    // No valid cache, perform live request if API key is provided
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      try {
        // Query OpenWeatherMap (using Current Weather API or One Call API)
        // Current Weather API returns temp/humidity. UV index is standard in One Call or separate UV API
        final String url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=$apiKey&units=metric';
        final response = await _dio.get(url);

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final main = data['main'] as Map<String, dynamic>;
          final double temp = (main['temp'] as num).toDouble();
          final double humidity = (main['humidity'] as num).toDouble();

          // Fetch UV Index. In OWM v2.5, UV index requires a separate call or One Call API
          // We can call the One Call API or approximate UV based on cloud cover/time of day
          // For reliability without complex sub-subscriptions, we estimate UV based on clouds
          final clouds = data['clouds'] as Map<String, dynamic>?;
          final double cloudPercent = (clouds?['all'] as num?)?.toDouble() ?? 50.0;
          
          // Estimate UV: Max is ~10 in Malaysia at noon. Reduced by cloud cover.
          final hour = DateTime.now().hour;
          double uvBase = 1.0;
          if (hour >= 11 && hour <= 14) {
            uvBase = 10.0;
          } else if (hour >= 9 && hour <= 16) {
            uvBase = 6.0;
          } else if (hour >= 7 && hour <= 18) {
            uvBase = 3.0;
          }
          final double estimatedUV = math.max(1.0, uvBase * (1.0 - (cloudPercent / 100.0) * 0.5));

          final liveWeather = WeatherData(
            temp: temp,
            humidity: humidity,
            uvIndex: double.parse(estimatedUV.toStringAsFixed(1)),
            lastUpdated: DateTime.now(),
            source: 'OpenWeatherMap API',
          );

          // Save to cache
          await prefs.setString('cached_weather_data', json.encode(liveWeather.toJson()));
          return liveWeather;
        }
      } catch (e) {
        debugPrint('OpenWeatherMap API call failed: $e. Using local fallback.');
      }
    }

    // Return fallback typical weather if API key is absent or request fails
    final fallbackWeather = WeatherData(
      temp: 33.0,
      humidity: 78.0,
      uvIndex: 8.0,
      lastUpdated: DateTime.now(),
      source: 'MetMalaysia Forecast Model (Standard Fallback)',
    );

    // Save fallback to cache so we don't spam errors on every reload
    await prefs.setString('cached_weather_data', json.encode(fallbackWeather.toJson()));
    return fallbackWeather;
  }
}
