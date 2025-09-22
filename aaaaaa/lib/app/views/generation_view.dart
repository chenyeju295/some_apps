import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/generation_controller.dart';
import '../models/theme_category_model.dart';
import '../widgets/loading_overlay.dart';

class GenerationView extends GetView<GenerationController> {
  const GenerationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get category name from arguments if passed
    final String? passedCategoryName = Get.arguments as String?;
    if (passedCategoryName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Find the category by name and select it
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
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
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
                        // Generation settings
                        _buildGenerationSettings(context),
                        const SizedBox(height: 24),

                        // Category selection
                        _buildCategorySelection(context),
                        const SizedBox(height: 24),

                        // Prompt selection
                        _buildPromptSelection(context),
                        const SizedBox(height: 24),

                        // Custom prompt
                        _buildCustomPrompt(context),
                        const SizedBox(height: 24),

                        // Generation actions
                        _buildGenerationActions(context),
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
          Obx(() => Text(
                controller.settingsSummary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
              )),
        ],
      ),
    );
  }

  Widget _buildGenerationSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generation Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Image size selection
          _buildSettingSection(
            context,
            'Image Size',
            Row(
              children: controller.imageSizeOptions.keys.map((size) {
                return Expanded(
                  child: Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildSettingChip(
                          context,
                          size.capitalize!,
                          controller.selectedImageSize.value == size,
                          () => controller.setImageSize(size),
                        ),
                      )),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Style selection
          _buildSettingSection(
            context,
            'Art Style',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.styleOptions.map((style) {
                return Obx(() => _buildSettingChip(
                      context,
                      style.capitalize!,
                      controller.selectedStyle.value == style,
                      () => controller.setStyle(style),
                    ));
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Quality selection
          _buildSettingSection(
            context,
            'Quality',
            Row(
              children: controller.qualityOptions.map((quality) {
                return Expanded(
                  child: Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildSettingChip(
                          context,
                          quality.toUpperCase(),
                          controller.selectedQuality.value == quality,
                          () => controller.setQuality(quality),
                        ),
                      )),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(
      BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildSettingChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCategorySelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Obx(() => controller.selectedCategory.value != null
                ? Text(
                    controller.selectedCategory.value!.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: controller.selectedCategory.value!.color,
                          fontWeight: FontWeight.w600,
                        ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return _buildCategoryCard(context, category);
                },
              )),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, ThemeCategoryModel category) {
    return Obx(() {
      final isSelected =
          controller.selectedCategory.value?.name == category.name;

      return GestureDetector(
        onTap: () => controller.selectCategory(category),
        child: Container(
          width: 100,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? category.color.withOpacity(0.2)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: category.color, width: 2)
                : Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? category.color
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPromptSelection(BuildContext context) {
    return Obx(() {
      if (controller.selectedCategory.value == null) {
        return const SizedBox.shrink();
      }

      final category = controller.selectedCategory.value!;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${category.name} Prompts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: controller.clearSelectedPrompts,
                      child: const Text('Clear'),
                    ),
                    TextButton(
                      onPressed: controller.selectAllPrompts,
                      child: const Text('Select All'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              category.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: category.prompts.map((prompt) {
                return Obx(() => _buildPromptChip(context, prompt));
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
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
                    child: Obx(() => Text(
                          'Selected: ${controller.selectedPromptsCount} prompts',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPromptChip(BuildContext context, String prompt) {
    final isSelected = controller.isPromptSelected(prompt);

    return GestureDetector(
      onTap: () => controller.togglePromptSelection(prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          prompt.length > 35 ? '${prompt.substring(0, 35)}...' : prompt,
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

  Widget _buildCustomPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Prompt',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Text input field
          Obx(() => TextField(
                onChanged: controller.updateCustomPrompt,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Describe your ideal wallpaper in detail...\n\nExample: A beautiful sunset over mountains with reflection in lake, photorealistic style, golden hour lighting',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  suffixIcon: controller.customPrompt.value.isNotEmpty
                      ? IconButton(
                          onPressed: controller.clearCustomPrompt,
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              )),

          const SizedBox(height: 12),

          // Character count
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.customPrompt.value.length}/500 characters',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                  if (controller.customPrompt.value.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Custom prompt ready',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildGenerationActions(BuildContext context) {
    return Column(
      children: [
        // Primary generation buttons
        Obx(() => Column(
              children: [
                // Generate with custom prompt
                if (controller.customPrompt.value.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: controller.generateWithCustomPrompt,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate with Custom Prompt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                // Generate with selected prompts
                if (controller.selectedPrompts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: controller.generateWithSelectedPrompts,
                        icon: const Icon(Icons.palette),
                        label: Text(
                            'Generate with ${controller.selectedPromptsCount} Prompts'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Random generation
                if (controller.selectedCategory.value != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: controller.generateRandomWallpaper,
                        icon: const Icon(Icons.shuffle),
                        label: Text(
                            'Random ${controller.selectedCategory.value!.name}'),
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )),

        const SizedBox(height: 16),

        // Batch generation
        Obx(() => controller.selectedPrompts.length > 1
            ? SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: controller.generateBatch,
                  icon: const Icon(Icons.burst_mode),
                  label: Text(
                      'Batch Generate (${controller.selectedPromptsCount})'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : const SizedBox.shrink()),

        const SizedBox(height: 16),

        // Generation tip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tip: Be specific in your prompts for better results. Include details about lighting, style, and composition.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
