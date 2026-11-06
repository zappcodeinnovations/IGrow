import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AppConfig {
  final bool enablePaymentGateway;
  final bool enableCoupons;
  final bool showPayments;
  final bool showCoupons;
  final bool enableAppleIap;
  final bool showAppleIap;

  const AppConfig({
    required this.enablePaymentGateway,
    required this.enableCoupons,
    required this.showPayments,
    required this.showCoupons,
    this.enableAppleIap = false,
    this.showAppleIap = false,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
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

    final dynamic paymentVal = json['enable_payment_gateway'] ??
        json['show_payments'] ??
        json['payment_enabled'] ??
        json['status'];
    final dynamic couponVal = json['enable_coupons'] ??
        json['show_coupons'] ??
        json['coupon_enabled'];
    final dynamic appleIapVal = json['enable_apple_iap'] ??
        json['show_apple_iap'] ??
        json['apple_iap_enabled'];

    final bool enablePayment = parseFlag(paymentVal, defaultValue: true);
    final bool enableCoupon = parseFlag(couponVal, defaultValue: true);
    final bool enableAppleIap = parseFlag(appleIapVal, defaultValue: false);

    return AppConfig(
      enablePaymentGateway: enablePayment,
      enableCoupons: enableCoupon,
      showPayments: parseFlag(json['show_payments'], defaultValue: enablePayment),
      showCoupons: parseFlag(json['show_coupons'], defaultValue: enableCoupon),
      enableAppleIap: enableAppleIap,
      showAppleIap: parseFlag(json['show_apple_iap'], defaultValue: enableAppleIap),
    );
  }

  /// Default configuration for platform.
  /// On Android, web, and other non-iOS platforms, always returns true.
  /// On iOS, defaults to false if not yet fetched.
  factory AppConfig.defaultForPlatform() {
    final isIos = !kIsWeb && Platform.isIOS;
    return AppConfig(
      enablePaymentGateway: !isIos,
      enableCoupons: !isIos,
      showPayments: !isIos,
      showCoupons: !isIos,
      enableAppleIap: isIos,
      showAppleIap: isIos,
    );
  }

  /// Helper to check if Razorpay payment gateway should be displayed.
  /// On Android/Web, this ALWAYS returns true.
  /// On iOS, it respects the remote feature flag.
  bool get canShowPaymentGateway {
    if (!kIsWeb && !Platform.isIOS) {
      return true;
    }
    return enablePaymentGateway && showPayments;
  }

  /// Helper to check if Apple Pay / In-App Purchase is active.
  /// Only applies on iOS when Razorpay is disabled during App Store review.
  bool get isApplePayActive {
    if (kIsWeb || !Platform.isIOS) {
      return false;
    }
    return !canShowPaymentGateway && (enableAppleIap || showAppleIap);
  }

  /// Helper to check if instructor can input any custom course price.
  /// When Razorpay is enabled (and Apple Pay disabled), custom price input is allowed.
  /// If Apple IAP is enforced (during review), fixed price tier dropdown is shown.
  bool get allowsCustomCoursePrice {
    return !isApplePayActive;
  }

  /// Helper to check if coupon field should be displayed.
  /// On Android/Web, this ALWAYS returns true.
  /// On iOS, it respects the remote feature flag.
  bool get canShowCoupons {
    if (!kIsWeb && !Platform.isIOS) {
      return true;
    }
    return enableCoupons && showCoupons;
  }
}

class AppConfigService {
  static const String endpoint = 'https://iagrow.zappcode.in/api/app-config/';
  static const Duration timeout = Duration(seconds: 4);

  static Future<AppConfig> fetchConfig({http.Client? client}) async {
    try {
      final httpClient = client ?? http.Client();
      final response = await httpClient
          .get(
            Uri.parse(endpoint),
            headers: {'Accept': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final config = AppConfig.fromJson(decoded);
        debugPrint(
          '⚙️ [AppConfigService] Loaded: paymentGateway=${config.enablePaymentGateway}, coupons=${config.enableCoupons}',
        );
        return config;
      } else {
        debugPrint(
          '⚠️ [AppConfigService] Unexpected response (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('⚠️ [AppConfigService] Failed to fetch app config: $e');
    }
    return AppConfig.defaultForPlatform();
  }
}

class AppConfigNotifier extends StateNotifier<AppConfig> {
  AppConfigNotifier() : super(AppConfig.defaultForPlatform());

  Future<void> loadConfig() async {
    final config = await AppConfigService.fetchConfig();
    state = config;
  }
}

final appConfigProvider =
    StateNotifierProvider<AppConfigNotifier, AppConfig>((ref) {
  return AppConfigNotifier();
});
