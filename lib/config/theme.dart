// config/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color brandBackground = Color(0xFFF9F2E8); // Light creamy yellow
  static const Color brandPrimary = Color(0xFF823BBE);    // Branded Blue

  static ThemeData lightTheme = ThemeData(
    fontFamily: "tajawal",
    useMaterial3: true,
    scaffoldBackgroundColor: brandBackground,
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandPrimary,
      primary: brandPrimary,
      brightness: Brightness.light,
      surface: brandBackground,
      onSurface: Colors.black87,
      primaryContainer: const Color(0xFFE3F2FD), // Harmonic light blue
      onPrimaryContainer: brandPrimary,
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: brandBackground,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: "tajawal",
        color: Colors.black87,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
      iconTheme: IconThemeData(color: brandPrimary),
    ),

    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.4), // Blends with yellow background
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: brandPrimary.withValues(alpha: 0.1), width: 1),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: "tajawal",
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        shadowColor: brandPrimary.withValues(alpha: 0.4),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: brandPrimary.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: brandPrimary.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: brandPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: brandBackground,
      selectedItemColor: brandPrimary,
      unselectedItemColor: Colors.black45,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: brandBackground,
      indicatorColor: brandPrimary.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: "tajawal", fontWeight: FontWeight.bold, fontSize: 12),
      ),
    ),
  );

  // Dark Theme (Keeping it harmonic but darker)
  static ThemeData darkTheme = ThemeData(
    fontFamily: "tajawal",
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
