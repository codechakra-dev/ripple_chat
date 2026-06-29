import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  /// --- 1. COLOR PALETTES ---
  // Light Mode Colors
  static const _lightPrimary = Colors.deepPurple;
  static const _lightBackground = Color(0xFFF8F9FA);
  static const _lightSurface = Colors.white;
  static const _lightOnSurface = Color(0xFF1A1A1A);

  // Dark Mode Colors (Using soft charcoal instead of pure black)
  static const _darkPrimary = Color(0xFFBB86FC);
  static const _darkBackground = Color(0xFF121212);
  static const _darkSurface = Color(0xFF1E1E1E);
  static const _darkOnSurface = Color(0xFFE1E1E1);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightPrimary,
        brightness: Brightness.light,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
      ),

      // Component Overrides
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        elevation: 0,

      ),
    );
  }


  static ThemeData get darkTheme{
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: _darkPrimary,
        brightness: Brightness.dark,
        surface: _darkSurface,
        onSurface: _darkOnSurface
      ),
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        elevation: 0,

      ),
    );
  }
}
