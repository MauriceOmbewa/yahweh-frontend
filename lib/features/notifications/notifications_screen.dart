// ============================================================
// FILE: lib/features/notifications/notifications_screen.dart
//
// PURPOSE: Shows all notifications grouped by TODAY / YESTERDAY.
//
// LAYOUT (same pattern as Friends):
//   - Part of the shell's IndexedStack (index 6)
//   - Wide: loads in centre panel, no right panel
//   - Mobile: no back arrow (it's a shell tab equivalent,
//     accessed via the bell icon in the feed app bar)
//
// THEME: Light (backgroundLight, textDark) — same as all other screens.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/mock_data.dart';
import '../../models/app_notification.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const NotificationsScreen({super.key, this.onBack});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(MockData.notifications);
  }

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
                isRead:           true,
              ))
          .toList();
    });
  }

  List<AppNotification> get _todayNotifs =>
      _notifications.where((n) => n.isToday).toList();

  List<AppNotification> get _yesterdayNotifs =>
      _notifications.where((n) => !n.isToday).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // ← light background

      // ── App Bar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor:        AppColors.backgroundLight,
        elevation:               0,
        scrolledUnderElevation:  0,
        automaticallyImplyLeading: false,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textDark, size: 18),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(
          'Notifications',
          style: AppTextStyles.headingLarge, // dark text on light bg
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              'Mark all read',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),

      // ── Body: centred + max-width (same as Friends) ──────────
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            children: [
              if (_todayNotifs.isNotEmpty) ...[
                _SectionLabel(label: 'TODAY'),
                ..._todayNotifs.map((n) => _NotificationRow(notification: n)),
              ],
              if (_yesterdayNotifs.isNotEmpty) ...[
                const SizedBox(height: 8),
                _SectionLabel(label: 'YESTERDAY'),
                ..._yesterdayNotifs.map(
                    (n) => _NotificationRow(notification: n)),
              ],
              const SizedBox(height: AppConstants.paddingXl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section label ("TODAY" / "YESTERDAY") ────────────────────
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
      child: Text(label, style: AppTextStyles.sectionTitleCaps),
    );
  }
}

// ── Notification row ──────────────────────────────────────────
class _NotificationRow extends StatelessWidget {
  final AppNotification notification;
  const _NotificationRow({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Unread: subtle left purple accent bar
      decoration: BoxDecoration(
        // Light lavender tint on unread rows
        color: notification.isRead
            ? Colors.transparent
            : AppColors.primaryPurple.withValues(alpha: 0.04),
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
          vertical:   14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar — no ring (just a regular avatar)
            UserAvatar(
              initials:    notification.fromUserInitials,
              streakCount: notification.fromUserStreak,
              size:        AppConstants.avatarMd,
              showRing:    false,
            ),
            const SizedBox(width: 14),

            // Notification text (bold name + normal rest)
            Expanded(
              child: _NotificationText(notification: notification),
            ),

            const SizedBox(width: 10),

            // Time ago — right-aligned
            Text(
              notification.timeAgo,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bold name + normal message text ──────────────────────────
class _NotificationText extends StatelessWidget {
  final AppNotification notification;
  const _NotificationText({required this.notification});

  @override
  Widget build(BuildContext context) {
    final String name = notification.fromUserName;
    final String rest = notification.message.startsWith(name)
        ? notification.message.substring(name.length)
        : notification.message;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text:  name,
            style: AppTextStyles.bodyMedium.copyWith(
              color:      AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text:  rest,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
