import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:badges/badges.dart' as badges;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../core/values/app_colors.dart';

class AnimatedTokenBadge extends StatelessWidget {
  final int tokenCount;
  final VoidCallback? onTap;

  const AnimatedTokenBadge({Key? key, required this.tokenCount, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: badges.Badge(
        position: badges.BadgePosition.topEnd(top: -8, end: -8),
        badgeContent: Text(
          tokenCount > 999 ? '999+' : tokenCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        badgeAnimation: const badges.BadgeAnimation.fade(
          animationDuration: Duration(milliseconds: 500),
          colorChangeAnimationDuration: Duration(milliseconds: 500),
        ),
        badgeStyle: badges.BadgeStyle(
          badgeColor: AppColors.accent,
          padding: const EdgeInsets.all(6),
          elevation: 4,
        ),
        child:
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                        FontAwesomeIcons.coins,
                        color: AppColors.textWhite,
                        size: 18,
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(
                        duration: 2000.ms,
                        begin: 0,
                        end: 1,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .shake(hz: 2, duration: 500.ms),
                  const SizedBox(width: 8),
                  Text(
                    tokenCount.toString(),
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(duration: 300.ms).scale(duration: 300.ms),
                ],
              ),
            ).animate().shimmer(
              duration: 3000.ms,
              color: Colors.white.withOpacity(0.3),
            ),
      ),
    );
  }
}
