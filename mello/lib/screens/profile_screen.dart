import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/enhanced_image_provider.dart';
import '../services/purchase_service.dart';
import '../theme/app_theme.dart';
import 'bookmarks_screen.dart';
import 'webview_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _setupPurchaseService();
  }

  void _setupPurchaseService() {
    final userProvider = context.read<UserProvider>();

    PurchaseService.instance.onPurchaseSuccess = (productId, tokens) {
      userProvider.addTokens(tokens);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully purchased $tokens tokens!')),
      );
    };

    PurchaseService.instance.onPurchaseError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $error')),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<UserProvider, EnhancedImageProvider>(
        builder: (context, userProvider, imageProvider, child) {
          return CustomScrollView(
            slivers: [
              // App Bar with user info
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: AppTheme.oceanGradientDecoration,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Profile Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: AppTheme.oceanBlue,
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'Diving Explorer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              'Member since ${_formatDate(userProvider.joinDate)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Token Balance Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Token Balance',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${userProvider.tokenBalance}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: AppTheme.oceanBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'tokens available',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showTokenPurchaseDialog(context, userProvider),
                          icon: const Icon(Icons.add_circle),
                          label: const Text('Buy More Tokens'),
                          style: AppTheme.primaryButtonStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Settings Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Settings',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      _SettingItem(
                        icon: Icons.privacy_tip,
                        title: 'Privacy Policy',
                        subtitle: 'View our privacy policy',
                        onTap: () => _openWebView(
                          context,
                          'Privacy Policy',
                          'https://www.baidu.com',
                        ),
                      ),
                      _SettingItem(
                        icon: Icons.description,
                        title: 'Terms of Service',
                        subtitle: 'View terms and conditions',
                        onTap: () => _openWebView(
                          context,
                          'Terms of Service',
                          'https://www.baidu.com',
                        ),
                      ),
                      _SettingItem(
                        icon: Icons.info,
                        title: 'About',
                        subtitle: 'App information and credits',
                        onTap: () => _showAboutDialog(context),
                      ),
                      const Divider(),
                      _SettingItem(
                        icon: Icons.delete_forever,
                        title: 'Reset All Data',
                        subtitle: 'Clear all app data',
                        onTap: () => _showResetDialog(context, userProvider),
                        titleColor: AppTheme.coral,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month}/${date.year}';
  }

  void _openWebView(BuildContext context, String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(
          title: title,
          url: url,
        ),
      ),
    );
  }

  void _showTokenPurchaseDialog(
      BuildContext context, UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Buy Tokens',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: PurchaseService.tokenPackages.length,
                    itemBuilder: (context, index) {
                      final entry = PurchaseService.tokenPackages.entries
                          .elementAt(index);
                      final package = entry.value;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: AppTheme.oceanGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            package.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(package.description),
                              const SizedBox(height: 4),
                              Text(
                                '${package.tokens} tokens',
                                style: TextStyle(
                                  color: AppTheme.oceanBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (package.valueDescription.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.coral,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    package.valueDescription,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                            package.price,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.oceanBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          onTap: () {
                            PurchaseService.instance.purchaseTokens(entry.key);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Mello',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppTheme.oceanGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.scuba_diving,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text(
          'Mello is your gateway to the underwater world. '
          'Learn diving techniques, explore marine life, and generate '
          'stunning ocean imagery with AI.',
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'Are you sure you want to reset all app data? '
          'This will delete all your progress, bookmarks, and generated images. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              userProvider.resetUserData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data has been reset')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.coral),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: titleColor ?? AppTheme.oceanBlue,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppTheme.deepNavy,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
