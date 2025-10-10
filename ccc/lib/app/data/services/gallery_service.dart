import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'storage_service.dart';
import '../models/wallpaper_model.dart';

class GalleryService extends GetxService {
  // 使用 getter 方式动态获取依赖，避免初始化顺序问题
  StorageService get _storageService => Get.find<StorageService>();

  final RxList<WallpaperModel> wallpapers = <WallpaperModel>[].obs;
  final RxList<String> favoriteIds = <String>[].obs;
  final RxBool isLoading = false.obs;

  Future<GalleryService> init() async {
    await loadWallpapers();
    await loadFavorites();
    return this;
  }

  // Load wallpapers from storage
  Future<void> loadWallpapers() async {
    isLoading.value = true;
    try {
      final savedWallpapers = _storageService.getWallpapers();
      wallpapers.value = savedWallpapers;

      // 清理内存中可能存在的样例数据
      _cleanupSampleData();
    } finally {
      isLoading.value = false;
    }
  }

  // 清理样例数据（从内存和存储中）
  void _cleanupSampleData() {
    // 从内存列表中移除样例数据
    final beforeCount = wallpapers.length;
    wallpapers.removeWhere((w) => w.isSample || w.id.startsWith('sample_'));
    favoriteIds.removeWhere((id) => id.startsWith('sample_'));

    final afterCount = wallpapers.length;
    if (beforeCount != afterCount) {
      print('Cleaned up ${beforeCount - afterCount} sample wallpapers');
      // 如果清理了数据，立即保存到存储
      _saveWallpapers();
      _saveFavorites();
    }
  }

  // Load favorites
  Future<void> loadFavorites() async {
    final savedFavorites = _storageService.getFavorites();
    favoriteIds.value = savedFavorites;
  }

  // Add wallpaper
  Future<void> addWallpaper(WallpaperModel wallpaper) async {
    wallpapers.insert(0, wallpaper);
    await _saveWallpapers();
  }

  // Remove wallpaper
  Future<void> removeWallpaper(String id) async {
    wallpapers.removeWhere((w) => w.id == id);
    favoriteIds.remove(id);
    await _saveWallpapers();
    await _saveFavorites();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String id) async {
    final index = wallpapers.indexWhere((w) => w.id == id);
    if (index != -1) {
      final wallpaper = wallpapers[index];
      final newWallpaper = wallpaper.copyWith(
        isFavorite: !wallpaper.isFavorite,
      );
      wallpapers[index] = newWallpaper;

      if (newWallpaper.isFavorite) {
        favoriteIds.add(id);
      } else {
        favoriteIds.remove(id);
      }

      await _saveWallpapers();
      await _saveFavorites();
    }
  }

  // Get favorites only
  List<WallpaperModel> getFavorites() {
    return wallpapers.where((w) => w.isFavorite).toList();
  }

  // Filter by style
  List<WallpaperModel> filterByStyle(String style) {
    return wallpapers.where((w) => w.style == style).toList();
  }

  // Filter by tag
  List<WallpaperModel> filterByTag(String tag) {
    return wallpapers.where((w) => w.tags.contains(tag)).toList();
  }

  // Save to device gallery
  Future<bool> saveToGallery(WallpaperModel wallpaper) async {
    try {
      // Request permission
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        print('Permission denied');
        return false;
      }

      dynamic imageBytes;

      // 判断是本地资源还是网络图片
      if (wallpaper.imageUrl.startsWith('http')) {
        // 网络图片
        final response = await http.get(Uri.parse(wallpaper.imageUrl));
        if (response.statusCode != 200) {
          print('Failed to download image: ${response.statusCode}');
          return false;
        }
        imageBytes = response.bodyBytes;
      } else if (wallpaper.imageUrl.startsWith('assets/')) {
        // 本地资源文件
        final ByteData data = await rootBundle.load(wallpaper.imageUrl);
        imageBytes = data.buffer.asUint8List();
      } else {
        // 本地文件路径
        final file = File(wallpaper.imageUrl);
        if (!await file.exists()) {
          print('Local file not found');
          return false;
        }
        imageBytes = await file.readAsBytes();
      }

      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: 'fashion_wallpaper_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('Save result: $result');
      return result != null &&
          (result['isSuccess'] == true || result['filePath'] != null);
    } catch (e) {
      print('Error saving to gallery: $e');
      return false;
    }
  }

  // Share wallpaper
  Future<void> shareWallpaper(WallpaperModel wallpaper) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_${wallpaper.id}.jpg');

      // 根据图片类型处理
      if (wallpaper.imageUrl.startsWith('http')) {
        // 网络图片
        final response = await http.get(Uri.parse(wallpaper.imageUrl));
        if (response.statusCode != 200) {
          print('Failed to download image for sharing');
          return;
        }
        await file.writeAsBytes(response.bodyBytes);
      } else if (wallpaper.imageUrl.startsWith('assets/')) {
        // 本地资源文件
        final ByteData data = await rootBundle.load(wallpaper.imageUrl);
        await file.writeAsBytes(data.buffer.asUint8List());
      } else {
        // 本地文件路径
        final sourceFile = File(wallpaper.imageUrl);
        if (await sourceFile.exists()) {
          await sourceFile.copy(file.path);
        } else {
          print('Source file not found');
          return;
        }
      }

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Check out this fashion wallpaper! Generated with Fashion Wallpaper app.',
      );
    } catch (e) {
      print('Error sharing wallpaper: $e');
    }
  }

  // Get wallpaper by ID
  WallpaperModel? getWallpaperById(String id) {
    try {
      return wallpapers.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear all wallpapers
  Future<void> clearAll() async {
    wallpapers.clear();
    favoriteIds.clear();
    await _saveWallpapers();
    await _saveFavorites();
  }

  // Private methods
  Future<void> _saveWallpapers() async {
    // 只保存真实生成的壁纸，过滤掉样例数据
    final realWallpapers = wallpapers
        .where((w) => !w.isSample && !w.id.startsWith('sample_'))
        .toList();
    await _storageService.saveWallpapers(realWallpapers);
  }

  Future<void> _saveFavorites() async {
    // 只保存真实壁纸的收藏ID，过滤掉样例数据
    final realFavorites = favoriteIds
        .where((id) => !id.startsWith('sample_'))
        .toList();
    await _storageService.saveFavorites(realFavorites);
  }

  // Get total count
  int get totalCount => wallpapers.length;
  int get favoriteCount => getFavorites().length;
}
