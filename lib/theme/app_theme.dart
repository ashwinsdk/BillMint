/**
 * App theme configuration
 * 
 * Dark theme with black background and electric blue primary color.
 * Uses Source Code Pro font throughout the app.
 */

import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF0080FF); // Electric blue
  static const Color darkBlue = Color(0xFF0066CC);
  static const Color backgroundColor = Color(0xFF000000); // Pure black
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF252525);
  static const Color dividerColor = Color(0xFF333333);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color errorColor = Color(0xFFFF4444);
  static const Color successColor = Color(0xFF00CC66);
  static const Color warningColor = Color(0xFFFFAA00);

  // Font family
  static const String fontFamily = 'SourceCodePro';

  /// Get the dark theme data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: fontFamily,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: darkBlue,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontFamily: fontFamily,
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontFamily: fontFamily,
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // List tile theme
      listTileTheme: const ListTileThemeData(
        textColor: textPrimary,
        iconColor: primaryBlue,
        tileColor: cardColor,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: primaryBlue),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textSecondary,
          fontFamily: fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}
