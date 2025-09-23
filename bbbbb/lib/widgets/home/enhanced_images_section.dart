import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../models/generated_image.dart';
import '../../theme/app_theme.dart';
import '../../screens/image_detail_screen.dart';
import '../animations/ocean_animations.dart';

class EnhancedImagesSection extends StatelessWidget {
  final List<GeneratedImage> images;

  const EnhancedImagesSection({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {


    return Container(
       child: _buildImageSwiper(context),
    );
  }

  Widget _buildImageSwiper(BuildContext context) {
    return SizedBox(
      height: 370,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final image = images[index];
          return OceanAnimations.staggeredList(
            index: index,
            delay: 100,
            child: _EnhancedImageCard(
              image: image,
              onTap: () => _navigateToDetail(context, image, index),
            ),
          );
        },
        itemCount: images.length,
        viewportFraction: 0.8,
        scale: 0.9,
        pagination: SwiperPagination(
          alignment: Alignment.bottomCenter,
          margin: const EdgeInsets.only(bottom: 16),
          builder: DotSwiperPaginationBuilder(
            activeColor: AppTheme.seaFoam,
            color: AppTheme.lightAqua,
            size: 8,
            activeSize: 10,
            space: 4,
          ),
        ),
        autoplay: true,
        autoplayDelay: 4000,
        autoplayDisableOnInteraction: true,
        curve: AppTheme.defaultCurve,
      ),
    );
  }

  void _navigateToDetail(
      BuildContext context, GeneratedImage image, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ImageDetailScreen(
          image: image,
          allImages: images,
          initialIndex: index,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppTheme.normalAnimation,
      ),
    );
  }
}

class _EnhancedImageCard extends StatelessWidget {
  final GeneratedImage image;
  final VoidCallback onTap;

  const _EnhancedImageCard({
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: AppTheme.animatedCardDecoration.copyWith(
          boxShadow: AppTheme.floatingShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image
              _buildImageWidget(),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Content overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        image.title ?? image.prompt,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Description or tags
                      if (image.description != null)
                        Text(
                          image.description!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.3,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else if (image.tags != null && image.tags!.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children: image.tags!.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 8),

                      // Footer info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.seaFoam.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              image.style.displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          if (image.isFavorite)
                            Icon(
                              Icons.favorite,
                              color: AppTheme.coral,
                              size: 16,
                            ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withOpacity(0.8),
                            size: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Ripple effect
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: AppTheme.seaFoam.withOpacity(0.3),
                  highlightColor: AppTheme.seaFoam.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (image.imageUrl.startsWith('assets/')) {
      return Image.asset(
        image.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: image.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppTheme.oceanDepthDecoration,
      child: Center(
        child: OceanAnimations.pulsingGlow(
          child: const Icon(
            Icons.scuba_diving,
            color: Colors.white,
            size: 48,
          ),
          glowColor: AppTheme.seaFoam,
        ),
      ),
    );
  }
}

class _EmptyImagesState extends StatelessWidget {
  final VoidCallback onGeneratePressed;

  const _EmptyImagesState({
    required this.onGeneratePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          OceanAnimations.floatingWidget(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.sunlightGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Ocean Images Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.deepNavy,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start creating beautiful underwater imagery',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OceanAnimations.scaleInAnimation(
            delay: const Duration(milliseconds: 300),
            child: ElevatedButton.icon(
              onPressed: onGeneratePressed,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Generate Images'),
              style: AppTheme.primaryButtonStyle,
            ),
          ),
        ],
      ),
    );
  }
}
