import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import 'favorites_controller.dart';
import 'home_controller.dart';

class SettingsController extends GetxController {
  // Observable variables
  final isDarkMode = false.obs;
  final apiKey = ''.obs;
  final isApiKeyValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    isDarkMode.value = StorageService.isDarkMode;
  }

  // Toggle dark mode
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    StorageService.isDarkMode = isDarkMode.value;

    // Update app theme
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    Get.snackbar(
      'Theme Changed',
      'Switched to ${isDarkMode.value ? 'dark' : 'light'} mode',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Reset generation confirmation
  void resetGenerationConfirm() {
    StorageService.showGenerationConfirm = true;
    Get.snackbar(
      'Generation Confirmation Reset',
      'Generation confirmation dialog will be shown again',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Update API key
  void updateApiKey(String key) {
    apiKey.value = key.trim();
    _validateApiKey();
  }

  void _validateApiKey() {
    // Basic validation - check if it starts with 'sk-' and has reasonable length
    final key = apiKey.value;
    isApiKeyValid.value =
        key.isNotEmpty && key.startsWith('sk-') && key.length > 20;
  }

  // Save API key
  void saveApiKey() {
    if (!isApiKeyValid.value) {
      Get.snackbar(
        'Invalid API Key',
        'Please enter a valid OpenAI API key',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Set API key in the service
    // Note: In production, you should store this securely
    Get.snackbar(
      'API Key Saved',
      'Your API key has been saved successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Clear favorites
  void clearFavorites() {
    Get.defaultDialog(
      title: 'Clear Favorites',
      middleText: 'Are you sure you want to clear all favorite wallpapers?',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        StorageService.clearFavorites();
        Get.back();
        Get.snackbar(
          'Favorites Cleared',
          'All favorite wallpapers have been removed',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // Clear history
  void clearHistory() {
    Get.defaultDialog(
      title: 'Clear History',
      middleText: 'Are you sure you want to clear all generation history?',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () {
        StorageService.clearHistory();
        Get.back();
        Get.snackbar(
          'History Cleared',
          'All generation history has been removed',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // Clear all data
  void clearAllData() {
    Get.defaultDialog(
      title: 'Clear All Data',
      middleText:
          'This will remove all favorites and generation history. This action cannot be undone.',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        StorageService.clearAll();

        Get.find<FavoritesController>().loadAllWallpapers();
        Get.find<FavoritesController>().loadFavorites();
        Get.find<HomeController>().refreshHistory();

        Get.back();
        Get.snackbar(
          'Data Cleared',
          'All app data has been cleared',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // App version getter
  String get appVersion => AppConstants.appVersion;

  // Show about dialog
  void showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('About AI Wallpaper Generator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${AppConstants.appVersion}'),
            const SizedBox(height: 8),

            const Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• AI-powered wallpaper generation'),
            const Text('• Multiple art styles and categories'),
            const Text('• High-quality HD images'),
            const Text('• Crystal-based pricing system'),
            const Text('• Favorites and history management'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
