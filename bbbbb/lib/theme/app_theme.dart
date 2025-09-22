import 'package:flutter/material.dart';

class AppTheme {
  // Enhanced ocean-inspired color palette
  static const Color oceanBlue = Color(0xFF0077BE);
  static const Color deepSeaGreen = Color(0xFF1B4D3E);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color lightAqua = Color(0xFFE3F2FD);
  static const Color deepNavy = Color(0xFF2C3E50);
  static const Color seaFoam = Color(0xFF4FC3F7);
  static const Color tropicalTeal = Color(0xFF00ACC1);
  static const Color sandyBeige = Color(0xFFF5F5DC);

  // New gradient colors
  static const Color shallowWater = Color(0xFF87CEEB);
  static const Color mediumDepth = Color(0xFF4682B4);
  static const Color deepOcean = Color(0xFF191970);
  static const Color sunlightYellow = Color(0xFFFFE135);
  static const Color aquaMarine = Color(0xFF7FFFD4);
  static const Color seahorse = Color(0xFF20B2AA);
  static const Color kelp = Color(0xFF006A4E);
  static const Color pearl = Color(0xFFF8F8FF);

  // Enhanced gradient definitions
  static const LinearGradient oceanDepthGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      shallowWater,
      mediumDepth,
      oceanBlue,
      deepOcean,
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient sunlightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      sunlightYellow,
      aquaMarine,
      seaFoam,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient coralReefGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      lightAqua,
      tropicalTeal,
      coral,
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      pearl,
      lightAqua,
      seaFoam,
    ],
  );

  static const RadialGradient bubbleGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFE3F2FD),
      Color(0xFF4FC3F7),
    ],
    stops: [0.0, 0.4, 1.0],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: oceanBlue,
        brightness: Brightness.light,
      ).copyWith(
        primary: oceanBlue,
        secondary: tropicalTeal,
        surface: Colors.white,
        background: lightAqua,
        error: coral,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: oceanBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: oceanBlue.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
          (states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: oceanBlue,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            );
          },
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: oceanBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: oceanBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: oceanBlue, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightAqua,
        selectedColor: oceanBlue,
        labelStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: deepNavy,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: deepNavy,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: deepNavy,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: deepNavy,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: deepNavy,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: deepNavy,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: deepNavy,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: deepNavy,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: oceanBlue,
        brightness: Brightness.dark,
      ).copyWith(
        primary: seaFoam,
        secondary: tropicalTeal,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        error: coral,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        indicatorColor: seaFoam.withOpacity(0.3),
        labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
          (states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: seaFoam,
              );
            }
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            );
          },
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seaFoam,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: seaFoam,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: seaFoam, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        selectedColor: seaFoam,
        labelStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF404040),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  // Custom button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: oceanBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: oceanBlue,
        side: const BorderSide(color: oceanBlue, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  // Enhanced container decorations with animations in mind
  static BoxDecoration get oceanDepthDecoration => const BoxDecoration(
        gradient: oceanDepthGradient,
      );

  // Legacy support - keeping old names for compatibility
  static BoxDecoration get oceanGradientDecoration => const BoxDecoration(
        gradient: oceanDepthGradient,
      );

  static LinearGradient get oceanGradient => oceanDepthGradient;

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get sunlightDecoration => const BoxDecoration(
        gradient: sunlightGradient,
      );

  static BoxDecoration get coralReefDecoration => const BoxDecoration(
        gradient: coralReefGradient,
      );

  static BoxDecoration get bubbleDecoration => const BoxDecoration(
        gradient: bubbleGradient,
        shape: BoxShape.circle,
      );

  static BoxDecoration get animatedCardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: oceanBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: seaFoam.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      );

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: seaFoam.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: oceanBlue.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      );

  static BoxDecoration get wavyBottomDecoration => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            lightAqua,
            seaFoam,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.elliptical(50, 20),
          bottomRight: Radius.elliptical(50, 20),
        ),
      );

  // Animation durations and curves
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 400);
  static const Duration slowAnimation = Duration(milliseconds: 800);
  static const Duration waveAnimation = Duration(milliseconds: 2000);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve waveCurve = Curves.easeInOutSine;
  static const Curve bubbleCurve = Curves.elasticOut;
  static const Curve fadeCurve = Curves.easeIn;

  // Special effects
  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: oceanBlue.withOpacity(0.15),
          blurRadius: 30,
          offset: const Offset(0, 15),
          spreadRadius: 5,
        ),
        BoxShadow(
          color: seaFoam.withOpacity(0.1),
          blurRadius: 50,
          offset: const Offset(0, 25),
        ),
      ];

  static List<BoxShadow> get pulsingGlow => [
        BoxShadow(
          color: aquaMarine.withOpacity(0.4),
          blurRadius: 15,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: seaFoam.withOpacity(0.3),
          blurRadius: 30,
          spreadRadius: 5,
        ),
      ];

  // Shimmer colors for loading states
  static Color get shimmerBaseColor => lightAqua.withOpacity(0.3);
  static Color get shimmerHighlightColor => pearl.withOpacity(0.8);
}
