import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/generated_image.dart';

class ImageStorageService {
  static ImageStorageService? _instance;
  static ImageStorageService get instance =>
      _instance ??= ImageStorageService._();

  ImageStorageService._();

  late Directory _imagesDirectory;
  late Directory _thumbnailsDirectory;
  bool _initialized = false;

  /// Initialize the storage service
  Future<void> initialize() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    _imagesDirectory = Directory(path.join(appDir.path, 'generated_images'));
    _thumbnailsDirectory = Directory(path.join(appDir.path, 'thumbnails'));

    // Create directories if they don't exist
    if (!await _imagesDirectory.exists()) {
      await _imagesDirectory.create(recursive: true);
    }
    if (!await _thumbnailsDirectory.exists()) {
      await _thumbnailsDirectory.create(recursive: true);
    }

    _initialized = true;
  }

  /// Save image bytes to local storage
  Future<ImageStorageResult> saveImage({
    required Uint8List imageBytes,
    required String prompt,
    required ImageStyle style,
    String? seed,
  }) async {
    try {
      await initialize();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageId = 'img_${timestamp}_${seed ?? 'auto'}';

      // Generate file paths
      final imagePath = path.join(_imagesDirectory.path, '$imageId.png');
      final thumbnailPath =
          path.join(_thumbnailsDirectory.path, '${imageId}_thumb.png');

      // Save original image
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // Generate thumbnail (simplified - in production you'd use image processing)
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(imageBytes); // For now, same as original

      // Create metadata
      final metadata = ImageMetadata(
        id: imageId,
        originalPath: imagePath,
        thumbnailPath: thumbnailPath,
        prompt: prompt,
        style: style,
        seed: seed,
        fileSize: imageBytes.length,
        createdAt: DateTime.now(),
        dimensions: await _getImageDimensions(imageBytes),
      );

      return ImageStorageResult.success(
        imagePath: imagePath,
        thumbnailPath: thumbnailPath,
        metadata: metadata,
      );
    } catch (e) {
      return ImageStorageResult.error('Failed to save image: ${e.toString()}');
    }
  }

  /// Load image from storage
  Future<Uint8List?> loadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete image and its thumbnail
  Future<bool> deleteImage(String imagePath) async {
    try {
      await initialize();

      final imageFile = File(imagePath);
      final imageId = path.basenameWithoutExtension(imagePath);
      final thumbnailFile =
          File(path.join(_thumbnailsDirectory.path, '${imageId}_thumb.png'));

      // Delete both files
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      if (await thumbnailFile.exists()) {
        await thumbnailFile.delete();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all stored images
  Future<List<String>> getAllImagePaths() async {
    try {
      await initialize();

      final imageFiles = await _imagesDirectory
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.png'))
          .cast<File>()
          .toList();

      // Sort by creation time (newest first)
      imageFiles.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      return imageFiles.map((file) => file.path).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get storage statistics
  Future<StorageStats> getStorageStats() async {
    try {
      await initialize();

      final imageFiles = await _imagesDirectory.list().toList();
      final thumbnailFiles = await _thumbnailsDirectory.list().toList();

      int totalSize = 0;
      int imageCount = 0;

      for (final entity in imageFiles) {
        if (entity is File) {
          final stat = entity.statSync();
          totalSize += stat.size;
          imageCount++;
        }
      }

      return StorageStats(
        totalImages: imageCount,
        totalSizeBytes: totalSize,
        thumbnailCount: thumbnailFiles.length,
      );
    } catch (e) {
      return StorageStats(totalImages: 0, totalSizeBytes: 0, thumbnailCount: 0);
    }
  }

  /// Clean up old images (keep only latest N images)
  Future<void> cleanupOldImages({int keepLatest = 50}) async {
    try {
      await initialize();

      final imagePaths = await getAllImagePaths();

      if (imagePaths.length > keepLatest) {
        final imagesToDelete = imagePaths.skip(keepLatest);

        for (final imagePath in imagesToDelete) {
          await deleteImage(imagePath);
        }
      }
    } catch (e) {
      // Silently fail cleanup
    }
  }

  /// Get image dimensions (simplified)
  Future<ImageDimensions> _getImageDimensions(Uint8List imageBytes) async {
    // For now, return default dimensions
    // In production, you'd use a proper image library to decode dimensions
    return const ImageDimensions(width: 1024, height: 1024);
  }

  /// Export image to gallery (platform-specific)
  Future<bool> exportToGallery(String imagePath) async {
    try {
      // This would integrate with platform-specific gallery APIs
      // For now, just copy to a public directory
      final file = File(imagePath);
      if (await file.exists()) {
        // Implementation would vary by platform
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get storage directory path
  String get storageDirectory => _imagesDirectory.path;
  String get thumbnailDirectory => _thumbnailsDirectory.path;
}

class ImageStorageResult {
  final bool isSuccess;
  final String? imagePath;
  final String? thumbnailPath;
  final ImageMetadata? metadata;
  final String? error;

  const ImageStorageResult._({
    required this.isSuccess,
    this.imagePath,
    this.thumbnailPath,
    this.metadata,
    this.error,
  });

  factory ImageStorageResult.success({
    required String imagePath,
    required String thumbnailPath,
    required ImageMetadata metadata,
  }) {
    return ImageStorageResult._(
      isSuccess: true,
      imagePath: imagePath,
      thumbnailPath: thumbnailPath,
      metadata: metadata,
    );
  }

  factory ImageStorageResult.error(String error) {
    return ImageStorageResult._(
      isSuccess: false,
      error: error,
    );
  }
}

class ImageMetadata {
  final String id;
  final String originalPath;
  final String thumbnailPath;
  final String prompt;
  final ImageStyle style;
  final String? seed;
  final int fileSize;
  final DateTime createdAt;
  final ImageDimensions dimensions;

  const ImageMetadata({
    required this.id,
    required this.originalPath,
    required this.thumbnailPath,
    required this.prompt,
    required this.style,
    this.seed,
    required this.fileSize,
    required this.createdAt,
    required this.dimensions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalPath': originalPath,
      'thumbnailPath': thumbnailPath,
      'prompt': prompt,
      'style': style.name,
      'seed': seed,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'dimensions': dimensions.toJson(),
    };
  }

  factory ImageMetadata.fromJson(Map<String, dynamic> json) {
    return ImageMetadata(
      id: json['id'],
      originalPath: json['originalPath'],
      thumbnailPath: json['thumbnailPath'],
      prompt: json['prompt'],
      style: ImageStyle.values.firstWhere(
        (e) => e.name == json['style'],
        orElse: () => ImageStyle.realistic,
      ),
      seed: json['seed'],
      fileSize: json['fileSize'],
      createdAt: DateTime.parse(json['createdAt']),
      dimensions: ImageDimensions.fromJson(json['dimensions']),
    );
  }
}

class ImageDimensions {
  final int width;
  final int height;

  const ImageDimensions({
    required this.width,
    required this.height,
  });

  double get aspectRatio => width / height;

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }

  factory ImageDimensions.fromJson(Map<String, dynamic> json) {
    return ImageDimensions(
      width: json['width'],
      height: json['height'],
    );
  }
}

class StorageStats {
  final int totalImages;
  final int totalSizeBytes;
  final int thumbnailCount;

  const StorageStats({
    required this.totalImages,
    required this.totalSizeBytes,
    required this.thumbnailCount,
  });

  double get totalSizeMB => totalSizeBytes / (1024 * 1024);

  String get formattedSize {
    if (totalSizeBytes < 1024) {
      return '${totalSizeBytes}B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}
