import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_image_provider.dart';
import '../providers/user_provider.dart';
import '../models/generated_image.dart';
import '../theme/app_theme.dart';
import 'history_screen.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController _promptController = TextEditingController();
  ImageStyle _selectedStyle = ImageStyle.realistic;
  static const int TOKEN_COST_PER_GENERATION = 200;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<EnhancedImageProvider, UserProvider>(
        builder: (context, imageProvider, userProvider, child) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildAppBar(userProvider),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (userProvider.tokenBalance <
                            TOKEN_COST_PER_GENERATION) ...[
                          _buildTokenWarning(),
                          const SizedBox(height: 16),
                        ],
                        _buildPromptInput(),
                        const SizedBox(height: 16),
                        _buildStyleSelection(),
                        const SizedBox(height: 16),
                        _buildQuickPrompts(),
                        const SizedBox(height: 16),
                        if (imageProvider.isGenerating) ...[
                          _buildProgress(imageProvider),
                          const SizedBox(height: 16),
                        ],
                        if (imageProvider.error != null) ...[
                          _buildError(imageProvider),
                          const SizedBox(height: 16),
                        ],
                        if (imageProvider.images.isNotEmpty) ...[
                          _buildRecentImage(imageProvider.images.first),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
              _buildGenerateButton(imageProvider, userProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(UserProvider userProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.deepNavy,
                AppTheme.oceanBlue,
                AppTheme.tropicalTeal
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Ocean Studio',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Create stunning underwater imagery',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      _buildTokenBalance(userProvider),
                      const SizedBox(width: 12),
                      _buildHistoryButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenBalance(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
          const SizedBox(width: 6),
          Text(
            '${userProvider.tokenBalance}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text('History',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.coral.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.coral.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: AppTheme.coral),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Insufficient tokens. Need $TOKEN_COST_PER_GENERATION tokens per generation. Purchase more in Profile.',
              style: TextStyle(color: AppTheme.deepNavy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightAqua.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.oceanBlue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppTheme.oceanBlue, AppTheme.tropicalTeal]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_note,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Describe Your Ocean Vision',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepNavy,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'A magnificent sea turtle swimming through crystal clear water...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Art Style',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.deepNavy,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ImageStyle.values.length,
            itemBuilder: (context, index) {
              final style = ImageStyle.values[index];
              final isSelected = style == _selectedStyle;
              final styleColors = _getStyleColors(style);

              return Container(
                width: 110,
                margin: const EdgeInsets.only(right: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedStyle = style),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  styleColors['primary']!.withOpacity(0.15),
                                  styleColors['secondary']!.withOpacity(0.08),
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? styleColors['primary']!
                              : Colors.grey[300]!,
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      styleColors['primary']!.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  styleColors['primary']!,
                                  styleColors['secondary']!,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      styleColors['primary']!.withOpacity(0.3),
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
                          const SizedBox(height: 8),
                          Text(
                            style.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? styleColors['primary']!
                                  : AppTheme.deepNavy,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 20,
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    styleColors['primary']!,
                                    styleColors['secondary']!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
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

  Widget _buildQuickPrompts() {
    final prompts = [
      'Vibrant coral reef with tropical fish',
      'Deep sea creatures with bioluminescence',
      'Professional diver with sea turtle',
      'Underwater cave with blue light',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Ideas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.deepNavy,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: prompts.map((prompt) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _promptController.text = prompt,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.lightAqua.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppTheme.lightAqua.withOpacity(0.5)),
                  ),
                  child: Text(
                    prompt,
                    style: const TextStyle(
                      color: AppTheme.deepNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgress(EnhancedImageProvider imageProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.oceanBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.oceanBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: imageProvider.generationProgress,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.oceanBlue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getStateText(imageProvider.generationState),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text('${(imageProvider.generationProgress * 100).toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildError(EnhancedImageProvider imageProvider) {
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
          Expanded(child: Text(imageProvider.error!)),
          TextButton(
            onPressed: () => imageProvider.clearError(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentImage(GeneratedImage image) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.lightAqua,
            ),
            child: image.imageUrl.startsWith('/')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(image.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.image, color: AppTheme.oceanBlue),
                    ),
                  )
                : Icon(Icons.image, color: AppTheme.oceanBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Latest Creation',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  image.title ?? image.prompt,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
            icon: Icon(Icons.arrow_forward_ios,
                color: AppTheme.oceanBlue, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(
      EnhancedImageProvider imageProvider, UserProvider userProvider) {
    final canGenerate =
        userProvider.tokenBalance >= TOKEN_COST_PER_GENERATION &&
            !imageProvider.isGenerating;

    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 16,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: canGenerate
              ? LinearGradient(
                  colors: [AppTheme.oceanBlue, AppTheme.tropicalTeal])
              : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!]),
          boxShadow: [
            BoxShadow(
              color: canGenerate
                  ? AppTheme.oceanBlue.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canGenerate
                ? () => _generateImage(imageProvider, userProvider)
                : null,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: imageProvider.isGenerating
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Creating...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Generate Ocean Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '($TOKEN_COST_PER_GENERATION Tokens)',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
            ),
          ),
        ),
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
      case ImageStyle.cartoon:
        return Icons.animation;
      case ImageStyle.cinematic:
        return Icons.movie;
    }
  }

  Map<String, Color> _getStyleColors(ImageStyle style) {
    switch (style) {
      case ImageStyle.realistic:
        return {
          'primary': const Color(0xFF2196F3), // Blue
          'secondary': const Color(0xFF42A5F5),
        };
      case ImageStyle.artistic:
        return {
          'primary': const Color(0xFFE91E63), // Pink
          'secondary': const Color(0xFFF06292),
        };
      case ImageStyle.vintage:
        return {
          'primary': const Color(0xFFFF7043), // Deep Orange
          'secondary': const Color(0xFFFFAB91),
        };
      case ImageStyle.cartoon:
        return {
          'primary': const Color(0xFF9C27B0), // Purple
          'secondary': const Color(0xFFBA68C8),
        };
      case ImageStyle.cinematic:
        return {
          'primary': const Color(0xFF607D8B), // Blue Grey
          'secondary': const Color(0xFF90A4AE),
        };
    }
  }

  String _getStateText(GenerationState state) {
    switch (state) {
      case GenerationState.preparing:
        return 'Preparing...';
      case GenerationState.generating:
        return 'Creating...';
      case GenerationState.processing:
        return 'Processing...';
      case GenerationState.saving:
        return 'Saving...';
      case GenerationState.completed:
        return 'Complete!';
      default:
        return 'Generating...';
    }
  }

  void _generateImage(
      EnhancedImageProvider imageProvider, UserProvider userProvider) async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a prompt'),
          backgroundColor: AppTheme.coral,
        ),
      );
      return;
    }

    // Check token balance before generation
    if (userProvider.tokenBalance < TOKEN_COST_PER_GENERATION) {
      _showInsufficientTokensDialog(userProvider);
      return;
    }

    final result = await imageProvider.generateImage(
      prompt: prompt,
      style: _selectedStyle,
      onTokensUsed: (tokens) {
        userProvider.useTokens(tokens);
        userProvider.incrementImagesGenerated();
      },
    );

    if (result != null) {
      _promptController.clear();
      // Show the generated image in a popup
      _showGeneratedImageDialog(result);
    }
  }

  void _showInsufficientTokensDialog(UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppTheme.coral, size: 28),
            const SizedBox(width: 12),
            const Text('Insufficient Tokens'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You need $TOKEN_COST_PER_GENERATION tokens to generate an image.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Current balance: ',
                    style: TextStyle(color: Colors.grey)),
                Text(
                  '${userProvider.tokenBalance} tokens',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Required: ', style: TextStyle(color: Colors.grey)),
                Text(
                  '$TOKEN_COST_PER_GENERATION tokens',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.coral,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to profile screen to buy tokens
              DefaultTabController.of(context).animateTo(3); // Profile tab
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Buy Tokens'),
          ),
        ],
      ),
    );
  }

  void _showGeneratedImageDialog(GeneratedImage image) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _GeneratedImageDialog(image: image),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        opaque: false,
      ),
    );
  }
}

class _GeneratedImageDialog extends StatelessWidget {
  final GeneratedImage image;

  const _GeneratedImageDialog({required this.image});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Image and details
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success indicator
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.oceanBlue, AppTheme.tropicalTeal],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Image Created Successfully!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Image
                    Container(
                      height: 300,
                      width: double.infinity,
                      child: Hero(
                        tag: 'generated_image_${image.id}',
                        child: image.imageUrl.startsWith('/')
                            ? Image.file(
                                File(image.imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.lightAqua,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 80,
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
                                        Icons.image_outlined,
                                        size: 80,
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  image.title ?? image.prompt,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.deepNavy,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.seaFoam,
                                      AppTheme.lightAqua,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  image.style.displayName,
                                  style: const TextStyle(
                                    color: AppTheme.deepNavy,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Token cost info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.oceanBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.oceanBlue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                  color: AppTheme.oceanBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Used ${image.tokensUsed} tokens',
                                  style: TextStyle(
                                    color: AppTheme.oceanBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HistoryScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.history),
                                  label: const Text('View History'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.oceanBlue,
                                    side: BorderSide(color: AppTheme.oceanBlue),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.auto_awesome),
                                  label: const Text('Create More'),
                                  style: AppTheme.primaryButtonStyle.copyWith(
                                    padding: WidgetStateProperty.all(
                                      const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
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
