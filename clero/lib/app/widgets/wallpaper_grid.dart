import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/home_controller.dart';
import '../models/wallpaper_model.dart';

class WallpaperGrid extends GetView<HomeController> {
  const WallpaperGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.generatedWallpapers.isEmpty) {
        return _buildEmptyState(context);
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: controller.generatedWallpapers.length,
        itemBuilder: (context, index) {
          final wallpaper = controller.generatedWallpapers[index];
          return _buildWallpaperCard(context, wallpaper);
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No wallpapers yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first wallpaper to see it here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.5),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperCard(BuildContext context, WallpaperModel wallpaper) {
    return GestureDetector(
      onTap: () => Get.toNamed('/wallpaper-detail', arguments: wallpaper),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Wallpaper image
              CachedNetworkImage(
                imageUrl: wallpaper.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) =>
                    _buildErrorWidget(context),
              ),

              // Gradient overlay
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

              // Content overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          wallpaper.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Prompt preview
                      Text(
                        wallpaper.prompt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Favorite button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => controller.toggleFavorite(wallpaper),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Obx(() => Icon(
                          controller.isFavorite(wallpaper.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: controller.isFavorite(wallpaper.id)
                              ? Colors.red
                              : Colors.white,
                          size: 20,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 32,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}
