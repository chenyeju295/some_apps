import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/generation_controller.dart';
import '../controllers/balance_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/navigation_controller.dart';
import '../models/theme_category_model.dart';
import '../models/wallpaper_model.dart';
import '../models/product_model.dart';
import '../widgets/loading_overlay.dart';

class GenerationView extends StatefulWidget {
  const GenerationView({super.key});

  @override
  State<GenerationView> createState() => _GenerationViewState();
}

class _GenerationViewState extends State<GenerationView>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  GenerationController get controller => Get.find<GenerationController>();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _handleArguments();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _handleArguments() {
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
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.all(20),
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
                        const SizedBox(height: 24),

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
              ? const LoadingOverlay(message: 'Creating your masterpiece...')
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: Theme.of(context).iconTheme.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Create Magic',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
              ),
            ),
            _buildCrystalBalance(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPromptInput(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Describe your vision',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: controller.customPrompt.value.isNotEmpty
                          ? Theme.of(context).primaryColor.withOpacity(0.05)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: controller.customPrompt.value.isNotEmpty
                            ? Theme.of(context).primaryColor.withOpacity(0.3)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      onChanged: controller.updateCustomPrompt,
                      maxLines: 4,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText:
                            'A majestic dragon soaring through clouds at sunset...',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: controller.customPrompt.value.isNotEmpty
                            ? IconButton(
                                onPressed: controller.clearCustomPrompt,
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.customPrompt.value.length}/500',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.6),
                            ),
                      ),
                      if (controller.customPrompt.value.isNotEmpty)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Ready ✨',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCategoryTabs(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Style',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.color
                        ?.withOpacity(0.8),
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];

                  return Obx(() {
                    final isSelected =
                        controller.selectedCategory.value?.name ==
                            category.name;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(right: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            controller.selectCategory(category);
                            // Trigger a small scale animation
                            _scaleController.reset();
                            _scaleController.forward();
                          },
                          borderRadius: BorderRadius.circular(25),
                          splashColor: category.color.withOpacity(0.2),
                          highlightColor: category.color.withOpacity(0.1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        category.color,
                                        category.color.withOpacity(0.8),
                                      ],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? category.color
                                    : category.color.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: category.color.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: category.color.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  transform: Matrix4.identity()
                                    ..scale(isSelected ? 1.1 : 1.0),
                                  child: Icon(
                                    category.icon,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : category.color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 14,
                                    letterSpacing: isSelected ? 0.5 : 0,
                                  ),
                                  child: Text(category.name),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPresetPrompts(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
        )),
        child: Obx(() {
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
                    '${category.name} Ideas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.color
                              ?.withOpacity(0.8),
                        ),
                  ),
                  if (controller.selectedPrompts.isNotEmpty)
                    TextButton.icon(
                      onPressed: controller.clearSelectedPrompts,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: category.prompts.take(8).map((prompt) {
                    return Obx(() => _buildAnimatedPromptChip(context, prompt));
                  }).toList(),
                ),
              ),
              if (category.prompts.length > 8) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showAllPrompts(context, category),
                    icon: const Icon(Icons.expand_more, size: 18),
                    label: Text('View all ${category.prompts.length} ideas'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAnimatedPromptChip(BuildContext context, String prompt) {
    final isSelected = controller.isPromptSelected(prompt);
    final displayPrompt =
        prompt.length > 24 ? '${prompt.substring(0, 24)}...' : prompt;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.togglePromptSelection(prompt),
          borderRadius: BorderRadius.circular(20),
          splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    )
                  : null,
              color: isSelected ? null : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                      letterSpacing: isSelected ? 0.3 : 0,
                    ),
                    child: Text(
                      displayPrompt,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedGenerateButton(context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
        )),
        child: Obx(() {
          final hasContent = controller.customPrompt.value.isNotEmpty ||
              controller.selectedPrompts.isNotEmpty;
          final crystalCost = CrystalCosts.calculateGenerationCost(
            quality: controller.selectedQuality.value,
            style: controller.selectedStyle.value,
          );

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: hasContent ? _handleGenerate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasContent
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: hasContent ? 8 : 0,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: hasContent
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, size: 24),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getGenerateButtonText(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$crystalCost crystals',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_outlined,
                              color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 8),
                          Text(
                            'Enter your idea first',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecentGenerations(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
        )),
        child: GetBuilder<HomeController>(
          builder: (homeController) {
            final recentWallpapers =
                homeController.generatedWallpapers.take(6).toList();

            if (recentWallpapers.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Creations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.find<NavigationController>()
                            .navigateToTab('Favorites');
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentWallpapers.length,
                    itemBuilder: (context, index) {
                      return _buildRecentItem(
                          context, recentWallpapers[index], index);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentItem(
      BuildContext context, WallpaperModel wallpaper, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          Get.toNamed('/wallpaper-detail', arguments: wallpaper);
        },
        child: Container(
          width: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: wallpaper.hasLocalFile
                ? Image.asset(
                    wallpaper.localPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).cardColor,
                        child: Icon(
                          Icons.image_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Theme.of(context).cardColor,
                    child: Icon(
                      Icons.image_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrystalBalance(BuildContext context) {
    final balanceController = Get.find<BalanceController>();

    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.diamond,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                balanceController.formattedBalance,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
      return 'Create Magic';
    } else if (controller.selectedPrompts.isNotEmpty) {
      return 'Generate Wallpaper';
    }
    return 'Create Wallpaper';
  }

  void _handleGenerate() {
    if (controller.customPrompt.value.isNotEmpty) {
      controller.generateWithCustomPrompt();
    } else if (controller.selectedPrompts.isNotEmpty) {
      controller.generateWithSelectedPrompts();
    }
  }

  void _showAllPrompts(BuildContext context, ThemeCategoryModel category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '${category.name} Ideas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: category.prompts.length,
                    itemBuilder: (context, index) {
                      final prompt = category.prompts[index];
                      return _buildAnimatedPromptChip(context, prompt);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
