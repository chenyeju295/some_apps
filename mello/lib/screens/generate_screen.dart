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
                        if (userProvider.tokenBalance <= 0) ...[
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
              'No tokens available. Purchase tokens in Profile to start creating.',
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
        userProvider.tokenBalance > 0 && !imageProvider.isGenerating;

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
                          '(200 Token)',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocean image created successfully!'),
          backgroundColor: AppTheme.seaFoam,
        ),
      );
    }
  }
}
