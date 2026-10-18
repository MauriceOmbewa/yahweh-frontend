// ============================================================
// FILE: lib/models/streak_buddy.dart
//
// PURPOSE: Defines a "streak buddy" relationship between users.
//
// A streak buddy is a friend you've paired with to read together.
// The Friends screen shows their reading status for today and
// lets you nudge them if they haven't read yet.
// ============================================================

// ── Streak Buddy Status ──────────────────────────────────────
enum StreakBuddyStatus {
  bothRead,      // Both have read today — "Streak safe"
  partnerAtRisk, // Partner hasn't read — "Streak at risk"
  nudgeSent,     // You already nudged them today
  youAtRisk,     // You haven't read yet
}

class StreakBuddy {
  final String id;
  final String userId;           // Your ID
  final String partnerName;      // Partner's display name
  final String partnerInitials;
  final int sharedStreakDays;    // Days you've both been reading together
  final StreakBuddyStatus status;
  final bool nudgeSentToday;
  final String? myInitials;      // Your initials (for the overlapping avatar)

  const StreakBuddy({
    required this.id,
    required this.userId,
    required this.partnerName,
    required this.partnerInitials,
    required this.sharedStreakDays,
    required this.status,
    this.nudgeSentToday = false,
    this.myInitials,
  });

  /// The status subtitle shown under the partner's name.
  String get statusLabel {
    switch (status) {
      case StreakBuddyStatus.bothRead:
        return 'Both read today. Streak safe.';
      case StreakBuddyStatus.partnerAtRisk:
        return "Hasn't read yet. Streak at risk.";
      case StreakBuddyStatus.nudgeSent:
        return 'Nudge sent 10 min ago';
      case StreakBuddyStatus.youAtRisk:
        return "You haven't read yet. Streak at risk.";
    }
  }
}
