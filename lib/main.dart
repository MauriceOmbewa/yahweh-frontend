// ============================================================
// FILE: lib/main.dart
//
// PURPOSE: The entry point of the entire Flutter app.
//
// WHAT THIS FILE DOES:
//   1. Starts the app with runApp()
//   2. Sets up the global theme (colors, fonts) from AppTheme
//   3. Sets up all named routes so the app knows which screen
//      to show when you navigate to a route name
//
// This file should stay SMALL. The heavy work (screens, widgets)
// lives in their own files. main.dart just wires everything up.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Our own files ────────────────────────────────────────────
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

// ── Screens — we import each one so we can map it to a route ─
// Auth
import 'features/auth/welcome_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/timezone_screen.dart';
// Navigation shell (main app)
import 'navigation/main_shell.dart';
// Settings
import 'features/profile/settings_screen.dart';

// main() is the very first function Flutter calls.
void main() {
  // Ensures Flutter is fully initialized before we do anything.
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait mode only (like most phone apps).
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Start the app!
  runApp(const YahwehApp());
}

// ── Root App Widget ───────────────────────────────────────────
class YahwehApp extends StatelessWidget {
  const YahwehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title (shown in task switcher on Android).
      title: 'Yahweh',

      // Hide the red "DEBUG" banner in the top-right corner.
      debugShowCheckedModeBanner: false,

      // Apply our custom theme from AppTheme.
      theme: AppTheme.light,

      // The first screen the app shows.
      // As we build more screens, we'll change this to the
      // welcome screen or the home shell depending on login state.
      initialRoute: AppRoutes.welcome,

      // ── Route Map ──────────────────────────────────────────
      // This is the "directory" of all screens.
      // When you call Navigator.pushNamed(context, AppRoutes.login),
      // Flutter looks it up here and shows LoginScreen.
      //
      // NOTE: We'll add more routes here as we build each phase.
      // For now, only the welcome screen exists.
      routes: {
        AppRoutes.welcome:   (context) => const WelcomeScreen(),
        AppRoutes.signup:    (context) => const SignupScreen(),
        AppRoutes.login:     (context) => const LoginScreen(),
        AppRoutes.timezone:  (context) => const TimezoneScreen(),
        AppRoutes.home:      (context) => const MainShell(),
        AppRoutes.settings:  (context) => const SettingsScreen(),
      },
    );
  }
}
