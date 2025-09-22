import 'package:get/get.dart';
import '../models/theme_category_model.dart';
import '../models/product_model.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import 'balance_controller.dart';

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

  // Toggle prompt selection
  void togglePromptSelection(String prompt) {
    if (selectedPrompts.contains(prompt)) {
      selectedPrompts.remove(prompt);
    } else {
      selectedPrompts.add(prompt);
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

  // Select all prompts in current category
  void selectAllPrompts() {
    if (selectedCategory.value != null) {
      selectedPrompts.clear();
      selectedPrompts.addAll(selectedCategory.value!.prompts);
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

    await _generateWallpaper(
      _buildFinalPrompt(customPrompt.value.trim()),
      selectedCategory.value?.name ?? 'Custom',
    );
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
    await _generateWallpaper(
      _buildFinalPrompt(combinedPrompt),
      selectedCategory.value?.name ?? 'Mixed',
    );
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

  // Generate multiple wallpapers (batch generation)
  Future<void> generateBatch() async {
    if (selectedPrompts.isEmpty) {
      Get.snackbar(
        'No Prompts Selected',
        'Please select prompts for batch generation',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedPrompts.length > 5) {
      Get.snackbar(
        'Too Many Prompts',
        'Please select maximum 5 prompts for batch generation',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Calculate total crystal cost for batch
    final balanceController = Get.find<BalanceController>();
    final batchCostPerImage = CrystalCosts.calculateGenerationCost(
      quality: selectedQuality.value,
      style: selectedStyle.value,
      isBatch: true,
    );
    final totalCost = batchCostPerImage * selectedPrompts.length;

    if (!balanceController.hasEnoughCrystals(totalCost)) {
      Get.snackbar(
        'Insufficient Crystals',
        'Batch generation needs $totalCost crystals but you only have ${balanceController.formattedBalance}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    Get.defaultDialog(
      title: 'Batch Generation',
      middleText:
          'Generate ${selectedPrompts.length} wallpapers?\n\nCost: $totalCost crystals\nRemaining: ${balanceController.crystalBalance.value - totalCost} crystals',
      textConfirm: 'Generate',
      textCancel: 'Cancel',
      onConfirm: () async {
        Get.back();
        await _generateBatchWallpapers();
      },
    );
  }

  // Internal method to generate batch wallpapers
  Future<void> _generateBatchWallpapers() async {
    isGenerating.value = true;
    int successCount = 0;

    try {
      Get.snackbar(
        'Batch Generation Started',
        'Generating ${selectedPrompts.length} wallpapers...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      for (int i = 0; i < selectedPrompts.length; i++) {
        final prompt = selectedPrompts[i];
        Get.snackbar(
          'Generating ${i + 1}/${selectedPrompts.length}',
          'Creating wallpaper: ${prompt.length > 30 ? "${prompt.substring(0, 30)}..." : prompt}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        final wallpaper = await AIService.generateWallpaper(
          prompt: _buildFinalPrompt(prompt),
          category: selectedCategory.value?.name ?? 'Batch',
          size: imageSizeOptions[selectedImageSize.value] ?? '1024x1792',
        );

        if (wallpaper != null) {
          StorageService.addToHistory(wallpaper);
          successCount++;
        }

        // Small delay between generations
        await Future.delayed(const Duration(milliseconds: 500));
      }

      Get.snackbar(
        'Batch Generation Complete',
        'Successfully generated $successCount/${selectedPrompts.length} wallpapers',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to home to view results
      Get.offAllNamed('/');
    } finally {
      isGenerating.value = false;
    }
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

    // Check crystal balance
    final balanceController = Get.find<BalanceController>();
    final crystalCost = CrystalCosts.calculateGenerationCost(
      quality: selectedQuality.value,
      style: selectedStyle.value,
    );

    if (!balanceController.hasEnoughCrystals(crystalCost)) {
      Get.snackbar(
        'Insufficient Crystals',
        'You need $crystalCost crystals but only have ${balanceController.formattedBalance}. Visit the shop to buy more!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

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
        size: imageSizeOptions[selectedImageSize.value] ?? '1024x1792',
        quality: selectedQuality.value,
        style: selectedStyle.value,
      );

      if (wallpaper != null) {
        // Deduct crystals
        balanceController.spendCrystals(crystalCost);

        // Add to history
        StorageService.addToHistory(wallpaper);

        Get.snackbar(
          'Success!',
          'Wallpaper generated successfully! Remaining crystals: ${balanceController.formattedBalance}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );

        // Navigate to wallpaper detail view
        Get.toNamed('/wallpaper-detail', arguments: wallpaper);
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
}
