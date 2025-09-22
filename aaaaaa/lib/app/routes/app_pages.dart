import 'package:get/get.dart';
import '../views/main_navigation_view.dart';
import '../views/home_view.dart';
import '../views/generation_view.dart';
import '../views/favorites_view.dart';
import '../views/settings_view.dart';
import '../views/wallpaper_detail_view.dart';
import '../views/api_key_setup_view.dart';
import '../views/onboarding_view.dart';
import '../bindings/navigation_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/generation_binding.dart';
import '../bindings/favorites_binding.dart';
import '../bindings/settings_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const MainNavigationView(),
      binding: NavigationBinding(),
    ),
    GetPage(
      name: AppRoutes.generation,
      page: () => const GenerationView(),
      binding: GenerationBinding(),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.wallpaperDetail,
      page: () => const WallpaperDetailView(),
    ),
    GetPage(
      name: AppRoutes.apiKeySetup,
      page: () => const ApiKeySetupView(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
    ),
  ];
}
