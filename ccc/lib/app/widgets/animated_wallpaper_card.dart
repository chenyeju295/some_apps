import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../core/values/app_colors.dart';

class AnimatedWallpaperCard extends StatelessWidget {
  final String imageUrl;
  final String style;
  final String outfitType;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final int index;

  const AnimatedWallpaperCard({
    Key? key,
    required this.imageUrl,
    required this.style,
    required this.outfitType,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    this.index = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:
          Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image with shimmer loading
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(
                                  color: AppColors.surfaceLight,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .shimmer(
                                  duration: 1500.ms,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceLight,
                          child: const Icon(
                            Icons.error,
                            color: AppColors.error,
                          ),
                        ),
                      ),

                      // Glassmorphism overlay at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          height: 80,
                          borderRadius: 0,
                          blur: 20,
                          alignment: Alignment.center,
                          border: 0,
                          linearGradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                          borderGradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.transparent],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  style,
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  outfitType,
                                  style: TextStyle(
                                    color: AppColors.textWhite.withOpacity(0.9),
                                    fontSize: 12,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Favorite button with animation
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: onFavoriteToggle,
                          child:
                              Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.9),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? AppColors.accent
                                          : AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  )
                                  .animate(target: isFavorite ? 1 : 0)
                                  .scale(
                                    duration: 200.ms,
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.2, 1.2),
                                    curve: Curves.easeOut,
                                  )
                                  .then()
                                  .scale(
                                    duration: 200.ms,
                                    begin: const Offset(1.2, 1.2),
                                    end: const Offset(1, 1),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: (50 * index).ms)
              .slideY(
                begin: 0.3,
                end: 0,
                duration: 400.ms,
                delay: (50 * index).ms,
                curve: Curves.easeOut,
              ),
    );
  }
}
