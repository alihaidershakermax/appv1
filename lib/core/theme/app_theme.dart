import 'package:flutter/material.dart';

class AppTheme {
  // Color Schemes
  static const _primaryColor = Color(0xFF6750A4);
  static const _secondaryColor = Color(0xFF625B71);
  static const _tertiaryColor = Color(0xFF7D5260);
  
  // Light Theme Colors
  static const _lightSurface = Color(0xFFFFFBFE);
  static const _lightOnSurface = Color(0xFF1C1B1F);
  static const _lightSurfaceVariant = Color(0xFFE7E0EC);
  static const _lightOnSurfaceVariant = Color(0xFF49454F);
  
  // Dark Theme Colors  
  static const _darkSurface = Color(0xFF121212);
  static const _darkOnSurface = Color(0xFFE6E1E5);
  static const _darkSurfaceVariant = Color(0xFF49454F);
  static const _darkOnSurfaceVariant = Color(0xFFCAC4D0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
        surfaceContainerHighest: _lightSurfaceVariant,
        onSurfaceVariant: _lightOnSurfaceVariant,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        surfaceContainerHighest: _darkSurfaceVariant,
        onSurfaceVariant: _darkOnSurfaceVariant,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// Chat-specific theme extensions
class ChatTheme {
  static const userBubbleColor = Color(0xFF6750A4);
  static const botBubbleColor = Color(0xFFE7E0EC);
  static const userBubbleColorDark = Color(0xFF6750A4);
  static const botBubbleColorDark = Color(0xFF49454F);
  
  static const chatBubbleRadius = 16.0;
  static const chatBubblePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const chatMessageSpacing = 8.0;
}