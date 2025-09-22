import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';
import '../providers/image_provider.dart' as img_provider;
import '../theme/app_theme.dart';
import '../widgets/home/welcome_section.dart';
import '../widgets/home/quick_stats_section.dart';
import '../widgets/home/featured_content_section.dart';
import '../widgets/home/recent_images_section.dart';
import '../widgets/common/error_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final userProvider = context.read<UserProvider>();
    final contentProvider = context.read<ContentProvider>();
    final imageProvider = context.read<img_provider.ImageProvider>();

    await Future.wait([
      contentProvider.loadContent(),
      imageProvider.loadImages(),
    ]);

    if (userProvider.error != null) {
      userProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer3<UserProvider, ContentProvider, img_provider.ImageProvider>(
          builder: (context, userProvider, contentProvider, imageProvider, child) {
            if (userProvider.isLoading || contentProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (userProvider.error != null) {
              return ErrorMessage(
                message: userProvider.error!,
                onRetry: _refreshData,
              );
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: true,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: AppTheme.oceanGradientDecoration,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.scuba_diving,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'DiveExplorer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.monetization_on,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${userProvider.tokenBalance}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Welcome Section
                SliverToBoxAdapter(
                  child: WelcomeSection(
                    userName: 'Diver', // Can be personalized later
                    tokenBalance: userProvider.tokenBalance,
                    onGeneratePressed: () {
                      // Switch to generate tab
                      final mainScreenState = context.findAncestorStateOfType<State<StatefulWidget>>();
                      if (mainScreenState != null) {
                        // This is a simple way - in production, you'd use better navigation
                        DefaultTabController.of(context)?.animateTo(2);
                      }
                    },
                  ),
                ),

                // Quick Stats
                SliverToBoxAdapter(
                  child: QuickStatsSection(
                    totalImagesGenerated: userProvider.totalImagesGenerated,
                    totalBookmarks: userProvider.totalBookmarks,
                    totalCompletedContent: userProvider.totalCompletedContent,
                    daysActive: userProvider.daysActive,
                  ),
                ),

                // Featured Content
                SliverToBoxAdapter(
                  child: FeaturedContentSection(
                    featuredContent: contentProvider.allContent.take(3).toList(),
                    onContentTap: (content) {
                      // Navigate to content detail - implement later
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening: ${content.title}')),
                      );
                    },
                  ),
                ),

                // Recent Images
                SliverToBoxAdapter(
                  child: RecentImagesSection(
                    recentImages: imageProvider.recentImages.take(4).toList(),
                    onImageTap: (image) {
                      // Navigate to image detail - implement later
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viewing image: ${image.prompt}')),
                      );
                    },
                    onSeeAllPressed: () {
                      // Switch to generate tab
                      DefaultTabController.of(context)?.animateTo(2);
                    },
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
      ),
    );
  }
}
