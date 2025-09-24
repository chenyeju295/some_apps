import 'dart:async';
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

  // Product IDs and their corresponding token amounts
  static const Map<String, TokenPackage> tokenPackages = {
    '999900': TokenPackage(
      id: '999900',
      price: '\$0.99',
      tokens: 100,
      name: 'Starter Pack',
      description: '100 tokens for underwater adventures',
    ),
    '999901': TokenPackage(
      id: '999901',
      price: '\$4.99',
      tokens: 500,
      name: 'Explorer Pack',
      description: '500 tokens with bonus value',
    ),
    '999902': TokenPackage(
      id: '999902',
      price: '\$9.99',
      tokens: 1200,
      name: 'Adventurer Pack',
      description: '1200 tokens - most popular choice',
    ),
    '999903': TokenPackage(
      id: '999903',
      price: '\$19.99',
      tokens: 2500,
      name: 'Pro Diver Pack',
      description: '2500 tokens for unlimited exploration',
    ),
    '999904': TokenPackage(
      id: '999904',
      price: '\$49.99',
      tokens: 7000,
      name: 'Master Pack',
      description: '7000 tokens - ultimate diving experience',
    ),
    '999905': TokenPackage(
      id: '999905',
      price: '\$99.99',
      tokens: 15000,
      name: 'Ocean Legend Pack',
      description: '15000 tokens - professional level',
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
    if (!_isInitialized) {
      print('Purchase service not initialized');
      return false;
    }

    try {
      final ProductDetails? product =
          _products.where((p) => p.id == productId).firstOrNull;

      if (product == null) {
        print('Product not found: $productId');
        return false;
      }

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
      );

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
          break;
        case PurchaseStatus.purchased:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handlePurchaseError(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          _handleRestoredPurchase(purchaseDetails);
          break;
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
      onPurchaseSuccess?.call(purchaseDetails.productID, package.tokens);
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

  String get valueDescription {
    if (id == 'dive_tokens_adventurer') {
      return 'MOST POPULAR';
    } else if (id == 'dive_tokens_pro' || id == 'dive_tokens_master') {
      return 'BEST VALUE';
    }
    return '';
  }
}
