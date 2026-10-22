// ============================================================
// FILE: lib/services/bookmark_service.dart
// PURPOSE: Verse bookmarks + bookmark collections.
// ============================================================

import 'api_client.dart';
import 'api_config.dart';

class BookmarkService {
  final ApiClient _client;
  BookmarkService({required ApiClient client}) : _client = client;

  // ── Verse bookmarks ───────────────────────────────────────
  Future<Map<String, dynamic>> saveBookmark({
    required String bibleId,
    required String verseId,
    String? note,
    String? highlightColor,
  }) async {
    return await _client.post(
      ApiConfig.saveBookmark(bibleId, verseId),
      body: {
        if (note           != null) 'note':           note,
        if (highlightColor != null) 'highlightColor': highlightColor,
      },
    ) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getBookmarks({int page = 0, int size = 50}) async {
    final data = await _client.get(ApiConfig.getBookmarks,
        queryParams: {'page': '$page', 'size': '$size'});
    if (data is Map) return (data['content'] as List?) ?? [];
    return data is List ? data : [];
  }

  Future<void> deleteBookmark(String bibleId, String verseId) async {
    await _client.delete(ApiConfig.deleteBookmark(bibleId, verseId));
  }

  // ── Collections ───────────────────────────────────────────
  Future<Map<String, dynamic>> createCollection(String name) async {
    return await _client.post(ApiConfig.createCollection,
        body: {'name': name}) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getCollections() async {
    final data = await _client.get(ApiConfig.getCollections);
    if (data is Map) return (data['content'] as List?) ?? [];
    return data is List ? data : [];
  }

  Future<void> updateCollection(String id, String name) async {
    await _client.put(ApiConfig.updateCollection(id), body: {'name': name});
  }

  Future<void> deleteCollection(String id) async {
    await _client.delete(ApiConfig.deleteCollection(id));
  }

  Future<void> addVerseToCollection(String collectionId,
      String verseBookmarkId) async {
    await _client.post(
      ApiConfig.addVerseToCollection(collectionId),
      body: {'verseBookmarkId': verseBookmarkId},
    );
  }

  Future<List<dynamic>> getCollectionVerses(String collectionId) async {
    final data = await _client.get(ApiConfig.getCollectionVerses(collectionId));
    if (data is Map) return (data['content'] as List?) ?? [];
    return data is List ? data : [];
  }

  Future<void> removeVerseFromCollection(
      String collectionId, String verseBookmarkId) async {
    await _client.delete(
        ApiConfig.removeVerseFromCollection(collectionId, verseBookmarkId));
  }
}
