import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/values/app_colors.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildTokenSection(),
            const SizedBox(height: 8),
            _buildMenuSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: FontAwesomeIcons.image,
              label: 'Wallpapers',
              value: controller.totalWallpapers.toString(),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.textWhite.withOpacity(0.3),
            ),
            _buildStatItem(
              icon: FontAwesomeIcons.heart,
              label: 'Favorites',
              value: controller.favoriteCount.toString(),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.textWhite.withOpacity(0.3),
            ),
            _buildStatItem(
              icon: FontAwesomeIcons.wandMagicSparkles,
              label: 'Generated',
              value: controller.totalGenerations.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textWhite, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Get.textTheme.headlineMedium?.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            color: AppColors.textWhite.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildTokenSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              FontAwesomeIcons.coins,
              color: AppColors.textWhite,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Token Balance',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.tokenBalance.toString(),
                    style: Get.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: controller.navigateToTokenShop,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Buy Tokens'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuTile(
          icon: FontAwesomeIcons.shareNodes,
          title: 'Share App',
          onTap: controller.shareApp,
        ),
        _buildMenuTile(
          icon: FontAwesomeIcons.star,
          title: 'Rate App',
          onTap: controller.rateApp,
        ),
        const Divider(height: 1),
        _buildMenuTile(
          icon: FontAwesomeIcons.fileContract,
          title: 'Terms of Service',
          onTap: controller.showTermsOfService,
        ),
        _buildMenuTile(
          icon: FontAwesomeIcons.shield,
          title: 'Privacy Policy',
          onTap: controller.showPrivacyPolicy,
        ),
        _buildMenuTile(
          icon: FontAwesomeIcons.circleInfo,
          title: 'About',
          onTap: controller.showAbout,
        ),
        const Divider(height: 1),
        _buildMenuTile(
          icon: FontAwesomeIcons.trash,
          title: 'Clear All Data',
          onTap: controller.clearAllData,
          textColor: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppColors.textSecondary,
        size: 20,
      ),
      title: Text(
        title,
        style: Get.textTheme.bodyLarge?.copyWith(color: textColor),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}
