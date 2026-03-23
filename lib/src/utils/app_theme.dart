import 'package:flutter/material.dart';

class AppTheme {
  // --- Modern Solar Palette ---
  // Primary (Teal/Green mix for clean energy vibe)
  static const Color primaryColor = Color(0xFF00BFA5); // Teal Accent 700
  static const Color primaryLightColor = Color(0xFF5DF2D6);
  static const Color primaryDarkColor = Color(0xFF008E76);

  // Secondary/Accent
  static const Color accentColor = Color(0xFFFFAB40); // Amber Accent (Sun)

  // Status Colors
  static const Color successColor = Color(0xFF66BB6A);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color warningColor = Color(0xFFFFA726);

  // Backgrounds & Surface
  static const Color lightBackground = Color(0xFFF8F9FA); // Very light grey
  static const Color darkBackground = Color(0xFF121212); // Material Dark

  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1E1E1E);

  static const String fontFamily = 'Cairo';

  // Typography
  static TextTheme _buildTextTheme(ThemeData base, Color textColor) {
    // Apply Cairo font to all text styles
    return base.textTheme
        .copyWith(
          displayLarge: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.bold, fontSize: 32),
          displayMedium: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.bold, fontSize: 28),
          displaySmall: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w600, fontSize: 24),
          headlineMedium: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w600, fontSize: 20),
          headlineSmall: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w500, fontSize: 18),
          titleLarge: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
          bodyLarge: TextStyle(fontFamily: fontFamily, color: textColor, fontSize: 16),
          bodyMedium: TextStyle(fontFamily: fontFamily, color: textColor.withValues(alpha: 0.8), fontSize: 14),
          labelLarge: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w500, fontSize: 14),
        )
        .apply(fontFamily: fontFamily, bodyColor: textColor, displayColor: textColor);
  }

  // --- Light Theme ---
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: lightSurface,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
      ),
      dividerColor: Colors.grey.withValues(alpha: 0.2),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: fontFamily, color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: Colors.grey, fontFamily: fontFamily),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: _buildTextTheme(base, Colors.black87),
    );
  }

  // --- Dark Theme ---
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkSurface,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onSurface: Colors.white,
      ),
      dividerColor: Colors.white12,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: fontFamily, color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: Colors.white70, fontFamily: fontFamily),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: _buildTextTheme(base, Colors.white),
    );
  }
}
