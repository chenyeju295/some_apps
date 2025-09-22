import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/generated_image.dart';
import '../../theme/app_theme.dart';
import '../animations/ocean_animations.dart';

class RecentImagesSection extends StatelessWidget {
  final List<GeneratedImage> recentImages;
  final Function(GeneratedImage) onImageTap;
  final VoidCallback onSeeAllPressed;

  const RecentImagesSection({
    super.key,
    required this.recentImages,
    required this.onImageTap,
    required this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (recentImages.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: _EmptyImagesState(onGeneratePressed: onSeeAllPressed),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Ocean Images',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.deepNavy,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onSeeAllPressed,
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
              itemCount: recentImages.length,
              itemBuilder: (context, index) {
                final image = recentImages[index];
                return OceanAnimations.staggeredList(
                  index: index,
                  delay: 100,
                  child: OceanAnimations.floatingWidget(
                    offset: 3.0,
                    duration: Duration(seconds: 4 + (index % 3)),
                    child: _RecentImageCard(
                      image: image,
                      onTap: () => onImageTap(image),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentImageCard extends StatelessWidget {
  final GeneratedImage image;
  final VoidCallback onTap;

  const _RecentImageCard({
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: CachedNetworkImage(
                    imageUrl: image.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.lightAqua,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.lightAqua,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Image not available',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.prompt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.deepNavy,
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStyleColor(image.style),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          image.style.displayName,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                      const Spacer(),
                      if (image.isFavorite)
                        Icon(
                          Icons.favorite,
                          color: AppTheme.coral,
                          size: 12,
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

  Color _getStyleColor(ImageStyle style) {
    switch (style) {
      case ImageStyle.realistic:
        return AppTheme.oceanBlue;
      case ImageStyle.artistic:
        return AppTheme.coral;
      case ImageStyle.vintage:
        return AppTheme.deepSeaGreen;
      case ImageStyle.cartoon:
        return AppTheme.tropicalTeal;
      case ImageStyle.cinematic:
        return AppTheme.deepNavy;
    }
  }
}

class _EmptyImagesState extends StatelessWidget {
  final VoidCallback onGeneratePressed;

  const _EmptyImagesState({
    required this.onGeneratePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.lightAqua,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: AppTheme.oceanBlue,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Ocean Images Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.deepNavy,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first underwater scene with AI',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onGeneratePressed,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Image'),
            style: AppTheme.primaryButtonStyle,
          ),
        ],
      ),
    );
  }
}
