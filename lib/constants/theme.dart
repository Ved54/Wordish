import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6750A4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  static const Map<String, Color> buttonColors = {
    'play': Color(0xFF4CAF50),
    'leaderboard': Color(0xFF2196F3),
    'stats': Color(0xFFFF9800),
    'logout': Color.fromARGB(255, 179, 27, 27),
  };

  static const Map<String, Color> gameColors = {
    'background': Color(0xFF1A1A1A),
    'correct': Color(0xFF4CAF50),
    'present': Color(0xFFFFC107),
    'absent': Color(0xFF757575),
  };

  static const Map<String, Color> textColors = {
    'primary': Colors.white,
    'secondary': Color(0xFFBDBDBD),
    'accent': Color(0xFF4CAF50),
  };

  static const Map<String, double> spacing = {
    'small': 8.0,
    'medium': 16.0,
    'large': 24.0,
    'xlarge': 32.0,
  };

  static const Map<String, double> borderRadius = {
    'small': 8.0,
    'medium': 16.0,
    'large': 24.0,
  };

  static const Map<String, double> fontSize = {
    'small': 14.0,
    'medium': 16.0,
    'large': 20.0,
    'xlarge': 24.0,
  };
}
