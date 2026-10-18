// ============================================================
// FILE: lib/models/user.dart
//
// PURPOSE: Defines what a "User" looks like in this app.
//
// THINK OF MODELS LIKE BLUEPRINTS: Just like a house blueprint
// says "a house has 3 bedrooms, 2 bathrooms, a kitchen", this
// model says "a User has an id, a name, an email, a streak..."
//
// Every user object in the app is created from this blueprint.
// ============================================================

class User {
  // ── Properties ───────────────────────────────────────────────
  final String id;             // Unique identifier, e.g. "user_001"
  final String displayName;    // How others see them, e.g. "Amina Njeri"
  final String email;          // e.g. "amina@example.com"
  final String initials;       // First letters of name, e.g. "AN"
  final int currentStreak;     // Days in a row they've read
  final int longestStreak;     // Their all-time best streak
  final int chaptersRead;      // Total chapters read ever
  final String timezone;       // e.g. "Nairobi"
  final String? statusVerse;   // The verse they've set on their profile (optional)
  final String? statusVerseRef;// e.g. "Psalm 23:1 · NIV" (optional)
  final DateTime joinedAt;     // When they created their account
  final bool hasReadToday;     // Did they read today? (used for streak buddy status)

  // ── Constructor ──────────────────────────────────────────────
  // 'required' means you MUST pass this value when creating a User.
  // A value with '?' can be null (left out).
  const User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.initials,
    required this.currentStreak,
    required this.longestStreak,
    required this.chaptersRead,
    required this.timezone,
    required this.joinedAt,
    required this.hasReadToday,
    this.statusVerse,
    this.statusVerseRef,
  });

  // ── copyWith ─────────────────────────────────────────────────
  // This lets you create a copy of a user with ONE field changed.
  // e.g. user.copyWith(currentStreak: 13)
  // Without this, you'd have to re-type every field just to
  // change the streak number.
  User copyWith({
    String? id,
    String? displayName,
    String? email,
    String? initials,
    int? currentStreak,
    int? longestStreak,
    int? chaptersRead,
    String? timezone,
    DateTime? joinedAt,
    bool? hasReadToday,
    String? statusVerse,
    String? statusVerseRef,
  }) {
    return User(
      id:              id              ?? this.id,
      displayName:     displayName     ?? this.displayName,
      email:           email           ?? this.email,
      initials:        initials        ?? this.initials,
      currentStreak:   currentStreak   ?? this.currentStreak,
      longestStreak:   longestStreak   ?? this.longestStreak,
      chaptersRead:    chaptersRead    ?? this.chaptersRead,
      timezone:        timezone        ?? this.timezone,
      joinedAt:        joinedAt        ?? this.joinedAt,
      hasReadToday:    hasReadToday    ?? this.hasReadToday,
      statusVerse:     statusVerse     ?? this.statusVerse,
      statusVerseRef:  statusVerseRef  ?? this.statusVerseRef,
    );
  }
}
