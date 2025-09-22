import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';
import '../models/diving_content.dart';
import '../theme/app_theme.dart';
import '../widgets/common/error_message.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: DivingCategory.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ContentProvider, UserProvider>(
        builder: (context, contentProvider, userProvider, child) {
          if (contentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (contentProvider.error != null) {
            return ErrorMessage(
              message: contentProvider.error!,
              onRetry: () => contentProvider.loadContent(),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: const Text('Learn Diving'),
                  floating: true,
                  pinned: true,
                  expandedHeight: 120,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: AppTheme.oceanGradientDecoration,
                      child: const SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore the depths of diving knowledge',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: DivingCategory.values.map((category) {
                      return Tab(text: category.displayName);
                    }).toList(),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: DivingCategory.values.map((category) {
                final categoryContent = contentProvider.getContentByCategory(category.displayName);
                return _CategoryContentList(
                  content: categoryContent,
                  userProvider: userProvider,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryContentList extends StatelessWidget {
  final List<DivingContent> content;
  final UserProvider userProvider;

  const _CategoryContentList({
    required this.content,
    required this.userProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const Center(
        child: Text('No content available for this category'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];
        final isCompleted = userProvider.isContentCompleted(item.id);
        final isBookmarked = userProvider.isBookmarked(item.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.oceanGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(item.difficulty),
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
                    Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(
                      '${item.readTimeMinutes}m read',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getContentPreview(item.content),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppTheme.coral : Colors.grey,
                  size: 20,
                ),
              ],
            ),
            onTap: () {
              _showContentDetail(context, item, userProvider);
            },
          ),
        );
      },
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
    return content.length > 100 ? '${content.substring(0, 100)}...' : content;
  }

  void _showContentDetail(BuildContext context, DivingContent content, UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                userProvider.addBookmark(content.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Added to bookmarks')),
                                );
                              },
                              icon: const Icon(Icons.bookmark_add),
                              label: const Text('Bookmark'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                userProvider.markContentCompleted(content.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Marked as completed')),
                                );
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Mark Complete'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          content.content,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
