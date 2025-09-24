import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'together_ai_service.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _imageGenerationEndpoint = '/images/generations';

  static AIService? _instance;
  static AIService get instance => _instance ??= AIService._internal();
  AIService._internal();

  String? _apiKey;

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  /// Generate image using Together AI FLUX.1 model (primary)
  Future<AIImageResponse> generateImage({
    required String prompt,
    String style = 'realistic',
    int width = 1024,
    int height = 1024,
  }) async {
    try {
      // Enhance prompt with style
      final enhancedPrompt =
          OceanImageStyles.enhancePromptWithStyle(prompt, style);

      // Use Together AI as primary service
      final result = await TogetherAIService.instance.generateImage(
        prompt: enhancedPrompt,
        width: width,
        height: height,
      );

      if (result.isSuccess) {
        return AIImageResponse.fromTogetherAI(
          imageBytes: result.imageBytes!,
          prompt: result.prompt!,
          originalPrompt: result.originalPrompt!,
          seed: result.seed,
        );
      } else {
        throw AIServiceException(result.error ?? 'Failed to generate image');
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Image generation failed: ${e.toString()}');
    }
  }

  /// Fallback to OpenAI DALL-E (if needed)
  Future<AIImageResponse> generateImageWithDALLE({
    required String prompt,
    String model = 'dall-e-3',
    String size = '1024x1024',
    String quality = 'standard',
    int n = 1,
  }) async {
    if (!isConfigured) {
      throw AIServiceException('API key not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_imageGenerationEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model,
          'prompt': _enhanceUnderwaterPrompt(prompt),
          'n': n,
          'size': size,
          'quality': quality,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AIImageResponse.fromJson(data);
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw AIServiceException(
          error['error']['message'] ?? 'Failed to generate image',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw AIServiceException('No internet connection');
    } on FormatException {
      throw AIServiceException('Invalid response format');
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Unexpected error: ${e.toString()}');
    }
  }

  String _enhanceUnderwaterPrompt(String originalPrompt) {
    // Enhance user prompts with underwater/diving context
    const String underwaterContext =
        "Underwater scene, marine environment, diving perspective, "
        "ocean depths, aquatic life, coral reefs, submarine lighting, "
        "crystal clear water, marine ecosystem, ";

    // Check if prompt already contains underwater keywords
    final String lowerPrompt = originalPrompt.toLowerCase();
    final List<String> underwaterKeywords = [
      'underwater',
      'ocean',
      'sea',
      'diving',
      'marine',
      'coral',
      'fish',
      'reef',
      'submarine',
      'aquatic',
      'diving'
    ];

    bool hasUnderwaterContext =
        underwaterKeywords.any((keyword) => lowerPrompt.contains(keyword));

    if (!hasUnderwaterContext) {
      return "$underwaterContext$originalPrompt";
    }

    return originalPrompt;
  }

  Future<bool> validateApiKey(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class AIImageResponse {
  final List<AIImageData> data;
  final DateTime created;
  final Uint8List? imageBytes;
  final String? seed;

  AIImageResponse({
    required this.data,
    required this.created,
    this.imageBytes,
    this.seed,
  });

  factory AIImageResponse.fromJson(Map<String, dynamic> json) {
    return AIImageResponse(
      data: (json['data'] as List)
          .map((item) => AIImageData.fromJson(item))
          .toList(),
      created: DateTime.fromMillisecondsSinceEpoch(json['created'] * 1000),
    );
  }

  factory AIImageResponse.fromTogetherAI({
    required Uint8List imageBytes,
    required String prompt,
    required String originalPrompt,
    String? seed,
  }) {
    return AIImageResponse(
      data: [
        AIImageData(
          url: '', // No URL for base64 data
          revisedPrompt: prompt,
          originalPrompt: originalPrompt,
        ),
      ],
      created: DateTime.now(),
      imageBytes: imageBytes,
      seed: seed,
    );
  }
}

class AIImageData {
  final String url;
  final String? revisedPrompt;
  final String? originalPrompt;

  AIImageData({
    required this.url,
    this.revisedPrompt,
    this.originalPrompt,
  });

  factory AIImageData.fromJson(Map<String, dynamic> json) {
    return AIImageData(
      url: json['url'],
      revisedPrompt: json['revised_prompt'],
    );
  }
}

class AIServiceException implements Exception {
  final String message;
  final int? statusCode;

  AIServiceException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'AIServiceException ($statusCode): $message';
    }
    return 'AIServiceException: $message';
  }
}

// Predefined underwater prompts for inspiration
class UnderwaterPrompts {
  static const List<String> suggestions = [
    "A school of colorful tropical fish swimming around a vibrant coral reef",
    "A majestic sea turtle gliding through crystal clear blue water",
    "An ancient shipwreck covered in coral and marine life",
    "A diver exploring a underwater cave filled with bioluminescent creatures",
    "A pod of dolphins playing in sunbeams filtering through water",
    "A giant octopus camouflaged among rocks and seaweed",
    "A underwater garden of sea anemones and clownfish",
    "A deep ocean scene with whale songs and mysterious depths",
    "A coral reef teeming with life during golden hour underwater",
    "A diver swimming alongside a graceful manta ray",
  ];

  static String getRandomSuggestion() {
    final random = DateTime.now().millisecondsSinceEpoch % suggestions.length;
    return suggestions[random];
  }
}
