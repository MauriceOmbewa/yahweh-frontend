// ============================================================
// FILE: lib/core/theme/app_theme.dart
//
// PURPOSE: Builds the ThemeData object that MaterialApp uses.
//          This sets defaults for every widget in the whole app —
//          so buttons, inputs, cards, and app bars all look right
//          without any extra styling in each widget.
//
// HOW TO USE:
//   MaterialApp(
//     theme: AppTheme.light,
//     ...
//   )
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// The main light theme used throughout the app.
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ── Scaffold (page) background ──────────────────────────
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // ── Color Scheme ────────────────────────────────────────
      // This seeds colors for buttons, checkboxes, chips, etc.
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        brightness: Brightness.light,
        primary: AppColors.primaryPurple,
        secondary: AppColors.orange,
        surface: AppColors.white,
        error: AppColors.error,
      ),

      // ── Default Text Theme ──────────────────────────────────
      // Sets Inter as the base font for all Material text widgets.
      textTheme: GoogleFonts.interTextTheme(),

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textDark,
        elevation: 0,          // No shadow under the app bar
        centerTitle: false,    // Title aligned to the left
        scrolledUnderElevation: 0, // No shadow when scrolling
      ),

      // ── Cards ────────────────────────────────────────────────
      // Default style for Card widgets — white, rounded, no shadow.
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Elevated Buttons ─────────────────────────────────────
      // We use our custom AppButton widget instead of ElevatedButton
      // directly, but this sets the fallback style just in case.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // ── Input Fields ─────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none, // No border by default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Bottom Navigation Bar ────────────────────────────────
      // This is a fallback. Our custom BottomNavBar widget handles
      // most of the styling itself.
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.textMedium,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
