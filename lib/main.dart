// ============================================================
// FILE: lib/main.dart
//
// PURPOSE: App entry point — wires theme, services, providers,
//          and routing all in one place.
//
// AUTH-BASED ROUTING:
//   - App starts → shows loading spinner while checking tokens
//   - Token found + valid → goes straight to /home (skip login)
//   - No token → goes to /welcome (auth flow)
//   - Logout from any screen → back to /welcome
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'navigation/app_router.dart';

// ── Services ──────────────────────────────────────────────────
import 'services/service_locator.dart';

// ── Providers ─────────────────────────────────────────────────
import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';

// ── Screens ───────────────────────────────────────────────────
import 'features/auth/welcome_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/timezone_screen.dart';
import 'navigation/main_shell.dart';
import 'features/profile/settings_screen.dart';
import 'features/friends/friends_screen.dart';
import 'features/profile/other_profile_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/messages/messages_screen.dart';
import 'features/read/bookmarks_screen.dart';
import 'features/wrapped/wrapped_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final locator = ServiceLocator();

  runApp(
    MultiProvider(
      providers: [
        // ── All domain services ────────────────────────────
        ...locator.providers,

        // ── Auth state (watches login/logout) ──────────────
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: locator.auth,
            storage:     locator.storage,
          ),
        ),
        // ── Feed state ──────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => FeedProvider(service: locator.posts),
        ),
      ],
      child: const YahwehApp(),
    ),
  );
}

// ── Root App Widget ───────────────────────────────────────────
class YahwehApp extends StatelessWidget {
  const YahwehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                      'Yahweh',
      debugShowCheckedModeBanner: false,
      theme:                      AppTheme.light,

      // ── Auth-aware home ────────────────────────────────────
      // Instead of a fixed initialRoute, we use 'home' which
      // shows the auth gate — it decides whether to show the
      // welcome screen or the main app based on login state.
      home: const _AuthGate(),

      routes: {
        AppRoutes.welcome:      (context) => const WelcomeScreen(),
        AppRoutes.signup:       (context) => const SignupScreen(),
        AppRoutes.login:        (context) => const LoginScreen(),
        AppRoutes.timezone:     (context) => const TimezoneScreen(),
        AppRoutes.home:         (context) => const MainShell(),
        AppRoutes.settings:     (context) => const SettingsScreen(),
        AppRoutes.friends:      (context) => const FriendsScreen(),
        AppRoutes.otherProfile: (context) => const OtherProfileScreen(),
        AppRoutes.notifications:(context) => const NotificationsScreen(),
        AppRoutes.messages:     (context) => const MessagesScreen(),
        AppRoutes.bookmarks:    (context) => const BookmarksScreen(),
        AppRoutes.wrapped:      (context) => const WrappedScreen(),
      },
    );
  }
}

// ── Auth Gate ─────────────────────────────────────────────────
// Watches AuthProvider state and shows the right screen.
// This replaces the hard-coded initialRoute.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.state) {
      // ── Still checking tokens ──────────────────────────────
      case AuthState.loading:
        return const Scaffold(
          backgroundColor: AppColors.primaryPurple,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.orange,
              strokeWidth: 3,
            ),
          ),
        );

      // ── Logged in → go straight to main app ───────────────
      case AuthState.loggedIn:
        return const MainShell();

      // ── Not logged in → show welcome / auth flow ──────────
      case AuthState.loggedOut:
        return const WelcomeScreen();
    }
  }
}
