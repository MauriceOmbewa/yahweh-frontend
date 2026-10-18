// ============================================================
// FILE: lib/core/theme/app_colors.dart
//
// PURPOSE: Every single color used in the Yahweh app lives here.
//
// HOW TO USE: Instead of writing Color(0xFF5B35A8) in your widgets,
// you write AppColors.primaryPurple — it's readable and if the
// design changes, you only update it in one place.
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  // Private constructor — this class should never be instantiated.
  // You only ever use it like: AppColors.primaryPurple
  AppColors._();

  // ── Primary Brand Colors ─────────────────────────────────────
  // The deep purple used on the welcome screen background,
  // app bar text, headings, and primary text.
  static const Color primaryPurple = Color(0xFF2D1B69);

  // A slightly lighter purple used on cards, stat boxes, and
  // the status verse card background.
  static const Color deepPurple = Color(0xFF3D2B82);

  // The warm orange used for: primary buttons, streak flames,
  // verse reference text, active icons, and accent highlights.
  static const Color orange = Color(0xFFF29A38);

  // A darker shade of orange for button text and pressed states.
  static const Color orangeDark = Color(0xFFD4851E);

  // ── Background Colors ────────────────────────────────────────
  // The very light lavender used as the scaffold (page) background
  // on all light screens (auth, feed, profile, etc.)
  static const Color backgroundLight = Color(0xFFF5F1FC);

  // Pure white — used for cards, input fields, bottom sheets.
  static const Color white = Color(0xFFFFFFFF);

  // The dark navy/black used on dark screens (notifications,
  // reader dark mode, wrapped slides).
  static const Color backgroundDark = Color(0xFF0F0F1A);

  // A slightly lighter dark surface for cards on dark screens.
  static const Color surfaceDark = Color(0xFF1A1A2E);

  // ── Text Colors ──────────────────────────────────────────────
  // Main text on light backgrounds (headings, body text).
  static const Color textDark = Color(0xFF1A1033);

  // Secondary text — lighter, used for timestamps, captions,
  // placeholder text.
  static const Color textMedium = Color(0xFF6B6B8A);

  // Subtle/disabled text — used for "0/500" character count,
  // locked stats labels.
  static const Color textLight = Color(0xFFAAAAAA);

  // Main text on dark backgrounds (notifications screen, wrapped).
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Input Field Colors ───────────────────────────────────────
  // The soft lavender fill of text input boxes.
  static const Color inputFill = Color(0xFFEDE8F8);

  // The border color of a focused/selected input or list item.
  static const Color inputBorder = Color(0xFF5B35A8);

  // ── Reaction / Status Colors ─────────────────────────────────
  // Used for the "streak at risk" warning text.
  static const Color streakRisk = Color(0xFFE05C2C);

  // Used for "streak safe" — both read today.
  static const Color streakSafe = Color(0xFFF29A38);

  // Red used for error messages (e.g. "Password needs 8 characters").
  static const Color error = Color(0xFFD32F2F);

  // The color of the left border on verse quote blocks in cards.
  static const Color verseBorder = Color(0xFFF29A38);

  // ── Divider / Border ─────────────────────────────────────────
  static const Color divider = Color(0xFFE8E3F0);

  // ── Highlight Colors (for verse highlighting) ────────────────
  // These 6 colors appear as circles in the verse context menu.
  static const Color highlightYellow  = Color(0xFFFFF176);
  static const Color highlightGreen   = Color(0xFFA5D6A7);
  static const Color highlightBlue    = Color(0xFF90CAF9);
  static const Color highlightPink    = Color(0xFFF48FB1);
  static const Color highlightPurple  = Color(0xFFCE93D8);
  static const Color highlightOrange  = Color(0xFFFFCC80);

  // Convenience list — used to render the row of circles.
  static const List<Color> highlightColors = [
    highlightYellow,
    highlightGreen,
    highlightBlue,
    highlightPink,
    highlightPurple,
    highlightOrange,
  ];
}
