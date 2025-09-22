import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';
import '../models/wallpaper_model.dart';

class StorageService {
  static final _box = GetStorage();

  // Initialize storage
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Generic value storage methods
  static T? getValue<T>(String key) => _box.read<T>(key);
  static void setValue<T>(String key, T value) => _box.write(key, value);
  static void removeValue(String key) => _box.remove(key);

  // First time user check
  static bool get isFirstTime => _box.read(AppConstants.keyFirstTime) ?? true;
  static set isFirstTime(bool value) =>
      _box.write(AppConstants.keyFirstTime, value);

  // Dark mode preference
  static bool get isDarkMode => _box.read(AppConstants.keyDarkMode) ?? false;
  static set isDarkMode(bool value) =>
      _box.write(AppConstants.keyDarkMode, value);

  // Selected theme
  static String get selectedTheme =>
      _box.read(AppConstants.keySelectedTheme) ?? 'Nature';
  static set selectedTheme(String value) =>
      _box.write(AppConstants.keySelectedTheme, value);

  // Favorite wallpapers
  static List<WallpaperModel> get favoriteWallpapers {
    final List<dynamic>? data = _box.read(AppConstants.keyFavoriteWallpapers);
    if (data == null) return [];
    return data.map((json) => WallpaperModel.fromJson(json)).toList();
  }

  static set favoriteWallpapers(List<WallpaperModel> wallpapers) {
    final data = wallpapers.map((w) => w.toJson()).toList();
    _box.write(AppConstants.keyFavoriteWallpapers, data);
  }

  // Add to favorites
  static void addToFavorites(WallpaperModel wallpaper) {
    final favorites = favoriteWallpapers;
    if (!favorites.any((w) => w.id == wallpaper.id)) {
      favorites.add(wallpaper.copyWith(isFavorite: true));
      // Keep only the latest favorites within limit
      if (favorites.length > AppConstants.maxFavorites) {
        favorites.removeRange(0, favorites.length - AppConstants.maxFavorites);
      }
      favoriteWallpapers = favorites;
    }
  }

  // Remove from favorites
  static void removeFromFavorites(String wallpaperId) {
    final favorites = favoriteWallpapers;
    favorites.removeWhere((w) => w.id == wallpaperId);
    favoriteWallpapers = favorites;
  }

  // Check if wallpaper is favorite
  static bool isFavorite(String wallpaperId) {
    return favoriteWallpapers.any((w) => w.id == wallpaperId);
  }

  // Generation history
  static List<WallpaperModel> get generationHistory {
    final List<dynamic>? data = _box.read(AppConstants.keyGenerationHistory);
    if (data == null) return [];
    return data.map((json) => WallpaperModel.fromJson(json)).toList();
  }

  static set generationHistory(List<WallpaperModel> wallpapers) {
    final data = wallpapers.map((w) => w.toJson()).toList();
    _box.write(AppConstants.keyGenerationHistory, data);
  }

  // Add to history
  static void addToHistory(WallpaperModel wallpaper) {
    final history = generationHistory;
    // Remove if already exists to avoid duplicates
    history.removeWhere((w) => w.id == wallpaper.id);
    // Add to beginning
    history.insert(0, wallpaper);
    // Keep only the latest history within limit
    if (history.length > AppConstants.maxGenerationHistory) {
      history.removeRange(AppConstants.maxGenerationHistory, history.length);
    }
    generationHistory = history;
  }

  // Clear all data
  static void clearAll() {
    _box.erase();
  }

  // Generation confirmation preference
  static bool get showGenerationConfirm =>
      _box.read(AppConstants.keyShowGenerationConfirm) ?? true;
  static set showGenerationConfirm(bool value) =>
      _box.write(AppConstants.keyShowGenerationConfirm, value);

  // Clear specific data
  static void clearFavorites() {
    _box.remove(AppConstants.keyFavoriteWallpapers);
  }

  static void clearHistory() {
    _box.remove(AppConstants.keyGenerationHistory);
  }
}
