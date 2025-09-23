import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';
import '../models/diving_content.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/ocean_animations.dart';
import 'content_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
        backgroundColor: AppTheme.oceanBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<ContentProvider, UserProvider>(
        builder: (context, contentProvider, userProvider, child) {
          final bookmarkedIds =
              userProvider.userProgress?.bookmarkedContentIds ?? [];

          if (bookmarkedIds.isEmpty) {
            return _buildEmptyState();
          }

          final bookmarkedContent = contentProvider.allContent
              .where((content) => bookmarkedIds.contains(content.id))
              .toList();

          if (bookmarkedContent.isEmpty) {
            return _buildEmptyState();
          }

          return _buildBookmarksList(bookmarkedContent, userProvider);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OceanAnimations.floatingWidget(
            offset: 20.0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.sunlightGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.floatingShadow,
              ),
              child: const Icon(
                Icons.bookmark_border,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No Bookmarks Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.deepNavy,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start exploring and bookmark your favorite diving content to access them quickly here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to learn tab
              DefaultTabController.of(context).animateTo(1);
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore Content'),
            style: AppTheme.primaryButtonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList(
      List<DivingContent> bookmarkedContent, UserProvider userProvider) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OceanAnimations.floatingWidget(
                      offset: 5.0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.coral.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.bookmark,
                          color: AppTheme.coral,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saved Content',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppTheme.deepNavy,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${bookmarkedContent.length} items saved',
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
              ],
            ),
          ),
        ),

        // Bookmarks Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final content = bookmarkedContent[index];
                return OceanAnimations.staggeredList(
                  index: index,
                  delay: 100,
                  child: _BookmarkCard(
                    content: content,
                    userProvider: userProvider,
                    onTap: () => _navigateToContent(content, bookmarkedContent),
                    onRemoveBookmark: () =>
                        _removeBookmark(content, userProvider),
                  ),
                );
              },
              childCount: bookmarkedContent.length,
            ),
          ),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  void _navigateToContent(
      DivingContent content, List<DivingContent> allBookmarks) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ContentDetailScreen(
          content: content,
          relatedContent:
              allBookmarks.where((c) => c.id != content.id).take(5).toList(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppTheme.normalAnimation,
      ),
    );
  }

  void _removeBookmark(DivingContent content, UserProvider userProvider) {
    userProvider.removeBookmark(content.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${content.title}" from bookmarks'),
        backgroundColor: AppTheme.coral,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            userProvider.addBookmark(content.id);
          },
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final DivingContent content;
  final UserProvider userProvider;
  final VoidCallback onTap;
  final VoidCallback onRemoveBookmark;

  const _BookmarkCard({
    required this.content,
    required this.userProvider,
    required this.onTap,
    required this.onRemoveBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = userProvider.isContentCompleted(content.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: AppTheme.animatedCardDecoration.copyWith(
              boxShadow: AppTheme.floatingShadow,
            ),
            child: Column(
              children: [
                // Header with category and difficulty
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(content.category)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getCategoryIcon(content.category),
                          color: _getCategoryColor(content.category),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content.category,
                              style: TextStyle(
                                color: _getCategoryColor(content.category),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _getDifficultyColor(content.difficulty),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    content.difficulty,
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
                                  '${content.readTimeMinutes}m',
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.seaFoam,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onRemoveBookmark,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.coral.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.bookmark_remove,
                                color: AppTheme.coral,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.deepNavy,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getContentPreview(content.content),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Tags
                if (content.tags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: content.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightAqua,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.seaFoam.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: AppTheme.oceanBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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

  String _getContentPreview(String content) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty &&
          !trimmed.startsWith('#') &&
          !trimmed.startsWith('*') &&
          trimmed.length > 50) {
        return trimmed;
      }
    }
    return content.length > 120 ? '${content.substring(0, 120)}...' : content;
  }
}
