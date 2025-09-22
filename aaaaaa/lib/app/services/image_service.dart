import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart' as getx;

class ImageService {
  static final Dio _dio = Dio();

  // Get app documents directory
  static Future<Directory> get _appDir async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final wallpaperDir = Directory(path.join(appDocDir.path, 'wallpapers'));

    // Create directory if it doesn't exist
    if (!await wallpaperDir.exists()) {
      await wallpaperDir.create(recursive: true);
    }

    return wallpaperDir;
  }

  // Download and save image from URL
  static Future<String?> downloadAndSaveImage({
    required String imageUrl,
    required String wallpaperId,
    String? prompt,
  }) async {
    try {
      print('Downloading image: $imageUrl');

      // Download image
      final response = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final imageBytes = Uint8List.fromList(response.data);

        // Generate filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filename = '${wallpaperId}_$timestamp.jpg';

        // Get app directory
        final appDir = await _appDir;
        final filePath = path.join(appDir.path, filename);

        // Save file
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);

        print('Image saved to: $filePath');

        // Return relative path
        return 'wallpapers/$filename';
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading image: $e');
      getx.Get.snackbar(
        'Download Failed',
        'Failed to save wallpaper: ${e.toString()}',
        snackPosition: getx.SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Get full path from relative path
  static Future<String> getFullPath(String relativePath) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return path.join(appDocDir.path, relativePath);
  }

  // Check if local file exists
  static Future<bool> fileExists(String relativePath) async {
    try {
      final fullPath = await getFullPath(relativePath);
      final file = File(fullPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Delete local file
  static Future<bool> deleteFile(String relativePath) async {
    try {
      final fullPath = await getFullPath(relativePath);
      final file = File(fullPath);

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  // Get file size
  static Future<int?> getFileSize(String relativePath) async {
    try {
      final fullPath = await getFullPath(relativePath);
      final file = File(fullPath);

      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Clean old files (optional, for storage management)
  static Future<void> cleanOldFiles({int maxFiles = 50}) async {
    try {
      final appDir = await _appDir;
      final files = appDir
          .listSync()
          .where((entity) => entity is File && entity.path.endsWith('.jpg'))
          .cast<File>()
          .toList();

      // Sort by modification time (newest first)
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Delete files beyond maxFiles limit
      if (files.length > maxFiles) {
        final filesToDelete = files.skip(maxFiles);
        for (final file in filesToDelete) {
          try {
            await file.delete();
            print('Deleted old file: ${file.path}');
          } catch (e) {
            print('Error deleting file ${file.path}: $e');
          }
        }
      }
    } catch (e) {
      print('Error cleaning old files: $e');
    }
  }

  // Get storage usage info
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final appDir = await _appDir;
      final files = appDir
          .listSync()
          .where((entity) => entity is File && entity.path.endsWith('.jpg'))
          .cast<File>()
          .toList();

      int totalSize = 0;
      for (final file in files) {
        totalSize += await file.length();
      }

      return {
        'fileCount': files.length,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      return {
        'fileCount': 0,
        'totalSize': 0,
        'totalSizeMB': '0.00',
      };
    }
  }

  // Copy file to external storage (for sharing/export)
  static Future<String?> copyToExternalStorage(String relativePath) async {
    try {
      // This would typically use a plugin like path_provider for external storage
      // For now, we'll return the current path
      return await getFullPath(relativePath);
    } catch (e) {
      print('Error copying to external storage: $e');
      return null;
    }
  }
}
