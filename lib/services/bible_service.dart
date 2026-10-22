// ============================================================
// FILE: lib/services/bible_service.dart
// PURPOSE: Proxy to API.Bible — list bibles, fetch passages, search.
// ============================================================

import 'api_client.dart';
import 'api_config.dart';

class BibleService {
  final ApiClient _client;
  BibleService({required ApiClient client}) : _client = client;

  // ── List available Bibles ─────────────────────────────────
  Future<List<dynamic>> getBibles() async {
    final data = await _client.get(ApiConfig.getBibles);
    if (data is Map) return (data['data'] as List?) ?? [];
    return data is List ? data : [];
  }

  // ── Get a passage (book + chapter) ───────────────────────
  // passageId format: "GEN.1" for Genesis chapter 1
  Future<Map<String, dynamic>> getPassage(
    String bibleId,
    String passageId, {
    bool contentType   = true,
    bool includeNotes  = false,
    bool includeTitles = true,
  }) async {
    return await _client.get(
      ApiConfig.getPassage(bibleId, passageId),
      queryParams: {
        'content-type':    'text',
        'include-notes':   '$includeNotes',
        'include-titles':  '$includeTitles',
      },
    ) as Map<String, dynamic>;
  }

  // ── Search within a Bible ─────────────────────────────────
  Future<Map<String, dynamic>> search(
    String bibleId,
    String query, {
    int limit = 10,
  }) async {
    return await _client.get(
      ApiConfig.searchBible(bibleId),
      queryParams: {'query': query, 'limit': '$limit'},
    ) as Map<String, dynamic>;
  }
}
