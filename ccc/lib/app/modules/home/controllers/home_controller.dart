import 'package:get/get.dart';
import '../../../data/services/gallery_service.dart';
import '../../../data/services/token_service.dart';
import '../../../data/services/sample_data_service.dart';
import '../../../data/models/wallpaper_model.dart';
import '../../../../core/values/app_constants.dart';

class HomeController extends GetxController {
  // 使用 getter 方式动态获取依赖，避免初始化顺序问题
  GalleryService get _galleryService => Get.find<GalleryService>();
  TokenService get _tokenService => Get.find<TokenService>();

  // 用户生成的内容
  final RxList<WallpaperModel> myFavorites = <WallpaperModel>[].obs;
  final RxList<WallpaperModel> myRecent = <WallpaperModel>[].obs;

  // 样例内容（灵感展示）
  final RxList<WallpaperModel> featuredWallpapers = <WallpaperModel>[].obs;
  final RxList<WallpaperModel> recentWallpapers = <WallpaperModel>[].obs;
  final RxList<WallpaperModel> trendingWallpapers = <WallpaperModel>[].obs;

  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = false.obs;
  final RxInt totalGenerated = 0.obs;

  // Carousel 相关
  final RxInt currentCarouselIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    try {
      // 1. 加载用户真实生成的内容
      final realWallpapers = _galleryService.wallpapers
          .where((w) => !w.isSample)
          .toList();

      final realFavorites = _galleryService
          .getFavorites()
          .where((w) => !w.isSample)
          .toList();

      // 用户收藏和最近生成
      myFavorites.value = realFavorites.take(6).toList();
      myRecent.value = realWallpapers.take(6).toList();

      // 统计用户生成数量
      totalGenerated.value = realWallpapers.length;

      // 2. 始终加载样例数据作为灵感展示
      final samples = SampleDataService.getSampleWallpapers();
      featuredWallpapers.value = SampleDataService.getFeaturedWallpapers();
      recentWallpapers.value = SampleDataService.getRecentWallpapers(limit: 6);
      trendingWallpapers.value = samples.take(4).toList();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    // Navigate to gallery with filter
    Get.toNamed('/gallery', arguments: {'category': category});
  }

  void navigateToGenerate() {
    if (_tokenService.needsToBuyTokens()) {
      Get.snackbar(
        'Insufficient Tokens',
        'You need tokens to generate wallpapers. Please purchase tokens.',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Navigate to token shop
      return;
    }
    Get.toNamed('/gallery');
  }

  List<String> get styleCategories => AppConstants.styleCategories;

  int get tokenBalance => _tokenService.tokenBalance.value;
}
