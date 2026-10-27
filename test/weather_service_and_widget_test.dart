import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:krushi_siksha/core/services/weather_service.dart';
import 'package:krushi_siksha/data/models/user_model.dart';
import 'package:krushi_siksha/data/models/user_role.dart';
import 'package:krushi_siksha/features/auth/providers/auth_provider.dart';
import 'package:krushi_siksha/features/home_farmer/providers/weather_provider.dart';
import 'package:krushi_siksha/features/home_farmer/screens/farmer_home_screen.dart';

void main() {
  group('WeatherData Model Tests', () {
    test('WeatherData serializes and deserializes correctly', () {
      final now = DateTime.now();
      final data = WeatherData(
        temperature: 27.4,
        locationName: 'Nashik',
        weatherCode: 0,
        isDay: true,
        fetchedAt: now,
      );

      final json = data.toJson();
      expect(json['temperature'], 27.4);
      expect(json['locationName'], 'Nashik');
      expect(json['weatherCode'], 0);
      expect(json['isDay'], true);

      final parsed = WeatherData.fromJson(json);
      expect(parsed.temperature, 27.4);
      expect(parsed.temperatureFormatted, '27°C');
      expect(parsed.locationName, 'Nashik');
      expect(parsed.weatherCode, 0);
      expect(parsed.isDay, true);
    });

    test('WeatherData maps weatherCode to appropriate Weather Icons', () {
      // Sunny / clear day
      final sunnyDay = WeatherData(
        temperature: 30,
        locationName: 'Pune',
        weatherCode: 0,
        isDay: true,
        fetchedAt: DateTime.now(),
      );
      expect(sunnyDay.weatherIcon, Icons.wb_sunny_rounded);

      // Clear night
      final clearNight = WeatherData(
        temperature: 20,
        locationName: 'Pune',
        weatherCode: 0,
        isDay: false,
        fetchedAt: DateTime.now(),
      );
      expect(clearNight.weatherIcon, Icons.nightlight_round);

      // Rain / drizzle
      final rainy = WeatherData(
        temperature: 22,
        locationName: 'Kolhapur',
        weatherCode: 61,
        isDay: true,
        fetchedAt: DateTime.now(),
      );
      expect(rainy.weatherIcon, Icons.grain_rounded);

      // Thunderstorm
      final storm = WeatherData(
        temperature: 24,
        locationName: 'Nagpur',
        weatherCode: 95,
        isDay: true,
        fetchedAt: DateTime.now(),
      );
      expect(storm.weatherIcon, Icons.thunderstorm_rounded);
    });
  });

  group('WeatherService Unit Tests', () {
    test('WeatherService parses Open-Meteo API response accurately', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host.contains('open-meteo.com')) {
          return http.Response(
            jsonEncode({
              'current_weather': {
                'temperature': 26.8,
                'weathercode': 1,
                'is_day': 1,
                'windspeed': 12.0,
              }
            }),
            200,
          );
        }
        return http.Response('{}', 404);
      });

      final service = WeatherService(httpClient: mockClient);
      final weather = await service.fetchWeather(preferredCity: 'Aurangabad');

      expect(weather.temperature, 26.8);
      expect(weather.temperatureFormatted, '27°C');
      expect(weather.locationName, 'Aurangabad');
      expect(weather.weatherCode, 1);
      expect(weather.isDay, true);
    });
  });

  group('FarmerHomeScreen Weather Chip Widget Tests', () {
    testWidgets('Dashboard renders live weather data from WeatherProvider', (tester) async {
      const mockUser = UserModel(
        id: 'farmer-1',
        email: 'farmer@agrilearn.com',
        fullName: 'Ramesh Patil',
        phone: '+919876543210',
        activeRole: UserRole.farmer,
        grantedRoles: [UserRole.farmer],
        locationDistrict: 'Nashik',
      );

      final mockWeatherData = WeatherData(
        temperature: 25.0,
        locationName: 'Nashik',
        weatherCode: 0,
        isDay: true,
        fetchedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier(mockUser)),
            weatherProvider.overrideWith((ref) => MockWeatherNotifier(AsyncValue.data(mockWeatherData))),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FarmerHomeScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check for user's greeting with firstName
      expect(find.text('Ramesh'), findsOneWidget);

      // Check that Weather Chip renders dynamic temperature and location
      expect(find.textContaining('25°C Nashik'), findsOneWidget);
    });
  });
}

class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier(UserModel user)
      : super(AuthState(status: AuthStatus.authenticated, user: user));

  @override
  Future<UserModel?> refreshUserSilent() async => state.user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWeatherNotifier extends StateNotifier<AsyncValue<WeatherData>> implements WeatherNotifier {
  MockWeatherNotifier(AsyncValue<WeatherData> initial) : super(initial);

  @override
  Future<void> refresh() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
