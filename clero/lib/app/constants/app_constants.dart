class AppConstants {
  // App Info
  static const String appName = 'AI Wallpaper Generator';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyFirstTime = 'first_time';
  static const String keyDarkMode = 'dark_mode';
  static const String keySelectedTheme = 'selected_theme';
  static const String keyFavoriteWallpapers = 'favorite_wallpapers';
  static const String keyGenerationHistory = 'generation_history';
  static const String keyShowGenerationConfirm = 'show_generation_confirm';

  // API Configuration
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String imageGenerationEndpoint = '/images/generations';

  // Theme Categories
  static const List<String> themeCategories = [
    'Nature',
    'City',
    'Space',
    'Abstract',
    'Minimal',
    'Fantasy',
    'Ocean',
    'Mountains',
    'Architecture',
    'Animals'
  ];

  // Image Sizes for DALL-E
  static const List<String> imageSizes = [
    '1024x1024',
    '1792x1024',
    '1024x1792'
  ];

  // Default Values
  static const String defaultImageSize = '1024x1792'; // iPhone wallpaper ratio
  static const int maxGenerationHistory = 100;
  static const int maxFavorites = 50;
}
