import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $userName!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.deepNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready for your next underwater adventure?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.oceanGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.waves,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Token balance and action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightAqua,
              borderRadius: BorderRadius.circular(12),
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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                        // Navigate to purchase screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Purchase tokens in Profile tab'),
                          ),
                        );
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
          
          const SizedBox(height: 16),
          
          // Daily tip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.coral.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.coral.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.coral,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diving Tip of the Day',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.coral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getDailyTip(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.deepNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDailyTip() {
    final tips = [
      'Always check your equipment before diving',
      'Never hold your breath while ascending',
      'Plan your dive and dive your plan',
      'Stay with your buddy at all times',
      'Equalize early and often during descent',
      'Monitor your air supply regularly',
      'Ascend slowly - no faster than 18m/min',
      'Take a safety stop at 5 meters for 3 minutes',
      'Respect marine life and don\'t touch',
      'Stay hydrated before and after diving',
    ];
    
    final dayOfYear = DateTime.now().dayOfYear;
    return tips[dayOfYear % tips.length];
  }
}

extension DateTimeExtension on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }
}
