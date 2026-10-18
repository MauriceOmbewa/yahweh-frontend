// ============================================================
// FILE: lib/models/app_notification.dart
//
// PURPOSE: Defines what a notification looks like.
//
// Note: We name this file 'app_notification.dart' (not
// 'notification.dart') to avoid conflicting with Flutter's
// own internal Notification class.
// ============================================================

// ── Notification Type Enum ───────────────────────────────────
// All the different kinds of notifications shown in the designs.
enum NotificationType {
  reaction,        // "Amina reacted Amen to your post"
  nudge,           // "Joel nudged you: keep your 9 day streak alive"
  friendAccepted,  // "Sam accepted your friend request"
  friendRequest,   // Someone sent you a friend request
  comment,         // "Tabitha commented on your post"
  streakMilestone, // "Amina hit a 7 day streak"
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String fromUserName;      // e.g. "Amina"
  final String fromUserInitials;  // e.g. "AN"
  final int fromUserStreak;       // For the streak badge on their avatar
  final String message;           // Full notification text
  final DateTime receivedAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.fromUserName,
    required this.fromUserInitials,
    required this.fromUserStreak,
    required this.message,
    required this.receivedAt,
    this.isRead = false,
  });

  // ── Computed: Time Ago ───────────────────────────────────────
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(receivedAt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24)   return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  // ── Computed: Is Today ───────────────────────────────────────
  /// Used to group notifications into "TODAY" and "YESTERDAY" sections.
  bool get isToday {
    final now = DateTime.now();
    return receivedAt.day == now.day &&
        receivedAt.month == now.month &&
        receivedAt.year == now.year;
  }
}
