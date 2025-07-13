import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define your primary color palette
  static const Color primaryColor = Color(0xFFFFA000); // A shade of orange
  static const Color primaryLightColor = Color(0xFFFFCC80);
  static const Color primaryDarkColor = Color(0xFFC67F00); // Darker orange

  static const Color accentColor = Color(
    0xFF4CAF50,
  ); // Green for accents/success
  static const Color errorColor = Color(0xFFD32F2F); // Red for errors

  // Text Colors
  static const Color lightTextColor = Colors.black87;
  static const Color darkTextColor = Colors.white;
  static const Color lightSecondaryTextColor = Colors.black54;
  static const Color darkSecondaryTextColor = Colors.white70;

  // Background Colors
  static const Color lightBackgroundColor = Color(0xFFF5F5F5); // Light grey
  static const Color darkBackgroundColor = Color(
    0xFF121212,
  ); // Dark grey almost black

  // Card & Surface Colors
  static const Color lightCardColor = Colors.white;
  static const Color darkCardColor = Color(0xFF1E1E1E);

  // App Bar Colors
  static const Color lightAppBarColor =
      primaryColor; // Using primary color for light app bar
  static const Color darkAppBarColor = Color(
    0xFF2C2C2C,
  ); // Darker grey for dark app bar

  // --- Light Theme ---
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLightColor,
      secondary: accentColor,
      error: errorColor,
      onPrimary: Colors.white, // Text/icons on primary color
      onSecondary: Colors.white, // Text/icons on background
      onError: Colors.white, // Text/icons on error color
      onSurface: lightTextColor, // Text/icons on surfaces like cards
      surface: lightCardColor, // Card/surface color
    ),
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: AppBarTheme(
      color: lightAppBarColor,
      foregroundColor: Colors.white, // Text and icon color on app bar
      elevation: 4,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.cairo(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        color: lightTextColor,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 60,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
      ), // Buttons
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: lightSecondaryTextColor,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: lightSecondaryTextColor,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.cairo(fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        textStyle: GoogleFonts.cairo(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: GoogleFonts.cairo(color: lightSecondaryTextColor),
      hintStyle: GoogleFonts.cairo(color: Colors.grey),
      floatingLabelStyle: GoogleFonts.cairo(color: primaryColor),
    ),
    cardTheme: CardThemeData(
      color: lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(8),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Colors.white, // Text color for selected tab
      unselectedLabelColor: Colors.white70, // Text color for unselected tabs
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.white, width: 3.0),
      ),
      labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedLabelStyle: GoogleFonts.cairo(
        fontWeight: FontWeight.normal,
        fontSize: 15,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  // --- Dark Theme ---
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: primaryDarkColor,
      secondary: accentColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: darkTextColor,
      surface: darkCardColor,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: AppBarTheme(
      color: darkAppBarColor,
      foregroundColor: Colors.white,
      elevation: 4,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.cairo(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        color: darkTextColor,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 60,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: darkSecondaryTextColor,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: darkSecondaryTextColor,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.cairo(fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        textStyle: GoogleFonts.cairo(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: GoogleFonts.cairo(color: darkSecondaryTextColor),
      hintStyle: GoogleFonts.cairo(color: Colors.grey),
      floatingLabelStyle: GoogleFonts.cairo(color: primaryColor),
    ),
    cardTheme: CardThemeData(
      color: darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(8),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.white, width: 3.0),
      ),
      labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedLabelStyle: GoogleFonts.cairo(
        fontWeight: FontWeight.normal,
        fontSize: 15,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );
}
