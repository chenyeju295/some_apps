import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/services/storage_service.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService.init();

  runApp(const AIWallpaperApp());
}

class AIWallpaperApp extends StatelessWidget {
  const AIWallpaperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Wallpaper Generator',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: StorageService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      debugShowCheckedModeBanner: false,
    );
  }
}
