import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/data/services/storage_service.dart';
import 'app/data/services/token_service.dart';
import 'app/data/services/generation_service.dart';
import 'app/data/services/gallery_service.dart';
import 'app/routes/app_pages.dart';
import 'app/widgets/main_scaffold.dart';
import 'core/theme/app_theme.dart';
import 'core/values/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services in order (MUST complete before app starts)
  await _initServices();

  runApp(const MyApp());
}

/// Initialize all services in dependency order
Future<void> _initServices() async {
  // 1. StorageService (no dependencies)
  await Get.putAsync(() => StorageService().init(), permanent: true);

  // 2. TokenService and GalleryService (depend on StorageService)
  await Get.putAsync(() => TokenService().init(), permanent: true);
  await Get.putAsync(() => GalleryService().init(), permanent: true);

  // 3. GenerationService (depends on TokenService and GalleryService)
  await Get.putAsync(() => GenerationService().init(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      home: const MainScaffold(),
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
