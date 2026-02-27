import 'package:flutter/material.dart';

class CandyColors {
  // Primary candy colors
  static const Color pink = Color(0xFFFF6B9D);
  static const Color purple = Color(0xFFC44569);
  static const Color blue = Color(0xFF60A3D9);
  static const Color yellow = Color(0xFFFFA07A);
  static const Color bg = Color(0xFFFFF5F7);

  // UI colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFF43F5E);
  static const Color warning = Color(0xFFF59E0B);

  // Text colors
  static const Color textPrimary = Color(0xFF334155);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
}

class CandyTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: CandyColors.pink,
        secondary: CandyColors.purple,
        tertiary: CandyColors.blue,
        surface: Colors.white,
        error: CandyColors.error,
      ),
      scaffoldBackgroundColor: CandyColors.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: CandyColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: CandyColors.pink.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CandyColors.pink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: CandyColors.pink.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: CandyColors.pink.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: CandyColors.pink,
            width: 2,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: CandyColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: CandyColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: CandyColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: CandyColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: CandyColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: CandyColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: CandyColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: CandyColors.textPrimary,
        ),
      ),
    );
  }

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CandyColors.pink.withValues(alpha: 0.2),
          width: 2,
        ),
      );

  static BoxDecoration gradientCardDecoration({
    required List<Color> colors,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      );

  static Widget difficultyBadge(String difficulty) {
    Color bgColor;
    Color textColor;

    switch (difficulty.toLowerCase()) {
      case 'easy':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        break;
      case 'medium':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      case 'hard':
        bgColor = const Color(0xFFFECDD3);
        textColor = const Color(0xFFDC2626);
        break;
      default:
        bgColor = const Color(0xFFE2E8F0);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
