import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'dart:io';
import 'providers/user_provider.dart';
import 'providers/content_provider.dart';
import 'providers/enhanced_image_provider.dart';
import 'services/storage_service.dart';
import 'services/purchase_service.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.instance.initialize();

  try {
    await PurchaseService.instance.initialize();
  } catch (e) {
    print('Purchase service initialization failed (development mode): $e');
  }

  runApp(const DiveExplorerApp());
}

class DiveExplorerApp extends StatelessWidget {
  const DiveExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedImageProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return MaterialApp(
            title: 'DiveExplorer',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: userProvider.preferences.darkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // Delay initialization to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    _animationController.forward();

    // Initialize providers
    final userProvider = context.read<UserProvider>();
    final contentProvider = context.read<ContentProvider>();
    final imageProvider = context.read<EnhancedImageProvider>();

    await Future.wait([
      userProvider.initializeUser(),
      contentProvider.loadContent(),
      imageProvider.initialize(),
    ]);

    // Initialize ATT for iOS
    if (Platform.isIOS) {
      await _initializeATT();
    }

    // Wait for animation to complete
    await _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  Future<void> _initializeATT() async {
    try {
      // Check if ATT is available and required
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      // Only request permission if status is not determined
      if (status == TrackingStatus.notDetermined) {
        await _requestATTPermissionWithRetry();
      } else {
        print('ATT Status: ${status.toString()}');
      }
    } catch (e) {
      print('ATT initialization error: $e');
      // Continue app initialization even if ATT fails
    }
  }

  Future<void> _requestATTPermissionWithRetry() async {
    const maxRetries = 20;
    const retryDelay = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('ATT Permission Request - Attempt $attempt/$maxRetries');

        // Add a small delay before requesting permission
        await Future.delayed(Duration(milliseconds: 500 * attempt));

        final status =
            await AppTrackingTransparency.requestTrackingAuthorization();

        print('ATT Permission Result: ${status.toString()}');

        // Handle the result
        switch (status) {
          case TrackingStatus.authorized:
            print('✅ ATT: Tracking authorized - User granted permission');
            return; // Success, exit retry loop

          case TrackingStatus.denied:
            print('❌ ATT: Tracking denied - User declined permission');
            return; // User made a choice, exit retry loop

          case TrackingStatus.restricted:
            print('⚠️ ATT: Tracking restricted - System level restriction');
            return; // System restriction, exit retry loop

          case TrackingStatus.notDetermined:
            print('⏳ ATT: Status still not determined - Retrying...');
            if (attempt == maxRetries) {
              print(
                  '❌ ATT: Max retries reached, continuing without permission');
              return;
            }
            break;

          case TrackingStatus.notSupported:
            print('ℹ️ ATT: Tracking not supported on this device/iOS version');
            return; // Not supported, exit retry loop
        }

        // If we reach here and it's not the last attempt, wait before retrying
        if (attempt < maxRetries) {
          print('⏳ Waiting ${retryDelay.inSeconds} seconds before retry...');
          await Future.delayed(retryDelay);
        }
      } catch (e) {
        print('❌ ATT Request Error (Attempt $attempt): $e');

        if (attempt == maxRetries) {
          print('❌ ATT: All attempts failed, continuing app initialization');
          return;
        }

        // Wait before retrying on error
        await Future.delayed(retryDelay);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.oceanBlue,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.scuba_diving,
                        size: 60,
                        color: AppTheme.oceanBlue,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Name
                    const Text(
                      'DiveExplorer',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Explore the Ocean Depths',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
