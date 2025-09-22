import 'package:flutter/foundation.dart';
import '../models/generated_image.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

class ImageProvider extends ChangeNotifier {
  List<GeneratedImage> _images = [];
  bool _isGenerating = false;
  String? _error;
  String _currentPrompt = '';

  List<GeneratedImage> get images => _images;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  String get currentPrompt => _currentPrompt;

  List<GeneratedImage> get favoriteImages =>
      _images.where((image) => image.isFavorite).toList();

  List<GeneratedImage> get recentImages =>
      List.from(_images)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> loadImages() async {
    try {
      _images = await StorageService.instance.getGeneratedImages();

      // Add sample female diver images if no images exist
      if (_images.isEmpty) {
        _images = _generateSampleImages();
        // Save sample images to storage
        for (final image in _images) {
          // await StorageService.instance.saveGeneratedImage(image);
        }
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load images: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<GeneratedImage?> generateImage({
    required String prompt,
    required ImageStyle style,
    required Function(int) onTokensUsed,
  }) async {
    if (prompt.trim().isEmpty) {
      _error = 'Please enter a prompt for image generation';
      notifyListeners();
      return null;
    }

    _setGenerating(true);
    _currentPrompt = prompt;

    try {
      // Call AI service to generate image
      final AIImageResponse response = await AIService.instance.generateImage(
        prompt: prompt,
        model: 'dall-e-3',
        size: '1024x1024',
        quality: 'standard',
      );

      if (response.data.isNotEmpty) {
        final AIImageData imageData = response.data.first;

        // Create GeneratedImage model
        final GeneratedImage generatedImage = GeneratedImage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          prompt: imageData.revisedPrompt ?? prompt,
          imageUrl: imageData.url,
          createdAt: DateTime.now(),
          style: style,
          tokensUsed: 1,
        );

        // Save to storage
        await StorageService.instance.addGeneratedImage(generatedImage);

        // Update local list
        _images.insert(0, generatedImage);

        // Notify token usage
        onTokensUsed(1);

        _error = null;
        notifyListeners();
        return generatedImage;
      } else {
        throw Exception('No image data received from AI service');
      }
    } on AIServiceException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Failed to generate image: ${e.toString()}';
      notifyListeners();
      return null;
    } finally {
      _setGenerating(false);
      _currentPrompt = '';
    }
  }

  Future<void> toggleImageFavorite(String imageId) async {
    try {
      final int index = _images.indexWhere((img) => img.id == imageId);
      if (index != -1) {
        final GeneratedImage image = _images[index];
        final GeneratedImage updatedImage = image.copyWith(
          isFavorite: !image.isFavorite,
        );

        _images[index] = updatedImage;
        await StorageService.instance.updateGeneratedImage(updatedImage);

        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update favorite: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteImage(String imageId) async {
    try {
      _images.removeWhere((img) => img.id == imageId);
      await StorageService.instance.deleteGeneratedImage(imageId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete image: ${e.toString()}';
      notifyListeners();
    }
  }

  GeneratedImage? getImageById(String id) {
    try {
      return _images.firstWhere((image) => image.id == id);
    } catch (e) {
      return null;
    }
  }

  List<GeneratedImage> getImagesByStyle(ImageStyle style) {
    return _images.where((image) => image.style == style).toList();
  }

  List<GeneratedImage> searchImages(String query) {
    if (query.trim().isEmpty) return _images;

    final String lowerQuery = query.toLowerCase();
    return _images.where((image) {
      return image.prompt.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void _setGenerating(bool generating) {
    _isGenerating = generating;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Statistics
  int get totalImagesGenerated => _images.length;
  int get totalFavorites => favoriteImages.length;
  int get totalTokensUsed =>
      _images.fold(0, (sum, img) => sum + img.tokensUsed);

  Map<ImageStyle, int> get imagesByStyle {
    final Map<ImageStyle, int> styleCount = {};
    for (final ImageStyle style in ImageStyle.values) {
      styleCount[style] = _images.where((img) => img.style == style).length;
    }
    return styleCount;
  }

  String get mostUsedStyle {
    final Map<ImageStyle, int> styleCounts = imagesByStyle;
    if (styleCounts.isEmpty) return ImageStyle.realistic.displayName;

    ImageStyle mostUsed = styleCounts.keys.first;
    int maxCount = styleCounts[mostUsed] ?? 0;

    for (final entry in styleCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostUsed = entry.key;
      }
    }

    return mostUsed.displayName;
  }

  Future<void> clearAllImages() async {
    try {
      for (final image in _images) {
        await StorageService.instance.deleteGeneratedImage(image.id);
      }
      _images.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear images: ${e.toString()}';
      notifyListeners();
    }
  }

  List<GeneratedImage> _generateSampleImages() {
    return [
      GeneratedImage(
        id: 'sample_001',
        prompt:
            'Professional female scuba diver underwater with crystal clear blue water',
        imageUrl: 'assets/images/female_diver_1.png',
        style: ImageStyle.realistic,
        tokensUsed: 10,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isFavorite: true,
      ),
      GeneratedImage(
        id: 'sample_002',
        prompt:
            'Graceful female diver exploring vibrant coral reef with tropical fish',
        imageUrl: 'assets/images/female_diver_2.png',
        style: ImageStyle.artistic,
        tokensUsed: 10,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isFavorite: false,
      ),
      GeneratedImage(
        id: 'sample_003',
        prompt: 'Female dive instructor demonstrating underwater techniques',
        imageUrl: 'assets/images/female_diver_instructor.png',
        style: ImageStyle.realistic,
        tokensUsed: 10,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isFavorite: true,
        title: 'Dive Instructor Training',
        description:
            'Professional instruction and skill demonstration underwater',
        knowledgeContent: '''**Professional Dive Instruction**

Becoming a dive instructor requires extensive training and certification:

• **Prerequisites**: Rescue Diver certification, 100+ logged dives, 18+ years old
• **Training Path**: Divemaster → Assistant Instructor → Open Water Scuba Instructor
• **Core Skills**: Teaching methodology, risk management, emergency response
• **Continuous Education**: Specialty instructor certifications and skill updates

**Teaching Underwater:**
- Crystal clear skill demonstrations at student pace
- Maintaining group management and safety oversight  
- Effective communication using hand signals
- Building student confidence through positive reinforcement

**Professional Opportunities:**
- Resort diving destinations worldwide
- Dive center employment and management
- Specialty course instruction (photography, navigation, etc.)
- Technical diving and advanced certifications

The diving industry values skilled female instructors who bring patience, attention to detail, and excellent communication skills.''',
        tags: [
          'dive instructor',
          'professional diving',
          'education',
          'career development'
        ],
      ),
      GeneratedImage(
        id: 'sample_004',
        prompt:
            'Female diver swimming peacefully with sea turtles in azure waters',
        imageUrl: 'assets/images/female_diver_turtle.png',
        style: ImageStyle.realistic,
        tokensUsed: 10,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        isFavorite: false,
      ),
      GeneratedImage(
        id: 'sample_005',
        prompt:
            'Team of diverse female divers preparing for underwater adventure',
        imageUrl: 'assets/images/female_diving_team.png',
        style: ImageStyle.artistic,
        tokensUsed: 10,
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        isFavorite: true,
      ),
      GeneratedImage(
        id: 'sample_006',
        prompt: 'Elegant female freediver in graceful underwater pose',
        imageUrl: 'assets/images/female_freediver.png',
        style: ImageStyle.artistic,
        tokensUsed: 10,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        isFavorite: false,
      ),
      GeneratedImage(
        id: 'sample_007',
        prompt:
            'Beautiful underwater ocean scene with coral reef and marine life',
        imageUrl: 'assets/images/ocean_background.png',
        style: ImageStyle.realistic,
        tokensUsed: 10,
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
        isFavorite: false,
      ),
      GeneratedImage(
        id: 'sample_008',
        prompt:
            'Coral reef welcome scene with tropical fish and vibrant colors',
        imageUrl: 'assets/images/coral_welcome.png',
        style: ImageStyle.realistic,
        tokensUsed: 10,
        createdAt: DateTime.now().subtract(const Duration(hours: 16)),
        isFavorite: true,
      ),
    ];
  }
}
