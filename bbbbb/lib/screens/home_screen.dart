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
import '../widgets/home/enhanced_images_section.dart';
import '../widgets/common/error_message.dart';
import '../widgets/animations/ocean_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: AppTheme.waveAnimation,
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _waveController.dispose();
    super.dispose();
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
        child: Consumer3<UserProvider, ContentProvider,
            img_provider.ImageProvider>(
          builder:
              (context, userProvider, contentProvider, imageProvider, child) {
            if (userProvider.isLoading || contentProvider.isLoading) {
              return Container(
                decoration: AppTheme.oceanDepthDecoration,
                child: Center(
                  child: OceanAnimations.pulsingGlow(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pearl),
                      strokeWidth: 3,
                    ),
                    glowColor: AppTheme.seaFoam,
                  ),
                ),
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
                // Enhanced App Bar with waves
                SliverAppBar(
                  expandedHeight: 140,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return Container(
                          decoration: AppTheme.oceanDepthDecoration,
                          child: CustomPaint(
                            painter: WavePainter(
                              animationValue: _waveController.value,
                              waveHeight: 15.0,
                            ),
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        OceanAnimations.floatingWidget(
                                          child: const Icon(
                                            Icons.scuba_diving,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          duration: const Duration(seconds: 4),
                                          offset: 8.0,
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
                                        OceanAnimations.pulsingGlow(
                                          duration: const Duration(seconds: 3),
                                          glowColor: AppTheme.aquaMarine,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.25),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppTheme.seaFoam
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
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
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Animated Welcome Section
                SliverToBoxAdapter(
                  child: OceanAnimations.staggeredList(
                    index: 0,
                    child: WelcomeSection(
                      userName: 'Diver',
                      tokenBalance: userProvider.tokenBalance,
                      onGeneratePressed: () {
                        final mainScreenState = context
                            .findAncestorStateOfType<State<StatefulWidget>>();
                        if (mainScreenState != null) {
                          DefaultTabController.of(context)!.animateTo(2);
                        }
                      },
                    ),
                  ),
                ),

                // Animated Quick Stats
                SliverToBoxAdapter(
                  child: OceanAnimations.staggeredList(
                    index: 1,
                    delay: 150,
                    child: QuickStatsSection(
                      totalImagesGenerated: userProvider.totalImagesGenerated,
                      totalBookmarks: userProvider.totalBookmarks,
                      totalCompletedContent: userProvider.totalCompletedContent,
                      daysActive: userProvider.daysActive,
                    ),
                  ),
                ),

                // Animated Featured Content
                SliverToBoxAdapter(
                  child: OceanAnimations.staggeredList(
                    index: 2,
                    delay: 200,
                    child: FeaturedContentSection(
                      featuredContent:
                          contentProvider.allContent.take(3).toList(),
                      onContentTap: (content) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening: ${content.title}'),
                            backgroundColor: AppTheme.oceanBlue,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Enhanced Images Gallery with Swiper
                SliverToBoxAdapter(
                  child: OceanAnimations.staggeredList(
                    index: 3,
                    delay: 250,
                    child: EnhancedImagesSection(
                      images: imageProvider.recentImages.take(6).toList(),
                      onSeeAllPressed: () {
                        DefaultTabController.of(context)!.animateTo(2);
                      },
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
      ),
    );
  }
}
