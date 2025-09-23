import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/in_app_purchase_service.dart';

class BalanceController extends GetxController {
  // Observable crystal balance
  final crystalBalance = 0.obs;

  // Storage key for crystal balance
  static const String _crystalBalanceKey = 'crystal_balance';

  @override
  void onInit() {
    super.onInit();
    _loadBalance();
  }

  // Load balance from storage
  void _loadBalance() {
    final box = GetStorage();
    crystalBalance.value =
        box.read(_crystalBalanceKey) ?? 1000; // Start with 1000 crystals
  }

  // Save balance to storage
  void _saveBalance() {
    final box = GetStorage();
    box.write(_crystalBalanceKey, crystalBalance.value);
  }

  // Add crystals (for purchases)
  void addCrystals(int amount) {
    crystalBalance.value += amount;
    _saveBalance();
  }

  // Purchase crystals using in-app purchase
  Future<bool> purchaseCrystals(
      String productId, int crystals, double price) async {
    try {
      // Use the InAppPurchaseService
      final iapService = Get.find<InAppPurchaseService>();

      if (!iapService.isAvailable.value) {
        Get.snackbar(
          'Store Unavailable',
          'The App Store is not available right now.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }

      // Start the purchase process
      final success = await iapService.purchaseProduct(productId);

      // Note: The actual crystal addition is handled in the InAppPurchaseService
      // when the purchase is successfully completed

      return success;
    } catch (e) {
      Get.snackbar(
        'Purchase Failed',
        'Could not complete the purchase. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }

  // Spend crystals (for generations)
  bool spendCrystals(int amount) {
    if (crystalBalance.value >= amount) {
      crystalBalance.value -= amount;
      _saveBalance();
      return true;
    }

    // Show insufficient balance message
    Get.snackbar(
      'Insufficient Crystals',
      'You need $amount crystals but only have ${crystalBalance.value}',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
    return false;
  }

  // Check if user has enough crystals
  bool hasEnoughCrystals(int amount) {
    return crystalBalance.value >= amount;
  }

  // Format crystal amount for display
  String get formattedBalance {
    if (crystalBalance.value >= 10000) {
      return '${(crystalBalance.value / 1000).toStringAsFixed(1)}K';
    }
    return crystalBalance.value.toString();
  }

  // Get balance status color
  String get balanceStatus {
    if (crystalBalance.value < 500) {
      return 'low';
    } else if (crystalBalance.value < 2000) {
      return 'medium';
    }
    return 'high';
  }

  // Reset balance (for testing)
  void resetBalance() {
    crystalBalance.value = 1000;
    _saveBalance();
  }
}
