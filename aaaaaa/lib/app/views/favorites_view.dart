import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.photo_library,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Gallery',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              padding: EdgeInsets.zero,
              dividerColor: Colors.transparent, // 移除黑色下划线
              // 完全移除水波纹效果
              controller: controller.tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.grid_view, size: 18),
                      const SizedBox(width: 8),
                      Obx(() =>
                          Text('All (${controller.allWallpapers.length})')),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, size: 18),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                          'Favorites (${controller.favoriteWallpapers.length})')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [],
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Get.theme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading wallpapers...',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      }

      final wallpapers = isFavoritesTab
          ? controller.favoriteWallpapers
          : controller.allWallpapers;
      final isEmpty =
          isFavoritesTab ? controller.isEmpty : controller.isAllWallpapersEmpty;

      if (isEmpty) {
        return _buildEmptyState(isFavoritesTab);
      }

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Get.theme.primaryColor.withOpacity(0.02),
              Get.theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => controller.refreshFavorites(),
          color: Get.theme.primaryColor,
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: wallpapers.length,
            itemBuilder: (context, index) {
              final wallpaper = wallpapers[index];
              return _buildEnhancedWallpaperCard(
                  context, wallpaper, index, isFavoritesTab);
            },
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState([bool isFavoritesTab = true]) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.primaryColor.withOpacity(0.1),
                  Get.theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavoritesTab
                  ? Icons.favorite_border
                  : Icons.auto_awesome_outlined,
              size: 64,
              color: Get.theme.primaryColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isFavoritesTab ? 'No Favorites Yet' : 'No Wallpapers Generated',
            style: Get.textTheme.headlineSmall?.copyWith(
              color: Get.theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              isFavoritesTab
                  ? 'Start generating amazing wallpapers and mark your favorites to see them here. Your creative journey begins with a single tap!'
                  : 'Ready to create stunning AI wallpapers? Your gallery is waiting for its first masterpiece!',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isFavoritesTab
                      ? Icons.auto_awesome
                      : Icons.add_circle_outline),
                  const SizedBox(width: 12),
                  Text(
                    isFavoritesTab
                        ? 'Start Creating'
                        : 'Create First Wallpaper',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFavoritesTab) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickTip(Icons.favorite, 'Tap heart to favorite'),
                const SizedBox(width: 20),
                _buildQuickTip(Icons.download, 'Long press to save'),
                const SizedBox(width: 20),
                _buildQuickTip(Icons.share, 'Share with friends'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickTip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: Get.theme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.textTheme.bodySmall?.color?.withOpacity(0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedWallpaperCard(
      BuildContext context, wallpaper, int index, bool isFavoritesTab) {
    return GestureDetector(
      onTap: () => Get.toNamed('/wallpaper-detail', arguments: wallpaper),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Wallpaper image
              CachedNetworkImage(
                imageUrl: wallpaper.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.shade200,
                        Colors.grey.shade300,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 2,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).cardColor,
                        Theme.of(context).primaryColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported,
                          size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Failed to load',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Enhanced gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.6, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),

              // Index badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),

              // Enhanced action button (favorite/remove)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    if (isFavoritesTab) {
                      controller.removeFromFavorites(wallpaper);
                    } else {
                      controller.toggleFavorite(wallpaper);
                    }
                  },
                  child: GetBuilder<FavoritesController>(builder: (logic) {
                    return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              (isFavoritesTab || logic.isFavorite(wallpaper.id))
                                  ? Colors.red.shade500.withOpacity(0.9)
                                  : Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isFavoritesTab ||
                                      controller.isFavorite(wallpaper.id))
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavoritesTab
                              ? Icons.favorite
                              : (logic.isFavorite(wallpaper.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border),
                          color: Colors.white,
                          size: 18,
                        ));
                  }),
                ),
              ),

              // Enhanced content overlay
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
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.9),
                              Theme.of(context).primaryColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          wallpaper.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Prompt preview
                      Text(
                        wallpaper.prompt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (isFavoritesTab) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white.withOpacity(0.7),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Favorite',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
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
