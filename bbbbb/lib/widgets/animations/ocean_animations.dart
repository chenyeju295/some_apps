import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../theme/app_theme.dart';

/// Ocean-themed animation widgets for the diving app
class OceanAnimations {
  /// Creates a floating animation that mimics underwater movement
  static Widget floatingWidget({
    required Widget child,
    Duration duration = const Duration(seconds: 3),
    double offset = 10.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, offset * (0.5 - (value * 0.5))),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a wave-like animation for backgrounds - requires TickerProvider
  static Widget waveBackground({
    required Widget child,
    required TickerProvider vsync,
    double waveHeight = 20.0,
    Duration duration = const Duration(seconds: 4),
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        final controller = AnimationController(
          duration: duration,
          vsync: vsync,
        )..repeat();

        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return CustomPaint(
              painter: WavePainter(
                animationValue: controller.value,
                waveHeight: waveHeight,
              ),
              child: child,
            );
          },
        );
      },
    );
  }

  /// Creates bubble animation effect
  static Widget bubbleEffect({
    required Widget child,
    int bubbleCount = 5,
    Duration duration = const Duration(seconds: 6),
  }) {
    return Stack(
      children: [
        child,
        ...List.generate(bubbleCount, (index) {
          return Positioned(
            left: (index * 60.0) % 300,
            bottom: 0,
            child: BubbleWidget(
              delay: Duration(milliseconds: index * 800),
              duration: duration,
            ),
          );
        }),
      ],
    );
  }

  /// Creates a shimmer loading effect with ocean colors
  static Widget oceanShimmer({
    required Widget child,
    bool isLoading = true,
  }) {
    if (!isLoading) return child;

    return AnimatedContainer(
      duration: AppTheme.normalAnimation,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
          colors: [
            AppTheme.shimmerBaseColor,
            AppTheme.shimmerHighlightColor,
            AppTheme.shimmerBaseColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }

  /// Creates staggered animation for lists
  static Widget staggeredList({
    required Widget child,
    int index = 0,
    double delay = 100,
  }) {
    return AnimationConfiguration.staggeredList(
      position: index,
      delay: Duration(milliseconds: delay.toInt()),
      child: SlideAnimation(
        verticalOffset: 50.0,
        curve: AppTheme.defaultCurve,
        child: FadeInAnimation(
          curve: AppTheme.fadeCurve,
          child: child,
        ),
      ),
    );
  }

  /// Creates a pulsing glow effect
  static Widget pulsingGlow({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    Color glowColor = AppTheme.seaFoam,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.3, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(value * 0.5),
                blurRadius: value * 20,
                spreadRadius: value * 3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a scale animation with ocean theme
  static Widget scaleInAnimation({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return AnimationConfiguration.synchronized(
      duration: duration,
      child: SlideAnimation(
        verticalOffset: 30.0,
        delay: delay,
        child: ScaleAnimation(
          scale: 0.8,
          curve: AppTheme.bubbleCurve,
          child: FadeInAnimation(
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for wave background
class WavePainter extends CustomPainter {
  final double animationValue;
  final double waveHeight;

  WavePainter({
    required this.animationValue,
    required this.waveHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = AppTheme.sunlightGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final normalizedI = i / size.width;
      final waveY = size.height -
          waveHeight *
              (0.5 +
                  0.5 *
                      math.sin(2 * math.pi * normalizedI +
                          animationValue * 2 * math.pi));
      path.lineTo(i, waveY);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Individual bubble widget
class BubbleWidget extends StatefulWidget {
  final Duration delay;
  final Duration duration;

  const BubbleWidget({
    Key? key,
    required this.delay,
    required this.duration,
  }) : super(key: key);

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppTheme.defaultCurve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            10 * math.sin(_animation.value * 2 * math.pi),
            -200 * _animation.value,
          ),
          child: Opacity(
            opacity: 1.0 - _animation.value,
            child: Container(
              width: 8 + (math.Random().nextDouble() * 12),
              height: 8 + (math.Random().nextDouble() * 12),
              decoration: AppTheme.bubbleDecoration.copyWith(
                color: AppTheme.seaFoam.withOpacity(0.6),
              ),
            ),
          ),
        );
      },
    );
  }
}
