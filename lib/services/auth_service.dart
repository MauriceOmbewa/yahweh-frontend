// ============================================================
// FILE: lib/services/auth_service.dart
// PURPOSE: Register, login, Google sign-in, logout, token refresh.
// ============================================================

import 'api_client.dart';
import 'api_config.dart';
import 'token_storage.dart';

class AuthService {
  final ApiClient      _client;
  final TokenStorage   _storage;

  AuthService({required ApiClient client, required TokenStorage storage})
      : _client  = client,
        _storage = storage;

  // ── Register ──────────────────────────────────────────────
  // Returns the AuthTokenResponse map on success.
  Future<Map<String, dynamic>> register({
    required String email,
    required String displayName,
    required String password,
  }) async {
    final data = await _client.post(
      ApiConfig.register,
      auth: false, // no token needed for registration
      body: {
        'email':       email,
        'displayName': displayName,
        'password':    password,
      },
    ) as Map<String, dynamic>;

    await _saveTokens(data);
    return data;
  }

  // ── Login ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post(
      ApiConfig.login,
      auth: false,
      body: {'email': email, 'password': password},
    ) as Map<String, dynamic>;

    await _saveTokens(data);
    return data;
  }

  // ── Google Sign-In ────────────────────────────────────────
  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    final data = await _client.post(
      ApiConfig.googleSignIn,
      auth: false,
      body: {'idToken': idToken},
    ) as Map<String, dynamic>;

    await _saveTokens(data);
    return data;
  }

  // ── Get current user (/auth/me) ───────────────────────────
  Future<Map<String, dynamic>> getMe() async {
    return await _client.get(ApiConfig.me) as Map<String, dynamic>;
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.refreshToken;
      if (refreshToken != null) {
        await _client.post(
          ApiConfig.logout,
          body: {'refreshToken': refreshToken},
        );
      }
    } finally {
      await _storage.clear();
    }
  }

  // ── Forgot password ───────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    await _client.post(
      ApiConfig.forgotPassword,
      auth: false,
      body: {'email': email},
    );
  }

  // ── Reset password ────────────────────────────────────────
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _client.post(
      ApiConfig.resetPassword,
      auth: false,
      body: {'token': token, 'newPassword': newPassword},
    );
  }

  // ── Helper: save tokens + user ID from auth response ──────
  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final user = data['user'] as Map<String, dynamic>;
    await _storage.saveTokens(
      accessToken:  data['accessToken']  as String,
      refreshToken: data['refreshToken'] as String,
      userId:       user['id']           as String,
    );
  }
}
