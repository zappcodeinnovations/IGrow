import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../network/swagger_generated/app_api.swagger.dart';
import '../../data/models/user_model.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Service that auto-detects user's City and State in the background
/// (via GPS reverse geocoding or IP geolocation) and updates their profile
/// silently without any user disruption.
class AutoLocationService {
  AutoLocationService._();
  static final AutoLocationService instance = AutoLocationService._();

  final http.Client _httpClient = http.Client();
  bool _isResolving = false;

  /// Checks if the user is missing state or district/city, and if so,
  /// fetches it from device GPS or IP and patches their profile.
  Future<void> resolveAndSyncLocation(
    AuthNotifier authNotifier,
    UserModel? user,
  ) async {
    if (user == null) return;
    if (_isResolving) return;

    final hasState = user.locationState != null && user.locationState!.trim().isNotEmpty;
    final hasDistrict = user.locationDistrict != null && user.locationDistrict!.trim().isNotEmpty;

    // If both state and district/location are already filled, no need to auto-fetch
    if (hasState && hasDistrict) {
      return;
    }

    _isResolving = true;
    debugPrint('📍 [AutoLocationService] User profile missing location. Auto-fetching in background...');

    try {
      final locData = await _detectCityAndState();
      if (locData != null) {
        final state = locData.state;
        final city = locData.city;

        debugPrint('📍 [AutoLocationService] Detected Location: City="$city", State="$state"');

        final String? newState = !hasState && state != null && state.isNotEmpty ? state : null;
        final String? newDistrict = !hasDistrict && city != null && city.isNotEmpty ? city : null;

        if (newState != null || newDistrict != null) {
          final request = PatchedUserProfileRequest(
            locationState: newState ?? user.locationState,
            locationDistrict: newDistrict ?? user.locationDistrict,
          );

          await authNotifier.updateProfile(request);
          debugPrint('✅ [AutoLocationService] Profile silently updated with auto-fetched location.');
        }
      }
    } catch (e) {
      debugPrint('ℹ️ [AutoLocationService] Background location sync skipped: $e');
    } finally {
      _isResolving = false;
    }
  }

  Future<({String? city, String? state})?> _detectCityAndState() async {
    // 1. Attempt GPS first if permission is already granted or available
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (isEnabled) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 5),
            ),
          );
          final gpsResult = await _reverseGeocode(pos.latitude, pos.longitude);
          if (gpsResult != null) {
            return gpsResult;
          }
        }
      }
    } catch (_) {}

    // 2. Fallback to HTTPS IP Geolocation (zero permission prompt needed)
    return await _fetchIpLocation();
  }

  Future<({String? city, String? state})?> _reverseGeocode(
    double lat,
    double lon,
  ) async {
    try {
      final uri = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en',
      );
      final res = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final city = (data['city'] as String?)?.trim() ??
            (data['locality'] as String?)?.trim();
        final state = (data['principalSubdivision'] as String?)?.trim();
        return (city: city, state: state);
      }
    } catch (_) {}
    return null;
  }

  Future<({String? city, String? state})?> _fetchIpLocation() async {
    // 1. ipapi.co
    try {
      final uri = Uri.parse('https://ipapi.co/json/');
      final res = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final city = (data['city'] as String?)?.trim();
        final state = (data['region'] as String?)?.trim();
        if ((city != null && city.isNotEmpty) || (state != null && state.isNotEmpty)) {
          return (city: city, state: state);
        }
      }
    } catch (_) {}

    // 2. freeipapi.com
    try {
      final uri = Uri.parse('https://freeipapi.com/api/json');
      final res = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final city = (data['cityName'] as String?)?.trim();
        final state = (data['regionName'] as String?)?.trim();
        if ((city != null && city.isNotEmpty) || (state != null && state.isNotEmpty)) {
          return (city: city, state: state);
        }
      }
    } catch (_) {}

    return null;
  }
}
