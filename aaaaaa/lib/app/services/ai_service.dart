import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../models/wallpaper_model.dart';
import 'image_service.dart';

class AIService {
  static const String _baseUrl =
      'https://api.together.xyz/v1/images/generations';
  static const String _apiKey =
      'tgp_v1_MmM3xO9NcFhbEUG7hpYkv9664YbSDWdib0n3DyeHCZ0';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    },
  ));

  // Set API key (should be set from secure storage or environment)
  static void setApiKey(String apiKey) {
    _dio.options.headers['Authorization'] = 'Bearer $apiKey';
  }

  // Generate wallpaper using FLUX.1-dev API with optimized defaults
  static Future<WallpaperModel?> generateWallpaper({
    required String prompt,
    required String category,
    String style = 'realistic',
  }) async {
    try {
      print('Generating image with Together AI - Prompt: $prompt');

      // Use optimized defaults: Portrait HD quality
      const size = '1024x1792'; // Portrait wallpaper
      final sizeMap = _getSizeFromString(size);
      final enhancedPrompt = _enhancePrompt(prompt, style);

      final response = await _dio.post(
        '', // Empty string since baseUrl is the full endpoint
        data: {
          'model': 'black-forest-labs/FLUX.1-dev',
          'prompt': enhancedPrompt,
          'width': sizeMap['width'],
          'height': sizeMap['height'],
          'steps': 50, // Always use high quality
          'seed': null,
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final imageData = data['data'][0];
        final imageUrl = imageData['url'] ?? imageData['b64_json'];

        final wallpaperId = DateTime.now().millisecondsSinceEpoch.toString();

        // Download and save image locally
        final localPath = await ImageService.downloadAndSaveImage(
          imageUrl: imageUrl,
          wallpaperId: wallpaperId,
          prompt: prompt,
        );

        return WallpaperModel(
          id: wallpaperId,
          url: imageUrl,
          localPath: localPath,
          prompt: prompt,
          category: category,
          createdAt: DateTime.now(),
          style: style,
          quality: 'hd', // Always HD
          size: size,
        );
      } else {
        getx.Get.snackbar(
          'Error',
          'Failed to generate wallpaper: ${response.statusMessage}',
          snackPosition: getx.SnackPosition.BOTTOM,
        );
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      print('DioException: ${e.toString()}');
      print('Response: ${e.response?.data}');

      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData != null && errorData['error'] != null) {
          errorMessage = errorData['error']['message'] ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout. Please try again.';
      }

      getx.Get.snackbar(
        'Generation Failed',
        errorMessage,
        snackPosition: getx.SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      getx.Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: getx.SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Enhance prompt with wallpaper-specific keywords and style
  static String _enhancePrompt(String prompt, String style) {
    String stylePrompt = '';

    switch (style) {
      case 'realistic':
        stylePrompt = 'photorealistic, high detail, professional photography';
        break;
      case 'artistic':
        stylePrompt = 'artistic style, creative composition, painterly';
        break;
      case 'anime':
        stylePrompt = 'anime style, manga artwork, Japanese animation';
        break;
      case 'fantasy':
        stylePrompt = 'fantasy art, magical, ethereal, otherworldly';
        break;
      case 'vintage':
        stylePrompt = 'vintage style, retro aesthetic, classic';
        break;
      case 'modern':
        stylePrompt = 'modern contemporary art, sleek design, minimalist';
        break;
      default:
        stylePrompt = 'high quality artwork';
    }

    return '$prompt, $stylePrompt, high resolution wallpaper, beautiful composition, vibrant colors, 4K quality, detailed';
  }

  // Helper method to convert size string to width/height
  static Map<String, int> _getSizeFromString(String size) {
    switch (size) {
      case 'portrait':
      case '1024x1792':
        return {'width': 1024, 'height': 1792};
      case 'landscape':
      case '1792x1024':
        return {'width': 1792, 'height': 1024};
      case 'square':
      case '1024x1024':
      default:
        return {'width': 1024, 'height': 1024};
    }
  }

  // Generate multiple wallpapers
  static Future<List<WallpaperModel>> generateMultipleWallpapers({
    required List<String> prompts,
    required String category,
    String size = '1024x1024',
    String quality = 'standard',
    String style = 'realistic',
  }) async {
    final List<WallpaperModel> wallpapers = [];

    for (final prompt in prompts) {
      try {
        final wallpaper = await generateWallpaper(
          prompt: prompt,
          category: category,
          size: size,
          quality: quality,
          style: style,
        );
        if (wallpaper != null) {
          wallpapers.add(wallpaper);
        }

        // Add small delay between requests to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 1000));
      } catch (e) {
        print('Error generating wallpaper for prompt "$prompt": $e');
        // Continue with other prompts even if one fails
      }
    }

    return wallpapers;
  }

  // Test API connection
  static Future<bool> testConnection() async {
    try {
      final result = await generateWallpaper(
        prompt: 'Test image',
        category: 'Test',
        size: '1024x1024',
        quality: 'standard',
      );
      return result != null;
    } catch (e) {
      print('API test failed: $e');
      return false;
    }
  }
}
