import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/gallery_service.dart';
import '../../../data/models/wallpaper_model.dart';

class GalleryController extends GetxController {
  final GalleryService _galleryService = Get.find<GalleryService>();

  final RxList<WallpaperModel> displayedWallpapers = <WallpaperModel>[].obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool showFavoritesOnly = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWallpapers();

    // Check if there's a filter from arguments
    if (Get.arguments != null && Get.arguments['category'] != null) {
      final category = Get.arguments['category'] as String;
      applyFilter(category);
    }
  }

  Future<void> loadWallpapers() async {
    isLoading.value = true;
    try {
      await _galleryService.loadWallpapers();
      _updateDisplayedWallpapers();
    } finally {
      isLoading.value = false;
    }
  }

  /// 刷新图库 - 用于下拉刷新
  Future<void> refreshGallery() async {
    try {
      // 从存储重新加载数据
      await _galleryService.loadWallpapers();
      await _galleryService.loadFavorites();

      // 更新显示
      _updateDisplayedWallpapers();

      // 显示刷新成功提示
      if (_galleryService.wallpapers.isNotEmpty) {
        Get.snackbar(
          'Refreshed',
          'Gallery updated with ${_galleryService.wallpapers.where((w) => !w.isSample).length} wallpapers',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh gallery',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _updateDisplayedWallpapers() {
    // 只显示真实生成的壁纸，过滤掉样例数据
    List<WallpaperModel> allWallpapers;

    if (showFavoritesOnly.value) {
      allWallpapers = _galleryService.getFavorites();
    } else if (selectedFilter.value == 'All') {
      allWallpapers = _galleryService.wallpapers;
    } else {
      allWallpapers = _galleryService.filterByStyle(selectedFilter.value);
    }

    // 过滤掉样例数据
    displayedWallpapers.value = allWallpapers
        .where((w) => !w.isSample)
        .toList();
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;
    showFavoritesOnly.value = false;
    _updateDisplayedWallpapers();
  }

  void toggleFavoritesOnly() {
    showFavoritesOnly.value = !showFavoritesOnly.value;
    _updateDisplayedWallpapers();
  }

  Future<void> toggleFavorite(String id) async {
    await _galleryService.toggleFavorite(id);
    _updateDisplayedWallpapers();
  }

  Future<void> deleteWallpaper(String id) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Wallpaper'),
        content: const Text('Are you sure you want to delete this wallpaper?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await _galleryService.removeWallpaper(id);
              _updateDisplayedWallpapers();
              Get.snackbar(
                'Deleted',
                'Wallpaper deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> saveToGallery(WallpaperModel wallpaper) async {
    final success = await _galleryService.saveToGallery(wallpaper);
    if (success) {
      Get.snackbar(
        'Success',
        'Wallpaper saved to gallery',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to save wallpaper. Please check permissions.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> shareWallpaper(WallpaperModel wallpaper) async {
    await _galleryService.shareWallpaper(wallpaper);
  }

  List<String> get availableFilters {
    // 只从真实生成的壁纸中获取样式列表
    final realWallpapers = _galleryService.wallpapers
        .where((w) => !w.isSample)
        .toList();

    if (realWallpapers.isEmpty) {
      return ['All'];
    }

    return ['All', ...realWallpapers.map((w) => w.style).toSet().toList()];
  }

  int get totalCount => _galleryService.totalCount;
  int get favoriteCount => _galleryService.favoriteCount;
}
