import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Service managing Apple In-App Purchases (StoreKit).
///
/// Communicates with StoreKit via [InAppPurchase.instance], listens to the
/// purchase stream, and delivers completed transaction receipts to the caller.
class AppleIapService {
  AppleIapService._();
  static final AppleIapService instance = AppleIapService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Active transaction completer
  Completer<PurchaseDetails>? _activePurchaseCompleter;
  String? _expectedProductId;

  /// Default fallback product tier provided by backend.
  static const String defaultProductId = 'com.zappkode.igrow.tier1';

  /// Predefined set of IAP product IDs configured in App Store Connect.
  static const Set<String> productIds = {
    'com.zappkode.igrow.tier1',
    'com.zappkode.igrow.tier2',
    'com.zappkode.igrow.tier3',
  };

  /// Initialize listener for purchase updates.
  void init() {
    if (_subscription != null) return;
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('❌ [AppleIapService] purchaseStream error: $error');
        if (_activePurchaseCompleter != null && !_activePurchaseCompleter!.isCompleted) {
          _activePurchaseCompleter!.completeError(error);
        }
      },
    );
  }

  /// Clean up subscriptions on app termination.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint('🍏 [AppleIapService] Purchase updated: id=${purchase.productID}, status=${purchase.status}');

      if (purchase.status == PurchaseStatus.pending) {
        debugPrint('⏳ [AppleIapService] Purchase pending for ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('❌ [AppleIapService] Purchase error: ${purchase.error}');
        if (_activePurchaseCompleter != null && !_activePurchaseCompleter!.isCompleted) {
          _activePurchaseCompleter!.completeError(
            Exception(purchase.error?.message ?? 'Apple In-App Purchase failed.'),
          );
        }
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        debugPrint('✅ [AppleIapService] Purchase SUCCESS: txId=${purchase.purchaseID}');

        // Complete the pending purchase future if waiting for this product
        if (_activePurchaseCompleter != null && !_activePurchaseCompleter!.isCompleted) {
          if (_expectedProductId == null || purchase.productID == _expectedProductId) {
            _activePurchaseCompleter!.complete(purchase);
          }
        }
      }

      // Finish transaction with StoreKit if pending complete
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (e) {
          debugPrint('⚠️ [AppleIapService] completePurchase error: $e');
        }
      }
    }
  }

  /// Purchase an IAP product on iOS using StoreKit.
  ///
  /// Returns the completed [PurchaseDetails] containing the receipt data and transaction ID.
  Future<PurchaseDetails> buyProduct({String productId = defaultProductId}) async {
    if (kIsWeb || !Platform.isIOS) {
      throw UnsupportedError('Apple In-App Purchase is only available on iOS devices.');
    }

    init();

    final isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      throw Exception('StoreKit In-App Purchase is not available on this device.');
    }

    _expectedProductId = productId;
    _activePurchaseCompleter = Completer<PurchaseDetails>();

    // 1. Query the product details from Apple StoreKit
    final ProductDetailsResponse response = await _iap.queryProductDetails({productId});
    if (response.error != null) {
      debugPrint('⚠️ [AppleIapService] queryProductDetails error: ${response.error}');
    }

    if (response.productDetails.isEmpty) {
      debugPrint('⚠️ [AppleIapService] Product $productId not returned by StoreKit. notFoundIDs=${response.notFoundIDs}');
      throw Exception(
        'Product "$productId" is not available yet from Apple StoreKit. '
        'Please ensure the product is approved in App Store Connect and propagation has completed.',
      );
    }

    final ProductDetails productToBuy = response.productDetails.firstWhere(
      (p) => p.id == productId,
      orElse: () => response.productDetails.first,
    );

    final purchaseParam = PurchaseParam(productDetails: productToBuy);

    debugPrint('🚀 [AppleIapService] Initiating buyNonConsumable for $productId...');
    final launched = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    if (!launched) {
      throw Exception('Failed to initiate Apple In-App Purchase sheet.');
    }

    // 3. Wait for the purchase update to complete with a safety timeout of 3 minutes
    return _activePurchaseCompleter!.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () {
        throw TimeoutException('Apple In-App Purchase timed out. If you were charged, please restore purchases.');
      },
    );
  }

  /// Extract receipt / JWS payload string from [PurchaseDetails].
  String extractReceiptData(PurchaseDetails purchase) {
    if (purchase.verificationData.serverVerificationData.isNotEmpty) {
      return purchase.verificationData.serverVerificationData;
    }
    if (purchase.verificationData.localVerificationData.isNotEmpty) {
      return purchase.verificationData.localVerificationData;
    }
    return '';
  }
}
