// ============================================================
// FILE: lib/services/user_service.dart
// PURPOSE: User profile, timezone, status verse, search.
// ============================================================

import 'api_client.dart';
import 'api_config.dart';

class UserService {
  final ApiClient _client;
  UserService({required ApiClient client}) : _client = client;

  // ── Update own profile ────────────────────────────────────
  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    return await _client.put(ApiConfig.updateMe, body: {
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl   != null) 'avatarUrl':   avatarUrl,
    }) as Map<String, dynamic>;
  }

  // ── Update timezone ───────────────────────────────────────
  Future<void> updateTimezone(String timezone) async {
    await _client.put(ApiConfig.updateTimezone,
        body: {'timezone': timezone});
  }

  // ── Set status verse ──────────────────────────────────────
  Future<void> setStatusVerse({
    required String bibleId,
    required String verseId,
    required String verseText,
    String? caption,
  }) async {
    await _client.put(ApiConfig.updateStatus, body: {
      'bibleId':  bibleId,
      'verseId':  verseId,
      'verseText': verseText,
      if (caption != null) 'caption': caption,
    });
  }

  // ── Clear status verse ────────────────────────────────────
  Future<void> clearStatusVerse() async {
    await _client.delete(ApiConfig.deleteStatus);
  }

  // ── Get another user's profile ────────────────────────────
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return await _client.get(ApiConfig.userProfile(userId))
        as Map<String, dynamic>;
  }

  // ── Search users ──────────────────────────────────────────
  Future<List<dynamic>> searchUsers(String query) async {
    final data = await _client.get(ApiConfig.searchUsers,
        queryParams: {'q': query});
    if (data is List) return data;
    if (data is Map) return (data['content'] as List?) ?? [];
    return [];
  }
}
