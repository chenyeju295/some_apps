import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        bottom: TabBar(

          controller: controller.tabController,
          tabs: const [ Tab(
            icon: Icon(Icons.grid_view),
            text: 'All',
          ),
            Tab(
              icon: Icon(Icons.favorite),
              text: 'Favorites',
            ),

          ],
        ),
        actions: [
           ],
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          // All Tab
          _buildWallpaperGrid(false),
          // Favorites Tab
          _buildWallpaperGrid(true),
        ],
      ),
    );
  }

  Widget _buildWallpaperGrid(bool isFavoritesTab) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final wallpapers = isFavoritesTab
          ? controller.favoriteWallpapers
          : controller.allWallpapers;
      final isEmpty =
          isFavoritesTab ? controller.isEmpty : controller.isAllWallpapersEmpty;

      if (isEmpty) {
        return _buildEmptyState(isFavoritesTab);
      }

      return RefreshIndicator(
        onRefresh: () async => controller.refreshFavorites(),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: wallpapers.length,
          itemBuilder: (context, index) {
            final wallpaper = wallpapers[index];
            return _buildWallpaperCard(
                context, wallpaper, index, isFavoritesTab);
          },
        ),
      );
    });
  }

  void _showClearDialog() {
    if (controller.currentTabIndex.value == 0) {
      // Favorites tab
      controller.clearAllFavorites();
    } else {
      // All tab - show clear all history dialog
      Get.defaultDialog(
        title: 'Clear All History',
        middleText:
            'Are you sure you want to clear all generation history? This action cannot be undone.',
        textConfirm: 'Clear All',
        textCancel: 'Cancel',
        onConfirm: () {
          // TODO: Implement clear all history
          Get.back();
          Get.snackbar(
            'Feature Coming Soon',
            'Clear all history functionality will be available soon',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    }
  }

  Widget _buildEmptyState([bool isFavoritesTab = true]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFavoritesTab ? Icons.favorite_border : Icons.image_outlined,
            size: 80,
            color: Get.theme.iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            isFavoritesTab ? 'No Favorites Yet' : 'No Wallpapers Generated',
            style: Get.textTheme.headlineSmall?.copyWith(
              color: Get.textTheme.headlineSmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isFavoritesTab
                ? 'Start generating wallpapers and mark your favorites to see them here'
                : 'Generate your first AI wallpaper to see it here',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: Icon(isFavoritesTab ? Icons.home : Icons.auto_awesome),
            label: Text(isFavoritesTab ? 'Go Home' : 'Create Wallpaper'),
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperCard(
      BuildContext context, wallpaper, int index, bool isFavoritesTab) {
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
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).cardColor,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 32),
                      SizedBox(height: 8),
                      Text('Failed to load'),
                    ],
                  ),
                ),
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

              // Action button (favorite/remove)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    if (isFavoritesTab) {
                      controller.removeFromFavorites(wallpaper);
                    } else {
                      controller.toggleFavorite(wallpaper);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavoritesTab
                          ? Icons.favorite
                          : (controller.isFavorite(wallpaper.id)
                              ? Icons.favorite
                              : Icons.favorite_border),
                      color:
                          isFavoritesTab || controller.isFavorite(wallpaper.id)
                              ? Colors.red
                              : Colors.white,
                      size: 20,
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
