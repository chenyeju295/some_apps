import 'package:get/get.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/generate/controllers/generate_controller.dart';
import '../modules/gallery/controllers/gallery_controller.dart';
import '../modules/profile/controllers/profile_controller.dart';

/// Initial binding for controllers only
/// Services must be initialized in main.dart before app starts
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Controllers - 懒加载，首次访问时创建
    // 注意：所有 Services 必须在 main.dart 中提前初始化完成
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<GenerateController>(() => GenerateController());
    Get.lazyPut<GalleryController>(() => GalleryController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
