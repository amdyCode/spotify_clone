import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_clone/utils/app_colors.dart';

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
