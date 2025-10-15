import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/token_service.dart';
import '../../../data/services/gallery_service.dart';
import '../../../../core/values/app_constants.dart';

class ProfileController extends GetxController {
  // 使用 getter 方式动态获取依赖，避免初始化顺序问题
  TokenService get _tokenService => Get.find<TokenService>();
  GalleryService get _galleryService => Get.find<GalleryService>();

  final RxBool isLoading = false.obs;

  int get tokenBalance => _tokenService.tokenBalance.value;
  int get totalGenerations => _tokenService.totalGenerations.value;
  int get totalWallpapers => _galleryService.totalCount;
  int get favoriteCount => _galleryService.favoriteCount;

  void navigateToTokenShop() {
    // TODO: Implement token shop navigation
    Get.snackbar(
      'Coming Soon',
      'Token shop will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy Content\n\n'
            'This app collects and processes the following data:\n\n'
            '1. Generated wallpapers and preferences\n'
            '2. Token balance and purchase history\n'
            '3. Usage statistics\n\n'
            'All data is stored locally on your device and is not shared with third parties.\n\n'
            'For AI image generation, your prompts are sent to our AI service provider but are not stored permanently.\n\n'
            'You can delete all your data at any time from the app settings.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void showTermsOfService() {
    Get.dialog(
      AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service\n\n'
            '1. Service Usage\n'
            'This app provides AI-generated wallpaper creation services. You must be at least 13 years old to use this service.\n\n'
            '2. Token System\n'
            'Tokens are required to generate wallpapers. Tokens can be purchased through in-app purchases. Tokens are non-refundable.\n\n'
            '3. Content Policy\n'
            'Users must not generate inappropriate, offensive, or illegal content. We reserve the right to terminate accounts that violate these terms.\n\n'
            '4. Intellectual Property\n'
            'Generated wallpapers are for personal use only. Commercial use requires separate licensing.\n\n'
            '5. Limitation of Liability\n'
            'We are not responsible for the content of AI-generated images.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void showAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text('About'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Version ${AppConstants.appVersion}'),
              const SizedBox(height: 16),
              const Text(
                'Fashion Wallpaper is an AI-powered app that creates beautiful, '
                'personalized fashion wallpapers based on your preferences.\n\n'
                'Features:\n'
                '• AI-powered wallpaper generation\n'
                '• Multiple style categories\n'
                '• Save and share wallpapers\n'
                '• Build your collection\n',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void clearAllData() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all your data? '
          'This includes all wallpapers, favorites, and history. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              isLoading.value = true;
              try {
                await _galleryService.clearAll();
                await _tokenService.resetTokens();
                Get.snackbar(
                  'Success',
                  'All data cleared successfully',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to clear data: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } finally {
                isLoading.value = false;
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void shareApp() {
    // TODO: Implement app sharing
    Get.snackbar(
      'Share',
      'Share functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void rateApp() {
    // TODO: Implement app rating
    Get.snackbar(
      'Rate App',
      'Thank you for your support!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
