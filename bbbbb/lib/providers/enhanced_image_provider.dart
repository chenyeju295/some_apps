import 'dart:io';
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
  String _currentPrompt = '';
  double _generationProgress = 0.0;
  String _generationStatusMessage = '';

  // Getters
  List<GeneratedImage> get images => _images;
  GenerationState get generationState => _generationState;
  bool get isGenerating =>
      _generationState != GenerationState.idle &&
      _generationState != GenerationState.completed &&
      _generationState != GenerationState.error;
  String? get error => _error;
  String get currentPrompt => _currentPrompt;
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

      // Load from SQLite storage
      final storedImages = await StorageService.instance.getGeneratedImages();

      // Load image paths from file system
      final imagePaths = await ImageStorageService.instance.getAllImagePaths();

      // Merge stored metadata with file system images
      final mergedImages = <GeneratedImage>[];

      for (final storedImage in storedImages) {
        // Check if the image file still exists
        if (imagePaths.contains(storedImage.imageUrl) ||
            storedImage.imageUrl.startsWith('assets/')) {
          mergedImages.add(storedImage);
        } else {
          // Remove from storage if file doesn't exist
          await StorageService.instance.deleteGeneratedImage(storedImage.id);
        }
      }

      // Add sample images if no real images exist
      if (mergedImages.isEmpty) {
        mergedImages.addAll(_generateSampleImages());
      }

      _images = mergedImages;
      _error = null;
      _setGenerationState(GenerationState.idle);

      // Cleanup old images in background
      _performBackgroundCleanup();
    } catch (e) {
      _error = 'Failed to load images: ${e.toString()}';
      _setGenerationState(GenerationState.error);
    }
  }

  /// Generate a new image with enhanced flow
  Future<GeneratedImage?> generateImage({
    required String prompt,
    required ImageStyle style,
    required Function(int) onTokensUsed,
    int width = 1024,
    int height = 1024,
  }) async {
    if (prompt.trim().isEmpty) {
      _error = 'Please enter a prompt for image generation';
      _setGenerationState(GenerationState.error);
      return null;
    }

    try {
      // Phase 1: Preparation
      _setGenerationState(GenerationState.preparing);
      _currentPrompt = prompt;
      _updateProgress(0.0, 'Preparing your request...');

      await Future.delayed(const Duration(milliseconds: 500));

      // Phase 2: AI Generation
      _setGenerationState(GenerationState.generating);
      _updateProgress(0.2, 'Creating your ocean masterpiece...');

      final AIImageResponse response = await AIService.instance.generateImage(
        prompt: prompt,
        style: style.name,
        width: width,
        height: height,
      );

      if (response.data.isEmpty) {
        throw Exception('No image data received from AI service');
      }

      // Phase 3: Processing
      _setGenerationState(GenerationState.processing);
      _updateProgress(0.7, 'Processing image data...');

      final AIImageData imageData = response.data.first;

      // Phase 4: Saving
      _setGenerationState(GenerationState.saving);
      _updateProgress(0.9, 'Saving to your gallery...');

      // Save image using new storage service
      String imageUrl = imageData.url;
      ImageMetadata? metadata;

      if (response.imageBytes != null) {
        final storageResult = await ImageStorageService.instance.saveImage(
          imageBytes: response.imageBytes!,
          prompt: prompt,
          style: style,
          seed: response.seed,
        );

        if (storageResult.isSuccess) {
          imageUrl = storageResult.imagePath!;
          metadata = storageResult.metadata;
        }
      }

      // Create GeneratedImage model
      final GeneratedImage generatedImage = GeneratedImage(
        id: metadata?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        prompt: imageData.originalPrompt ?? prompt,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        style: style,
        tokensUsed: 1,
        title: _generateImageTitle(prompt),
        description: imageData.revisedPrompt,
        tags: _extractTagsFromPrompt(prompt),
      );

      // Save to database
      await StorageService.instance.addGeneratedImage(generatedImage);

      // Update local list
      _images.insert(0, generatedImage);

      // Notify token usage
      onTokensUsed(1);

      // Phase 5: Completed
      _setGenerationState(GenerationState.completed);
      _updateProgress(1.0, 'Image created successfully!');

      // Reset to idle after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        _setGenerationState(GenerationState.idle);
        _currentPrompt = '';
        _generationProgress = 0.0;
      });

      return generatedImage;
    } on AIServiceException catch (e) {
      _error = e.message;
      _setGenerationState(GenerationState.error);
      return null;
    } catch (e) {
      _error = 'Failed to generate image: ${e.toString()}';
      _setGenerationState(GenerationState.error);
      return null;
    }
  }

  /// Toggle image favorite status
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

  /// Delete image with enhanced cleanup
  Future<bool> deleteImage(String imageId) async {
    try {
      final image = _images.firstWhere((img) => img.id == imageId);

      // Remove from file system
      if (image.imageUrl.startsWith('/')) {
        await ImageStorageService.instance.deleteImage(image.imageUrl);
      }

      // Remove from database
      await StorageService.instance.deleteGeneratedImage(imageId);

      // Remove from local list
      _images.removeWhere((img) => img.id == imageId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete image: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get storage statistics
  Future<StorageStats> getStorageStats() async {
    return await ImageStorageService.instance.getStorageStats();
  }

  /// Export image to device gallery
  Future<bool> exportImage(String imageId) async {
    try {
      final image = _images.firstWhere((img) => img.id == imageId);
      if (image.imageUrl.startsWith('/')) {
        return await ImageStorageService.instance
            .exportToGallery(image.imageUrl);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Share image data
  Future<File?> getImageFile(String imageId) async {
    try {
      final image = _images.firstWhere((img) => img.id == imageId);
      if (image.imageUrl.startsWith('/')) {
        final file = File(image.imageUrl);
        if (await file.exists()) {
          return file;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search and filter methods
  List<GeneratedImage> searchImages(String query) {
    if (query.trim().isEmpty) return _images;

    final String lowerQuery = query.toLowerCase();
    return _images.where((image) {
      return image.prompt.toLowerCase().contains(lowerQuery) ||
          (image.title?.toLowerCase().contains(lowerQuery) ?? false) ||
          (image.tags?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ??
              false);
    }).toList();
  }

  List<GeneratedImage> getImagesByStyle(ImageStyle style) {
    return _images.where((image) => image.style == style).toList();
  }

  List<GeneratedImage> getImagesByDateRange(DateTime start, DateTime end) {
    return _images.where((image) {
      return image.createdAt.isAfter(start) && image.createdAt.isBefore(end);
    }).toList();
  }

  // Utility methods
  void clearError() {
    _error = null;
    if (_generationState == GenerationState.error) {
      _setGenerationState(GenerationState.idle);
    }
    notifyListeners();
  }

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
      // Cleanup old images (keep latest 100)
      await ImageStorageService.instance.cleanupOldImages(keepLatest: 100);
    } catch (e) {
      // Silently fail background tasks
    }
  }

  String _generateImageTitle(String prompt) {
    final words = prompt.split(' ').take(4).join(' ');
    return words.length > 30 ? '${words.substring(0, 30)}...' : words;
  }

  List<String> _extractTagsFromPrompt(String prompt) {
    final tags = <String>[];
    final lowerPrompt = prompt.toLowerCase();

    const oceanTags = [
      'underwater',
      'ocean',
      'sea',
      'marine',
      'coral',
      'reef',
      'fish',
      'turtle',
      'whale',
      'dolphin',
      'shark',
      'diving',
      'scuba',
      'freediving',
      'shipwreck',
      'kelp',
      'anemone',
      'submarine',
      'deep sea',
      'tropical',
      'aquatic'
    ];

    for (final tag in oceanTags) {
      if (lowerPrompt.contains(tag)) {
        tags.add(tag);
      }
    }

    return tags.take(5).toList();
  }

  // Statistics getters
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
      // Delete all files
      for (final image in _images) {
        if (image.imageUrl.startsWith('/')) {
          await ImageStorageService.instance.deleteImage(image.imageUrl);
        }
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
        title: 'Professional Diver',
        description: 'Crystal clear underwater photography',
        tags: ['scuba', 'professional', 'underwater', 'diving'],
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
        title: 'Coral Reef Explorer',
        description: 'Vibrant underwater coral ecosystem',
        tags: ['coral', 'reef', 'tropical', 'fish'],
      ),
      GeneratedImage(
        id: 'sample_003',
        prompt: 'Female dive instructor demonstrating underwater techniques',
        imageUrl: 'assets/images/female_diver_instructor.png',
        style: ImageStyle.realistic,
        tokensUsed: 10,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isFavorite: true,
        title: 'Dive Instructor',
        description: 'Professional underwater instruction and techniques',
        tags: ['instructor', 'professional', 'education', 'techniques'],
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
        title: 'Swimming with Turtles',
        description: 'Peaceful encounter with sea turtles',
        tags: ['turtle', 'sea', 'wildlife', 'peaceful'],
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
        title: 'Diving Team',
        description: 'Team preparation for underwater exploration',
        tags: ['team', 'adventure', 'preparation', 'group'],
      ),
      GeneratedImage(
        id: 'sample_006',
        prompt: 'Elegant female freediver in graceful underwater pose',
        imageUrl: 'assets/images/female_freediver.png',
        style: ImageStyle.artistic,
        tokensUsed: 10,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        isFavorite: false,
        title: 'Freediver Grace',
        description: 'Elegant freediving techniques and form',
        tags: ['freediving', 'elegant', 'graceful', 'artistic'],
      ),
    ];
  }
}
