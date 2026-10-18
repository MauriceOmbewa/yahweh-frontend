// ============================================================
// FILE: lib/models/post.dart
//
// PURPOSE: Defines what a feed post looks like.
//
// A Post is what appears on the Feed screen — it's when a user
// shares a Bible verse with an optional caption and reactions.
//
// It CONTAINS a BibleVerse (the verse they shared) and a User
// (the person who posted it).
// ============================================================

import 'user.dart';
import 'bible_verse.dart';

// ── Visibility Enum ──────────────────────────────────────────
// An enum is a fixed list of options. PostVisibility can only
// ever be 'friendsOnly' or 'public' — nothing else.
enum PostVisibility { friendsOnly, public }

class Post {
  final String id;              // Unique post ID
  final User author;            // The person who made this post
  final BibleVerse verse;       // The verse they shared
  final String? caption;        // Optional text they added
  final DateTime postedAt;      // When it was posted
  final PostVisibility visibility;

  // ── Reaction counts ──────────────────────────────────────────
  // Each reaction type has its own count.
  final int amenCount;
  final int heartCount;
  final int fireCount;
  final int prayCount;
  final int commentCount;

  const Post({
    required this.id,
    required this.author,
    required this.verse,
    required this.postedAt,
    required this.visibility,
    this.caption,
    this.amenCount    = 0,
    this.heartCount   = 0,
    this.fireCount    = 0,
    this.prayCount    = 0,
    this.commentCount = 0,
  });

  // ── Computed: Time Ago String ────────────────────────────────
  /// Returns a human-readable "2h ago", "1d ago", "5m ago" string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(postedAt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
