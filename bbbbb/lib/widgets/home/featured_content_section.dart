import 'package:flutter/material.dart';
import '../../models/diving_content.dart';
import '../../theme/app_theme.dart';

class FeaturedContentSection extends StatelessWidget {
  final List<DivingContent> featuredContent;
  final Function(DivingContent) onContentTap;

  const FeaturedContentSection({
    super.key,
    required this.featuredContent,
    required this.onContentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (featuredContent.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Featured Learning',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.deepNavy,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to learn tab
                  DefaultTabController.of(context).animateTo(1);
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppTheme.oceanBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featuredContent.length,
              itemBuilder: (context, index) {
                final content = featuredContent[index];
                return _FeaturedContentCard(
                  content: content,
                  onTap: () => onContentTap(content),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedContentCard extends StatelessWidget {
  final DivingContent content;
  final VoidCallback onTap;

  const _FeaturedContentCard({
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.oceanGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Icon(
                      _getCategoryIcon(content.category),
                      color: Colors.white.withOpacity(0.3),
                      size: 60,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        content.category,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.deepNavy,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(content.difficulty),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            content.difficulty,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${content.readTimeMinutes}m',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.deepNavy,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: Text(
                        _getContentPreview(content.content),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tags
                    Wrap(
                      spacing: 4,
                      children: content.tags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightAqua,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.oceanBlue,
                                ),
                          ),
                        );
                      }).toList(),
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
    // Remove markdown headers and get first paragraph
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
}
