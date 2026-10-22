// ============================================================
// FILE: lib/providers/feed_provider.dart
//
// PURPOSE: Manages the feed post list — loading, refreshing,
//          and reacting to posts.
//
// WHY A PROVIDER:
//   The Feed screen, Profile screen, and Post detail all need
//   the same post data. Putting it in a Provider means they all
//   share one list — reacting on the Feed updates the count
//   everywhere automatically.
// ============================================================

import 'package:flutter/material.dart';
import '../services/post_service.dart';

// ── Simplified post model for UI ──────────────────────────────
// We map the API response to this flat structure so screens
// don't need to dig into nested maps.
class FeedPost {
  final String              id;
  final String              authorId;
  final String              authorName;
  final String?             authorAvatarUrl;
  final String              bibleId;
  final String              verseId;
  final String              verseText;
  final String?             caption;
  final String              visibility;
  final Map<String, int>    reactionCounts;
  final String?             viewerReaction;
  final int                 commentCount;
  final DateTime            createdAt;

  const FeedPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.bibleId,
    required this.verseId,
    required this.verseText,
    this.caption,
    required this.visibility,
    required this.reactionCounts,
    this.viewerReaction,
    required this.commentCount,
    required this.createdAt,
  });

  factory FeedPost.fromJson(Map<String, dynamic> j) {
    final author = j['author'] as Map<String, dynamic>? ?? {};
    final raw    = (j['reactionCounts'] as Map?)
            ?.map((k, v) => MapEntry(k.toString(), (v as num).toInt()))
        ?? <String, int>{};
    return FeedPost(
      id:              j['id'] as String,
      authorId:        author['id'] as String? ?? '',
      authorName:      author['displayName'] as String? ?? '',
      authorAvatarUrl: author['avatarUrl'] as String?,
      bibleId:         j['bibleId'] as String? ?? '',
      verseId:         j['verseId'] as String? ?? '',
      verseText:       j['verseText'] as String? ?? '',
      caption:         j['caption'] as String?,
      visibility:      j['visibility'] as String? ?? 'FRIENDS_ONLY',
      reactionCounts:  raw,
      viewerReaction:  j['viewerReaction'] as String?,
      commentCount:    (j['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(
          j['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  int get amenCount  => reactionCounts['AMEN']  ?? 0;
  int get heartCount => reactionCounts['HEART'] ?? 0;
  int get fireCount  => reactionCounts['FIRE']  ?? 0;
  int get prayCount  => reactionCounts['PRAY']  ?? 0;
}

class FeedProvider extends ChangeNotifier {
  final PostService _service;

  FeedProvider({required PostService service}) : _service = service;

  List<FeedPost> _posts      = [];
  bool           _isLoading  = false;
  bool           _hasMore    = true;
  int            _page       = 0;
  String?        _error;

  List<FeedPost> get posts     => _posts;
  bool           get isLoading => _isLoading;
  bool           get hasMore   => _hasMore;
  String?        get error     => _error;

  // ── Load first page ───────────────────────────────────────
  Future<void> loadFeed() async {
    if (_isLoading) return;
    _isLoading = true;
    _error     = null;
    _page      = 0;
    notifyListeners();

    try {
      final data    = await _service.getFeed(page: 0);
      final content = (data['content'] as List? ?? []);
      _posts   = content.map((j) =>
          FeedPost.fromJson(j as Map<String, dynamic>)).toList();
      _hasMore = !(data['last'] as bool? ?? true);
      _page    = 1;
    } catch (e) {
      _error = 'Could not load feed. Pull down to retry.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load next page (infinite scroll) ─────────────────────
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data    = await _service.getFeed(page: _page);
      final content = (data['content'] as List? ?? []);
      _posts.addAll(content.map((j) =>
          FeedPost.fromJson(j as Map<String, dynamic>)));
      _hasMore = !(data['last'] as bool? ?? true);
      _page++;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  // ── React to a post ───────────────────────────────────────
  Future<void> react(String postId, String reactionType) async {
    try {
      await _service.reactToPost(postId, reactionType);
      await loadFeed(); // refresh counts
    } catch (_) {}
  }

  // ── Remove reaction ───────────────────────────────────────
  Future<void> removeReaction(String postId) async {
    try {
      await _service.removeReaction(postId);
      await loadFeed();
    } catch (_) {}
  }
}
