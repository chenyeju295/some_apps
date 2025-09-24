import 'package:flutter/foundation.dart';
import '../models/generated_image.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/image_storage_service.dart';

enum GenerationState {
  idle,
  preparing,
  generating,
  processing,
  saving,
  completed,
  error,
}

class EnhancedImageProvider extends ChangeNotifier {
  List<GeneratedImage> _images = [];
  GenerationState _generationState = GenerationState.idle;
  String? _error;
  double _generationProgress = 0.0;
  String _generationStatusMessage = '';

  // Getters
  List<GeneratedImage> get images => _images;
  List<GeneratedImage> get sampleImages => _generateSampleImages();
  GenerationState get generationState => _generationState;
  bool get isGenerating =>
      _generationState != GenerationState.idle &&
      _generationState != GenerationState.completed &&
      _generationState != GenerationState.error;
  String? get error => _error;
  double get generationProgress => _generationProgress;
  String get generationStatusMessage => _generationStatusMessage;

  List<GeneratedImage> get favoriteImages =>
      _images.where((image) => image.isFavorite).toList();

  List<GeneratedImage> get recentImages =>
      List.from(_images)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Initialize the provider
  Future<void> initialize() async {
    await ImageStorageService.instance.initialize();
    await loadImages();
  }

  /// Load images from storage
  Future<void> loadImages() async {
    try {
      _setGenerationState(GenerationState.preparing);

      final storedImages = await StorageService.instance.getGeneratedImages();
      final imagePaths = await ImageStorageService.instance.getAllImagePaths();

      final validImages = <GeneratedImage>[];
      for (final image in storedImages) {
        if (imagePaths.contains(image.imageUrl) ||
            image.imageUrl.startsWith('assets/')) {
          validImages.add(image);
        } else {
          await StorageService.instance.deleteGeneratedImage(image.id);
        }
      }

      _images = validImages;

      // Add sample images if no images exist (for demonstration)
      if (_images.isEmpty) {
        _images = _generateSampleImages();
      }

      _error = null;
      _setGenerationState(GenerationState.idle);

      _performBackgroundCleanup();
    } catch (e) {
      _error = 'Failed to load images: ${e.toString()}';
      _setGenerationState(GenerationState.error);
    }
  }

  /// Generate image
  Future<GeneratedImage?> generateImage({
    required String prompt,
    required ImageStyle style,
    required Function(int) onTokensUsed,
  }) async {
    if (prompt.trim().isEmpty) {
      _error = 'Please enter a prompt for image generation';
      _setGenerationState(GenerationState.error);
      return null;
    }

    try {
      _setGenerationState(GenerationState.preparing);
      _updateProgress(0.1, 'Preparing request...');

      _setGenerationState(GenerationState.generating);
      _updateProgress(0.3, 'Creating ocean art...');

      final response = await AIService.instance.generateImage(
        prompt: prompt,
        style: style.name,
      );

      if (response.data.isEmpty) {
        throw Exception('No image data received');
      }

      _setGenerationState(GenerationState.processing);
      _updateProgress(0.7, 'Processing image...');

      final imageData = response.data.first;
      String imageUrl = imageData.url;

      if (response.imageBytes != null) {
        final result = await ImageStorageService.instance.saveImage(
          imageBytes: response.imageBytes!,
          prompt: prompt,
          style: style,
          seed: response.seed,
        );

        if (result.isSuccess) {
          imageUrl = result.imagePath!;
        }
      }

      _setGenerationState(GenerationState.saving);
      _updateProgress(0.9, 'Saving to gallery...');

      final generatedImage = GeneratedImage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        prompt: prompt,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        style: style,
        tokensUsed: 200,
        title: _generateTitle(prompt),
      );

      await StorageService.instance.addGeneratedImage(generatedImage);
      _images.insert(0, generatedImage);
      onTokensUsed(200);

      _setGenerationState(GenerationState.completed);
      _updateProgress(1.0, 'Complete!');

      Future.delayed(const Duration(seconds: 1), () {
        _setGenerationState(GenerationState.idle);
        _generationProgress = 0.0;
      });

      return generatedImage;
    } catch (e) {
      _error = 'Failed to generate image: ${e.toString()}';
      _setGenerationState(GenerationState.error);
      return null;
    }
  }

  /// Toggle favorite
  Future<void> toggleImageFavorite(String imageId) async {
    try {
      final index = _images.indexWhere((img) => img.id == imageId);
      if (index != -1) {
        final image = _images[index];
        final updated = image.copyWith(isFavorite: !image.isFavorite);
        _images[index] = updated;
        await StorageService.instance.updateGeneratedImage(updated);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update favorite: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Delete image
  Future<bool> deleteImage(String imageId) async {
    try {
      final image = _images.firstWhere((img) => img.id == imageId);

      if (image.imageUrl.startsWith('/')) {
        await ImageStorageService.instance.deleteImage(image.imageUrl);
      }

      await StorageService.instance.deleteGeneratedImage(imageId);
      _images.removeWhere((img) => img.id == imageId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete image: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Search images
  List<GeneratedImage> searchImages(String query) {
    if (query.trim().isEmpty) return _images;

    final lowerQuery = query.toLowerCase();
    return _images.where((image) {
      return image.prompt.toLowerCase().contains(lowerQuery) ||
          (image.title?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get images by style
  List<GeneratedImage> getImagesByStyle(ImageStyle style) {
    return _images.where((image) => image.style == style).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    if (_generationState == GenerationState.error) {
      _setGenerationState(GenerationState.idle);
    }
    notifyListeners();
  }

  /// Statistics
  int get totalImagesGenerated => _images.length;
  int get totalFavorites => favoriteImages.length;

  // Private methods
  void _setGenerationState(GenerationState state) {
    _generationState = state;
    notifyListeners();
  }

  void _updateProgress(double progress, String message) {
    _generationProgress = progress.clamp(0.0, 1.0);
    _generationStatusMessage = message;
    notifyListeners();
  }

  Future<void> _performBackgroundCleanup() async {
    try {
      await ImageStorageService.instance.cleanupOldImages(keepLatest: 100);
    } catch (e) {
      // Silent fail
    }
  }

  String _generateTitle(String prompt) {
    final words = prompt.split(' ').take(4).join(' ');
    return words.length > 30 ? '${words.substring(0, 30)}...' : words;
  }

  List<GeneratedImage> _generateSampleImages() {
    return [
      GeneratedImage(
        id: 'sample_001',
        prompt:
            'Professional female scuba diver underwater with crystal clear blue water',
        imageUrl: 'assets/images/female_diver_1.png',
        style: ImageStyle.realistic,
        tokensUsed: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isFavorite: true,
        title: 'Professional Diver',
      ),
      GeneratedImage(
        id: 'sample_002',
        prompt:
            'Graceful female diver exploring vibrant coral reef with tropical fish',
        imageUrl: 'assets/images/female_diver_2.png',
        style: ImageStyle.artistic,
        tokensUsed: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isFavorite: false,
        title: 'Coral Reef Explorer',
      ),
      GeneratedImage(
        id: 'sample_003',
        prompt: 'Female dive instructor demonstrating underwater techniques',
        imageUrl: 'assets/images/female_diver_instructor.png',
        style: ImageStyle.realistic,
        tokensUsed: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isFavorite: true,
        title: 'Dive Instructor',
      ),
      GeneratedImage(
        id: 'sample_004',
        prompt:
            'Female diver swimming peacefully with sea turtles in azure waters',
        imageUrl: 'assets/images/female_diver_turtle.png',
        style: ImageStyle.realistic,
        tokensUsed: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        isFavorite: false,
        title: 'Swimming with Turtles',
      ),
      GeneratedImage(
        id: 'sample_005',
        prompt:
            'Team of diverse female divers preparing for underwater adventure',
        imageUrl: 'assets/images/female_diving_team.png',
        style: ImageStyle.artistic,
        tokensUsed: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        isFavorite: true,
        title: 'Diving Team',
      ),
      GeneratedImage(
        id: 'sample_006',
        prompt: 'Elegant female freediver in graceful underwater pose',
        imageUrl: 'assets/images/female_freediver.png',
        style: ImageStyle.artistic,
        tokensUsed: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        isFavorite: false,
        title: 'Freediver Grace',
      ),
    ];
  }
}
