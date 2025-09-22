import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class QuickStatsSection extends StatelessWidget {
  final int totalImagesGenerated;
  final int totalBookmarks;
  final int totalCompletedContent;
  final int daysActive;

  const QuickStatsSection({
    super.key,
    required this.totalImagesGenerated,
    required this.totalBookmarks,
    required this.totalCompletedContent,
    required this.daysActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Diving Journey',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.auto_awesome,
                  iconColor: AppTheme.tropicalTeal,
                  title: 'Images',
                  value: totalImagesGenerated.toString(),
                  subtitle: 'Generated',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.bookmark,
                  iconColor: AppTheme.coral,
                  title: 'Bookmarks',
                  value: totalBookmarks.toString(),
                  subtitle: 'Saved',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.school,
                  iconColor: AppTheme.oceanBlue,
                  title: 'Lessons',
                  value: totalCompletedContent.toString(),
                  subtitle: 'Completed',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today,
                  iconColor: AppTheme.deepSeaGreen,
                  title: 'Days',
                  value: daysActive.toString(),
                  subtitle: 'Active',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
