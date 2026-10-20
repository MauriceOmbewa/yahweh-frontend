// ============================================================
// FILE: lib/features/notifications/notifications_screen.dart
//
// PURPOSE: Shows all notifications grouped by TODAY / YESTERDAY.
//
// DESIGN NOTES (from the screenshot):
//   - Dark background (#0F0F1A) — different from every other screen
//   - "Notifications" title in white, left-aligned
//   - "Mark all read" in purple/blue, right-aligned
//   - TODAY / YESTERDAY section labels in orange uppercase
//   - Each notification row:
//       [Avatar + badge]  [Bold name] normal text   [time]
//   - Unread rows get a subtle left accent bar
//
// RESPONSIVE:
//   - Same Center + ConstrainedBox(maxWidth: 680) pattern
//   - Accessed via Navigator.pushNamed (not a shell tab)
//   - Has a back arrow on wide screens
//
// STATE: Stateful because "Mark all read" changes local state.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/mock_data.dart';
import '../../models/app_notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Local mutable copy so "Mark all read" can update the UI
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(MockData.notifications);
  }

  // ── Mark all as read ─────────────────────────────────────
  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => AppNotification(
                id:               n.id,
                type:             n.type,
                fromUserName:     n.fromUserName,
                fromUserInitials: n.fromUserInitials,
                fromUserStreak:   n.fromUserStreak,
                message:          n.message,
                receivedAt:       n.receivedAt,
                isRead:           true, // ← mark read
              ))
          .toList();
    });
  }

  // ── Split into today / yesterday ──────────────────────────
  List<AppNotification> get _todayNotifs =>
      _notifications.where((n) => n.isToday).toList();

  List<AppNotification> get _yesterdayNotifs =>
      _notifications.where((n) => !n.isToday).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,

      // ── App Bar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor:       AppColors.backgroundDark,
        elevation:              0,
        scrolledUnderElevation: 0,
        // Back arrow — white on dark background
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
            size:  18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.headingLarge.copyWith(
            color: AppColors.white,
          ),
        ),
        titleSpacing: 0,
        // "Mark all read" link on the right
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              'Mark all read',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primaryPurple.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            // ListView is better than SingleChildScrollView here
            // because it lazily renders items — better performance
            // when there are many notifications.
            children: [
              // ── TODAY section ─────────────────────────────
              if (_todayNotifs.isNotEmpty) ...[
                _SectionLabel(label: 'TODAY'),
                ..._todayNotifs.map(
                  (n) => _NotificationRow(notification: n),
                ),
              ],

              // ── YESTERDAY section ─────────────────────────
              if (_yesterdayNotifs.isNotEmpty) ...[
                const SizedBox(height: 8),
                _SectionLabel(label: 'YESTERDAY'),
                ..._yesterdayNotifs.map(
                  (n) => _NotificationRow(notification: n),
                ),
              ],

              // Bottom breathing room
              const SizedBox(height: AppConstants.paddingXl),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SECTION LABEL  ("TODAY" / "YESTERDAY")
// ════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        AppConstants.paddingSm,
      ),
      child: Text(
        label,
        // Orange uppercase caps — sectionTitleCaps style
        style: AppTextStyles.sectionTitleCaps,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NOTIFICATION ROW
// ════════════════════════════════════════════════════════════
class _NotificationRow extends StatelessWidget {
  final AppNotification notification;
  const _NotificationRow({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Unread rows: subtle left blue accent bar
      decoration: BoxDecoration(
        border: notification.isRead
            ? null
            : const Border(
                left: BorderSide(
                  color: AppColors.primaryPurple,
                  width: 3,
                ),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
          vertical:   12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar with streak badge ──────────────────
            UserAvatar(
              initials:    notification.fromUserInitials,
              streakCount: notification.fromUserStreak,
              size:        AppConstants.avatarMd,
              showRing:    false, // No ring in notifications
            ),
            const SizedBox(width: 14),

            // ── Notification text ─────────────────────────
            Expanded(
              child: _NotificationText(notification: notification),
            ),

            const SizedBox(width: 10),

            // ── Time ago ──────────────────────────────────
            Text(
              notification.timeAgo,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification text with bold name ─────────────────────────
// Renders e.g.:  "Amina reacted Amen to your post"
// where "Amina" is bold white and the rest is normal grey.
class _NotificationText extends StatelessWidget {
  final AppNotification notification;
  const _NotificationText({required this.notification});

  @override
  Widget build(BuildContext context) {
    // Split the message to bold the first word (the user's name).
    // e.g. "Amina reacted Amen to your post"
    //   → bold "Amina" + normal " reacted Amen to your post"
    final String fullMessage = notification.message;
    final String name        = notification.fromUserName;
    final String rest        = fullMessage.startsWith(name)
        ? fullMessage.substring(name.length)
        : fullMessage;

    return RichText(
      text: TextSpan(
        children: [
          // Bold name
          TextSpan(
            text:  name,
            style: AppTextStyles.bodyMedium.copyWith(
              color:      AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          // Rest of the message
          TextSpan(
            text:  rest,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
