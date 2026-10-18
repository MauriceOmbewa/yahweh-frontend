// ============================================================
// FILE: lib/navigation/app_router.dart
//
// PURPOSE: One place that lists EVERY screen name and how to
//          navigate to it.
//
// HOW NAVIGATION WORKS IN FLUTTER:
//   - Every screen has a "route name" — like a URL path
//   - To go to a screen: Navigator.pushNamed(context, AppRoutes.login)
//   - To go back:        Navigator.pop(context)
//
// Having all route names here means you never mistype a route
// name — you just use the constant: AppRoutes.login instead
// of the string '/login'.
// ============================================================

// ── Route Name Constants ──────────────────────────────────────
// These are the "addresses" of each screen.
class AppRoutes {
  AppRoutes._();

  // ── Auth Flow ────────────────────────────────────────────────
  static const String welcome   = '/';           // Splash / welcome screen
  static const String signup    = '/signup';     // Create account
  static const String login     = '/login';      // Log in
  static const String timezone  = '/timezone';   // Timezone picker (after signup)

  // ── Main App Shell ───────────────────────────────────────────
  // This is the screen that holds the bottom navigation bar.
  // All tab screens (feed, read, progress, profile) live inside it.
  static const String home      = '/home';

  // ── Read Tab ─────────────────────────────────────────────────
  static const String chapter   = '/chapter';   // Bible reader (single chapter)
  static const String bookmarks = '/bookmarks'; // Bookmarks + Collections

  // ── Social ───────────────────────────────────────────────────
  static const String friends        = '/friends';
  static const String notifications  = '/notifications';
  static const String messages       = '/messages';
  static const String chat           = '/chat';        // Single conversation

  // ── Profile ──────────────────────────────────────────────────
  static const String profile        = '/profile';       // Own profile
  static const String otherProfile   = '/other-profile'; // Someone else's profile
  static const String settings       = '/settings';

  // ── Share ────────────────────────────────────────────────────
  // This is opened as a bottom sheet (modal), not a full route,
  // but having the name here keeps things organised.
  static const String shareVerse = '/share-verse';

  // ── Weekly Wrapped ───────────────────────────────────────────
  static const String wrapped = '/wrapped';
}
