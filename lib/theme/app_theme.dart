import 'package:flutter/material.dart';

class AppTheme {
  // Orthodox color palette - light theme
  static const Color goldColor = Color(0xFFB8860B); // Dark gold for contrast on white
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color surfaceColor = Color(0xFFF5F0E8); // Warm cream surface
  static const Color cardColor = Color(0xFFFAF6F0); // Light warm card
  static const Color creamColor = Color(0xFF2C1810); // Dark brown for text
  static const Color deepRedColor = Color(0xFF8B0000); // Deep red
  static const Color accentGoldLight = Color(0xFF996515); // Darker gold for readability
  static const Color dividerColor = Color(0xFFD4C5B0); // Light brown divider

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: goldColor,
      colorScheme: const ColorScheme.light(
        primary: goldColor,
        secondary: deepRedColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: creamColor,
        tertiary: accentGoldLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: goldColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: goldColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: goldColor),
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: creamColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: creamColor,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: creamColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: goldColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          color: goldColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: goldColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: creamColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: creamColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: creamColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: creamColor,
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          color: creamColor,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: accentGoldLight,
          fontSize: 12,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: goldColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          color: goldColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: TextStyle(
          color: accentGoldLight,
          fontSize: 11,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: goldColor,
        size: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: goldColor,
        unselectedItemColor: Color(0xFFA09080),
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: cardColor,
        iconColor: goldColor,
        textColor: creamColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}
