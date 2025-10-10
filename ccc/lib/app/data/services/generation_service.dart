import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/wallpaper_model.dart';
import '../models/generation_request_model.dart';
import 'token_service.dart';
import 'gallery_service.dart';
import 'together_api_service.dart';

class GenerationService extends GetxService {
  // 使用 getter 方式动态获取依赖，避免初始化顺序问题
  TokenService get _tokenService => Get.find<TokenService>();
  GalleryService get _galleryService => Get.find<GalleryService>();
  final _uuid = const Uuid();

  final RxBool isGenerating = false.obs;
  final RxString currentStatus = ''.obs;
  final RxDouble progress = 0.0.obs;

  Future<GenerationService> init() async {
    return this;
  }

  /// Generate wallpaper from request using Together AI
  Future<WallpaperModel?> generateWallpaper(
    GenerationRequestModel request,
  ) async {
    if (isGenerating.value) {
      throw Exception('Generation already in progress');
    }

    if (!_tokenService.hasTokens()) {
      throw Exception('Insufficient tokens');
    }

    isGenerating.value = true;
    progress.value = 0.0;

    try {
      // 1. Deduct token first
      currentStatus.value = 'Using token...';
      _tokenService.useToken();
      progress.value = 0.1;

      // 2. Build fashion prompt
      currentStatus.value = 'Building prompt...';
      final fashionPrompt = TogetherApiService.buildFashionPrompt(
        style: request.style,
        outfitType: request.outfitType,
        scene: request.scene,
        additionalPrompt: request.prompt,
      );
      progress.value = 0.2;

      // 3. Call Together AI API
      currentStatus.value = 'Generating image...';
      final imageUrl = await TogetherApiService.generateImage(
        prompt: fashionPrompt,
        width: 768, // 9:16 aspect ratio
        height: 1344,
        steps: 4, // Fast generation with FLUX.1-schnell
      );
      progress.value = 0.8;

      // 4. Create wallpaper model
      currentStatus.value = 'Saving wallpaper...';
      final wallpaper = WallpaperModel(
        id: _uuid.v4(),
        imageUrl: imageUrl,
        prompt: fashionPrompt,
        style: request.style,
        outfitType: request.outfitType,
        scene: request.scene,
        createdAt: DateTime.now(),
        tags: [
          request.style.toLowerCase(),
          request.outfitType.toLowerCase(),
          request.scene.toLowerCase(),
          'generated',
        ],
        isSample: false, // 标记为真实生成的数据
      );

      // 5. Add to gallery
      await _galleryService.addWallpaper(wallpaper);
      progress.value = 1.0;
      currentStatus.value = 'Complete!';

      return wallpaper;
    } catch (e) {
      // Refund token on error - add token back
      await _tokenService.addTokens(1);
      currentStatus.value = 'Error: $e';
      rethrow;
    } finally {
      isGenerating.value = false;
      // Clear status after a delay
      Future.delayed(const Duration(seconds: 2), () {
        currentStatus.value = '';
        progress.value = 0.0;
      });
    }
  }

  /// Test API connection
  Future<bool> testApi() async {
    try {
      return await TogetherApiService.testConnection();
    } catch (e) {
      print('API test failed: $e');
      return false;
    }
  }
}
