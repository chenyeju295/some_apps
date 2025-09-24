import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/main_screen.dart';
import '../theme/app_theme.dart';

class NavigationHelper {
  /// Navigate to a specific tab in the main screen
  static void navigateToTab(BuildContext context, int tabIndex) {
    try {
      // Close any open modals/dialogs first
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Try to find the MainScreen and call its navigation method
      final mainScreenState = MainScreen.of(context);
      if (mainScreenState != null) {
        mainScreenState.navigateToTab(tabIndex);

        // Show success feedback
        _showNavigationFeedback(context, tabIndex);
      } else {
        // Fallback: show a more informative message
        _showNavigationError(context, tabIndex);
      }
    } catch (e) {
      // Error handling
      _showNavigationError(context, tabIndex);
    }
  }

  /// Show navigation success feedback
  static void _showNavigationFeedback(BuildContext context, int tabIndex) {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getTabIcon(tabIndex),
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(_getTabName(tabIndex)),
          ],
        ),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.oceanBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show navigation error feedback
  static void _showNavigationError(BuildContext context, int tabIndex) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cannot navigate to ${_getTabName(tabIndex)}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Welcome to Home';
      case 1:
        return 'Explore Learning';
      case 2:
        return 'Create Images';
      case 3:
        return 'Your Profile';
      default:
        return 'Navigation';
    }
  }

  static IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.school;
      case 2:
        return Icons.auto_awesome;
      case 3:
        return Icons.person;
      default:
        return Icons.tab;
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
