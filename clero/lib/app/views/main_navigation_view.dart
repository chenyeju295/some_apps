import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'home_view.dart';
import 'generation_view.dart';
import 'favorites_view.dart';
import 'settings_view.dart';

class MainNavigationView extends GetView<NavigationController> {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,  // Disable swipe navigation
        children: const [
          HomeView(),
          GenerationView(),
          FavoritesView(),
          SettingsView(),
        ],
      ),
      bottomNavigationBar: const EnhancedBottomNavBar(),
    );
  }
}

// Enhanced version with more animations
class EnhancedBottomNavBar extends GetView<NavigationController> {
  const EnhancedBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: controller.tabItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = controller.currentIndex.value == index;

                  return _buildNavItem(context, item, index, isSelected);
                }).toList(),
              ),
            ),
          ),
        ));
  }

  Widget _buildNavItem(
      BuildContext context, NavigationItem item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).iconTheme.color?.withOpacity(0.6),
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.6),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
