import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/generation_service.dart';
import '../../../data/services/token_service.dart';
import '../../../data/services/gallery_service.dart';
import '../../../data/models/generation_request_model.dart';
import '../widgets/generation_result_dialog.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_colors.dart';

class GenerateController extends GetxController {
  final GenerationService _generationService = Get.find<GenerationService>();
  final TokenService _tokenService = Get.find<TokenService>();
  final GalleryService _galleryService = Get.find<GalleryService>();

  final TextEditingController promptController = TextEditingController();

  final RxString selectedStyle = ''.obs;
  final RxString selectedOutfit = ''.obs;
  final RxString selectedScene = ''.obs;
  final RxBool isGenerating = false.obs;
  final RxDouble generationProgress = 0.0.obs;
  final RxString generationStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Set default values
    if (AppConstants.styleCategories.isNotEmpty) {
      selectedStyle.value = AppConstants.styleCategories.first;
    }
    if (AppConstants.outfitTypes.isNotEmpty) {
      selectedOutfit.value = AppConstants.outfitTypes.first;
    }
    if (AppConstants.sceneSettings.isNotEmpty) {
      selectedScene.value = AppConstants.sceneSettings.first;
    }
  }

  @override
  void onClose() {
    promptController.dispose();
    super.onClose();
  }

  Future<void> generateWallpaper() async {
    // Validate inputs
    if (promptController.text.trim().isEmpty) {
      Get.snackbar(
        'Input Required',
        'Please enter a description for your wallpaper',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedStyle.value.isEmpty ||
        selectedOutfit.value.isEmpty ||
        selectedScene.value.isEmpty) {
      Get.snackbar(
        'Selection Required',
        'Please select style, outfit, and scene',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Check token balance
    if (_tokenService.needsToBuyTokens()) {
      Get.snackbar(
        'Insufficient Tokens',
        'You need at least ${AppConstants.tokensPerGeneration} token to generate',
        snackPosition: SnackPosition.BOTTOM,
      );
      // TODO: Navigate to token shop
      return;
    }

    try {
      isGenerating.value = true;

      // Create generation request
      final request = GenerationRequestModel(
        prompt: promptController.text.trim(),
        style: selectedStyle.value,
        outfitType: selectedOutfit.value,
        scene: selectedScene.value,
      );

      // Consume token
      final success = await _tokenService.consumeTokens(
        AppConstants.tokensPerGeneration,
      );
      if (!success) {
        throw Exception('Failed to consume tokens');
      }

      // Generate wallpaper
      final wallpaper = await _generationService.generateWallpaper(request);

      if (wallpaper == null) {
        throw Exception('Failed to generate wallpaper');
      }

      // Save to gallery
      await _galleryService.addWallpaper(wallpaper);

      // Reset form
      promptController.clear();

      // Show result dialog
      Get.dialog(
        GenerationResultDialog(wallpaper: wallpaper),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate wallpaper: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.8),
        colorText: AppColors.textWhite,
      );

      // Refund token on error
      await _tokenService.addTokens(AppConstants.tokensPerGeneration);
    } finally {
      isGenerating.value = false;
    }
  }

  void selectStyle(String style) {
    selectedStyle.value = style;
  }

  void selectOutfit(String outfit) {
    selectedOutfit.value = outfit;
  }

  void selectScene(String scene) {
    selectedScene.value = scene;
  }

  /// Apply quick preset for faster generation
  void applyPreset(String style, String outfit, String scene) {
    // Find matching values from constants
    final matchingStyle = AppConstants.styleCategories.firstWhere(
      (s) => s.toLowerCase().contains(style.toLowerCase()),
      orElse: () => AppConstants.styleCategories.isNotEmpty
          ? AppConstants.styleCategories.first
          : '',
    );

    final matchingOutfit = AppConstants.outfitTypes.firstWhere(
      (o) => o.toLowerCase().contains(outfit.toLowerCase()),
      orElse: () => AppConstants.outfitTypes.isNotEmpty
          ? AppConstants.outfitTypes.first
          : '',
    );

    final matchingScene = AppConstants.sceneSettings.firstWhere(
      (sc) => sc.toLowerCase().contains(scene.toLowerCase()),
      orElse: () => AppConstants.sceneSettings.isNotEmpty
          ? AppConstants.sceneSettings.first
          : '',
    );

    selectedStyle.value = matchingStyle;
    selectedOutfit.value = matchingOutfit;
    selectedScene.value = matchingScene;

    // Show feedback
    Get.snackbar(
      'Preset Applied',
      'Quick settings have been applied',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
      backgroundColor: AppColors.primary.withOpacity(0.9),
      colorText: AppColors.textWhite,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  List<String> get styleCategories => AppConstants.styleCategories;
  List<String> get outfitTypes => AppConstants.outfitTypes;
  List<String> get sceneSettings => AppConstants.sceneSettings;

  int get tokenBalance => _tokenService.tokenBalance.value;
}
