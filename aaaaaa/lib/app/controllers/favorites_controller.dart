import 'package:get/get.dart';
import '../models/wallpaper_model.dart';
import '../services/storage_service.dart';

class FavoritesController extends GetxController {
  // Observable variables
  final favoriteWallpapers = <WallpaperModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
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
        );
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
        );
      },
    );
  }

  // Refresh favorites
  void refreshFavorites() {
    loadFavorites();
  }

  // Get favorites count
  int get favoritesCount => favoriteWallpapers.length;

  // Check if list is empty
  bool get isEmpty => favoriteWallpapers.isEmpty;

  // Get favorites by category
  List<WallpaperModel> getFavoritesByCategory(String category) {
    return favoriteWallpapers.where((w) => w.category == category).toList();
  }

  // Get all categories in favorites
  List<String> get categoriesInFavorites {
    return favoriteWallpapers.map((w) => w.category).toSet().toList()..sort();
  }
}
