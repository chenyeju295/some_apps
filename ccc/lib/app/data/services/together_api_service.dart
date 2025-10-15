import 'dart:convert';
import 'package:http/http.dart' as http;

/// Together AI API service for image generation
class TogetherApiService {
  static const String _baseUrl = 'https://api.together.xyz/v1';
  static const String _apiKey =
      'tgp_v1_bSX64ZBBTekVGi93CIXgPOGbm-uSNVOAewa1mo9Og_0';
  static const String _model = 'black-forest-labs/FLUX.1-schnell-Free';

  /// Generate image from prompt
  /// Returns the image URL or throws an exception
  static Future<String> generateImage({
    required String prompt,
    int? width,
    int? height,
    int? steps,
    int? seed,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/images/generations'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'prompt': prompt,
          if (width != null) 'width': width,
          if (height != null) 'height': height,
          if (steps != null) 'steps': steps,
          if (seed != null) 'seed': seed,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Together API 返回格式: {"data": [{"url": "..."}]}
        if (data['data'] != null &&
            data['data'] is List &&
            data['data'].isNotEmpty) {
          final imageData = data['data'][0];

          // 可能是 url 或 b64_json
          if (imageData['url'] != null) {
            return imageData['url'] as String;
          } else if (imageData['b64_json'] != null) {
            // 如果返回base64，需要转换处理
            return imageData['b64_json'] as String;
          }
        }

        throw Exception('Invalid response format: no image URL found');
      } else {
        final errorBody = response.body;
        throw Exception(
          'API request failed with status ${response.statusCode}: $errorBody',
        );
      }
    } catch (e) {
      throw Exception('Image generation failed: $e');
    }
  }

  /// Build fashion wallpaper prompt with style details
  static String buildFashionPrompt({
    required String style,
    required String outfitType,
    required String scene,
    String? additionalPrompt,
  }) {
    final basePrompt =
        '''
A beautiful fashionable woman in $outfitType, 
$style style, 
set in $scene, 
professional fashion photography, 
high quality, detailed, 
stunning composition, 
cinematic lighting, 
9:16 aspect ratio wallpaper''';

    if (additionalPrompt != null && additionalPrompt.isNotEmpty) {
      return '$basePrompt, $additionalPrompt';
    }

    return basePrompt;
  }

  /// Test API connection
  static Future<bool> testConnection() async {
    try {
      await generateImage(prompt: 'test image');
      return true;
    } catch (e) {
      print('API connection test failed: $e');
      return false;
    }
  }
}
