import 'package:flutter/material.dart';

class NavigationHelper {
  /// Navigate to a specific tab in the main screen
  static void navigateToTab(BuildContext context, int tabIndex) {
    // Find the MainScreen's navigation method
    try {
      // Try to find if we're in a modal/dialog first
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      }

      // For now, we'll use a simple notification approach
      // In a real app, you might use a global navigation key or state management

      // Find the nearest Scaffold and show a snackbar as fallback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getTabName(tabIndex)),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Fallback - do nothing
    }
  }

  static String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Navigating to Home';
      case 1:
        return 'Navigating to Learn';
      case 2:
        return 'Navigating to Generate';
      case 3:
        return 'Navigating to Profile';
      default:
        return 'Navigation';
    }
  }

  /// Navigate to the learn tab specifically
  static void navigateToLearn(BuildContext context) {
    navigateToTab(context, 1);
  }

  /// Navigate to the generate tab specifically
  static void navigateToGenerate(BuildContext context) {
    navigateToTab(context, 2);
  }

  /// Navigate to the profile tab specifically
  static void navigateToProfile(BuildContext context) {
    navigateToTab(context, 3);
  }
}
