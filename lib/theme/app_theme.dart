import 'package:flutter/material.dart';

/// Centralized app theme defining semantic colors via ColorScheme.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Very light gray (surface)
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4F46E5),      // Indigo primary
        onPrimary: Colors.white,
        secondary: Color(0xFF64748B),    // Slate secondary
        onSecondary: Colors.white,
        surface: Colors.white,           // Pure white surface for cards
        onSurface: Color(0xFF111827),    // Dark text (gray-900)
        onSurfaceVariant: Color(0xFF6B7280), // Muted text (gray-500)
        outline: Color(0xFFE5E7EB),      // Border color (gray-200)
        outlineVariant: Color(0xFFF3F4F6), // Lighter border
        error: Color(0xFFEF4444),        // Important task category (Red)
        onError: Colors.white,
        tertiary: Color(0xFF10B981),     // Normal task category (Green)
        onTertiary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        prefixIconColor: const Color(0xFF6B7280),
        suffixIconColor: const Color(0xFF6B7280),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
