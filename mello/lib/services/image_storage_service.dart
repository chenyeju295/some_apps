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
  bool _initialized = false;

  /// Initialize storage
  Future<void> initialize() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    _imagesDirectory = Directory(path.join(appDir.path, 'generated_images'));

    if (!await _imagesDirectory.exists()) {
      await _imagesDirectory.create(recursive: true);
    }

    _initialized = true;
  }

  /// Save image
  Future<ImageStorageResult> saveImage({
    required Uint8List imageBytes,
    required String prompt,
    required ImageStyle style,
    String? seed,
  }) async {
    try {
      await initialize();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageId = 'img_$timestamp';
      final imagePath = path.join(_imagesDirectory.path, '$imageId.png');

      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      final metadata = ImageMetadata(
        id: imageId,
        originalPath: imagePath,
        prompt: prompt,
        style: style,
        fileSize: imageBytes.length,
        createdAt: DateTime.now(),
      );

      return ImageStorageResult.success(
        imagePath: imagePath,
        metadata: metadata,
      );
    } catch (e) {
      return ImageStorageResult.error('Failed to save: ${e.toString()}');
    }
  }

  /// Delete image
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all image paths
  Future<List<String>> getAllImagePaths() async {
    try {
      await initialize();

      final imageFiles = await _imagesDirectory
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.png'))
          .cast<File>()
          .toList();

      imageFiles.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      return imageFiles.map((file) => file.path).toList();
    } catch (e) {
      return [];
    }
  }

  /// Cleanup old images
  Future<void> cleanupOldImages({int keepLatest = 50}) async {
    try {
      final imagePaths = await getAllImagePaths();

      if (imagePaths.length > keepLatest) {
        final toDelete = imagePaths.skip(keepLatest);
        for (final imagePath in toDelete) {
          await deleteImage(imagePath);
        }
      }
    } catch (e) {
      // Silent fail
    }
  }
}

class ImageStorageResult {
  final bool isSuccess;
  final String? imagePath;
  final ImageMetadata? metadata;
  final String? error;

  const ImageStorageResult._({
    required this.isSuccess,
    this.imagePath,
    this.metadata,
    this.error,
  });

  factory ImageStorageResult.success({
    required String imagePath,
    required ImageMetadata metadata,
  }) {
    return ImageStorageResult._(
      isSuccess: true,
      imagePath: imagePath,
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
  final String prompt;
  final ImageStyle style;
  final int fileSize;
  final DateTime createdAt;

  const ImageMetadata({
    required this.id,
    required this.originalPath,
    required this.prompt,
    required this.style,
    required this.fileSize,
    required this.createdAt,
  });
}
