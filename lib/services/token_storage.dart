// ============================================================
// FILE: lib/services/token_storage.dart
//
// PURPOSE: Persists JWT tokens and current user ID on the device
//          using shared_preferences (survives app restarts).
//
// HOW TO USE:
//   final storage = TokenStorage();
//   await storage.saveTokens(accessToken: '...', refreshToken: '...');
//   final token = await storage.accessToken;
//   await storage.clear(); // on logout
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  // Preference keys
  static const _keyAccess   = 'jwt_access';
  static const _keyRefresh  = 'jwt_refresh';
  static const _keyUserId   = 'user_id';

  // ── Save tokens after login / register ────────────────────
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccess,  accessToken);
    await prefs.setString(_keyRefresh, refreshToken);
    await prefs.setString(_keyUserId,  userId);
  }

  // ── Read access token ─────────────────────────────────────
  Future<String?> get accessToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccess);
  }

  // ── Read refresh token ────────────────────────────────────
  Future<String?> get refreshToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefresh);
  }

  // ── Read current user ID ──────────────────────────────────
  Future<String?> get userId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // ── Update access token after a refresh ───────────────────
  Future<void> updateAccessToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccess, newToken);
  }

  // ── Clear everything on logout ────────────────────────────
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccess);
    await prefs.remove(_keyRefresh);
    await prefs.remove(_keyUserId);
  }

  // ── Are we logged in? ─────────────────────────────────────
  Future<bool> get isLoggedIn async {
    final token = await accessToken;
    return token != null && token.isNotEmpty;
  }
}
