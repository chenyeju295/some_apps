import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import '../models/wallpaper_model.dart';
import '../../../core/values/app_constants.dart';

class StorageService extends GetxService {
  late GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // User Data
  Future<void> saveUser(UserModel user) async {
    await _box.write(AppConstants.keyUserData, user.toJson());
  }

  UserModel? getUser() {
    final data = _box.read(AppConstants.keyUserData);
    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  // Token Balance
  Future<void> saveTokenBalance(int balance) async {
    await _box.write(AppConstants.keyTokenBalance, balance);
  }

  int getTokenBalance() {
    return _box.read(AppConstants.keyTokenBalance) ??
        AppConstants.initialTokens;
  }

  // Wallpapers
  Future<void> saveWallpapers(List<WallpaperModel> wallpapers) async {
    final data = wallpapers.map((w) => w.toJson()).toList();
    await _box.write(AppConstants.keyWallpapers, data);
  }

  List<WallpaperModel> getWallpapers() {
    final data = _box.read(AppConstants.keyWallpapers);
    if (data == null) return [];

    // 加载并过滤掉所有样例数据
    return (data as List)
        .map((item) => WallpaperModel.fromJson(Map<String, dynamic>.from(item)))
        .where((wallpaper) {
          // 过滤掉isSample=true的数据
          if (wallpaper.isSample) return false;
          // 过滤掉ID以'sample_'开头的数据（历史遗留数据）
          if (wallpaper.id.startsWith('sample_')) return false;
          return true;
        })
        .toList();
  }

  // Favorites
  Future<void> saveFavorites(List<String> favoriteIds) async {
    await _box.write(AppConstants.keyFavorites, favoriteIds);
  }

  List<String> getFavorites() {
    final data = _box.read(AppConstants.keyFavorites);
    if (data == null) return [];

    // 过滤掉样例数据的ID
    return (data as List)
        .map((e) => e.toString())
        .where((id) => !id.startsWith('sample_'))
        .toList();
  }

  // First Launch
  bool isFirstLaunch() {
    return _box.read(AppConstants.keyFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await _box.write(AppConstants.keyFirstLaunch, false);
  }

  // Privacy Accepted
  bool isPrivacyAccepted() {
    return _box.read(AppConstants.keyPrivacyAccepted) ?? false;
  }

  Future<void> setPrivacyAccepted(bool accepted) async {
    await _box.write(AppConstants.keyPrivacyAccepted, accepted);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _box.erase();
  }

  // Clear specific key
  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  // Check if key exists
  bool hasKey(String key) {
    return _box.hasData(key);
  }
}
