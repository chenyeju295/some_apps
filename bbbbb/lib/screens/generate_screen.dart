import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_image_provider.dart';
import '../providers/user_provider.dart';
import '../models/generated_image.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/ocean_animations.dart';
import '../services/together_ai_service.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  final TextEditingController _promptController = TextEditingController();
  ImageStyle _selectedStyle = ImageStyle.realistic;
  bool _isAdvancedMode = false;
  int _selectedWidth = 1024;
  int _selectedHeight = 1024;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _floatingController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<EnhancedImageProvider, UserProvider>(
        builder: (context, imageProvider, userProvider, child) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildEnhancedAppBar(userProvider),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _EnhancedGenerateTab(
                  promptController: _promptController,
                  selectedStyle: _selectedStyle,
                  isAdvancedMode: _isAdvancedMode,
                  selectedWidth: _selectedWidth,
                  selectedHeight: _selectedHeight,
                  onStyleChanged: (style) =>
                      setState(() => _selectedStyle = style),
                  onAdvancedModeToggle: () =>
                      setState(() => _isAdvancedMode = !_isAdvancedMode),
                  onSizeChanged: (width, height) => setState(() {
                    _selectedWidth = width;
                    _selectedHeight = height;
                  }),
                  imageProvider: imageProvider,
                  userProvider: userProvider,
                  floatingController: _floatingController,
                  pulseController: _pulseController,
                ),
                _EnhancedGalleryTab(
                  imageProvider: imageProvider,
                  floatingController: _floatingController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedAppBar(UserProvider userProvider) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Enhanced gradient background with multiple layers
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.deepNavy,
                    AppTheme.oceanBlue,
                    AppTheme.tropicalTeal.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),

            // Animated wave pattern overlay
            Positioned.fill(
              child: CustomPaint(
                painter: WavePatternPainter(),
              ),
            ),

            // Enhanced floating elements with more variety
            Positioned(
              top: 50,
              right: 20,
              child: OceanAnimations.floatingWidget(
                offset: 25.0,
                duration: const Duration(seconds: 4),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 90,
              left: 30,
              child: OceanAnimations.floatingWidget(
                offset: 18.0,
                duration: const Duration(seconds: 3),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.08),
                  ),
                  child: Icon(
                    Icons.palette,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 70,
              left: 120,
              child: OceanAnimations.floatingWidget(
                offset: 15.0,
                duration: const Duration(seconds: 5),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.seaFoam.withOpacity(0.6),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.seaFoam.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content with improved layout
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [Colors.white, Color(0xFFE3F2FD)],
                                ).createShader(bounds),
                                child: const Text(
                                  'AI Ocean Studio',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Create stunning underwater imagery',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        OceanAnimations.pulsingGlow(
                          glowColor: AppTheme.seaFoam,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.seaFoam.withOpacity(0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.seaFoam.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.monetization_on,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${userProvider.tokenBalance}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.seaFoam,
            indicatorWeight: 4,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 24),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: [
              Tab(
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 24),
                    const SizedBox(height: 4),
                    Text('Create'),
                  ],
                ),
              ),
              Tab(
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, size: 24),
                    const SizedBox(height: 4),
                    Text('Gallery'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedGenerateTab extends StatelessWidget {
  final TextEditingController promptController;
  final ImageStyle selectedStyle;
  final bool isAdvancedMode;
  final int selectedWidth;
  final int selectedHeight;
  final Function(ImageStyle) onStyleChanged;
  final VoidCallback onAdvancedModeToggle;
  final Function(int, int) onSizeChanged;
  final EnhancedImageProvider imageProvider;
  final UserProvider userProvider;
  final AnimationController floatingController;
  final AnimationController pulseController;

  const _EnhancedGenerateTab({
    required this.promptController,
    required this.selectedStyle,
    required this.isAdvancedMode,
    required this.selectedWidth,
    required this.selectedHeight,
    required this.onStyleChanged,
    required this.onAdvancedModeToggle,
    required this.onSizeChanged,
    required this.imageProvider,
    required this.userProvider,
    required this.floatingController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Token status card
          if (userProvider.tokenBalance <= 0) ...[
            _buildTokenWarningCard(context),
            const SizedBox(height: 20),
          ],

          // Prompt input section
          _buildPromptSection(context),
          const SizedBox(height: 24),

          // Style selection
          _buildStyleSection(context),
          const SizedBox(height: 24),

          // Advanced settings
          _buildAdvancedSettings(context),
          const SizedBox(height: 24),

          // Inspiration section
          _buildInspirationSection(context),
          const SizedBox(height: 32),

          // Generate button
          _buildGenerateButton(context),
          const SizedBox(height: 16),

          // Generation progress indicator
          if (imageProvider.isGenerating) ...[
            _buildGenerationProgress(context),
            const SizedBox(height: 16),
          ],

          // Error display
          if (imageProvider.error != null) ...[
            _buildErrorCard(context),
            const SizedBox(height: 16),
          ],

          // Recent generation (if any)
          if (imageProvider.images.isNotEmpty) ...[
            _buildRecentGeneration(context),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildTokenWarningCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.coral.withOpacity(0.1),
            AppTheme.coral.withOpacity(0.05)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.coral.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.coral.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.coral,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Tokens Available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.coral,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Purchase tokens in your Profile to start creating amazing ocean imagery',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.deepNavy,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.lightAqua.withOpacity(0.1),
                AppTheme.seaFoam.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.lightAqua.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.oceanBlue, AppTheme.tropicalTeal],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.oceanBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_note,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Describe Your Ocean Vision',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.deepNavy,
                                    letterSpacing: -0.3,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'The more detailed, the better your results',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.oceanBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.lightAqua.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.oceanBlue.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: promptController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'A magnificent sea turtle swimming gracefully through crystal clear water with vibrant coral formations and tropical fish...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                      height: 1.4,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppTheme.deepNavy,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.seaFoam,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pro tip: Include colors, lighting, and emotions for stunning results',
                    style: TextStyle(
                      color: AppTheme.seaFoam,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.tropicalTeal.withOpacity(0.08),
                AppTheme.oceanBlue.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.tropicalTeal.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.tropicalTeal, AppTheme.seaFoam],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.tropicalTeal.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.palette,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Choose Your Art Style',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.deepNavy,
                          letterSpacing: -0.3,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: ImageStyle.values.length,
                itemBuilder: (context, index) {
                  final style = ImageStyle.values[index];
                  final isSelected = style == selectedStyle;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onStyleChanged(style),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.oceanBlue.withOpacity(0.15),
                                    AppTheme.tropicalTeal.withOpacity(0.1),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [Colors.white, Colors.grey[50]!],
                                ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.oceanBlue
                                : Colors.grey[300]!,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.oceanBlue.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          AppTheme.oceanBlue,
                                          AppTheme.tropicalTeal
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.grey[400]!,
                                          Colors.grey[500]!
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? AppTheme.oceanBlue.withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getStyleIcon(style),
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    style.displayName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppTheme.oceanBlue
                                          : AppTheme.deepNavy,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Selected',
                                      style: TextStyle(
                                        color: AppTheme.seaFoam,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.seaFoam,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.tune,
              color: AppTheme.deepSeaGreen,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Advanced Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
            ),
            const Spacer(),
            Switch(
              value: isAdvancedMode,
              onChanged: (_) => onAdvancedModeToggle(),
              activeColor: AppTheme.seaFoam,
            ),
          ],
        ),
        if (isAdvancedMode) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightAqua.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Image Dimensions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _SizeChip(
                      label: '1024×1024\nSquare',
                      width: 1024,
                      height: 1024,
                      isSelected:
                          selectedWidth == 1024 && selectedHeight == 1024,
                      onTap: () => onSizeChanged(1024, 1024),
                    ),
                    _SizeChip(
                      label: '1344×768\nLandscape',
                      width: 1344,
                      height: 768,
                      isSelected:
                          selectedWidth == 1344 && selectedHeight == 768,
                      onTap: () => onSizeChanged(1344, 768),
                    ),
                    _SizeChip(
                      label: '768×1344\nPortrait',
                      width: 768,
                      height: 1344,
                      isSelected:
                          selectedWidth == 768 && selectedHeight == 1344,
                      onTap: () => onSizeChanged(768, 1344),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInspirationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppTheme.coral,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Need Inspiration?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: OceanPromptSuggestions.getFeaturedSuggestions().length,
            itemBuilder: (context, index) {
              final suggestion =
                  OceanPromptSuggestions.getFeaturedSuggestions()[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => promptController.text = suggestion,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: AppTheme.seaFoam,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to use',
                                style: TextStyle(
                                  color: AppTheme.seaFoam,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenerationProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.oceanBlue.withOpacity(0.1),
            AppTheme.seaFoam.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.oceanBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: imageProvider.generationProgress,
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.oceanBlue),
                  backgroundColor: AppTheme.lightAqua,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGenerationStateText(imageProvider.generationState),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                    ),
                    if (imageProvider.generationStatusMessage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        imageProvider.generationStatusMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.oceanBlue,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${(imageProvider.generationProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.oceanBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: imageProvider.generationProgress,
            backgroundColor: AppTheme.lightAqua,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.oceanBlue),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  String _getGenerationStateText(GenerationState state) {
    switch (state) {
      case GenerationState.preparing:
        return 'Preparing Request';
      case GenerationState.generating:
        return 'Creating Ocean Art';
      case GenerationState.processing:
        return 'Processing Image';
      case GenerationState.saving:
        return 'Saving to Gallery';
      case GenerationState.completed:
        return 'Creation Complete!';
      default:
        return 'Generating...';
    }
  }

  Widget _buildGenerateButton(BuildContext context) {
    final canGenerate =
        userProvider.tokenBalance > 0 && !imageProvider.isGenerating;

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: canGenerate
            ? [
                BoxShadow(
                  color: AppTheme.oceanBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppTheme.seaFoam.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: canGenerate ? () => _generateImage(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: canGenerate
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.oceanBlue,
                      AppTheme.tropicalTeal,
                      AppTheme.seaFoam,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  )
                : LinearGradient(
                    colors: [Colors.grey[400]!, Colors.grey[500]!],
                  ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: imageProvider.isGenerating
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Creating Ocean Magic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'This might take a moment...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Generate Ocean Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '1 Token Required',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.coral.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.coral.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.coral),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              imageProvider.error!,
              style: TextStyle(color: AppTheme.deepNavy),
            ),
          ),
          TextButton(
            onPressed: () => imageProvider.clearError(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGeneration(BuildContext context) {
    final recentImage = imageProvider.images.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: AppTheme.seaFoam,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Latest Creation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.lightAqua,
                ),
                child: recentImage.imageUrl.startsWith('/')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(recentImage.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              color: AppTheme.oceanBlue,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.image,
                        color: AppTheme.oceanBlue,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recentImage.title ?? recentImage.prompt,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recentImage.style.displayName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Already on generate screen, scroll to gallery section
                  Navigator.of(context).maybePop();
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.oceanBlue,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getStyleIcon(ImageStyle style) {
    switch (style) {
      case ImageStyle.realistic:
        return Icons.photo_camera;
      case ImageStyle.artistic:
        return Icons.brush;
      case ImageStyle.vintage:
        return Icons.filter_vintage;
      default:
        return Icons.image;
    }
  }

  void _generateImage(BuildContext context) async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a prompt to describe your vision'),
          backgroundColor: AppTheme.coral,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await imageProvider.generateImage(
      prompt: prompt,
      style: selectedStyle,
      onTokensUsed: (tokens) {
        userProvider.useTokens(tokens);
        userProvider.incrementImagesGenerated();
      },
    );

    if (result != null) {
      promptController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Ocean image created successfully!'),
            ],
          ),
          backgroundColor: AppTheme.seaFoam,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class _SizeChip extends StatelessWidget {
  final String label;
  final int width;
  final int height;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeChip({
    required this.label,
    required this.width,
    required this.height,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.seaFoam : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.seaFoam : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.deepNavy,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _EnhancedGalleryTab extends StatelessWidget {
  final EnhancedImageProvider imageProvider;
  final AnimationController floatingController;

  const _EnhancedGalleryTab({
    required this.imageProvider,
    required this.floatingController,
  });

  @override
  Widget build(BuildContext context) {
    if (imageProvider.images.isEmpty) {
      return _buildEmptyGalleryState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await imageProvider.loadImages();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: imageProvider.images.length,
        itemBuilder: (context, index) {
          final image = imageProvider.images[index];
          return OceanAnimations.staggeredList(
            index: index,
            delay: 100,
            child: _EnhancedImageCard(
              image: image,
              onTap: () => _showImageDetail(context, image),
              onFavoriteToggle: () =>
                  imageProvider.toggleImageFavorite(image.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyGalleryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OceanAnimations.floatingWidget(
            offset: 20.0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.sunlightGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.floatingShadow,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Ocean Images Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start creating beautiful underwater scenes with AI. Your gallery will showcase all your generated ocean imagery.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Builder(
            builder: (context) => ElevatedButton.icon(
              onPressed: () {
                // Already on generate tab, just dismiss any modals
                Navigator.of(context).maybePop();
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Create Your First Image'),
              style: AppTheme.primaryButtonStyle,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDetail(BuildContext context, GeneratedImage image) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _ImageDetailDialog(image: image),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppTheme.normalAnimation,
        opaque: false,
      ),
    );
  }
}

class _EnhancedImageCard extends StatelessWidget {
  final GeneratedImage image;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _EnhancedImageCard({
    required this.image,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.oceanBlue.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with enhanced styling
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        // Image display with hero animation
                        Hero(
                          tag: 'image_${image.id}',
                          child: image.imageUrl.startsWith('/')
                              ? Image.file(
                                  File(image.imageUrl),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholder();
                                  },
                                )
                              : Image.asset(
                                  image.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholder();
                                  },
                                ),
                        ),

                        // Gradient overlay for better contrast
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                ],
                                stops: const [0.7, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Enhanced favorite button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: onFavoriteToggle,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                image.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: image.isFavorite
                                    ? AppTheme.coral
                                    : Colors.grey[600],
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                        // Style badge
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.oceanBlue.withOpacity(0.9),
                                  AppTheme.tropicalTeal.withOpacity(0.9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              image.style.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Enhanced content section
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with better typography
                      Text(
                        image.title ?? image.prompt,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.deepNavy,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),

                      // Enhanced footer with more info
                      Row(
                        children: [
                          // Time indicator with icon
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: AppTheme.seaFoam,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(image.createdAt),
                                style: TextStyle(
                                  color: AppTheme.seaFoam,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // View indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightAqua.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility,
                                  size: 12,
                                  color: AppTheme.oceanBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'View',
                                  style: TextStyle(
                                    color: AppTheme.oceanBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppTheme.oceanDepthDecoration,
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.white.withOpacity(0.5),
          size: 40,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }
}

// Wave pattern painter for the header background
class WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();

    // Create multiple wave layers
    for (int i = 0; i < 3; i++) {
      path.reset();
      final yOffset = size.height * 0.3 + i * 20;
      final amplitude = 15.0 - i * 3;
      final frequency = 0.02 + i * 0.005;

      path.moveTo(0, yOffset);

      for (double x = 0; x <= size.width; x += 2) {
        final y = yOffset + amplitude * sin(x * frequency);
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ImageDetailDialog extends StatelessWidget {
  final GeneratedImage image;

  const _ImageDetailDialog({required this.image});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),

            // Image and details
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    Container(
                      height: 300,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: image.imageUrl.startsWith('/')
                            ? Image.file(
                                File(image.imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.lightAqua,
                                    child: Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 100,
                                        color: AppTheme.oceanBlue,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                image.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.lightAqua,
                                    child: Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 100,
                                        color: AppTheme.oceanBlue,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    // Details
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            image.title ?? image.prompt,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (image.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              image.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Tags and metadata
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightAqua,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  image.style.displayName,
                                  style: TextStyle(
                                    color: AppTheme.oceanBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  context
                                      .read<EnhancedImageProvider>()
                                      .toggleImageFavorite(image.id);
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  image.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: AppTheme.coral,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
