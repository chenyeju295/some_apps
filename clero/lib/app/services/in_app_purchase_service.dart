import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../models/product_model.dart';
import '../controllers/balance_controller.dart';

class InAppPurchaseService extends GetxService {
  static InAppPurchaseService get instance => Get.find<InAppPurchaseService>();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs from our ProductModel
  final Set<String> _productIds =
      ProductModel.products.map((product) => product.productId).toSet();

  // Available products
  final RxList<ProductDetails> availableProducts = <ProductDetails>[].obs;

  // Purchase states
  final RxBool isLoading = false.obs;
  final RxBool isAvailable = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeStore();
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  Future<void> _initializeStore() async {
    try {
      isLoading.value = true;

      // Check if the store is available
      final bool available = await _inAppPurchase.isAvailable();
      isAvailable.value = available;

      if (!available) {
        debugPrint('InAppPurchase: Store not available');
        return;
      }

      // iOS specific setup
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      }

      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => debugPrint('InAppPurchase: Stream done'),
        onError: (error) => debugPrint('InAppPurchase: Stream error: $error'),
      );

      // Query available products
      await _queryProducts();
    } catch (e) {
      debugPrint('InAppPurchase: Initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _queryProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.error != null) {
        debugPrint('InAppPurchase: Query error: ${response.error}');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint(
            'InAppPurchase: Products not found: ${response.notFoundIDs}');
      }

      availableProducts.value = response.productDetails;
      debugPrint(
          'InAppPurchase: Found ${response.productDetails.length} products');
    } catch (e) {
      debugPrint('InAppPurchase: Query products error: $e');
    }
  }

  // 重新查询商品的方法，用于网络恢复后重试
  Future<void> retryQueryProducts() async {
    await _queryProducts();
  }

  // 检查是否已初始化并尝试重新初始化
  Future<bool> ensureInitialized() async {
    if (!isAvailable.value || availableProducts.isEmpty) {
      debugPrint(
          'InAppPurchase: Re-initializing due to missing products or unavailable store');
      await _initializeStore();
      return isAvailable.value && availableProducts.isNotEmpty;
    }
    return true;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchaseUpdate(purchaseDetails);
    }
  }

  void _handlePurchaseUpdate(PurchaseDetails purchaseDetails) {
    debugPrint('InAppPurchase: Purchase update - ${purchaseDetails.status}');

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        _showPendingUI();
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        _handleSuccessfulPurchase(purchaseDetails);
        break;

      case PurchaseStatus.error:
        _handleFailedPurchase(purchaseDetails);
        break;

      default:
        break;
    }

    // Complete the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  void _showPendingUI() {
    Get.snackbar(
      'Purchase Processing',
      'Your purchase is being processed...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    // Find the product that was purchased
    final ProductModel? product = ProductModel.products.firstWhereOrNull(
      (p) => p.productId == purchaseDetails.productID,
    );

    if (product != null) {
      // Add crystals to balance
      final balanceController = Get.find<BalanceController>();
      balanceController.addCrystals(product.crystals);

      // Show success message
      Get.snackbar(
        'Purchase Successful!',
        'Added ${product.crystals} crystals to your balance',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
      _inAppPurchase.completePurchase(purchaseDetails);

      // Notify listeners
      Get.find<BalanceController>().update();
    }
  }

  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    String errorMessage = 'Purchase failed. Please try again.';

    if (purchaseDetails.error != null) {
      final error = purchaseDetails.error!;

      // Handle specific error codes
      if (error.code == 'storekit_user_cancelled') {
        errorMessage = 'Purchase was cancelled.';
      } else if (error.code == 'storekit_payment_invalid') {
        errorMessage = 'Payment method is invalid.';
      } else if (error.code == 'storekit_payment_not_allowed') {
        errorMessage = 'Payments are not allowed on this device.';
      }

      debugPrint(
          'InAppPurchase: Purchase failed - ${error.code}: ${error.message}');
    }

    Get.snackbar(
      'Purchase Failed',
      errorMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  Future<bool> purchaseProduct(String productId) async {
    try {
      // 购买前确保已正确初始化
      final bool initialized = await ensureInitialized();
      if (!initialized) {
        Get.snackbar(
          'Store Unavailable',
          'The App Store is not available right now. Please check your network connection and try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Find the product
      final ProductDetails? product = availableProducts.firstWhereOrNull(
        (p) => p.id == productId,
      );

      if (product == null) {
        Get.snackbar(
          'Product Not Found',
          'This product is not available for purchase. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Create purchase param
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product, applicationUserName: "clero");

      // Start the purchase
      final bool success =
          await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);

      return success;
    } catch (e) {
      debugPrint('InAppPurchase: Purchase error: $e');

      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();

      Get.snackbar(
        'Restore Complete',
        'Any previous purchases have been restored.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('InAppPurchase: Restore error: $e');
      Get.snackbar(
        'Restore Failed',
        'Failed to restore purchases. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  ProductDetails? getProductDetails(String productId) {
    return availableProducts.firstWhereOrNull((p) => p.id == productId);
  }

  String getLocalizedPrice(String productId) {
    final product = getProductDetails(productId);
    return product?.price ?? 'N/A';
  }
}

// iOS specific payment queue delegate
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

// Extension to find first element or return null
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
