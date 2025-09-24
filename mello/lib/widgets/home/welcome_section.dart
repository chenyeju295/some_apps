import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../theme/app_theme.dart';
import '../../utils/navigation_helper.dart';
import '../animations/ocean_animations.dart';

class WelcomeSection extends StatelessWidget {
  final String userName;
  final int tokenBalance;
  final VoidCallback onGeneratePressed;

  const WelcomeSection({
    super.key,
    required this.userName,
    required this.tokenBalance,
    required this.onGeneratePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.animatedCardDecoration.copyWith(
        gradient: AppTheme.surfaceGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Welcome back, $userName!',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme.deepNavy,
                                fontWeight: FontWeight.bold,
                              ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      isRepeatingAnimation: false,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready for your next underwater adventure?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              OceanAnimations.pulsingGlow(
                glowColor: AppTheme.seaFoam,
                child: OceanAnimations.floatingWidget(
                  offset: 6.0,
                  duration: const Duration(seconds: 3),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: AppTheme.coralReefGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.floatingShadow,
                    ),
                    child: const Icon(
                      Icons.waves,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Enhanced token balance section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.sunlightGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.aquaMarine.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: AppTheme.oceanBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tokens Available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.deepNavy,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '$tokenBalance',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.oceanBlue,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
                if (tokenBalance > 0) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onGeneratePressed,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate Ocean Image'),
                      style: AppTheme.primaryButtonStyle,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        NavigationHelper.navigateToProfile(context);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Get More Tokens'),
                      style: AppTheme.secondaryButtonStyle,
                    ),
                  ),
                ],
              ],
            ),
          ),


        ],
      ),
    );
  }


}

extension DateTimeExtension on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }
}
