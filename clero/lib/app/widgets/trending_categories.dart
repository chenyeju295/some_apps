import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animations/animations.dart';
import '../models/showcase_model.dart';
import '../controllers/navigation_controller.dart';

class TrendingCategories extends StatefulWidget {
  const TrendingCategories({super.key});

  @override
  State<TrendingCategories> createState() => _TrendingCategoriesState();
}

class _TrendingCategoriesState extends State<TrendingCategories>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _staggerAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final trendingCategories = ShowcaseModel.trendingCategories;
    _staggerAnimations = List.generate(
      trendingCategories.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(
          index * 0.2,
          0.6 + (index * 0.2),
          curve: Curves.easeOutCubic,
        ),
      )),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trendingCategories = ShowcaseModel.trendingCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Trending Categories',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => Get.toNamed('/generation'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Trending categories list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trendingCategories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final category = trendingCategories[index];
            return AnimatedBuilder(
              animation: _staggerAnimations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - _staggerAnimations[index].value), 0),
                  child: Opacity(
                    opacity: _staggerAnimations[index].value,
                    child: _buildTrendingCategoryCard(context, category, index),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendingCategoryCard(
      BuildContext context, ShowcaseModel category, int index) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      transitionDuration: const Duration(milliseconds: 500),
      closedBuilder: (context, action) =>
          _buildCategoryCard(context, category, index),
      openBuilder: (context, action) =>
          Container(), // Placeholder for detail page
      onClosed: (data) {
        // Navigate to generation page with category
        final navController = Get.find<NavigationController>();
        navController.navigateToGeneration(category: category.category);
      },
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, ShowcaseModel category, int index) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Row(
              children: [
                // Image section
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: Image.asset(
                      category.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.7),
                                Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.white.withOpacity(0.7),
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Content section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tags
                            Wrap(
                              spacing: 6,
                              children: category.tags.take(2).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getTagColor(tag).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: _getTagColor(tag),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 6),

                            // Title
                            Text(
                              category.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Subtitle
                            Text(
                              category.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.7),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        // Stats
                        Row(
                          children: [
                            _buildStatItem(
                              Icons.favorite_outline,
                              _formatNumber(category.likes),
                              Colors.red,
                            ),
                            const SizedBox(width: 12),
                            _buildStatItem(
                              Icons.download_outlined,
                              _formatNumber(category.downloads),
                              Colors.blue,
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Trending indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.whatshot,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'HOT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'new':
        return Colors.green;
      case 'hot':
      case 'trending':
        return Colors.orange;
      case 'popular':
        return Colors.blue;
      case 'creative':
        return Colors.purple;
      case 'futuristic':
        return Colors.cyan;
      case 'modern':
        return Colors.indigo;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
