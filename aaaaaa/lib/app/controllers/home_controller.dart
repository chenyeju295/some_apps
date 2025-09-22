import 'package:get/get.dart';
import '../models/wallpaper_model.dart';
import '../services/storage_service.dart';

class HomeController extends GetxController {
  // Observable variables
  final generatedWallpapers = <WallpaperModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadGeneratedWallpapers();
  }

  void _loadGeneratedWallpapers() {
    generatedWallpapers.value = StorageService.generationHistory;
  }

  // Toggle favorite status
  void toggleFavorite(WallpaperModel wallpaper) {
    final isFav = StorageService.isFavorite(wallpaper.id);

    if (isFav) {
      StorageService.removeFromFavorites(wallpaper.id);
      Get.snackbar(
        'Removed from Favorites',
        'Wallpaper removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      StorageService.addToFavorites(wallpaper);
      Get.snackbar(
        'Added to Favorites',
        'Wallpaper added to favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    // Update the list
    _loadGeneratedWallpapers();
  }

  // Check if wallpaper is favorite
  bool isFavorite(String wallpaperId) {
    return StorageService.isFavorite(wallpaperId);
  }

  // Refresh history
  void refreshHistory() {
    _loadGeneratedWallpapers();
  }
}
