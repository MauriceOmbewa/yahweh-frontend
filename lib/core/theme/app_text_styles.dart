// ============================================================
// FILE: lib/core/theme/app_text_styles.dart
//
// PURPOSE: Every text style used in the app defined in one place.
//
// HOW TO USE: In any widget, write:
//   Text('Yahweh', style: AppTextStyles.displayBold)
//
// We use TWO font families:
//   - Playfair Display → serif font for big headings (like the
//     "Yahweh" title and verse text in the reader)
//   - Inter → clean sans-serif for all body text, labels, buttons
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display / Hero Text ──────────────────────────────────────
  // The giant "Yahweh" title on the welcome screen.
  static TextStyle get displayBold => GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.white,
        height: 1.1,
      );

  // ── Screen Headings ─────────────────────────────────────────
  // Used for screen titles like "Create account", "Welcome back",
  // "Friends", "Progress", "Settings".
  static TextStyle get headingLarge => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.2,
      );

  // Slightly smaller heading — used for card titles, section names.
  static TextStyle get headingMedium => GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.2,
      );

  // ── Verse Text ───────────────────────────────────────────────
  // The Bible verse text inside cards and the reader.
  // Uses Playfair Display for the "scripture feel".
  static TextStyle get verseText => GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
        height: 1.6,
      );

  // Larger verse text used in the full Bible reader screen.
  static TextStyle get verseLarge => GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
        height: 1.7,
      );

  // ── Body Text ────────────────────────────────────────────────
  // Regular body text — captions, descriptions, chat messages.
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
        height: 1.5,
      );

  // Slightly smaller body text — used for timestamps, subtitles.
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMedium,
        height: 1.4,
      );

  // ── Labels & UI Text ─────────────────────────────────────────
  // Form field labels ("Email", "Password", "Display name").
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      );

  // Small labels — "NIV" translation pill, "2h ago" timestamps.
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMedium,
      );

  // ── Verse Reference ─────────────────────────────────────────
  // "Psalm 23:1–2" — the orange reference label above a verse.
  static TextStyle get verseReference => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.orange,
      );

  // ── Button Text ──────────────────────────────────────────────
  // Text inside the primary (orange) and secondary buttons.
  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  // Button label for outlined/secondary buttons.
  static TextStyle get buttonLabelOutlined => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );

  // ── Input Field Text ─────────────────────────────────────────
  // What the user types into a text field.
  static TextStyle get inputText => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      );

  // Placeholder/hint text inside empty fields.
  static TextStyle get inputHint => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      );

  // ── Navigation Bar ───────────────────────────────────────────
  // Labels under the bottom navigation icons.
  static TextStyle get navLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  // ── Reaction Counts ──────────────────────────────────────────
  // "Amen 24", "Heart 18" counts on feed cards.
  static TextStyle get reactionCount => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMedium,
      );

  // ── Section Headers ──────────────────────────────────────────
  // "Streak buddies", "Requests", "TODAY", "YESTERDAY"
  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  // Upper-case section labels (like "TODAY" on notifications screen)
  static TextStyle get sectionTitleCaps => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.orange,
        letterSpacing: 1.2,
      );

  // ── Streak Number ────────────────────────────────────────────
  // The large "12" in the streak badge on avatars.
  static TextStyle get streakNumber => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
      );

  // The giant streak number on the Progress screen.
  static TextStyle get streakHero => GoogleFonts.inter(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: AppColors.orange,
        height: 1.0,
      );

  // ── Wrapped / Story Slides ───────────────────────────────────
  // The huge stat numbers on weekly wrapped slides ("11", "4.2h")
  static TextStyle get wrappedStat => GoogleFonts.inter(
        fontSize: 80,
        fontWeight: FontWeight.w900,
        color: AppColors.orange,
        height: 1.0,
      );

  // Labels under wrapped stats ("chapters", "with scripture")
  static TextStyle get wrappedLabel => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      );

  // ── Error Text ───────────────────────────────────────────────
  // "Password needs at least 8 characters."
  static TextStyle get errorText => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
      );

  // ── User Name ────────────────────────────────────────────────
  // Display names on posts, notifications, messages.
  static TextStyle get userName => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  // ── Status Verse Card ────────────────────────────────────────
  // "STATUS VERSE" label on the profile card.
  static TextStyle get statusVerseLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.orange,
        letterSpacing: 1.5,
      );
}
