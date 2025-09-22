import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/generation_controller.dart';
import '../controllers/balance_controller.dart';
import '../models/theme_category_model.dart';
import '../models/product_model.dart';
import '../widgets/loading_overlay.dart';

class GenerationView extends GetView<GenerationController> {
  const GenerationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get category name from arguments if passed
    final String? passedCategoryName = Get.arguments as String?;
    if (passedCategoryName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final category = controller.categories.firstWhere(
          (cat) => cat.name.toLowerCase() == passedCategoryName.toLowerCase(),
          orElse: () => controller.categories.first,
        );
        controller.selectCategory(category);
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.05),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main prompt input with animation
                        _buildAnimatedPromptInput(context),
                        const SizedBox(height: 24),

                        // Category selection with animation
                        _buildAnimatedCategoryTabs(context),
                        const SizedBox(height: 20),

                        // Preset prompts with animation
                        _buildAnimatedPresetPrompts(context),
                        const SizedBox(height: 32),

                        // Generate button with animation
                        _buildAnimatedGenerateButton(context),
                        const SizedBox(height: 16),

                        // Recent generations
                        _buildRecentGenerations(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          Obx(() => controller.isGenerating.value
              ? const LoadingOverlay(message: 'Generating your wallpaper...')
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Create Wallpaper',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          _buildCrystalBalance(context),
        ],
      ),
    );
  }

  Widget _buildMainPromptInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Describe your wallpaper',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => TextField(
                onChanged: controller.updateCustomPrompt,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'A beautiful sunset over mountains with golden light...',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: controller.customPrompt.value.isNotEmpty
                      ? IconButton(
                          onPressed: controller.clearCustomPrompt,
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              )),
          const SizedBox(height: 8),
          Obx(() => Text(
                '${controller.customPrompt.value.length}/500',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.6),
                    ),
              )),
        ],
      ),
    );
  }

  Widget _buildQuickSettings(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSettingCard(
            context,
            'Size',
            controller.selectedImageSize.value.capitalize!,
            Icons.aspect_ratio,
            () => _showSizeSelector(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSettingCard(
            context,
            'Style',
            controller.selectedStyle.value.capitalize!,
            Icons.palette,
            () => _showStyleSelector(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSettingCard(
            context,
            'Quality',
            controller.selectedQuality.value.toUpperCase(),
            Icons.high_quality,
            () => _showQualitySelector(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Obx(() => SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  final isSelected =
                      controller.selectedCategory.value?.name == category.name;

                  return GestureDetector(
                    onTap: () => controller.selectCategory(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.color.withOpacity(0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? category.color
                              : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 16,
                            color: isSelected
                                ? category.color
                                : Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.name,
                            style: TextStyle(
                              color: isSelected
                                  ? category.color
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }

  Widget _buildPresetPrompts(BuildContext context) {
    return Obx(() {
      if (controller.selectedCategory.value == null) {
        return const SizedBox.shrink();
      }

      final category = controller.selectedCategory.value!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${category.name} Presets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (controller.selectedPrompts.isNotEmpty)
                TextButton(
                  onPressed: controller.clearSelectedPrompts,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: category.prompts.take(6).map((prompt) {
              return Obx(() => _buildPromptChip(context, prompt));
            }).toList(),
          ),
          if (category.prompts.length > 6) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => _showAllPrompts(context, category),
                child: Text('View all ${category.prompts.length} presets'),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildPromptChip(BuildContext context, String prompt) {
    final isSelected = controller.isPromptSelected(prompt);
    final displayPrompt =
        prompt.length > 25 ? '${prompt.substring(0, 25)}...' : prompt;

    return GestureDetector(
      onTap: () => controller.togglePromptSelection(prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          displayPrompt,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    return Obx(() {
      final hasContent = controller.customPrompt.value.isNotEmpty ||
          controller.selectedPrompts.isNotEmpty;

      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: hasContent ? _handleGenerate : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome),
              const SizedBox(width: 8),
              Text(
                _getGenerateButtonText(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCostInfo(BuildContext context) {
    return Obx(() {
      final crystalCost = CrystalCosts.calculateGenerationCost(
        quality: controller.selectedQuality.value,
        style: controller.selectedStyle.value,
      );

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Each generation costs $crystalCost crystals',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCrystalBalance(BuildContext context) {
    final balanceController = Get.find<BalanceController>();

    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.diamond,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                balanceController.formattedBalance,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ));
  }

  // Helper methods
  String _getGenerateButtonText() {
    if (controller.customPrompt.value.isNotEmpty) {
      return 'Generate Custom';
    } else if (controller.selectedPrompts.isNotEmpty) {
      return 'Generate Selected (${controller.selectedPrompts.length})';
    }
    return 'Generate Wallpaper';
  }

  void _handleGenerate() {
    if (controller.customPrompt.value.isNotEmpty) {
      controller.generateWithCustomPrompt();
    } else if (controller.selectedPrompts.isNotEmpty) {
      if (controller.selectedPrompts.length == 1) {
        controller.generateWithSelectedPrompts();
      } else {
        controller.generateBatch();
      }
    }
  }

  void _showSizeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Size',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...controller.imageSizeOptions.keys.map((size) {
              return ListTile(
                title: Text(size.capitalize!),
                subtitle: Text(controller.imageSizeOptions[size]!),
                trailing: controller.selectedImageSize.value == size
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  controller.setImageSize(size);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showStyleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Art Style',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...controller.styleOptions.map((style) {
              return ListTile(
                title: Text(style.capitalize!),
                trailing: controller.selectedStyle.value == style
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  controller.setStyle(style);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showQualitySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Quality',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...controller.qualityOptions.map((quality) {
              return ListTile(
                title: Text(quality.toUpperCase()),
                trailing: controller.selectedQuality.value == quality
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  controller.setQuality(quality);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showAllPrompts(BuildContext context, ThemeCategoryModel category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '${category.name} Presets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: category.prompts.length,
                  itemBuilder: (context, index) {
                    final prompt = category.prompts[index];
                    return _buildPromptChip(context, prompt);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
