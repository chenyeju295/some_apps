import 'package:flutter/foundation.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';
import '../providers/enhanced_image_provider.dart';

class AppInitializer {
  static Future<AppInitializationResult> initialize({
    required UserProvider userProvider,
    required ContentProvider contentProvider,
    required EnhancedImageProvider imageProvider,
  }) async {
    try {
      // Initialize each provider with error isolation
      final results = await Future.wait([
        _safeInitialize('User', () => userProvider.initializeUser()),
        _safeInitialize('Content', () => contentProvider.loadContent()),
        _safeInitialize('Images', () => imageProvider.initialize()),
      ]);

      final errors = results.where((r) => r.error != null).toList();

      if (errors.isEmpty) {
        return AppInitializationResult.success();
      } else if (errors.length < 3) {
        // Partial success - app can still function
        return AppInitializationResult.partialSuccess(
          errors: errors.map((e) => e.error!).toList(),
        );
      } else {
        // Complete failure
        return AppInitializationResult.failure(
          errors: errors.map((e) => e.error!).toList(),
        );
      }
    } catch (e) {
      return AppInitializationResult.failure(
        errors: ['Critical initialization error: ${e.toString()}'],
      );
    }
  }

  static Future<_InitResult> _safeInitialize(
    String component,
    Future<void> Function() initialize,
  ) async {
    try {
      await initialize();
      return _InitResult(component: component);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize $component: $e');
      }
      return _InitResult(
        component: component,
        error: '$component initialization failed: ${e.toString()}',
      );
    }
  }
}

class _InitResult {
  final String component;
  final String? error;

  _InitResult({required this.component, this.error});
}

class AppInitializationResult {
  final bool isSuccess;
  final bool isPartialSuccess;
  final List<String> errors;

  const AppInitializationResult._({
    required this.isSuccess,
    required this.isPartialSuccess,
    required this.errors,
  });

  factory AppInitializationResult.success() {
    return const AppInitializationResult._(
      isSuccess: true,
      isPartialSuccess: false,
      errors: [],
    );
  }

  factory AppInitializationResult.partialSuccess({
    required List<String> errors,
  }) {
    return AppInitializationResult._(
      isSuccess: false,
      isPartialSuccess: true,
      errors: errors,
    );
  }

  factory AppInitializationResult.failure({
    required List<String> errors,
  }) {
    return AppInitializationResult._(
      isSuccess: false,
      isPartialSuccess: false,
      errors: errors,
    );
  }

  bool get canProceed => isSuccess || isPartialSuccess;

  String get errorSummary => errors.join('\n');
}
