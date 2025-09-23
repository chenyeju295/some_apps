import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diving_content.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/ocean_animations.dart';

class ContentDetailScreen extends StatefulWidget {
  final DivingContent content;
  final List<DivingContent>? relatedContent;

  const ContentDetailScreen({
    super.key,
    required this.content,
    this.relatedContent,
  });

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _progressController;
  late ScrollController _scrollController;

  bool _isBookmarked = false;
  bool _isCompleted = false;
  double _readingProgress = 0.0;
  bool _isReading = false;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _progressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeUserData() {
    final userProvider = context.read<UserProvider>();
    setState(() {
      _isBookmarked = userProvider.isBookmarked(widget.content.id);
      _isCompleted = userProvider.isContentCompleted(widget.content.id);
    });
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll > 0) {
      final progress = currentScroll / maxScroll;
      setState(() {
        _readingProgress = progress.clamp(0.0, 1.0);
        _isReading = progress > 0.1;
      });

      // Auto-complete when 90% read
      if (progress >= 0.9 && !_isCompleted) {
        _markAsCompleted();
      }
    }
  }

  void _markAsCompleted() async {
    if (_isCompleted) return;

    final userProvider = context.read<UserProvider>();
    await userProvider.markContentCompleted(widget.content.id);

    setState(() {
      _isCompleted = true;
    });

    _progressController.forward();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Lesson completed! Well done!'),
            ],
          ),
          backgroundColor: AppTheme.seaFoam,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Header
          _buildHeroHeader(),

          // Content Body
          _buildContentBody(),

          // Related Content
          if (widget.relatedContent?.isNotEmpty == true) _buildRelatedContent(),

          // Bottom Actions
          _buildBottomActions(),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Reading Progress Indicator
      bottomNavigationBar: _isReading ? _buildProgressIndicator() : null,
    );
  }

  Widget _buildHeroHeader() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [


      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background with category-specific image
            Container(
              decoration: BoxDecoration(
                gradient: _getCategoryGradient(widget.content.category),
              ),
            ),

            // Category-specific background image
            if (widget.content.imageUrl != null)
              Positioned.fill(
                child: Image.asset(
                  widget.content.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: _getCategoryGradient(widget.content.category),
                      ),
                    );
                  },
                ),
              ),

            // Gradient overlay
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

            // Floating elements
            Positioned(
              top: 120,
              right: 30,
              child: OceanAnimations.floatingWidget(
                offset: 15.0,
                duration: const Duration(seconds: 4),
                child: Icon(
                  _getCategoryIcon(widget.content.category),
                  color: Colors.white.withOpacity(0.3),
                  size: 80,
                ),
              ),
            ),

            // Content info
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and difficulty badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.content.category,
                          style: TextStyle(
                            color: _getCategoryColor(widget.content.category),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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
                          color: _getDifficultyColor(widget.content.difficulty)
                              .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.content.difficulty,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_isCompleted)
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_progressController.value * 0.2),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.seaFoam.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    widget.content.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Reading time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.content.readTimeMinutes} min read',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
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
    );
  }

  Widget _buildContentBody() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Tags
          if (widget.content.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.content.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightAqua,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.seaFoam.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: AppTheme.oceanBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Content
          OceanAnimations.staggeredList(
            index: 0,
            child: _buildMarkdownContent(widget.content.content),
          ),
        ]),
      ),
    );
  }

  Widget _buildMarkdownContent(String content) {
    // Simple markdown parser for basic formatting
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(2),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(3),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.substring(4),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
      } else if (line.startsWith('* ') || line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.seaFoam,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.trim().isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRelatedContent() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Related Content',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.relatedContent!.length,
                itemBuilder: (context, index) {
                  final content = widget.relatedContent![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ContentDetailScreen(
                            content: content,
                            relatedContent: widget.relatedContent,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getCategoryIcon(content.category),
                                color: _getCategoryColor(content.category),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                content.category,
                                style: TextStyle(
                                  color: _getCategoryColor(content.category),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            '${content.readTimeMinutes}m read',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isCompleted ? null : _markAsCompleted,
                icon: Icon(_isCompleted ? Icons.check : Icons.school),
                label: Text(_isCompleted ? 'Completed' : 'Mark as Complete'),
                style: _isCompleted
                    ? AppTheme.secondaryButtonStyle
                    : AppTheme.primaryButtonStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      child: LinearProgressIndicator(
        value: _readingProgress,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.seaFoam),
      ),
    );
  }

  // Helper methods
  LinearGradient _getCategoryGradient(String category) {
    final color = _getCategoryColor(category);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(0.8),
        color,
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'safety':
        return Icons.security;
      case 'equipment':
        return Icons.build;
      case 'marine life':
        return Icons.pets;
      case 'techniques':
        return Icons.fitness_center;
      case 'certification':
        return Icons.card_membership;
      case 'destinations':
        return Icons.map;
      default:
        return Icons.article;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'safety':
        return AppTheme.coral;
      case 'equipment':
        return AppTheme.oceanBlue;
      case 'marine life':
        return AppTheme.tropicalTeal;
      case 'techniques':
        return AppTheme.deepSeaGreen;
      case 'certification':
        return AppTheme.aquaMarine;
      case 'destinations':
        return AppTheme.seaFoam;
      default:
        return AppTheme.deepNavy;
    }
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
