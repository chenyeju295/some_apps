import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/wallpaper_model.dart';
import '../../../data/services/gallery_service.dart';
import '../../../../core/values/app_colors.dart';

class GenerationResultDialog extends StatelessWidget {
  final WallpaperModel wallpaper;

  const GenerationResultDialog({Key? key, required this.wallpaper})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final galleryService = Get.find<GalleryService>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.solidCircleCheck,
                      color: AppColors.textWhite,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generation Complete!',
                          style: Get.textTheme.titleLarge?.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your wallpaper is ready',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textWhite.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

            // Image Preview
            Container(
                  height: 300,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildImage(),
                  ),
                )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                )
                .fadeIn(duration: 400.ms),

            // Details
            Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildDetailChip(
                            icon: FontAwesomeIcons.palette,
                            label: wallpaper.style,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          _buildDetailChip(
                            icon: FontAwesomeIcons.shirt,
                            label: wallpaper.outfitType,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildDetailChip(
                        icon: FontAwesomeIcons.locationDot,
                        label: wallpaper.scene,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Action Buttons
            Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Save to Gallery Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            final success = await galleryService.saveToGallery(
                              wallpaper,
                            );
                            if (success) {
                              Get.snackbar(
                                'Saved!',
                                'Wallpaper saved to your gallery',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.success.withOpacity(
                                  0.9,
                                ),
                                colorText: AppColors.textWhite,
                                icon: const Icon(
                                  FontAwesomeIcons.solidCircleCheck,
                                  color: AppColors.textWhite,
                                ),
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                'Failed to save. Please check permissions.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.error.withOpacity(
                                  0.9,
                                ),
                                colorText: AppColors.textWhite,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(FontAwesomeIcons.download, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Save to Gallery',
                                style: Get.textTheme.titleMedium?.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Secondary Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await galleryService.shareWallpaper(wallpaper);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.share,
                                    size: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Share',
                                    style: Get.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Get.back();
                                Get.toNamed('/gallery');
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.images,
                                    size: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Gallery',
                                    style: Get.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 12),

            // Close Button
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Close',
                style: Get.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (wallpaper.imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: wallpaper.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surfaceLight,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surfaceLight,
          child: const Center(
            child: Icon(
              FontAwesomeIcons.image,
              size: 48,
              color: AppColors.textLight,
            ),
          ),
        ),
      );
    } else {
      return Image.asset(
        wallpaper.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.surfaceLight,
            child: const Center(
              child: Icon(
                FontAwesomeIcons.image,
                size: 48,
                color: AppColors.textLight,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Get.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
