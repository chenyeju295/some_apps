import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';
import '../providers/enhanced_image_provider.dart';
import '../models/diving_content.dart';
import '../theme/app_theme.dart';
import '../widgets/home/welcome_section.dart';
import '../widgets/home/featured_content_section.dart';
import '../widgets/home/enhanced_images_section.dart';
import '../widgets/common/error_message.dart';
import '../widgets/animations/ocean_animations.dart';
import 'content_detail_screen.dart';
import '../utils/navigation_helper.dart';

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
    final imageProvider = context.read<EnhancedImageProvider>();

    await Future.wait([
      contentProvider.loadContent(),
      imageProvider.initialize(),
    ]);

    if (userProvider.error != null) {
      userProvider.clearError();
    }
  }

  // Optimized data field methods for better text content management
  String _getUserDisplayName(UserProvider userProvider) {
    // Field-based user name handling with fallback
    return 'Ocean Explorer'; // Default display name for diving theme
  }

  void _navigateToGenerateScreen() {
    NavigationHelper.navigateToGenerate(context);
  }

  void _navigateToContentDetail(
      DivingContent content, List<DivingContent> allContent) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ContentDetailScreen(
          content: content,
          relatedContent: allContent
              .where((c) =>
                  c.id != content.id &&
                  (c.category == content.category ||
                      c.tags.any((tag) => content.tags.contains(tag))))
              .take(5)
              .toList(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppTheme.normalAnimation,
      ),
    );
  }

  Widget _buildAppBarContent(UserProvider userProvider) {
    return Row(
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
        Text(
          _getAppTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        _buildTokenBalanceChip(userProvider.tokenBalance),
      ],
    );
  }

  String _getAppTitle() {
    return 'DiveExplorer';
  }

  Widget _buildTokenBalanceChip(int tokenBalance) {
    return OceanAnimations.pulsingGlow(
      duration: const Duration(seconds: 3),
      glowColor: AppTheme.aquaMarine,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.seaFoam.withOpacity(0.3),
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
              '$tokenBalance',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer3<UserProvider, ContentProvider, EnhancedImageProvider>(
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
                                    _buildAppBarContent(userProvider),
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

                // Enhanced Images Gallery with Swiper - Moved to top position
                SliverToBoxAdapter(
                  child: OceanAnimations.staggeredList(
                    index: 0,
                    child: EnhancedImagesSection(
                      images: imageProvider.recentImages.take(6).toList(),
                      onSeeAllPressed: () {
                        NavigationHelper.navigateToGenerate(context);
                      },
                    ),
                  ),
                ),

                // Animated Welcome Section
                SliverToBoxAdapter(
                  child: OceanAnimations.staggeredList(
                    index: 1,
                    delay: 100,
                    child: WelcomeSection(
                      userName: _getUserDisplayName(userProvider),
                      tokenBalance: userProvider.tokenBalance,
                      onGeneratePressed: () {
                        _navigateToGenerateScreen();
                      },
                    ),
                  ),
                ),

                // Animated Featured Content
                SliverToBoxAdapter(
                  child: OceanAnimations.staggeredList(
                    index: 3,
                    delay: 200,
                    child: FeaturedContentSection(
                      featuredContent:
                          contentProvider.allContent.take(3).toList(),
                      onContentTap: (content) => _navigateToContentDetail(
                          content, contentProvider.allContent),
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
