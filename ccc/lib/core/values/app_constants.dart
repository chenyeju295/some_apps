class AppConstants {
  // App Info
  static const String appName = 'Fashion Wallpaper';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String apiBaseUrl =
      'YOUR_API_BASE_URL'; // TODO: Replace with actual API
  static const String apiKey =
      'YOUR_API_KEY'; // TODO: Replace with actual API key

  // Token Configuration
  static const int initialTokens = 100;
  static const int tokensPerGeneration = 1;

  // IAP Product IDs
  static const List<String> iapProductIds = [
    'com.fashionwallpaper.tokens_500',
    'com.fashionwallpaper.tokens_1000',
    'com.fashionwallpaper.tokens_2500',
    'com.fashionwallpaper.tokens_6000',
    'com.fashionwallpaper.tokens_18000',
  ];

  // IAP Product Configuration
  static const Map<String, Map<String, dynamic>> iapProducts = {
    'com.fashionwallpaper.tokens_500': {
      'price': 2.99,
      'tokens': 500,
      'title': '500 Tokens',
      'description': 'Generate 500 wallpapers',
    },
    'com.fashionwallpaper.tokens_1000': {
      'price': 4.99,
      'tokens': 1000,
      'title': '1,000 Tokens',
      'description': 'Generate 1,000 wallpapers',
      'popular': true,
    },
    'com.fashionwallpaper.tokens_2500': {
      'price': 9.99,
      'tokens': 2500,
      'title': '2,500 Tokens',
      'description': 'Generate 2,500 wallpapers',
      'bestValue': true,
    },
    'com.fashionwallpaper.tokens_6000': {
      'price': 19.99,
      'tokens': 6000,
      'title': '6,000 Tokens',
      'description': 'Generate 6,000 wallpapers',
    },
    'com.fashionwallpaper.tokens_18000': {
      'price': 49.99,
      'tokens': 18000,
      'title': '18,000 Tokens',
      'description': 'Generate 18,000 wallpapers',
    },
  };

  // Image Generation Configuration
  static const String defaultAspectRatio = '9:16'; // Phone wallpaper
  static const int imageWidth = 1080;
  static const int imageHeight = 1920;

  // Style Categories (精简到4个最常用)
  static const List<String> styleCategories = [
    'Elegant',
    'Casual',
    'Vintage',
    'Modern',
  ];

  // Outfit Types (精简到5个最常用)
  static const List<String> outfitTypes = [
    'Dress',
    'Casual Wear',
    'Street Style',
    'Sportswear',
    'Beachwear',
  ];

  // Scene Settings (精简到4个最常用)
  static const List<String> sceneSettings = [
    'Urban',
    'Beach',
    'Nature',
    'Indoor',
  ];

  // Storage Keys
  static const String keyUserData = 'user_data';
  static const String keyTokenBalance = 'token_balance';
  static const String keyWallpapers = 'wallpapers';
  static const String keyFavorites = 'favorites';
  static const String keyGenerationHistory = 'generation_history';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyPrivacyAccepted = 'privacy_accepted';

  // UI Configuration
  static const int gridCrossAxisCount = 2;
  static const double gridSpacing = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Animation Duration
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
}
