import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color spotifyGreen = Color(0xFF1DB954);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF242424);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color surfaceElevated = Color(0xFF333333);
  static const Color textPrimary = Colors.white;
  static const Color textMuted = Color(0xFFB3B3B3);
  static const Color miniPlayerBg = Color(0xFF2A1616);
  static const Color chipInactive = Color(0xFF2A2A2A);
  static const Color chipActive = Color(0xFF1DB954);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.spotifyGreen,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.figtreeTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: AppColors.background,
        elevation: 0,
      ),
    );
  }
}
