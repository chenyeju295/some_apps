import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

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
            // App Settings Section
            _buildSectionHeader(context, 'App Settings'),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              children: _buildThemeToggle(context),
            ),

            const SizedBox(height: 24),

            // API Configuration Section
            _buildSectionHeader(context, 'API Configuration'),
            const SizedBox(height: 16),
            _buildApiKeySection(context),

            const SizedBox(height: 24),

            // Data Management Section
            _buildSectionHeader(context, 'Data Management'),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              children: _buildDataManagementTiles(),
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader(context, 'About'),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              children: _buildAboutTiles(),
            ),
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

  Widget _buildApiKeySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.key,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'OpenAI API Key',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your OpenAI API key to generate wallpapers',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 16),

          // API Key input
          Obx(() => TextField(
                onChanged: controller.updateApiKey,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: controller.isApiKeyValid.value
                      ? Icon(Icons.check_circle, color: Colors.green[600])
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )),

          const SizedBox(height: 12),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.saveApiKey,
              icon: const Icon(Icons.save),
              label: const Text('Save API Key'),
            ),
          ),

          const SizedBox(height: 12),

          // Help text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Get your API key from platform.openai.com',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
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

  Widget _buildDataManagementTiles() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.orange),
          title: const Text('Clear Favorites'),
          subtitle: const Text('Remove all favorite wallpapers'),
          onTap: controller.clearFavorites,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.history, color: Colors.blue),
          title: const Text('Clear History'),
          subtitle: const Text('Remove all generation history'),
          onTap: controller.clearHistory,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Clear All Data'),
          subtitle: const Text('Remove all app data'),
          onTap: controller.clearAllData,
        ),
      ],
    );
  }

  Widget _buildAboutTiles() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          subtitle: Text('Version ${controller.appVersion}'),
          onTap: controller.showAboutDialog,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.auto_awesome),
          title: const Text('Powered by OpenAI'),
          subtitle: const Text('DALL-E 3 Image Generation'),
          onTap: () {},
        ),
      ],
    );
  }
}
