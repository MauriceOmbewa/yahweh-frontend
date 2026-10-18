// ============================================================
// FILE: lib/core/constants/app_constants.dart
//
// PURPOSE: Stores magic numbers, fixed strings, and durations
//          that are used across the app.
//
// WHY THIS MATTERS: Instead of writing 16.0 or 24.0 everywhere,
// you write AppConstants.paddingMd. When the design changes,
// you update one value and every screen adapts.
// ============================================================

class AppConstants {
  AppConstants._();

  // ── App Info ─────────────────────────────────────────────────
  static const String appName    = 'Yahweh';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Read together. Grow together.';

  // ── Spacing / Padding ────────────────────────────────────────
  // These are the standard spacing values from the designs.
  // Use these instead of arbitrary numbers.
  static const double paddingXs  = 4.0;
  static const double paddingSm  = 8.0;
  static const double paddingMd  = 16.0;
  static const double paddingLg  = 24.0;
  static const double paddingXl  = 32.0;
  static const double paddingXxl = 48.0;

  // ── Border Radius ────────────────────────────────────────────
  static const double radiusSm  = 8.0;
  static const double radiusMd  = 14.0;
  static const double radiusLg  = 20.0;
  static const double radiusXl  = 28.0;
  static const double radiusFull = 999.0; // Fully rounded (pill shape)

  // ── Button Sizes ─────────────────────────────────────────────
  static const double buttonHeight  = 56.0;
  static const double buttonHeightSm = 44.0;

  // ── Avatar Sizes ─────────────────────────────────────────────
  static const double avatarSm  = 36.0;  // In story circles row
  static const double avatarMd  = 48.0;  // In feed cards
  static const double avatarLg  = 56.0;  // In messages list
  static const double avatarXl  = 88.0;  // On profile screen

  // ── Bottom Nav ───────────────────────────────────────────────
  static const double bottomNavHeight   = 72.0;
  static const double bottomNavFabSize  = 56.0;

  // ── Reading ──────────────────────────────────────────────────
  // Default daily reading goal in minutes.
  static const int defaultDailyGoalMinutes = 25;

  // Maximum caption length for verse posts.
  static const int maxCaptionLength = 500;

  // ── Bible Translations ───────────────────────────────────────
  // The translation options shown in the reader.
  static const List<String> bibleTranslations = [
    'NIV',
    'ESV',
    'KJV',
    'NLT',
    'NKJV',
  ];

  // ── Timezone Options ─────────────────────────────────────────
  // Shown on the timezone selection screen during onboarding.
  static const List<Map<String, String>> timezones = [
    {'city': 'Nairobi',  'offset': 'UTC+3'},
    {'city': 'Lagos',    'offset': 'UTC+1'},
    {'city': 'London',   'offset': 'UTC+0'},
    {'city': 'New York', 'offset': 'UTC-5'},
  ];

  // ── Animation Durations ──────────────────────────────────────
  static const Duration animFast   = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow   = Duration(milliseconds: 500);
}
