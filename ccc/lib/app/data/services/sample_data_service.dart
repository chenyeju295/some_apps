import '../models/wallpaper_model.dart';

/// Service to provide sample wallpaper data for demo and testing
class SampleDataService {
  static List<WallpaperModel> getSampleWallpapers() {
    final now = DateTime.now();

    return [
      // Elegant & Formal
      WallpaperModel(
        id: 'sample_001',
        imageUrl: 'assets/images/sample_wallpapers/elegant_evening_01.png',
        prompt: 'Elegant evening dress in urban street at golden hour',
        tags: ['elegant', 'formal', 'evening', 'urban'],
        style: 'Elegant & Formal',
        outfitType: 'Evening Dress',
        scene: 'Urban Street',
        isFavorite: true,
        isSample: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),

      WallpaperModel(
        id: 'sample_002',
        imageUrl: 'assets/images/sample_wallpapers/elegant_cocktail_01.png',
        prompt: 'Cocktail dress at night city with glamorous style',
        tags: ['elegant', 'cocktail', 'night', 'glamorous'],
        style: 'Elegant & Formal',
        outfitType: 'Cocktail Dress',
        scene: 'Night City',
        isFavorite: true,
        isSample: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),

      // Casual & Street
      WallpaperModel(
        id: 'sample_003',
        imageUrl: 'assets/images/sample_wallpapers/casual_street_01.png',
        prompt: 'Trendy casual street style with urban fashion',
        tags: ['casual', 'street', 'trendy', 'urban'],
        style: 'Casual & Street',
        outfitType: 'Street Style',
        scene: 'Urban Street',
        isFavorite: false,
        isSample: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),

      // Vintage & Retro
      WallpaperModel(
        id: 'sample_004',
        imageUrl: 'assets/images/sample_wallpapers/vintage_retro_01.png',
        prompt: '1960s vintage style with retro cafe atmosphere',
        tags: ['vintage', 'retro', '1960s', 'cafe'],
        style: 'Vintage & Retro',
        outfitType: 'Casual Wear',
        scene: 'Cafe',
        isFavorite: true,
        isSample: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),

      // Minimalist & Modern
      WallpaperModel(
        id: 'sample_005',
        imageUrl: 'assets/images/sample_wallpapers/minimalist_modern_01.png',
        prompt: 'Sleek minimalist modern style with clean aesthetics',
        tags: ['minimalist', 'modern', 'sleek', 'clean'],
        style: 'Minimalist & Modern',
        outfitType: 'Casual Wear',
        scene: 'Indoor Studio',
        isFavorite: false,
        isSample: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),

      // Bohemian & Free
      WallpaperModel(
        id: 'sample_006',
        imageUrl: 'assets/images/sample_wallpapers/bohemian_free_01.png',
        prompt: 'Bohemian flowing dress in natural garden setting',
        tags: ['bohemian', 'free', 'natural', 'garden'],
        style: 'Bohemian & Free',
        outfitType: 'Casual Wear',
        scene: 'Garden',
        isFavorite: true,
        isSample: true,
        createdAt: now.subtract(const Duration(days: 6)),
      ),

      // Athletic & Sporty
      WallpaperModel(
        id: 'sample_007',
        imageUrl: 'assets/images/sample_wallpapers/athletic_sporty_01.png',
        prompt: 'Athletic activewear with energetic outdoor vibes',
        tags: ['athletic', 'sporty', 'activewear', 'energetic'],
        style: 'Athletic & Sporty',
        outfitType: 'Sportswear',
        scene: 'Urban Street',
        isFavorite: false,
        isSample: true,
        createdAt: now.subtract(const Duration(days: 7)),
      ),

      // Business Professional
      WallpaperModel(
        id: 'sample_008',
        imageUrl:
            'assets/images/sample_wallpapers/business_professional_01.png',
        prompt: 'Professional business suit in modern office',
        tags: ['business', 'professional', 'formal', 'office'],
        style: 'Elegant & Formal',
        outfitType: 'Business Suit',
        scene: 'Office',
        isFavorite: false,
        isSample: true,
        createdAt: now.subtract(const Duration(days: 8)),
      ),

      // Beach Summer
      WallpaperModel(
        id: 'sample_009',
        imageUrl: 'assets/images/sample_wallpapers/beach_summer_01.png',
        prompt: 'Summer beachwear with tropical sunset vibes',
        tags: ['beach', 'summer', 'tropical', 'casual'],
        style: 'Casual & Street',
        outfitType: 'Beachwear',
        scene: 'Beach',
        isFavorite: true,
        isSample: true,
        createdAt: now.subtract(const Duration(days: 9)),
      ),

      // Traditional Elegant
      WallpaperModel(
        id: 'sample_010',
        imageUrl: 'assets/images/sample_wallpapers/traditional_elegant_01.png',
        prompt: 'Traditional elegant dress in garden with flowers',
        tags: ['traditional', 'elegant', 'garden', 'flowers'],
        style: 'Elegant & Formal',
        outfitType: 'Traditional',
        scene: 'Garden',
        isFavorite: false,
        isSample: true,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }

  /// Get featured wallpapers (favorites)
  static List<WallpaperModel> getFeaturedWallpapers() {
    return getSampleWallpapers().where((w) => w.isFavorite).take(6).toList();
  }

  /// Get recent wallpapers
  static List<WallpaperModel> getRecentWallpapers({int limit = 6}) {
    return getSampleWallpapers().take(limit).toList();
  }

  /// Get wallpapers by style category
  static List<WallpaperModel> getWallpapersByStyle(String style) {
    return getSampleWallpapers().where((w) => w.style == style).toList();
  }

  /// Get wallpapers by outfit type
  static List<WallpaperModel> getWallpapersByOutfit(String outfitType) {
    return getSampleWallpapers()
        .where((w) => w.outfitType == outfitType)
        .toList();
  }

  /// Get wallpapers by scene
  static List<WallpaperModel> getWallpapersByScene(String scene) {
    return getSampleWallpapers().where((w) => w.scene == scene).toList();
  }
}
