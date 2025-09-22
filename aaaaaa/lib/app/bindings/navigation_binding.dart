import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/generation_controller.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/balance_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Main navigation controller
    Get.lazyPut<NavigationController>(
      () => NavigationController(),
      fenix: true,
    );

    // All page controllers
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true,
    );

    Get.lazyPut<GenerationController>(
      () => GenerationController(),
      fenix: true,
    );

    Get.lazyPut<FavoritesController>(
      () => FavoritesController(),
      fenix: true,
    );

    Get.lazyPut<SettingsController>(
      () => SettingsController(),
      fenix: true,
    );

    Get.lazyPut<BalanceController>(
      () => BalanceController(),
      fenix: true,
    );
  }
}
