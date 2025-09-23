import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/balance_controller.dart';
import '../models/product_model.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crystal Balance Section
            _buildBalanceSection(context),
            const SizedBox(height: 24),

            // App Settings Section
            _buildSectionHeader(context, 'App Settings'),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              children: _buildThemeToggle(context),
            ),

            const SizedBox(height: 24),

            // Data Management Section
            _buildSectionHeader(context, 'Data Management'),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              children: _buildDataManagementTiles(),
            ),

            const SizedBox(height: 24),

            // Legal & Privacy Section
            _buildSectionHeader(context, 'Legal & Privacy'),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              children: _buildLegalTiles(),
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader(context, 'About'),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              children: _buildAboutTiles(),
            ),
            const SizedBox(height: 86),

          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required Widget children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: children,
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Obx(() => SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Switch between light and dark themes'),
          value: controller.isDarkMode.value,
          onChanged: (value) => controller.toggleDarkMode(),
          secondary: Icon(
            controller.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).primaryColor,
          ),
        ));
  }


  Widget _buildDataManagementTiles() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications_active, color: Colors.green),
          title: const Text('Reset Generation Confirmation'),
          subtitle:
              const Text('Re-enable confirmation dialog before generation'),
          onTap: controller.resetGenerationConfirm,
        ),
        const Divider(height: 1,color: Colors.grey,),

        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Clear All Data'),
          subtitle: const Text('Remove all app data'),
          onTap: controller.clearAllData,
        ),
      ],
    );
  }

  Widget _buildLegalTiles() {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.policy, color: Colors.blue, size: 20),
          ),
          title: const Text('Privacy Policy'),
          subtitle: const Text('How we protect and use your data'),
          trailing: const Icon(Icons.open_in_new, size: 16),
          onTap: () => _openWebView(
            'Privacy Policy',
            'https://h5.joinclero.com/clero/about/index.html#/privacy-agreement', // 示例隐私政策链接
          ),
        ),
        const Divider(height: 1,color: Colors.grey,),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description, color: Colors.green, size: 20),
          ),
          title: const Text('Terms of Service'),
          subtitle: const Text('Terms and conditions of use'),
          trailing: const Icon(Icons.open_in_new, size: 16),
          onTap: () => _openWebView(
            'Terms of Service',
            'https://h5.joinclero.com/clero/about/index.html#/user-agreement', // 示例服务条款链接
          ),
        ),


      ],
    );
  }

  Widget _buildAboutTiles() {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.info_outline,
              color: Get.theme.primaryColor,
              size: 20,
            ),
          ),
          title: const Text('About'),
          subtitle: Text('Version ${controller.appVersion}'),
          onTap: controller.showAboutDialog,
        ),
      ],
    );
  }

  Widget _buildBalanceSection(BuildContext context) {
    // Get or create balance controller
    final balanceController = Get.put(BalanceController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Crystal Balance'),
        const SizedBox(height: 16),

        // Balance Card
        Obx(() => _buildBalanceCard(context, balanceController)),

        const SizedBox(height: 16),

        // Shop Entry
        _buildShopEntry(context),
      ],
    );
  }

  Widget _buildBalanceCard(
      BuildContext context, BalanceController balanceController) {
    final status = balanceController.balanceStatus;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'low':
        statusColor = Colors.red;
        statusIcon = Icons.warning_amber;
        statusText = 'Low Balance';
        break;
      case 'medium':
        statusColor = Colors.orange;
        statusIcon = Icons.info_outline;
        statusText = 'Good Balance';
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Excellent Balance';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crystal Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                balanceController.formattedBalance,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Crystals are used to generate AI wallpapers. Each generation costs ${CrystalCosts.basicGeneration}-${CrystalCosts.premiumGeneration} crystals.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopEntry(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showShopDialog(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crystal Shop',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buy crystal packs to generate more wallpapers',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showShopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crystal Shop'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ProductModel.products.map((product) {
              return _buildProductCard(context, product);
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final balanceController = Get.find<BalanceController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: product.isPopular
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
          width: product.isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.diamond,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (product.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: product.isPopular
                                  ? Colors.orange
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${product.crystals} Crystals',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${product.crystalsPerDollar.toInt()} crystals/\$',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Simulate purchase (in real app, this would use in_app_purchase)
                balanceController.addCrystals(product.crystals);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: product.isPopular
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Buy ${product.formattedPrice}'),
            ),
          ),
        ],
      ),
    );
  }

  void _openWebView(String title, String url) {
    Get.toNamed('/webview', arguments: {
      'title': title,
      'url': url,
    });
  }
}
