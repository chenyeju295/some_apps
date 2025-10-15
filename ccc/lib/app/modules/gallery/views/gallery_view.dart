import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/gallery_controller.dart';
import '../../../../core/values/app_colors.dart';

class GalleryView extends GetView<GalleryController> {
  const GalleryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.showFavoritesOnly.value
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: controller.showFavoritesOnly.value
                    ? AppColors.accent
                    : null,
              ),
              onPressed: controller.toggleFavoritesOnly,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.displayedWallpapers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.displayedWallpapers.isEmpty) {
          // 空状态也支持下拉刷新
          return RefreshIndicator(
            onRefresh: controller.refreshGallery,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: Get.height - 100,
                child: _buildEmptyState(),
              ),
            ),
          );
        }

        return Column(
          children: [
            // 只在有壁纸时显示过滤栏
            _buildFilterBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshGallery,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: controller.displayedWallpapers.length,
                  itemBuilder: (context, index) {
                    final wallpaper = controller.displayedWallpapers[index];
                    return _buildWallpaperCard(wallpaper);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.availableFilters.length,
          itemBuilder: (context, index) {
            final filter = controller.availableFilters[index];
            final isSelected = controller.selectedFilter.value == filter;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) => controller.applyFilter(filter),
                backgroundColor: AppColors.surfaceLight,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.textWhite
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.images,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              controller.showFavoritesOnly.value
                  ? 'No Favorites Yet'
                  : 'Your Gallery is Empty',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              controller.showFavoritesOnly.value
                  ? 'Mark wallpapers as favorites to see them here'
                  : 'Create your first AI-generated fashion wallpaper',
              style: Get.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.arrowDown,
                  size: 14,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pull down to refresh',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (controller.showFavoritesOnly.value) {
                      controller.toggleFavoritesOnly();
                    } else {
                      Get.back(); // 返回到生成页面
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          FontAwesomeIcons.wandMagicSparkles,
                          color: AppColors.textWhite,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          controller.showFavoritesOnly.value
                              ? 'View All Wallpapers'
                              : 'Start Creating',
                          style: Get.textTheme.titleMedium?.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaperCard(wallpaper) {
    return GestureDetector(
      onTap: () => _showWallpaperDetail(wallpaper),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 支持本地资源和网络图片
              wallpaper.imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: wallpaper.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceLight,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.secondary.withOpacity(0.2),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            FontAwesomeIcons.image,
                            color: AppColors.textLight,
                            size: 32,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      wallpaper.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.2),
                                AppColors.secondary.withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              FontAwesomeIcons.image,
                              color: AppColors.textLight,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
              Positioned(
                top: 8,
                right: 8,
                child: Obx(() {
                  final isFavorite = controller.displayedWallpapers
                      .firstWhere((w) => w.id == wallpaper.id)
                      .isFavorite;
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? AppColors.accent
                          : AppColors.textWhite,
                    ),
                    onPressed: () => controller.toggleFavorite(wallpaper.id),
                  );
                }),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallpaper.style,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wallpaper.outfitType,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.textWhite.withOpacity(0.8),
                        ),
                        maxLines: 1,
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

  void _showWallpaperDetail(wallpaper) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.download),
                    title: const Text('Save to Gallery'),
                    onTap: () {
                      Get.back();
                      controller.saveToGallery(wallpaper);
                    },
                  ),
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.share),
                    title: const Text('Share'),
                    onTap: () {
                      Get.back();
                      controller.shareWallpaper(wallpaper);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      FontAwesomeIcons.trash,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      Get.back();
                      controller.deleteWallpaper(wallpaper.id);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
