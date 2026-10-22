// ============================================================
// FILE: lib/providers/auth_provider.dart
//
// PURPOSE: Manages the authentication state for the whole app.
//
// THIS IS THE MOST IMPORTANT PROVIDER.
// It answers: "Is the user logged in? Who are they?"
//
// STATES:
//   loading  → checking stored tokens on app start
//   loggedIn → user is authenticated, _user is populated
//   loggedOut → no tokens / tokens expired
//
// HOW SCREENS USE IT:
//   final auth = context.watch<AuthProvider>();
//   if (auth.isLoggedIn) { ... }
//   await auth.login(email, password);
//   await auth.logout();
// ============================================================

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/token_storage.dart';

// ── Authentication state enum ─────────────────────────────────
enum AuthState { loading, loggedIn, loggedOut }

class AuthProvider extends ChangeNotifier {
  final AuthService    _authService;
  final TokenStorage   _storage;

  AuthState          _state = AuthState.loading;
  Map<String, dynamic>? _user;
  String?            _error;

  AuthProvider({
    required AuthService authService,
    required TokenStorage storage,
  })  : _authService = authService,
        _storage     = storage {
    // Check tokens immediately when the provider is created
    _checkAuthState();
  }

  // ── Getters ───────────────────────────────────────────────
  AuthState            get state     => _state;
  bool                 get isLoading => _state == AuthState.loading;
  bool                 get isLoggedIn => _state == AuthState.loggedIn;
  Map<String, dynamic>? get user     => _user;
  String?              get error     => _error;

  // Convenience getters for common user fields
  String get displayName => _user?['displayName'] as String? ?? '';
  String get userId      => _user?['id']          as String? ?? '';
  String get email       => _user?['email']        as String? ?? '';

  // ── Check stored tokens on app start ─────────────────────
  Future<void> _checkAuthState() async {
    final loggedIn = await _storage.isLoggedIn;
    if (loggedIn) {
      try {
        // Verify the token is still valid by fetching current user
        _user  = await _authService.getMe();
        _state = AuthState.loggedIn;
      } catch (_) {
        // Token expired or invalid — log out
        await _storage.clear();
        _state = AuthState.loggedOut;
      }
    } else {
      _state = AuthState.loggedOut;
    }
    notifyListeners();
  }

  // ── Register ──────────────────────────────────────────────
  Future<bool> register({
    required String email,
    required String displayName,
    required String password,
  }) async {
    _error = null;
    try {
      final data = await _authService.register(
        email:       email,
        displayName: displayName,
        password:    password,
      );
      _user  = data['user'] as Map<String, dynamic>;
      _state = AuthState.loggedIn;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = _extractMessage(e);
      notifyListeners();
      return false;
    }
  }

  // ── Login ─────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _error = null;
    try {
      final data = await _authService.login(
          email: email, password: password);
      _user  = data['user'] as Map<String, dynamic>;
      _state = AuthState.loggedIn;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = _extractMessage(e);
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    _user  = null;
    _state = AuthState.loggedOut;
    notifyListeners();
  }

  // ── Update local user data (e.g. after profile edit) ──────
  void updateUser(Map<String, dynamic> updated) {
    _user = {...?_user, ...updated};
    notifyListeners();
  }

  // ── Extract human-readable message from exception ────────
  String _extractMessage(Exception e) {
    final msg = e.toString();
    // Strip "Exception: " prefix if present
    if (msg.startsWith('Exception: ')) return msg.substring(11);
    // Extract message from ApiException format
    final match = RegExp(r'ApiException\(\d+\): (.+)').firstMatch(msg);
    return match?.group(1) ?? 'Something went wrong. Please try again.';
  }
}
