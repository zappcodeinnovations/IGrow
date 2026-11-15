import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../data/models/discount_banner_model.dart';

final discountBannerProvider = StateNotifierProvider<DiscountBannerNotifier, AsyncValue<DiscountBannerModel?>>((ref) {
  return DiscountBannerNotifier();
});

class DiscountBannerNotifier extends StateNotifier<AsyncValue<DiscountBannerModel?>> {
  DiscountBannerNotifier() : super(const AsyncValue.loading()) {
    fetchActiveBanner();
  }

  static const String _dismissedPrefix = 'iagrow_offer_dismissed_';

  Future<void> fetchActiveBanner() async {
    try {
      final response = await http.get(
        Uri.parse('https://iagrow.zappcode.in/api/v1/support/app-config/'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final rawBanners = data['active_discount_banner'] ?? data['activeDiscountBanner'];

        if (rawBanners is List && rawBanners.isNotEmpty) {
          final activeList = rawBanners
              .map((b) => DiscountBannerModel.fromJson(b as Map<String, dynamic>))
              .where((b) => b.active)
              .toList();

          if (activeList.isNotEmpty) {
            final latest = activeList.last;
            final prefs = await SharedPreferences.getInstance();
            final isDismissed = prefs.getBool('$_dismissedPrefix${latest.id}') ?? false;

            if (!isDismissed) {
              state = AsyncValue.data(latest);
              return;
            }
          }
        }
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> dismissBanner(String bannerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_dismissedPrefix$bannerId', true);
    state = const AsyncValue.data(null);
  }
}
