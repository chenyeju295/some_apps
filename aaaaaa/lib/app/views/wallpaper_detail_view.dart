import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper_model.dart';
import '../services/image_service.dart';
import '../controllers/favorites_controller.dart';

class WallpaperDetailView extends StatefulWidget {
  const WallpaperDetailView({super.key});

  @override
  State<WallpaperDetailView> createState() => _WallpaperDetailViewState();
}

class _WallpaperDetailViewState extends State<WallpaperDetailView> {
  WallpaperModel? wallpaper;
  bool isLoading = true;
  String? fullImagePath;

  @override
  void initState() {
    super.initState();
    _loadWallpaper();
  }

  void _loadWallpaper() async {
    // Get wallpaper from arguments
    final arg = Get.arguments;
    if (arg is WallpaperModel) {
      wallpaper = arg;

      // If has local path, get full path
      if (wallpaper!.hasLocalFile) {
        try {
          fullImagePath = await ImageService.getFullPath(wallpaper!.localPath!);
        } catch (e) {
          print('Error getting full path: $e');
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || wallpaper == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: GetBuilder<FavoritesController>(
              builder: (controller) => Icon(
                controller.isFavorite(wallpaper!.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: controller.isFavorite(wallpaper!.id)
                    ? Colors.red
                    : Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: _showActions,
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full screen image
          Center(
            child: Hero(
              tag: 'wallpaper_${wallpaper!.id}',
              child: _buildImage(),
            ),
          ),

          // Bottom info panel
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
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Prompt
                      Text(
                        wallpaper!.prompt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Details row
                      Row(
                        children: [
                          _buildDetailChip(
                            wallpaper!.category,
                            Icons.category,
                          ),
                          const SizedBox(width: 8),
                          _buildDetailChip(
                            wallpaper!.formattedStyle,
                            Icons.palette,
                          ),
                          const SizedBox(width: 8),
                          _buildDetailChip(
                            wallpaper!.formattedQuality,
                            Icons.high_quality,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Size and date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(wallpaper!.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            wallpaper!.formattedSize,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _setAsWallpaper,
                              icon: const Icon(Icons.wallpaper),
                              label: const Text('Set as Wallpaper'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _shareWallpaper,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Icon(Icons.share),
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

  Widget _buildImage() {
    if (wallpaper!.hasLocalFile && fullImagePath != null) {
      // Show local image
      final file = File(fullImagePath!);
      if (file.existsSync()) {
        return InteractiveViewer(
          child: Image.file(
            file,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildNetworkImage();
            },
          ),
        );
      }
    }

    // Fallback to network image
    return _buildNetworkImage();
  }

  Widget _buildNetworkImage() {
    return InteractiveViewer(
      child: CachedNetworkImage(
        imageUrl: wallpaper!.url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _toggleFavorite() {
    final controller = Get.find<FavoritesController>();
    controller.toggleFavorite(wallpaper!);
  }

  void _setAsWallpaper() {
    // TODO: Implement wallpaper setting functionality
    Get.snackbar(
      'Feature Coming Soon',
      'Set as wallpaper functionality will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _shareWallpaper() {
    // TODO: Implement share functionality
    Get.snackbar(
      'Feature Coming Soon',
      'Share functionality will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Prompt'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: wallpaper!.prompt));
                  Navigator.pop(context);
                  Get.snackbar(
                    'Copied',
                    'Prompt copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download Original'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadOriginal();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Image Info'),
                onTap: () {
                  Navigator.pop(context);
                  _showImageInfo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadOriginal() {
    // TODO: Implement download functionality
    Get.snackbar(
      'Feature Coming Soon',
      'Download functionality will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showImageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('ID', wallpaper!.id),
            _buildInfoRow('Category', wallpaper!.category),
            _buildInfoRow('Style', wallpaper!.formattedStyle),
            _buildInfoRow('Quality', wallpaper!.formattedQuality),
            _buildInfoRow('Size', wallpaper!.formattedSize),
            _buildInfoRow('Created', _formatDate(wallpaper!.createdAt)),
            _buildInfoRow('Local File', wallpaper!.hasLocalFile ? 'Yes' : 'No'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wallpaper'),
        content: const Text(
            'Are you sure you want to delete this wallpaper? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteWallpaper();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteWallpaper() {
    // TODO: Implement delete functionality
    Get.snackbar(
      'Feature Coming Soon',
      'Delete functionality will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
