import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// Import webview_flutter conditionally
// ignore: depend_on_referenced_packages
// import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // For now, we'll show a placeholder until webview_flutter is properly set up
    setState(() {
      _isLoading = false;
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.oceanBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: 'Copy URL',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInExternalBrowser,
            tooltip: 'Open in Browser',
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView Content
          if (_hasError) _buildErrorView() else _buildWebViewPlaceholder(),

          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppTheme.oceanGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.oceanBlue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading ${widget.title}...',
                      style: TextStyle(
                        color: AppTheme.deepNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebViewPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.oceanBlue.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.oceanGradient,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.language,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightAqua.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.seaFoam.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'URL Preview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.oceanBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        color: AppTheme.oceanBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.url,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _openInExternalBrowser,
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Open in Browser'),
                    style: AppTheme.primaryButtonStyle,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy URL'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.oceanBlue,
                      side: BorderSide(color: AppTheme.oceanBlue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.coral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppTheme.coral,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load page',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage.isEmpty
                  ? 'Please check your internet connection and try again.'
                  : _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _openInExternalBrowser,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in Browser'),
                  style: AppTheme.primaryButtonStyle,
                ),
                OutlinedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy URL'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.oceanBlue,
                    side: BorderSide(color: AppTheme.oceanBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('URL copied to clipboard'),
          ],
        ),
        backgroundColor: AppTheme.oceanBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _openInExternalBrowser() {
    // Show dialog to confirm opening in external browser
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open in Browser'),
        content: Text(
            'Do you want to open ${widget.title} in your default browser?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you would typically use url_launcher package
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('URL: ${widget.url}'),
                  action: SnackBarAction(
                    label: 'Copy',
                    onPressed: () {
                      // Copy URL to clipboard
                    },
                  ),
                ),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}
