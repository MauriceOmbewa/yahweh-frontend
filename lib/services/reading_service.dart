// ============================================================
// FILE: lib/services/reading_service.dart
// PURPOSE: Reading progress, sessions, goals, streaks, stats.
// ============================================================

import 'api_client.dart';
import 'api_config.dart';

class ReadingService {
  final ApiClient _client;
  ReadingService({required ApiClient client}) : _client = client;

  // ── Reading progress ──────────────────────────────────────
  Future<void> markChapterRead(String bibleId, String chapterId) async {
    await _client.post(ApiConfig.markChapterRead(bibleId, chapterId));
  }

  Future<List<dynamic>> getAllProgress() async {
    final data = await _client.get(ApiConfig.getAllProgress);
    if (data is Map) return (data['content'] as List?) ?? [];
    return data is List ? data : [];
  }

  Future<int> getProgressCount() async {
    final data = await _client.get(ApiConfig.getProgressCount);
    if (data is int) return data;
    if (data is Map) return (data['count'] as int?) ?? 0;
    return 0;
  }

  Future<Map<String, dynamic>?> getChapterStatus(
      String bibleId, String chapterId) async {
    try {
      return await _client.get(ApiConfig.chapterStatus(bibleId, chapterId))
          as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ── Reading sessions ──────────────────────────────────────
  Future<Map<String, dynamic>> startSession({
    required String bibleId,
    required String chapterId,
  }) async {
    return await _client.post(ApiConfig.startSession, body: {
      'bibleId':   bibleId,
      'chapterId': chapterId,
    }) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> endSession({
    required String sessionId,
    required int durationSeconds,
  }) async {
    return await _client.post(ApiConfig.endSession, body: {
      'sessionId':        sessionId,
      'durationSeconds':  durationSeconds,
    }) as Map<String, dynamic>;
  }

  // ── Reading goal ──────────────────────────────────────────
  Future<Map<String, dynamic>> getGoal() async {
    return await _client.get(ApiConfig.getGoal) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateGoal(int dailyMinutes) async {
    return await _client.put(ApiConfig.updateGoal,
        body: {'dailyGoalMinutes': dailyMinutes}) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTodayGoalProgress() async {
    return await _client.get(ApiConfig.goalProgressToday)
        as Map<String, dynamic>;
  }

  // ── Reading streak ────────────────────────────────────────
  Future<Map<String, dynamic>> getStreak() async {
    return await _client.get(ApiConfig.getStreak) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getStreakCalendar() async {
    final data = await _client.get(ApiConfig.streakCalendar);
    return data is List ? data : [];
  }

  // ── Reading statistics ────────────────────────────────────
  Future<Map<String, dynamic>> getStats() async {
    return await _client.get(ApiConfig.getStats) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getActivityByHour() async {
    final data = await _client.get(ApiConfig.activityByHour);
    return data is List ? data : [];
  }

  Future<List<dynamic>> getWeeklyActivityByHour() async {
    final data = await _client.get(ApiConfig.weeklyActivityByHour);
    return data is List ? data : [];
  }
}
