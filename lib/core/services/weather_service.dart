import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Represents real-time weather data for the user's location.
class WeatherData {
  final double temperature;
  final String locationName;
  final int weatherCode;
  final bool isDay;
  final DateTime fetchedAt;

  const WeatherData({
    required this.temperature,
    required this.locationName,
    required this.weatherCode,
    this.isDay = true,
    required this.fetchedAt,
  });

  String get temperatureFormatted => '${temperature.round()}°C';

  IconData get weatherIcon {
    if (weatherCode == 0) {
      return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    } else if (weatherCode >= 1 && weatherCode <= 3) {
      return isDay ? Icons.cloud_queue_rounded : Icons.nights_stay_rounded;
    } else if (weatherCode >= 45 && weatherCode <= 48) {
      return Icons.cloud_outlined; // Fog
    } else if (weatherCode >= 51 && weatherCode <= 67) {
      return Icons.grain_rounded; // Drizzle / Rain
    } else if (weatherCode >= 71 && weatherCode <= 77) {
      return Icons.ac_unit_rounded; // Snow
    } else if (weatherCode >= 80 && weatherCode <= 82) {
      return Icons.water_drop_rounded; // Showers
    } else if (weatherCode >= 95 && weatherCode <= 99) {
      return Icons.thunderstorm_rounded; // Thunderstorm
    }
    return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'locationName': locationName,
        'weatherCode': weatherCode,
        'isDay': isDay,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        temperature: (json['temperature'] as num).toDouble(),
        locationName: json['locationName'] as String,
        weatherCode: (json['weatherCode'] as num).toInt(),
        isDay: json['isDay'] as bool? ?? true,
        fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Service to fetch real-time device geolocation coordinates and live weather data.
class WeatherService {
  WeatherService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  static final WeatherService instance = WeatherService();

  final http.Client _httpClient;

  static const String _prefKeyWeather = 'cached_weather_v1';

  /// Default coordinates for India / Maharashtra agricultural region fallback (Pune)
  static const double defaultLat = 18.5204;
  static const double defaultLon = 73.8567;
  static const String defaultCity = 'Pune';

  /// Fetches real-time weather using device GPS, fallback IP geolocation, and Open-Meteo API.
  Future<WeatherData> fetchWeather({String? preferredCity}) async {
    double lat = defaultLat;
    double lon = defaultLon;
    String city = preferredCity?.trim().isNotEmpty == true ? preferredCity!.trim() : defaultCity;

    bool foundCoords = false;

    // 1. Attempt device GPS coordinate acquisition (if permitted)
    try {
      final gpsPos = await _getDevicePosition();
      if (gpsPos != null) {
        lat = gpsPos.latitude;
        lon = gpsPos.longitude;
        foundCoords = true;

        // Reverse-geocode to get actual city name from coordinates
        final resolvedCity = await _reverseGeocode(lat, lon);
        if (resolvedCity != null && resolvedCity.isNotEmpty) {
          city = resolvedCity;
        }
      }
    } catch (e) {
      debugPrint('ℹ️ [WeatherService] GPS resolution skipped: $e');
    }

    // 2. If GPS coordinates were not obtained, use IP Geolocation
    if (!foundCoords) {
      try {
        final ipGeo = await _fetchIpGeolocation();
        if (ipGeo != null) {
          lat = ipGeo['lat'] as double;
          lon = ipGeo['lon'] as double;
          if (ipGeo['city'] != null && (ipGeo['city'] as String).isNotEmpty) {
            city = ipGeo['city'] as String;
          }
          foundCoords = true;
        }
      } catch (e) {
        debugPrint('ℹ️ [WeatherService] IP Geolocation fallback skipped: $e');
      }
    }

    // 3. Fetch real-time weather from Open-Meteo API
    final weather = await _fetchOpenMeteoWeather(lat: lat, lon: lon, city: city);

    // Cache the latest successful result
    await cacheWeather(weather);

    return weather;
  }

  /// Queries real-time Open-Meteo weather for coordinates
  Future<WeatherData> _fetchOpenMeteoWeather({
    required double lat,
    required double lon,
    required String city,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true',
    );

    final res = await _httpClient.get(uri).timeout(const Duration(seconds: 6));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final current = json['current_weather'] as Map<String, dynamic>;

      return WeatherData(
        temperature: (current['temperature'] as num).toDouble(),
        locationName: city,
        weatherCode: (current['weathercode'] as num).toInt(),
        isDay: (current['is_day'] as num?)?.toInt() == 1,
        fetchedAt: DateTime.now(),
      );
    } else {
      throw Exception('Open-Meteo returned status ${res.statusCode}');
    }
  }

  /// Gets device position using Geolocator if permissions allow
  Future<Position?> _getDevicePosition() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 4),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Reverse geocodes coordinates to a clean human-readable city/locality name
  Future<String?> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en',
      );
      final res = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final city = (data['city'] as String?)?.trim();
        if (city != null && city.isNotEmpty) return city;

        final locality = (data['locality'] as String?)?.trim();
        if (locality != null && locality.isNotEmpty) return locality;

        final subdivision = (data['principalSubdivision'] as String?)?.trim();
        if (subdivision != null && subdivision.isNotEmpty) return subdivision;
      }
    } catch (_) {}
    return null;
  }

  /// IP-based geolocation fallback (requires no device permissions)
  Future<Map<String, dynamic>?> _fetchIpGeolocation() async {
    try {
      final uri = Uri.parse('http://ip-api.com/json');
      final res = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] == 'success') {
          return {
            'lat': (data['lat'] as num).toDouble(),
            'lon': (data['lon'] as num).toDouble(),
            'city': data['city'] as String?,
          };
        }
      }
    } catch (_) {}
    return null;
  }

  /// Retrieves locally cached weather data for instant display without network lag
  Future<WeatherData?> getCachedWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKeyWeather);
      if (raw != null && raw.isNotEmpty) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return WeatherData.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  /// Saves weather data to local cache
  Future<void> cacheWeather(WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyWeather, jsonEncode(data.toJson()));
    } catch (_) {}
  }
}
