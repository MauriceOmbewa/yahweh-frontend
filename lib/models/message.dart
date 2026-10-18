// ============================================================
// FILE: lib/models/message.dart
//
// PURPOSE: Defines a chat message and a conversation thread.
//
// Two models live here:
//   - Message: a single chat bubble
//   - Conversation: the thread shown in the Messages list screen
// ============================================================

import 'bible_verse.dart';

// ── Message Type ─────────────────────────────────────────────
enum MessageType {
  text,        // A regular text bubble
  verseShare,  // A shared Bible verse (renders as a verse card in chat)
  nudge,       // System message: "You nudged Amina to keep the streak alive"
}

class Message {
  final String id;
  final String senderId;      // User ID of who sent it
  final MessageType type;
  final String? text;         // Used when type is 'text'
  final BibleVerse? verse;    // Used when type is 'verseShare'
  final DateTime sentAt;
  final bool isFromMe;        // true = right-aligned dark bubble, false = left

  const Message({
    required this.id,
    required this.senderId,
    required this.type,
    required this.sentAt,
    required this.isFromMe,
    this.text,
    this.verse,
  });
}

// ── Conversation ─────────────────────────────────────────────
// Represents one row in the Messages list screen.
class Conversation {
  final String id;
  final String otherUserName;
  final String otherUserInitials;
  final int otherUserStreak;
  final String lastMessagePreview;  // Short snippet of last message
  final DateTime lastMessageAt;
  final bool hasUnread;             // Orange dot indicator
  final bool isStreakBuddy;
  final int sharedStreakDays;       // "12 days together"
  final List<Message> messages;

  const Conversation({
    required this.id,
    required this.otherUserName,
    required this.otherUserInitials,
    required this.otherUserStreak,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.messages,
    this.hasUnread = false,
    this.isStreakBuddy = false,
    this.sharedStreakDays = 0,
  });

  /// Formatted time string for the conversation list.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24)   return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
