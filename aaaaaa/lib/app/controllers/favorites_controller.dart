import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/wallpaper_model.dart';
import '../services/storage_service.dart';

class FavoritesController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Observable variables
  final favoriteWallpapers = <WallpaperModel>[].obs;
  final allWallpapers = <WallpaperModel>[].obs;
  final isLoading = false.obs;
  final currentTabIndex = 0.obs;

  // Tab controller
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });
    loadFavorites();
    loadAllWallpapers();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Load favorites from storage
  void loadFavorites() {
    isLoading.value = true;
    try {
      favoriteWallpapers.value = StorageService.favoriteWallpapers;
    } finally {
      isLoading.value = false;
    }
  }

  // Load all generated wallpapers from storage
  void loadAllWallpapers() {
    try {
      allWallpapers.value = StorageService.generationHistory;
    } catch (e) {
      print('Error loading all wallpapers: $e');
    }
  }

  // Check if wallpaper is favorite
  bool isFavorite(String wallpaperId) {
    return favoriteWallpapers.any((w) => w.id == wallpaperId);
  }

  // Toggle favorite status
  void toggleFavorite(WallpaperModel wallpaper) {
    if (isFavorite(wallpaper.id)) {
      // Remove from favorites
      StorageService.removeFromFavorites(wallpaper.id);
      favoriteWallpapers.removeWhere((w) => w.id == wallpaper.id);

    } else {
      // Add to favorites
      final updatedWallpaper = wallpaper.copyWith(isFavorite: true);
      StorageService.addToFavorites(updatedWallpaper);
      favoriteWallpapers.add(updatedWallpaper);

    }

    update(); // Trigger UI update
  }

  // Remove from favorites
  void removeFromFavorites(WallpaperModel wallpaper) {
    Get.defaultDialog(
      title: 'Remove Favorite',
      middleText:
          'Are you sure you want to remove this wallpaper from favorites?',
      textConfirm: 'Remove',
      textCancel: 'Cancel',
      onConfirm: () {
        StorageService.removeFromFavorites(wallpaper.id);
        favoriteWallpapers.removeWhere((w) => w.id == wallpaper.id);
        Get.back();
        Get.snackbar(
          'Removed',
          'Wallpaper removed from favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          icon: Icon(Icons.delete_outline, color: Colors.red.shade800),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        update(); // Trigger UI update
      },
    );
  }

  // Clear all favorites
  void clearAllFavorites() {
    if (favoriteWallpapers.isEmpty) {
      Get.snackbar(
        'No Favorites',
        'You don\'t have any favorite wallpapers',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        icon: Icon(Icons.info_outline, color: Colors.blue.shade800),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    Get.defaultDialog(
      title: 'Clear All Favorites',
      middleText:
          'Are you sure you want to remove all favorite wallpapers? This action cannot be undone.',
      textConfirm: 'Clear All',
      textCancel: 'Cancel',
      onConfirm: () {
        StorageService.clearFavorites();
        favoriteWallpapers.clear();
        Get.back();
        Get.snackbar(
          'Cleared',
          'All favorites have been removed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          icon: Icon(Icons.clear_all, color: Colors.orange.shade800),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      },
    );
  }

  // Refresh favorites
  void refreshFavorites() {
    loadFavorites();
    loadAllWallpapers();
  }

  // Get favorites count
  int get favoritesCount => favoriteWallpapers.length;

  // Check if list is empty
  bool get isEmpty => favoriteWallpapers.isEmpty;

  // Check if all wallpapers list is empty
  bool get isAllWallpapersEmpty => allWallpapers.isEmpty;

  // Get current tab wallpapers
  List<WallpaperModel> get currentWallpapers {
    return currentTabIndex.value == 0 ? favoriteWallpapers : allWallpapers;
  }

  // Get favorites by category
  List<WallpaperModel> getFavoritesByCategory(String category) {
    return favoriteWallpapers.where((w) => w.category == category).toList();
  }

  // Get all categories in favorites
  List<String> get categoriesInFavorites {
    return favoriteWallpapers.map((w) => w.category).toSet().toList()..sort();
  }

  // Get all categories in all wallpapers
  List<String> get categoriesInAllWallpapers {
    return allWallpapers.map((w) => w.category).toSet().toList()..sort();
  }
}
