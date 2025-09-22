import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../constants/app_constants.dart';
import '../models/wallpaper_model.dart';

class AIService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // Set API key (should be set from secure storage or environment)
  static void setApiKey(String apiKey) {
    _dio.options.headers['Authorization'] = 'Bearer $apiKey';
  }

  // Generate wallpaper using DALL-E API
  static Future<WallpaperModel?> generateWallpaper({
    required String prompt,
    required String category,
    String size = AppConstants.defaultImageSize,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.imageGenerationEndpoint,
        data: {
          'model': 'dall-e-3',
          'prompt': _enhancePrompt(prompt),
          'n': 1,
          'size': size,
          'quality': 'hd',
          'response_format': 'url',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final imageUrl = data['data'][0]['url'] as String;
        final revisedPrompt =
            data['data'][0]['revised_prompt'] as String? ?? prompt;

        return WallpaperModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: imageUrl,
          prompt: revisedPrompt,
          category: category,
          createdAt: DateTime.now(),
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
      getx.Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: getx.SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Enhance prompt with wallpaper-specific keywords
  static String _enhancePrompt(String prompt) {
    // Add wallpaper-specific enhancements
    final enhancedPrompt =
        '$prompt, high resolution wallpaper, beautiful composition, vibrant colors, professional photography style, 4K quality';
    return enhancedPrompt;
  }

  // Test API connection
  static Future<bool> testConnection() async {
    try {
      // Use a simple request to test the connection
      final response = await _dio.get('/models');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get available models
  static Future<List<String>> getAvailableModels() async {
    try {
      final response = await _dio.get('/models');
      if (response.statusCode == 200) {
        final data = response.data;
        final models = data['data'] as List;
        return models
            .where((model) => model['id'].toString().contains('dall-e'))
            .map((model) => model['id'].toString())
            .toList();
      }
      return ['dall-e-3']; // Default fallback
    } catch (e) {
      return ['dall-e-3']; // Default fallback
    }
  }
}
