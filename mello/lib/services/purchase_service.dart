import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static PurchaseService? _instance;
  static PurchaseService get instance =>
      _instance ??= PurchaseService._internal();
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Purchase state callbacks
  Function(String productId, int tokens)? onPurchaseSuccess;
  Function(String error)? onPurchaseError;
  Function()? onPurchaseRestored;
  Function()? onPurchaseStarted;
  Function()? onPurchasePending;

  // Product IDs and their corresponding token amounts
  static const Map<String, TokenPackage> tokenPackages = {
    'com.testee.yesyes.level1': TokenPackage(
      id: 'com.testee.yesyes.level1',
      price: '\$4.99',
      tokens: 3500,
      name: 'Starter Pack',
      description: '100 tokens for underwater adventures',
    ),
    'com.testee.yesyes.level2': TokenPackage(
      id: 'com.testee.yesyes.level2',
      price: '\$9.99',
      tokens: 7000,
      name: 'Explorer Pack',
      description: '500 tokens with bonus value',
    ),
    'com.testee.yesyes.level3': TokenPackage(
      id: 'com.testee.yesyes.level3',
      price: '\$19.99',
      tokens: 14000,
      name: 'Adventurer Pack',
      description: '14000 tokens - most popular choice',
    ),
    'com.testee.yesyes.level4': TokenPackage(
      id: 'com.testee.yesyes.level4',
      price: '\$49.99',
      tokens:  35000 ,
      name: 'Pro Diver Pack',
      description: '35000 tokens for unlimited exploration',
    ),
  };

  bool _isInitialized = false;
  List<ProductDetails> _products = [];

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        print('In-app purchases not available');
        return false;
      }

      // iOS-specific configuration is handled automatically by the plugin

      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _subscription.cancel(),
        onError: (error) => print('Purchase stream error: $error'),
      );

      await _loadProducts();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Failed to initialize purchase service: $e');
      return false;
    }
  }

  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = tokenPackages.keys.toSet();
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      print('Loaded ${_products.length} products');
    } catch (e) {
      print('Failed to load products: $e');
    }
  }

  List<ProductDetails> get availableProducts => _products;

  TokenPackage? getTokenPackage(String productId) {
    return tokenPackages[productId];
  }

  Future<bool> purchaseTokens(String productId) async {
    // Debug mode: simulate successful purchase for testing
    if (kDebugMode && !_isInitialized) {
      print('Debug mode: Simulating purchase for $productId');
      onPurchaseStarted?.call();

      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 1));

      final TokenPackage? package = getTokenPackage(productId);
      if (package != null) {
        print(
            'Debug mode: Simulating successful purchase of ${package.tokens} tokens');
        onPurchaseSuccess?.call(productId, package.tokens);
        return true;
      } else {
        onPurchaseError?.call('Product not found');
        return false;
      }
    }

    if (!_isInitialized) {
      print('Purchase service not initialized');
      onPurchaseError?.call('Purchase service not initialized');
      return false;
    }

    try {
      final ProductDetails? product =
          _products.where((p) => p.id == productId).firstOrNull;

      if (product == null) {
        print('Product not found: $productId');
        onPurchaseError?.call('Product not found');
        return false;
      }

      print('Starting purchase for product: $productId');
      onPurchaseStarted?.call();

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        onPurchaseError?.call('Failed to initiate purchase');
      }

      return success;
    } catch (e) {
      print('Purchase failed: $e');
      onPurchaseError?.call('Purchase failed: ${e.toString()}');
      return false;
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          print('Purchase pending: ${purchaseDetails.productID}');
          onPurchasePending?.call();
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handlePurchaseError(purchaseDetails);
          break;
        // case PurchaseStatus.restored:
        //   _handleRestoredPurchase(purchaseDetails);
        //   break;
        case PurchaseStatus.canceled:
          print('Purchase canceled: ${purchaseDetails.productID}');
          onPurchaseError?.call('Purchase was canceled');
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase successful: ${purchaseDetails.productID}');

    final TokenPackage? package = getTokenPackage(purchaseDetails.productID);
    if (package != null) {
      print('Adding ${package.tokens} tokens to user balance');
      onPurchaseSuccess?.call(purchaseDetails.productID, package.tokens);
    } else {
      print(
          'Warning: Token package not found for product ${purchaseDetails.productID}');
      onPurchaseError?.call('Invalid product configuration');
    }
  }

  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    print('Purchase error: ${purchaseDetails.error}');
    onPurchaseError?.call(purchaseDetails.error?.message ?? 'Purchase failed');
  }

  void _handleRestoredPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase restored: ${purchaseDetails.productID}');
    onPurchaseRestored?.call();
  }

  Future<void> restorePurchases() async {
    if (!_isInitialized) return;

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Failed to restore purchases: $e');
      onPurchaseError?.call('Failed to restore purchases');
    }
  }

  void dispose() {
    _subscription.cancel();
  }

  // Convenience methods for development
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isInitialized;

  List<TokenPackage> getAvailablePackages() {
    return tokenPackages.values.toList();
  }
}

class TokenPackage {
  final String id;
  final String price;
  final int tokens;
  final String name;
  final String description;

  const TokenPackage({
    required this.id,
    required this.price,
    required this.tokens,
    required this.name,
    required this.description,
  });

  double get tokensPerDollar {
    final double priceValue =
        double.tryParse(price.replaceAll('\$', '')) ?? 0.0;
    if (priceValue == 0.0) return 0.0;
    return tokens / priceValue;
  }

}
