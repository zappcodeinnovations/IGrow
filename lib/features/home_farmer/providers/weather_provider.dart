import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/weather_service.dart';
import '../../auth/providers/auth_provider.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService.instance);

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherData>> {
  WeatherNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final WeatherService _service;
  final Ref _ref;

  Future<void> _initialize() async {
    // 1. Immediately present cached weather if available for zero-lag display
    final cached = await _service.getCachedWeather();
    if (cached != null && mounted) {
      state = AsyncValue.data(cached);
    }

    // 2. Refresh live weather from real-time coordinates in background
    await refresh();
  }

  Future<void> refresh() async {
    final user = _ref.read(authProvider).user;
    final preferredCity = (user?.locationDistrict != null && user!.locationDistrict!.trim().isNotEmpty)
        ? user.locationDistrict!
        : (user?.locationState != null && user!.locationState!.trim().isNotEmpty)
            ? user.locationState!
            : (user?.location != null && user!.location!.trim().isNotEmpty)
                ? user.location!
                : null;

    try {
      final weather = await _service.fetchWeather(preferredCity: preferredCity);
      if (mounted) {
        state = AsyncValue.data(weather);
      }
    } catch (e, st) {
      // If cached data already exists, retain it gracefully
      if (state.hasValue && mounted) {
        return;
      }
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherData>>((ref) {
  final service = ref.watch(weatherServiceProvider);
  return WeatherNotifier(service, ref);
});
