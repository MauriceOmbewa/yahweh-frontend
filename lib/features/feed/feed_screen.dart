// ============================================================
// FILE: lib/features/feed/feed_screen.dart
//
// PURPOSE: The home Feed tab — the first thing a logged-in
//          user sees.
//
// WHAT IT SHOWS (matching the designs exactly):
//   App Bar:
//     - "Yahweh" title (bold, left)
//     - Chat bubble icon (opens Messages) — right
//     - Bell icon with orange badge count (opens Notifications) — right
//
//   Body (scrollable):
//     1. Friend story circles row — horizontal scrollable row of
//        UserAvatar widgets with names below. Tapping one would
//        open their profile (wired in Phase 9).
//
//     2. Vertical list of VerseCard widgets built from MockData.feedPosts.
//        Each card shows: avatar, name, time, translation pill,
//        verse reference, quoted verse, caption, reactions.
// ============================================================

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/widgets/verse_card.dart';
import '../../data/mock_data.dart';
import '../../models/user.dart';
import '../../navigation/app_router.dart';
import '../status/status_story_screen.dart';

class FeedScreen extends StatelessWidget {
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onMessagesTap;

  const FeedScreen({
    super.key,
    this.onNotificationsTap,
    this.onMessagesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      // ── App Bar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation:       0,
        scrolledUnderElevation: 0,
        // "Yahweh" bold title — left aligned
        title: Text(
          'Yahweh',
          style: AppTextStyles.headingLarge.copyWith(fontSize: 22),
        ),
        actions: [
          // Messages icon
          IconButton(
            icon: const Icon(
              Iconsax.message,
              color: AppColors.textDark,
              size:  24,
            ),
            onPressed: () {
              if (onMessagesTap != null) {
                onMessagesTap!();
              } else {
                Navigator.pushNamed(context, AppRoutes.messages);
              }
            },
          ),
          // Notifications bell with badge
          _NotificationBell(
            count: MockData.notifications
                .where((n) => !n.isRead)
                .length,
            onTap: () {
              if (onNotificationsTap != null) {
                // Shell is available — switch panel in place
                onNotificationsTap!();
              } else {
                // Fallback: push as a route
                Navigator.pushNamed(context, AppRoutes.notifications);
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────
      body: CustomScrollView(
        // CustomScrollView lets us mix different types of
        // scrollable content (slivers) in one scroll area.
        slivers: [
          // ── Friend Story Circles ─────────────────────────────
          SliverToBoxAdapter(
            child: _FriendStoriesRow(friends: MockData.friends),
          ),

          // ── Gap between stories and first card ───────────────
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Feed Post Cards ───────────────────────────────────
          // SliverList efficiently renders a scrollable list —
          // it only builds cards that are currently on screen.
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = MockData.feedPosts[index];
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.paddingMd,
                    index == 0 ? 0 : AppConstants.paddingSm,
                    AppConstants.paddingMd,
                    index == MockData.feedPosts.length - 1
                        ? AppConstants.paddingXl // Extra space at the bottom
                        : 0,
                  ),
                  child: VerseCard(post: post),
                );
              },
              childCount: MockData.feedPosts.length,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  FRIEND STORY CIRCLES ROW
// ════════════════════════════════════════════════════════════
class _FriendStoriesRow extends StatelessWidget {
  final List<User> friends;
  const _FriendStoriesRow({required this.friends});

  @override
  Widget build(BuildContext context) {
    // Build statuses once for the whole row so we can pass the
    // full list to the story viewer (swipe through all friends).
    final statuses = buildMockStatuses(friends);

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
          vertical:   AppConstants.paddingSm,
        ),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          // Find this friend's status (if any)
          final friendStatuses = statuses
              .where((s) => s.author.id == friends[index].id)
              .toList();
          final hasActiveStatus =
              friendStatuses.isNotEmpty && friendStatuses.first.isActive;

          return _FriendStoryItem(
            user:           friends[index],
            hasActiveStatus: hasActiveStatus,
            onTap: () {
              if (hasActiveStatus) {
                // Open story viewer starting at this friend's story
                final startIdx = statuses
                    .indexWhere((s) => s.author.id == friends[index].id);
                StatusStoryScreen.show(
                  context,
                  stories:      statuses.where((s) => s.isActive).toList(),
                  initialIndex: startIdx.clamp(0, statuses.length - 1),
                );
              } else {
                // No status — open their profile instead
                Navigator.pushNamed(
                  context,
                  AppRoutes.otherProfile,
                  arguments: friends[index],
                );
              }
            },
          );
        },
      ),
    );
  }
}

// ── Single story circle item ──────────────────────────────────
class _FriendStoryItem extends StatelessWidget {
  final User user;
  final bool hasActiveStatus;
  final VoidCallback onTap;

  const _FriendStoryItem({
    required this.user,
    required this.hasActiveStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = user.displayName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Orange ring = has active status (like WhatsApp green ring)
          // Grey ring  = no active status
          UserAvatar(
            initials:       user.initials,
            streakCount:    user.currentStreak,
            size:           AppConstants.avatarSm + 8,
            isStreakActive: hasActiveStatus,  // orange = has status
            showRing:       true,
            onTap:          onTap,
          ),
          const SizedBox(height: 4),
          Text(
            firstName,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NOTIFICATION BELL WITH BADGE
// ════════════════════════════════════════════════════════════
// Bell icon with an orange circle badge showing unread count.
// Matches the "3" badge shown in the designs.
class _NotificationBell extends StatelessWidget {
  final int count;       // Number of unread notifications
  final VoidCallback onTap;
  const _NotificationBell({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bell icon
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Iconsax.notification,
              color: AppColors.textDark,
              size:  24,
            ),
          ),

          // Orange count badge — only shown when count > 0
          if (count > 0)
            Positioned(
              top:   2,
              right: 2,
              child: Container(
                width:  18,
                height: 18,
                decoration: const BoxDecoration(
                  color:  AppColors.orange,
                  shape:  BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: AppTextStyles.streakNumber.copyWith(
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
