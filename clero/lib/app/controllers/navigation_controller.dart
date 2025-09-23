import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'generation_controller.dart';

class NavigationController extends GetxController {
  // Current page index
  final currentIndex = 0.obs;

  // Page controller for smooth transitions
  final PageController pageController = PageController();

  // Tab items configuration
  final List<NavigationItem> tabItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: '/home',
    ),
    NavigationItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: 'Create',
      route: '/generation',
    ),
    NavigationItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favorites',
      route: '/favorites',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      route: '/settings',
    ),
  ];

  // Change tab with animation
  void changeTab(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      pageController.jumpToPage(
        index,
      );
    }
  }

  // Handle page view changes
  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  // Navigate to generation page with optional category
  void navigateToGeneration({String? category}) {
    changeTab(1); // Generation tab is at index 1
    if (category != null) {
      // Pass category argument to generation controller
      Get.find<GenerationController>().navigateWithCategory(category);
    }
  }

  // Navigate to specific tab by name
  void navigateToTab(String tabName) {
    final index = tabItems.indexWhere(
        (item) => item.label.toLowerCase() == tabName.toLowerCase());
    if (index != -1) {
      changeTab(index);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
