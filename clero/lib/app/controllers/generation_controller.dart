import 'package:clero/app/controllers/home_controller.dart';
import 'package:get/get.dart';
import '../models/theme_category_model.dart';
import '../models/product_model.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import 'balance_controller.dart';
import 'package:flutter/material.dart';

import 'favorites_controller.dart';

class GenerationController extends GetxController {
  // Observable variables
  final categories = <ThemeCategoryModel>[].obs;
  final selectedCategory = Rx<ThemeCategoryModel?>(null);
  final selectedPrompts = <String>[].obs;
  final customPrompt = ''.obs;
  final isGenerating = false.obs;
  final selectedImageSize = 'portrait'.obs; // portrait, square, landscape
  final selectedStyle = 'realistic'.obs; // realistic, artistic, anime, fantasy
  final selectedQuality = 'hd'.obs; // standard, hd

  // Image size options
  final imageSizeOptions = {
    'portrait': '1024x1792',
    'square': '1024x1024',
    'landscape': '1792x1024',
  };

  // Style options
  final styleOptions = [
    'realistic',
    'artistic',
    'anime',
    'fantasy',
    'vintage',
    'modern',
  ];

  // Quality options
  final qualityOptions = ['standard', 'hd'];

  @override
  void onInit() {
    super.onInit();
    _initializeCategories();
    _loadSelectedCategory();
  }

  void _initializeCategories() {
    categories.value = ThemeCategoryModel.categories;
  }

  void _loadSelectedCategory() {
    final savedTheme = StorageService.selectedTheme;
    final category = categories.firstWhereOrNull((c) => c.name == savedTheme);
    if (category != null) {
      selectedCategory.value = category;
    } else if (categories.isNotEmpty) {
      selectedCategory.value = categories.first;
    }
  }

  // Select category
  void selectCategory(ThemeCategoryModel category) {
    selectedCategory.value = category;
    selectedPrompts.clear();
    StorageService.selectedTheme = category.name;
  }

  // Navigate with category - for navigation controller
  void navigateWithCategory(String categoryName) {
    final category = categories.firstWhere(
      (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => categories.first,
    );
    selectCategory(category);
  }

  // Toggle prompt selection (single selection mode)
  void togglePromptSelection(String prompt) {
    if (selectedPrompts.contains(prompt)) {
      selectedPrompts.clear(); // Clear selection if same prompt is clicked
    } else {
      selectedPrompts.clear(); // Clear previous selection
      selectedPrompts.add(prompt); // Add only the new selection
    }
  }

  // Check if prompt is selected
  bool isPromptSelected(String prompt) {
    return selectedPrompts.contains(prompt);
  }

  // Update custom prompt
  void updateCustomPrompt(String prompt) {
    customPrompt.value = prompt;
  }

  // Clear custom prompt
  void clearCustomPrompt() {
    customPrompt.value = '';
  }

  // Clear all selected prompts
  void clearSelectedPrompts() {
    selectedPrompts.clear();
  }

  // Select random prompt from current category
  void selectRandomPrompt() {
    if (selectedCategory.value != null &&
        selectedCategory.value!.prompts.isNotEmpty) {
      final prompts = selectedCategory.value!.prompts;
      final randomPrompt = prompts[DateTime.now().millisecond % prompts.length];
      selectedPrompts.clear();
      selectedPrompts.add(randomPrompt);
    }
  }

  // Set image size
  void setImageSize(String size) {
    selectedImageSize.value = size;
  }

  // Set style
  void setStyle(String style) {
    selectedStyle.value = style;
  }

  // Set quality
  void setQuality(String quality) {
    selectedQuality.value = quality;
  }

  // Build final prompt
  String _buildFinalPrompt(String basePrompt) {
    var finalPrompt = basePrompt;

    // Add style enhancement
    switch (selectedStyle.value) {
      case 'realistic':
        finalPrompt +=
            ', photorealistic, high detail, professional photography';
        break;
      case 'artistic':
        finalPrompt +=
            ', artistic painting style, beautiful composition, fine art';
        break;
      case 'anime':
        finalPrompt += ', anime style, manga art, beautiful anime artwork';
        break;
      case 'fantasy':
        finalPrompt += ', fantasy art style, magical atmosphere, epic fantasy';
        break;
      case 'vintage':
        finalPrompt += ', vintage style, retro aesthetic, classic photography';
        break;
      case 'modern':
        finalPrompt += ', modern contemporary style, sleek design, minimalist';
        break;
    }

    // Add quality enhancement
    finalPrompt += ', high resolution wallpaper, stunning visual quality, 4K';

    return finalPrompt;
  }

  // Generate wallpaper with custom prompt
  Future<void> generateWithCustomPrompt() async {
    if (customPrompt.value.trim().isEmpty) {
      Get.snackbar(
        'Invalid Input',
        'Please enter a prompt to generate wallpaper',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Check if should show confirmation
    if (StorageService.showGenerationConfirm) {
      final crystalCost = CrystalCosts.calculateGenerationCost(
        quality: selectedQuality.value,
        style: selectedStyle.value,
      );

      await _showGenerationConfirmDialog(
        title: 'Generate Custom Wallpaper',
        description: customPrompt.value.trim(),
        cost: crystalCost,
        onConfirm: () => _generateWallpaper(
          _buildFinalPrompt(customPrompt.value.trim()),
          selectedCategory.value?.name ?? 'Custom',
        ),
      );
    } else {
      await _generateWallpaper(
        _buildFinalPrompt(customPrompt.value.trim()),
        selectedCategory.value?.name ?? 'Custom',
      );
    }
  }

  // Generate wallpaper with selected prompts
  Future<void> generateWithSelectedPrompts() async {
    if (selectedPrompts.isEmpty) {
      Get.snackbar(
        'No Prompts Selected',
        'Please select at least one prompt',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Combine selected prompts
    final combinedPrompt = selectedPrompts.join(', ');

    // Check if should show confirmation
    if (StorageService.showGenerationConfirm) {
      final crystalCost = CrystalCosts.calculateGenerationCost(
        quality: selectedQuality.value,
        style: selectedStyle.value,
      );

      await _showGenerationConfirmDialog(
        title: 'Generate Selected Idea',
        description: combinedPrompt.length > 80
            ? "${combinedPrompt.substring(0, 80)}..."
            : combinedPrompt,
        cost: crystalCost,
        onConfirm: () => _generateWallpaper(
          _buildFinalPrompt(combinedPrompt),
          selectedCategory.value?.name ?? 'Selected',
        ),
      );
    } else {
      await _generateWallpaper(
        _buildFinalPrompt(combinedPrompt),
        selectedCategory.value?.name ?? 'Mixed',
      );
    }
  }

  // Generate random wallpaper from selected category
  Future<void> generateRandomWallpaper() async {
    if (selectedCategory.value == null) {
      Get.snackbar(
        'No Category Selected',
        'Please select a category first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final prompts = selectedCategory.value!.prompts;
    if (prompts.isEmpty) return;

    final randomPrompt = prompts[DateTime.now().millisecond % prompts.length];
    await _generateWallpaper(
      _buildFinalPrompt(randomPrompt),
      selectedCategory.value!.name,
    );
  }

  // Internal method to generate single wallpaper
  Future<void> _generateWallpaper(String prompt, String category) async {
    if (isGenerating.value) {
      Get.snackbar(
        'Generation in Progress',
        'Please wait for the current generation to complete',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final balanceController = Get.find<BalanceController>();
    final crystalCost = CrystalCosts.calculateGenerationCost(
      quality: selectedQuality.value,
      style: selectedStyle.value,
    );

    isGenerating.value = true;

    try {
      Get.snackbar(
        'Generating Wallpaper',
        'Creating your ${selectedQuality.value.toUpperCase()} quality wallpaper... (-$crystalCost crystals)',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      final wallpaper = await AIService.generateWallpaper(
        prompt: prompt,
        category: category,
        style: selectedStyle.value,
      );

      if (wallpaper != null) {
        // Deduct crystals
        balanceController.spendCrystals(crystalCost);

        // Add to history and update UI
        StorageService.addToHistory(wallpaper);

        // Update home controller to refresh the list
        final homeController = Get.find<HomeController>();
        homeController.onInit(); // Reload generated wallpapers

        // Navigate to wallpaper detail view with hero animation
        Get.toNamed('/wallpaper-detail', arguments: wallpaper);
        Get.find<FavoritesController>().loadAllWallpapers();
        Get.find<FavoritesController>().loadFavorites();
      }
    } catch (e) {
      Get.snackbar(
        'Generation Failed',
        'Failed to generate wallpaper: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // Get current settings summary
  String get settingsSummary {
    final size = selectedImageSize.value.capitalize;
    final style = selectedStyle.value.capitalize;
    final quality = selectedQuality.value.toUpperCase();
    return '$size • $style • $quality';
  }

  // Get selected prompts count
  int get selectedPromptsCount => selectedPrompts.length;

  // Check if can generate
  bool get canGenerate =>
      customPrompt.value.trim().isNotEmpty || selectedPrompts.isNotEmpty;

  TextEditingController customPromptController = TextEditingController();

  // Show generation confirmation dialog
  Future<void> _showGenerationConfirmDialog({
    required String title,
    required String description,
    required int cost,
    required VoidCallback onConfirm,
  }) async {
    final balanceController = Get.find<BalanceController>();

    final showConfirmCheckbox = true.obs;

    Get.defaultDialog(
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.diamond,
                  color: Get.theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cost: $cost crystals',
                  style: TextStyle(
                    color: Get.theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Remaining: ${balanceController.crystalBalance.value - cost} crystals',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => CheckboxListTile(
                title: const Text(
                  "Don't show this confirmation again",
                  style: TextStyle(fontSize: 14),
                ),
                value: !showConfirmCheckbox.value,
                onChanged: (value) {
                  showConfirmCheckbox.value = !(value ?? false);
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              )),
        ],
      ),
      textConfirm: 'Generate',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Get.theme.primaryColor,
      onConfirm: () {
        // Update settings if user chose not to show again
        if (!showConfirmCheckbox.value) {
          StorageService.showGenerationConfirm = false;
        }
        Get.back();
        onConfirm();
      },
      onCancel: () => Get.back(),
    );
  }
}
