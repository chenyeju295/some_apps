import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import '../models/generated_image.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/ocean_animations.dart';

class ImageDetailScreen extends StatefulWidget {
  final GeneratedImage image;
  final List<GeneratedImage> allImages;
  final int initialIndex;

  const ImageDetailScreen({
    super.key,
    required this.image,
    required this.allImages,
    required this.initialIndex,
  });

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    super.dispose();
  }

  GeneratedImage get currentImage => widget.allImages[_currentIndex];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.oceanDepthDecoration,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title:
          Text(
            '${_currentIndex + 1} / ${widget.allImages.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [

            OceanAnimations.scaleInAnimation(
              delay: const Duration(milliseconds: 100),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    currentImage.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                    currentImage.isFavorite ? AppTheme.coral : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            ),
            SizedBox(width: 12,)
          ],
        ),
        body: Column(
          children: [

            // Image Swiper
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildImageSwiper(),
              ),
            ),

            // Content Section
            Expanded(
              flex: 2,
              child: _buildContentSection(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildImageSwiper() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final image = widget.allImages[index];
          return Container(
            decoration: AppTheme.animatedCardDecoration,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImageWidget(image),
            ),
          );
        },
        itemCount: widget.allImages.length,
        index: widget.initialIndex,
        pagination: SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            activeColor: AppTheme.seaFoam,
            color: Colors.white.withOpacity(0.5),
            size: 8,
            activeSize: 12,
          ),
        ),
        control: SwiperControl(
          iconNext: Icons.arrow_forward_ios,
          iconPrevious: Icons.arrow_back_ios,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        viewportFraction: 1.0,
        scale: 1.0,
        loop: false,
        duration: 300,
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildImageWidget(GeneratedImage image) {
    if (image.imageUrl.startsWith('assets/')) {
      return Image.asset(
        image.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: image.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: AppTheme.sunlightDecoration,
      child: const Center(
        child: Icon(
          Icons.scuba_diving,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and tags
            _buildHeader(),
            const SizedBox(height: 16),

            // Description
            if (currentImage.description != null) ...[
              _buildDescription(),
              const SizedBox(height: 20),
            ],

            // Knowledge content
            if (currentImage.knowledgeContent != null) ...[
              _buildKnowledgeContent(),
              const SizedBox(height: 20),
            ],

            // Image info
            _buildImageInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          currentImage.title ?? currentImage.prompt,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 8),

        // Tags
        if (currentImage.tags != null && currentImage.tags!.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: currentImage.tags!.map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lightAqua,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.seaFoam.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.oceanBlue,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightAqua.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.seaFoam.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            currentImage.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.deepNavy,
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.school,
              color: AppTheme.oceanBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Diving Knowledge',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.pearl.withOpacity(0.5),
                AppTheme.lightAqua.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.oceanBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            currentImage.knowledgeContent!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.deepNavy,
                  height: 1.6,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Style', currentImage.style.displayName),
          const SizedBox(height: 8),
          _buildInfoRow('Created', _formatDate(currentImage.createdAt)),
          const SizedBox(height: 8),
          _buildInfoRow('Tokens Used', '${currentImage.tokensUsed}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  void _toggleFavorite() {
    // TODO: Implement favorite toggle logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(currentImage.isFavorite
            ? 'Removed from favorites'
            : 'Added to favorites'),
        backgroundColor: AppTheme.oceanBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
