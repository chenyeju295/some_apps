import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/values/app_colors.dart';

class EnhancedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const EnhancedBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: CurvedNavigationBar(
        index: currentIndex,
        height: 70,
        backgroundColor: Colors.transparent,
        color: Colors.white,
        buttonBackgroundColor: AppColors.primary,
        animationDuration: const Duration(milliseconds: 350),
        animationCurve: Curves.easeInOutCubic,
        onTap: onTap,
        items: [
          // Home icon with label
          _buildNavItem(
            icon: FontAwesomeIcons.house,
            label: 'Home',
            isSelected: currentIndex == 0,
            index: 0,
          ),
          // Center Create icon (larger and more prominent)
          _buildCenterIcon(
            icon: FontAwesomeIcons.wandMagicSparkles,
            isSelected: currentIndex == 1,
          ),
          // Profile icon with label
          _buildNavItem(
            icon: FontAwesomeIcons.user,
            label: 'Profile',
            isSelected: currentIndex == 2,
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required int index,
  }) {
    final bool isInCurve = currentIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isInCurve
                    ? Colors.transparent
                    : (isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isInCurve
                    ? AppColors.textWhite
                    : (isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary),
              ),
            )
            .animate(target: isSelected ? 1 : 0)
            .scale(
              duration: 250.ms,
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
              curve: Curves.easeOutBack,
            )
            .then()
            .shake(hz: 2, duration: 200.ms),
        if (!isInCurve) ...[
          const SizedBox(height: 4),
          Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              )
              .animate(target: isSelected ? 1 : 0)
              .fadeIn(duration: 200.ms)
              .slideY(begin: 0.3, end: 0, duration: 200.ms),
        ],
      ],
    );
  }

  Widget _buildCenterIcon({required IconData icon, required bool isSelected}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow effect
        if (isSelected)
          Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                duration: 2000.ms,
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.3, 1.3),
                curve: Curves.easeInOut,
              )
              .fadeIn(duration: 500.ms)
              .then()
              .fadeOut(duration: 500.ms),

        // Main button
        Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.primary,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: isSelected ? 3 : 1,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: isSelected ? 2 : 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating border ring
                  if (isSelected)
                    Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(duration: 3000.ms, curve: Curves.linear),

                  // Icon
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 30, color: AppColors.textWhite)
                          .animate(target: isSelected ? 1 : 0)
                          .rotate(
                            duration: 400.ms,
                            begin: 0,
                            end: 0.1,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .rotate(duration: 400.ms, begin: 0.1, end: -0.1)
                          .then()
                          .rotate(duration: 400.ms, begin: -0.1, end: 0)
                          .then()
                          .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withOpacity(0.5),
                          ),
                      const SizedBox(height: 2),
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Create',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                          .animate(target: isSelected ? 1 : 0)
                          .fadeIn(duration: 200.ms)
                          .slideY(begin: 0.5, end: 0, duration: 300.ms),
                    ],
                  ),
                ],
              ),
            )
            .animate(target: isSelected ? 1 : 0)
            .scaleXY(
              duration: 300.ms,
              begin: 1.0,
              end: 1.1,
              curve: Curves.easeOut,
            ),
      ],
    );
  }
}
