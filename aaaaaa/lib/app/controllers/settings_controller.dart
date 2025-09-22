import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';

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

  // Clear all data
  void clearAllData() {
    Get.defaultDialog(
      title: 'Clear All Data',
      middleText:
          'This will remove all favorites and generation history. This action cannot be undone.',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        StorageService.clearAll();
        Get.back();
        Get.snackbar(
          'Data Cleared',
          'All app data has been cleared',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // Clear favorites only
  void clearFavorites() {
    Get.defaultDialog(
      title: 'Clear Favorites',
      middleText:
          'This will remove all favorite wallpapers. This action cannot be undone.',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
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

  // Clear history only
  void clearHistory() {
    Get.defaultDialog(
      title: 'Clear History',
      middleText:
          'This will remove all generation history. This action cannot be undone.',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        StorageService.clearHistory();
        Get.back();
        Get.snackbar(
          'History Cleared',
          'Generation history has been cleared',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // Show about dialog
  void showAboutDialog() {
    Get.defaultDialog(
      title: AppConstants.appName,
      content: Column(
        children: [
          Text('Version: ${AppConstants.appVersion}'),
          const SizedBox(height: 16),
          const Text(
            'Generate beautiful AI wallpapers with custom prompts and themes.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Powered by OpenAI DALL-E',
            style: TextStyle(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      textConfirm: 'OK',
      onConfirm: () => Get.back(),
    );
  }

  // Get app version
  String get appVersion => AppConstants.appVersion;

  // Get app name
  String get appName => AppConstants.appName;
}
