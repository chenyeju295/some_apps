import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class TogetherAIService {
  static String _baseUrl = ('#h#t#t@p#s://a@pi#.to@ge@ther.xy@z/v@1')
      .replaceAll('@', '')
      .replaceAll('#', '');
  static const String _apiKey =
      'tgp_v1_CmuQYjkoM6_tW3F26ZQewIkpHgTDBoND998_oyVoumw';
  static const String _model = 'black-forest-labs/FLUX.1-schnell-Free';

  static TogetherAIService? _instance;
  static TogetherAIService get instance => _instance ??= TogetherAIService._();

  TogetherAIService._();

  /// Generate an image using Together AI FLUX.1 model
  Future<GenerateImageResult> generateImage({
    required String prompt,
    int width = 1024,
    int height = 1024,
    int steps = 4, // FLUX.1-schnell optimized for 1-4 steps
    String? seed,
  }) async {
    try {
      // Optimize prompt for ocean/diving theme
      final optimizedPrompt = _optimizePromptForOcean(prompt);

      final response = await http.post(
        Uri.parse('$_baseUrl/images/generations'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _model,
          'prompt': optimizedPrompt,
          'width': width,
          'height': height,
          'steps': steps,
          if (seed != null) 'seed': int.tryParse(seed),
          'response_format': 'b64_json',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final images = data['data'] as List;

        if (images.isNotEmpty) {
          final imageData = images.first;
          final base64Image = imageData['b64_json'] as String;
          final imageBytes = base64Decode(base64Image);

          return GenerateImageResult.success(
            imageBytes: imageBytes,
            prompt: optimizedPrompt,
            originalPrompt: prompt,
            seed: imageData['seed']?.toString(),
          );
        } else {
          return GenerateImageResult.error('No image generated');
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ??
            'Failed to generate image (${response.statusCode})';
        return GenerateImageResult.error(errorMessage);
      }
    } catch (e) {
      return GenerateImageResult.error('Network error: ${e.toString()}');
    }
  }

  /// Optimize prompt specifically for ocean and diving themes
  String _optimizePromptForOcean(String userPrompt) {
    // Add ocean-specific quality and style enhancements
    const oceanEnhancements = [
      'underwater photography',
      'crystal clear water',
      'natural lighting',
      'marine environment',
      'high quality',
      'detailed',
      'realistic',
      'professional photography'
    ];

    // Check if prompt already contains ocean-related terms
    final lowerPrompt = userPrompt.toLowerCase();
    final hasOceanContext = [
      'underwater',
      'ocean',
      'sea',
      'marine',
      'diving',
      'coral',
      'fish',
      'whale',
      'dolphin',
      'shark',
      'reef',
      'shipwreck'
    ].any((term) => lowerPrompt.contains(term));

    String optimizedPrompt = userPrompt.trim();

    // Add ocean context if missing
    if (!hasOceanContext) {
      optimizedPrompt = 'Underwater scene: $optimizedPrompt';
    }

    // Add quality enhancements
    optimizedPrompt += ', ${oceanEnhancements.join(', ')}';

    // Add negative prompts to avoid common issues
    optimizedPrompt +=
        '. Avoid: blurry, low quality, distorted, cartoon, anime';

    return optimizedPrompt;
  }

  /// Check API status and rate limits
  Future<bool> checkApiStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get available models
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = data['data'] as List;
        return models
            .where((model) => model['id']?.toString().contains('flux') == true)
            .map((model) => model['id'].toString())
            .toList();
      }
      return [_model];
    } catch (e) {
      return [_model];
    }
  }
}

class GenerateImageResult {
  final bool isSuccess;
  final Uint8List? imageBytes;
  final String? prompt;
  final String? originalPrompt;
  final String? seed;
  final String? error;

  const GenerateImageResult._({
    required this.isSuccess,
    this.imageBytes,
    this.prompt,
    this.originalPrompt,
    this.seed,
    this.error,
  });

  factory GenerateImageResult.success({
    required Uint8List imageBytes,
    required String prompt,
    required String originalPrompt,
    String? seed,
  }) {
    return GenerateImageResult._(
      isSuccess: true,
      imageBytes: imageBytes,
      prompt: prompt,
      originalPrompt: originalPrompt,
      seed: seed,
    );
  }

  factory GenerateImageResult.error(String error) {
    return GenerateImageResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// Ocean-themed prompt suggestions with better quality
class OceanPromptSuggestions {
  static const List<String> suggestions = [
    'A vibrant coral reef teeming with colorful tropical fish, sea anemones, and marine life',
    'A majestic sea turtle swimming gracefully through crystal clear blue water with sunbeams',
    'An ancient shipwreck covered in coral and surrounded by schools of fish',
    'A professional diver exploring an underwater cave with bioluminescent creatures',
    'A pod of dolphins playing in the deep blue ocean with streaming sunlight',
    'A giant Pacific octopus camouflaged among kelp forest and rocky formations',
    'A underwater garden of sea anemones with clownfish in a tropical reef',
    'A deep ocean scene with mysterious whale silhouettes and ethereal lighting',
    'A macro shot of colorful nudibranch sea slugs on vibrant coral',
    'A manta ray gliding elegantly over a sandy ocean floor with coral formations',
    'A school of hammerhead sharks swimming in formation in deep blue water',
    'An underwater photographer capturing marine life in a kelp forest',
  ];

  static String getRandomSuggestion() {
    return suggestions[DateTime.now().millisecond % suggestions.length];
  }

  static List<String> getFeaturedSuggestions() {
    return suggestions.take(8).toList();
  }
}

/// Image style enhancements for ocean themes
class OceanImageStyles {
  static const Map<String, String> styleEnhancements = {
    'realistic':
        'photorealistic underwater photography, natural lighting, professional quality',
    'artistic':
        'artistic underwater scene, painterly style, vibrant colors, dreamy atmosphere',
    'cinematic':
        'cinematic underwater shot, dramatic lighting, movie quality, epic composition',
    'macro':
        'macro underwater photography, close-up details, sharp focus, professional marine photography',
    'wide_angle':
        'wide angle underwater scene, expansive ocean view, dramatic perspective',
    'vintage':
        'vintage underwater photography, film grain, nostalgic ocean exploration',
  };

  static String enhancePromptWithStyle(String prompt, String style) {
    final enhancement =
        styleEnhancements[style] ?? styleEnhancements['realistic']!;
    return '$prompt, $enhancement';
  }
}
