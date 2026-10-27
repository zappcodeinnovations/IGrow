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

  const AppConfig({
    required this.enablePaymentGateway,
    required this.enableCoupons,
    required this.showPayments,
    required this.showCoupons,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final bool enablePayment = (json['enable_payment_gateway'] ??
            json['show_payments'] ??
            json['payment_enabled'] ??
            false) as bool;
    final bool enableCoupon = (json['enable_coupons'] ??
            json['show_coupons'] ??
            json['coupon_enabled'] ??
            false) as bool;

    return AppConfig(
      enablePaymentGateway: enablePayment,
      enableCoupons: enableCoupon,
      showPayments: (json['show_payments'] ?? enablePayment) as bool,
      showCoupons: (json['show_coupons'] ?? enableCoupon) as bool,
    );
  }

  /// Safe default for iOS during review: false; true for others.
  factory AppConfig.defaultForPlatform() {
    final isIos = !kIsWeb && Platform.isIOS;
    return AppConfig(
      enablePaymentGateway: !isIos,
      enableCoupons: !isIos,
      showPayments: !isIos,
      showCoupons: !isIos,
    );
  }

  /// Helper to check if payment gateway should be displayed
  bool get canShowPaymentGateway {
    if (!kIsWeb && Platform.isIOS) {
      return enablePaymentGateway && showPayments;
    }
    return enablePaymentGateway;
  }

  /// Helper to check if coupon field should be displayed
  bool get canShowCoupons {
    if (!kIsWeb && Platform.isIOS) {
      return enableCoupons && showCoupons;
    }
    return enableCoupons;
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
