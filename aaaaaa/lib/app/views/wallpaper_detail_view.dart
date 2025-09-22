import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../models/wallpaper_model.dart';

class WallpaperDetailView extends StatelessWidget {
  const WallpaperDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final WallpaperModel wallpaper = Get.arguments as WallpaperModel;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Wallpaper image
          Center(
            child: CachedNetworkImage(
              imageUrl: wallpaper.url,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load wallpaper',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top app bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.arrow_back,
                    onTap: () => Get.back(),
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    onTap: () => _shareWallpaper(wallpaper),
                  ),
                ],
              ),
            ),
          ),

          // Bottom actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Wallpaper info
                      _buildWallpaperInfo(context, wallpaper),
                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _downloadWallpaper(wallpaper),
                              icon: const Icon(Icons.download),
                              label: const Text('Download'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _setAsWallpaper(wallpaper),
                              icon: const Icon(Icons.wallpaper),
                              label: const Text('Set as Wallpaper'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildWallpaperInfo(BuildContext context, WallpaperModel wallpaper) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              wallpaper.category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Prompt
          Text(
            'Prompt:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            wallpaper.prompt,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),

          // Created date
          Text(
            'Created: ${_formatDate(wallpaper.createdAt)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _shareWallpaper(WallpaperModel wallpaper) async {
    try {
      await Share.share(
        'Check out this amazing AI-generated wallpaper!\n\nPrompt: ${wallpaper.prompt}\n\n${wallpaper.url}',
        subject: 'AI Wallpaper - ${wallpaper.category}',
      );
    } catch (e) {
      Get.snackbar(
        'Share Failed',
        'Could not share wallpaper: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _downloadWallpaper(WallpaperModel wallpaper) async {
    try {
      // Request storage permission
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download wallpapers',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Get.snackbar(
        'Downloading',
        'Downloading wallpaper...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Download image
      final dio = Dio();
      final response = await dio.get(
        wallpaper.url,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        response.data,
        name: 'wallpaper_${wallpaper.id}',
        quality: 100,
      );

      if (result['isSuccess'] == true) {
        Get.snackbar(
          'Download Complete',
          'Wallpaper saved to gallery',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      Get.snackbar(
        'Download Failed',
        'Could not download wallpaper: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _setAsWallpaper(WallpaperModel wallpaper) async {
    // Note: Setting wallpaper programmatically requires platform-specific code
    // For now, we'll show a dialog with instructions
    Get.defaultDialog(
      title: 'Set as Wallpaper',
      content: const Column(
        children: [
          Text(
            'To set this as your wallpaper:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            '1. Download the wallpaper\n'
            '2. Go to Settings > Wallpaper\n'
            '3. Select the downloaded image\n'
            '4. Choose Lock Screen or Home Screen',
            textAlign: TextAlign.left,
          ),
        ],
      ),
      textConfirm: 'Download First',
      textCancel: 'OK',
      onConfirm: () {
        Get.back();
        _downloadWallpaper(wallpaper);
      },
    );
  }
}
