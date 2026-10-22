// ============================================================
// FILE: lib/services/post_service.dart
// PURPOSE: Feed posts — create, fetch, react, comment.
// ============================================================

import 'api_client.dart';
import 'api_config.dart';

class PostService {
  final ApiClient _client;
  PostService({required ApiClient client}) : _client = client;

  // ── Get feed (paginated) ──────────────────────────────────
  Future<Map<String, dynamic>> getFeed({int page = 0, int size = 20}) async {
    return await _client.get(ApiConfig.getFeed,
        queryParams: {'page': '$page', 'size': '$size'})
        as Map<String, dynamic>;
  }

  // ── Create a post ─────────────────────────────────────────
  Future<Map<String, dynamic>> createPost({
    required String bibleId,
    required String verseId,
    required String verseText,
    String? caption,
    String visibility = 'FRIENDS_ONLY',
  }) async {
    return await _client.post(ApiConfig.createPost, body: {
      'bibleId':    bibleId,
      'verseId':    verseId,
      'verseText':  verseText,
      if (caption != null) 'caption': caption,
      'visibility': visibility,
    }) as Map<String, dynamic>;
  }

  // ── Delete a post ─────────────────────────────────────────
  Future<void> deletePost(String postId) async {
    await _client.delete(ApiConfig.deletePost(postId));
  }

  // ── React to a post ───────────────────────────────────────
  // reactionType: "AMEN" | "HEART" | "FIRE" | "PRAY"
  Future<void> reactToPost(String postId, String reactionType) async {
    await _client.post(
      ApiConfig.reactToPost(postId),
      body: {'reactionType': reactionType},
    );
  }

  // ── Remove reaction ───────────────────────────────────────
  Future<void> removeReaction(String postId) async {
    await _client.delete(ApiConfig.removeReaction(postId));
  }

  // ── Add comment ───────────────────────────────────────────
  Future<Map<String, dynamic>> addComment(
      String postId, String content) async {
    return await _client.post(
      ApiConfig.addComment(postId),
      body: {'content': content},
    ) as Map<String, dynamic>;
  }

  // ── Get comments ──────────────────────────────────────────
  Future<List<dynamic>> getComments(String postId,
      {int page = 0, int size = 20}) async {
    final data = await _client.get(
      ApiConfig.getComments(postId),
      queryParams: {'page': '$page', 'size': '$size'},
    );
    if (data is Map) return (data['content'] as List?) ?? [];
    return data is List ? data : [];
  }

  // ── Get a user's posts ────────────────────────────────────
  Future<Map<String, dynamic>> getUserPosts(String userId,
      {int page = 0, int size = 20}) async {
    return await _client.get(
      ApiConfig.getUserPosts(userId),
      queryParams: {'page': '$page', 'size': '$size'},
    ) as Map<String, dynamic>;
  }
}
