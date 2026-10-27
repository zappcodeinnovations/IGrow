import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_provider.dart';

/// App Feature Flags for App Store review compliance and remote switches.
class AppFeatureFlags {
  final bool enablePaymentGateway; // 1 = show Razorpay/payments, 0 = hide
  final bool enableCoupons;        // 1 = show coupons, 0 = hide

  const AppFeatureFlags({
    this.enablePaymentGateway = true,
    this.enableCoupons = true,
  });

  factory AppFeatureFlags.fromJson(Map<String, dynamic> json) {
    // Supports boolean or 0/1 integer flags
    final paymentVal = json['enable_payment_gateway'] ?? json['show_payments'] ?? json['payment_enabled'] ?? json['status'];
    final couponVal = json['enable_coupons'] ?? json['show_coupons'] ?? json['coupon_enabled'];

    bool parseFlag(dynamic val, {bool defaultValue = true}) {
      if (val == null) return defaultValue;
      if (val is bool) return val;
      if (val is num) return val != 0;
      if (val is String) {
        final s = val.trim().toLowerCase();
        if (s == '0' || s == 'false' || s == 'disabled' || s == 'hide') return false;
        if (s == '1' || s == 'true' || s == 'enabled' || s == 'show') return true;
      }
      return defaultValue;
    }

    return AppFeatureFlags(
      enablePaymentGateway: parseFlag(paymentVal, defaultValue: true),
      enableCoupons: parseFlag(couponVal, defaultValue: true),
    );
  }
}

class AppFeatureFlagsNotifier extends StateNotifier<AppFeatureFlags> {
  AppFeatureFlagsNotifier(this._prefs) : super(const AppFeatureFlags()) {
    _loadCachedFlags();
    fetchRemoteFlags();
  }

  final SharedPreferences _prefs;
  static const _cacheKey = 'app_feature_flags_cache';

  void _loadCachedFlags() {
    final cached = _prefs.getString(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        state = AppFeatureFlags.fromJson(map);
      } catch (_) {}
    }
  }

  /// Fetches the switch configuration from backend.
  /// If your backend provides an endpoint (e.g. `/api/app-config/` or `/api/flags/`),
  /// it will read the flags. Defaults safely to active state if offline.
  Future<void> fetchRemoteFlags() async {
    try {
      final url = Uri.parse('https://iagrow.zappcode.in/api/app-config/');
      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          state = AppFeatureFlags.fromJson(data);
          await _prefs.setString(_cacheKey, jsonEncode(data));
        }
      }
    } catch (e) {
      debugPrint('ℹ️ [AppFeatureFlags] Using default/cached flags ($e)');
    }
  }

  void updateManually({bool? enablePaymentGateway, bool? enableCoupons}) {
    state = AppFeatureFlags(
      enablePaymentGateway: enablePaymentGateway ?? state.enablePaymentGateway,
      enableCoupons: enableCoupons ?? state.enableCoupons,
    );
  }
}

/// Global provider for remote app feature switches (Payment Gateway & Coupon visibility).
final appFeatureFlagsProvider = StateNotifierProvider<AppFeatureFlagsNotifier, AppFeatureFlags>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppFeatureFlagsNotifier(prefs);
});
