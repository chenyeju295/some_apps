import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_image_provider.dart';
import '../models/generated_image.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/ocean_animations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Generation History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.oceanBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.oceanBlue,
                AppTheme.tropicalTeal,
              ],
            ),
          ),
        ),
      ),
      body: Consumer<EnhancedImageProvider>(
        builder: (context, imageProvider, child) {
          if (imageProvider.images.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await imageProvider.loadImages();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: imageProvider.images.length,
              itemBuilder: (context, index) {
                final image = imageProvider.images[index];
                return OceanAnimations.staggeredList(
                  index: index,
                  delay: 50,
                  child: _HistoryItem(
                    image: image,
                    onTap: () => _showImageDetail(context, image),
                    onFavoriteToggle: () =>
                        imageProvider.toggleImageFavorite(image.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OceanAnimations.floatingWidget(
            offset: 20.0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.sunlightGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.floatingShadow,
              ),
              child: const Icon(
                Icons.history,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Generation History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Your generated ocean images will appear here. Start creating to build your history!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDetail(BuildContext context, GeneratedImage image) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _ImageDetailDialog(image: image),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppTheme.normalAnimation,
        opaque: false,
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final GeneratedImage image;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _HistoryItem({
    required this.image,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.oceanBlue.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image thumbnail
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppTheme.lightAqua,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Hero(
                      tag: 'history_image_${image.id}',
                      child: image.imageUrl.startsWith('/')
                          ? Image.file(
                              File(image.imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            )
                          : Image.asset(
                              image.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            ),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          image.title ?? image.prompt,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.deepNavy,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Style and date
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.oceanBlue.withOpacity(0.8),
                                    AppTheme.tropicalTeal.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                image.style.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppTheme.seaFoam,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(image.createdAt),
                              style: TextStyle(
                                color: AppTheme.seaFoam,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Favorite button
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: image.isFavorite
                            ? AppTheme.coral.withOpacity(0.1)
                            : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        image.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: image.isFavorite
                            ? AppTheme.coral
                            : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: AppTheme.oceanDepthDecoration,
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.white.withOpacity(0.5),
          size: 30,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }
}

class _ImageDetailDialog extends StatelessWidget {
  final GeneratedImage image;

  const _ImageDetailDialog({required this.image});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),

            // Image and details
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    Container(
                      height: 300,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Hero(
                          tag: 'history_image_${image.id}',
                          child: image.imageUrl.startsWith('/')
                              ? Image.file(
                                  File(image.imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppTheme.lightAqua,
                                      child: Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 100,
                                          color: AppTheme.oceanBlue,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Image.asset(
                                  image.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppTheme.lightAqua,
                                      child: Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 100,
                                          color: AppTheme.oceanBlue,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),

                    // Details
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            image.title ?? image.prompt,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                          if (image.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              image.description!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Tags and metadata
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightAqua,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  image.style.displayName,
                                  style: TextStyle(
                                    color: AppTheme.oceanBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  context
                                      .read<EnhancedImageProvider>()
                                      .toggleImageFavorite(image.id);
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  image.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: AppTheme.coral,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
