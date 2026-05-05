// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8F65);
  static const Color primaryDark = Color(0xFFE04E1A);
  static const Color secondary = Color(0xFF2EC4B6);
  static const Color accent = Color(0xFFFFBF69);
  static const Color error = Color(0xFFE63946);

  static const Color surfaceLight = Color(0xFFFAF9F6);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B8A);
  static const Color divider = Color(0xFFEEEEF2);

  // Dark
  static const Color surfaceDark = Color(0xFF0F0F1A);
  static const Color cardDark = Color(0xFF1E1E2E);
  static const Color textPrimaryDark = Color(0xFFF8F8FF);
  static const Color textSecondaryDark = Color(0xFF9898B0);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      surface: surfaceLight,
      error: error,
    ),
    scaffoldBackgroundColor: surfaceLight,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 15,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 13,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardLight,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: divider,
      selectedColor: primary.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.poppins(fontSize: 13),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      hintStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
    ),
  );
}
