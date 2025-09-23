import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';
import '../models/diving_content.dart';
import '../theme/app_theme.dart';
import '../widgets/common/error_message.dart';
import '../widgets/animations/ocean_animations.dart';
import 'content_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: AppTheme.waveAnimation,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ContentProvider, UserProvider>(
        builder: (context, contentProvider, userProvider, child) {
          if (contentProvider.isLoading) {
            return Container(
              decoration: AppTheme.oceanDepthDecoration,
              child: Center(
                child: OceanAnimations.pulsingGlow(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pearl),
                    strokeWidth: 3,
                  ),
                  glowColor: AppTheme.seaFoam,
                ),
              ),
            );
          }

          if (contentProvider.error != null) {
            return ErrorMessage(
              message: contentProvider.error!,
              onRetry: () => contentProvider.loadContent(),
            );
          }

          return CustomScrollView(
            slivers: [
              // Hero Header with Background Image
              _buildHeroHeader(),

              // Knowledge Categories Grid
              _buildKnowledgeCategories(userProvider),

              // Featured Learning Path
              _buildFeaturedLearningPath(contentProvider, userProvider),

              // Quick Tips Section
              _buildQuickTipsSection(),

              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/ocean_knowledge_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Animated Waves
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    animationValue: _waveController.value,
                    waveHeight: 20.0,
                    isInverted: true,
                  ),
                  child: Container(),
                );
              },
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OceanAnimations.staggeredList(
                      index: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              OceanAnimations.floatingWidget(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.seaFoam.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.seaFoam.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Ocean Knowledge',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dive deeper into marine wisdom',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
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

  Widget _buildKnowledgeCategories(UserProvider userProvider) {
    final categories = [
      _KnowledgeCategory(
        title: 'Diving Safety',
        subtitle: 'Essential skills',
        imagePath: 'assets/images/diving_safety_instructor.png',
        color: AppTheme.coral,
        icon: Icons.security,
        category: DivingCategory.safety,
      ),
      _KnowledgeCategory(
        title: 'Marine Life',
        subtitle: 'Ocean wonders',
        imagePath: 'assets/images/female_diver_turtle.png',
        color: AppTheme.tropicalTeal,
        icon: Icons.pets,
        category: DivingCategory.marineLife,
      ),
      _KnowledgeCategory(
        title: 'Equipment',
        subtitle: 'Gear mastery',
        imagePath: 'assets/images/diving_equipment_showcase.png',
        color: AppTheme.oceanBlue,
        icon: Icons.build,
        category: DivingCategory.equipment,
      ),
      _KnowledgeCategory(
        title: 'Techniques',
        subtitle: 'Advanced skills',
        imagePath: 'assets/images/diving_techniques_demo.png',
        color: AppTheme.deepSeaGreen,
        icon: Icons.fitness_center,
        category: DivingCategory.techniques,
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = categories[index];
            return OceanAnimations.staggeredList(
              index: index,
              delay: 100,
              child: _KnowledgeCategoryCard(
                category: category,
                onTap: () => _showCategoryContent(context, category),
              ),
            );
          },
          childCount: categories.length,
        ),
      ),
    );
  }

  Widget _buildFeaturedLearningPath(
      ContentProvider contentProvider, UserProvider userProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Learning Path',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: AppTheme.animatedCardDecoration.copyWith(
                image: const DecorationImage(
                  image: AssetImage('assets/images/coral_welcome.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beginner\'s Journey',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start your underwater adventure',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.seaFoam.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '6 Lessons',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.coral.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Beginner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildQuickTipsSection() {
    final tips = [
      _QuickTip(
        title: 'Never Hold Breath',
        description: 'Always breathe continuously',
        icon: Icons.air,
        color: AppTheme.coral,
      ),
      _QuickTip(
        title: 'Check Equipment',
        description: 'Pre-dive safety inspection',
        icon: Icons.check_circle,
        color: AppTheme.seaFoam,
      ),
      _QuickTip(
        title: 'Buddy System',
        description: 'Stay close to your partner',
        icon: Icons.people,
        color: AppTheme.oceanBlue,
      ),
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Safety Tips',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...tips.asMap().entries.map((entry) {
              return OceanAnimations.staggeredList(
                index: entry.key,
                delay: 150,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cardDecoration,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: entry.value.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          entry.value.icon,
                          color: entry.value.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.value.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.value.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showCategoryContent(BuildContext context, _KnowledgeCategory category) {
    final contentProvider = context.read<ContentProvider>();
    final categoryContent =
        contentProvider.getContentByCategory(category.category.displayName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryDetailSheet(
        category: category,
        content: categoryContent,
      ),
    );
  }
}

class _KnowledgeCategory {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color color;
  final IconData icon;
  final DivingCategory category;

  const _KnowledgeCategory({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.color,
    required this.icon,
    required this.category,
  });
}

class _QuickTip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _QuickTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _KnowledgeCategoryCard extends StatelessWidget {
  final _KnowledgeCategory category;
  final VoidCallback onTap;

  const _KnowledgeCategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.animatedCardDecoration.copyWith(
          boxShadow: AppTheme.floatingShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              Image.asset(
                category.imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          category.color.withOpacity(0.7),
                          category.color,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        category.icon,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              category.icon,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  category.subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
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
              // Ripple Effect
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: category.color.withOpacity(0.3),
                  highlightColor: category.color.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDetailSheet extends StatelessWidget {
  final _KnowledgeCategory category;
  final List<DivingContent> content;

  const _CategoryDetailSheet({
    required this.category,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${content.length} lessons available',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Content List
              Expanded(
                child: content.isEmpty
                    ? _buildEmptyState()
                    : _buildContentList(context, scrollController),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Wave Painter for animated background
class WavePainter extends CustomPainter {
  final double animationValue;
  final double waveHeight;
  final bool isInverted;

  WavePainter({
    required this.animationValue,
    required this.waveHeight,
    this.isInverted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveLength = size.width / 2;
    final waveOffset = animationValue * waveLength * 2;

    if (isInverted) {
      path.moveTo(-waveLength + waveOffset, size.height);
      for (double x = -waveLength; x <= size.width + waveLength; x += 1) {
        final y = size.height -
            waveHeight *
                (1 + sin((x + waveOffset) * 2 * 3.14159 / waveLength)) /
                2;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      path.moveTo(-waveLength + waveOffset, 0);
      for (double x = -waveLength; x <= size.width + waveLength; x += 1) {
        final y = waveHeight *
            (1 + sin((x + waveOffset) * 2 * 3.14159 / waveLength)) /
            2;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Extension methods for _CategoryDetailSheet
extension _CategoryDetailSheetMethods on _CategoryDetailSheet {
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We\'re preparing comprehensive ${category.title.toLowerCase()} content for you. Stay tuned!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList(
      BuildContext context, ScrollController scrollController) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: content.length,
          itemBuilder: (context, index) {
            final item = content[index];
            final isCompleted = userProvider.isContentCompleted(item.id);
            final isBookmarked = userProvider.isBookmarked(item.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ContentDetailScreen(
                          content: item,
                          relatedContent: content
                              .where((c) => c.id != item.id)
                              .take(5)
                              .toList(),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppTheme.seaFoam
                                : category.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : category.icon,
                            color: isCompleted ? Colors.white : category.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _getDifficultyColor(item.difficulty),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.difficulty,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item.readTimeMinutes}m',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            if (isBookmarked)
                              Icon(
                                Icons.bookmark,
                                color: AppTheme.coral,
                                size: 16,
                              ),
                            if (isCompleted)
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.seaFoam,
                                size: 16,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
