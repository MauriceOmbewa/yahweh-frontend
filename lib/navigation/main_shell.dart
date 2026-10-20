// ============================================================
// FILE: lib/navigation/main_shell.dart
//
// PURPOSE: The persistent scaffold that wraps all main screens.
//
// ── INDEX MAP ────────────────────────────────────────────────
//   0 = Feed          ← mobile bottom nav + wide sidebar
//   1 = Read          ← mobile bottom nav + wide sidebar
//   2 = Progress      ← mobile bottom nav + wide sidebar
//   3 = Profile       ← mobile bottom nav + wide sidebar
//   4 = Friends       ← WIDE SIDEBAR ONLY
//   5 = Messages      ← WIDE SIDEBAR ONLY
//   6 = Notifications ← bell icon tap (both mobile + wide)
//
// ── LAYOUTS ──────────────────────────────────────────────────
//   Mobile (<700px):
//     IndexedStack (indices 0–3) + AppBottomNavBar
//     Friends/Messages open as separate routes via Navigator
//
//   Wide (>=700px):
//     Left sidebar (220px) — all 6 links
//     Centre: IndexedStack (indices 0–5)
//     Right panel: only shown on Feed (index 0)
// ============================================================

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_constants.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../core/widgets/user_avatar.dart';
import '../core/utils/responsive.dart';
import '../data/mock_data.dart';
import '../features/feed/feed_screen.dart';
import '../features/read/read_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/friends/friends_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/share/share_verse_screen.dart';
import '../navigation/app_router.dart';

// ── Placeholder for Messages (Phase 8) ───────────────────────
class _MessagesPlaceholder extends StatelessWidget {
  const _MessagesPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.message, size: 64, color: AppColors.primaryPurple),
            const SizedBox(height: 16),
            Text('Messages', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text('Coming in Phase 8', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Starts on Feed
  int _currentIndex = 0;

  // ── All screens in index order ────────────────────────────
  // Indices 0–3 are used by both mobile and wide.
  // Indices 4–5 are wide-only (sidebar) — never shown in mobile bottom nav.
  // _screens can no longer be a static const list because FeedScreen
  // now needs a callback from this StatefulWidget's state.
  // We build it lazily in _buildScreens() instead.
  List<Widget> _buildScreens() => [
    FeedScreen(onNotificationsTap: () => _onTabTapped(6)), // 0
    const ReadScreen(),               // 1
    const ProgressScreen(),           // 2
    const ProfileScreen(),            // 3
    const FriendsScreen(),            // 4 — wide sidebar only
    const _MessagesPlaceholder(),     // 5 — wide sidebar only
    const NotificationsScreen(),      // 6 — bell icon
  ];

  void _onTabTapped(int index) => setState(() => _currentIndex = index);
  void _onShareTapped()         => ShareVerseScreen.show(context);

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: _buildMobileShell(),
      wide:   _buildWideShell(),
    );
  }

  // ════════════════════════════════════════════════════════
  //  MOBILE SHELL
  //  Only uses indices 0–3. Friends/Messages open via routes.
  // ════════════════════════════════════════════════════════
  Widget _buildMobileShell() {
    // If the user somehow ends up on a wide-only index on mobile,
    // clamp back to Feed so the bottom nav doesn't break.
    final mobileIndex = _currentIndex > 3 ? 0 : _currentIndex;

    return Scaffold(
      body: IndexedStack(
        index:    mobileIndex,
        children: _buildScreens().sublist(0, 4), // Only 0–3 on mobile
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: mobileIndex,
        onTap:        _onTabTapped,
        onShareTap:   _onShareTapped,
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  WIDE / WEB SHELL — 3-column layout
  // ════════════════════════════════════════════════════════
  Widget _buildWideShell() {
    // Right panel visible on Feed (0) AND Friends (4)
    final bool showRightPanel = _currentIndex == 0 || _currentIndex == 4;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LEFT: Sidebar ────────────────────────────────
          _Sidebar(
            currentIndex: _currentIndex,
            onTap:        _onTabTapped,
            onShareTap:   _onShareTapped,
          ),

          Container(width: 1, color: AppColors.divider),

          // ── CENTRE: Active screen ─────────────────────────
          Expanded(
            child: IndexedStack(
              index:    _currentIndex,
              children: _buildScreens(), // All 7 screens on wide
            ),
          ),

          // ── RIGHT: Panel (Feed only) ─────────────────────
          if (showRightPanel) ...[
            Container(width: 1, color: AppColors.divider),
            _RightPanel(),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LEFT SIDEBAR
// ════════════════════════════════════════════════════════════
class _Sidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onShareTap;

  const _Sidebar({
    required this.currentIndex,
    required this.onTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  220,
      height: double.infinity,
      color:  AppColors.backgroundLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Text('Yahweh',
                style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primaryPurple)),
          ),

          // ── Nav links ─────────────────────────────────────
          _SideNavItem(
            icon:     Iconsax.home,
            iconFill: Iconsax.home_1,
            label:    'Feed',
            isActive: currentIndex == 0,
            onTap:    () => onTap(0),
          ),
          _SideNavItem(
            icon:     Iconsax.book,
            iconFill: Iconsax.book_1,
            label:    'Read',
            isActive: currentIndex == 1,
            onTap:    () => onTap(1),
          ),
          _SideNavItem(
            icon:     Iconsax.chart,
            iconFill: Iconsax.chart_1,
            label:    'Progress',
            isActive: currentIndex == 2,
            onTap:    () => onTap(2),
          ),
          _SideNavItem(
            icon:     Iconsax.people,
            iconFill: Iconsax.people,
            label:    'Friends',
            // Index 4 = Friends in the wide shell
            isActive: currentIndex == 4,
            onTap:    () => onTap(4),
          ),
          _SideNavItem(
            icon:     Iconsax.message,
            iconFill: Iconsax.message_tick,
            label:    'Messages',
            // Index 5 = Messages in the wide shell
            isActive: currentIndex == 5,
            onTap:    () => onTap(5),
          ),
          _SideNavItem(
            icon:     Iconsax.user,
            iconFill: Iconsax.user_square,
            label:    'Profile',
            isActive: currentIndex == 3,
            onTap:    () => onTap(3),
          ),

          const SizedBox(height: 20),

          // ── Share a verse button ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
              label:  'Share a verse',
              onTap:  onShareTap,
              height: 44,
            ),
          ),

          const Spacer(),

          // ── User avatar + Settings ────────────────────────
          _SidebarUserTile(
            onSettingsTap: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Sidebar nav item ──────────────────────────────────────────
class _SideNavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconFill;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.icon,
    required this.iconFill,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:    onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        margin:   const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryPurple.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? iconFill : icon,
              color: isActive ? AppColors.primaryPurple : AppColors.textMedium,
              size:  20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color:      isActive ? AppColors.primaryPurple : AppColors.textMedium,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom user tile ──────────────────────────────────────────
class _SidebarUserTile extends StatelessWidget {
  final VoidCallback onSettingsTap;
  const _SidebarUserTile({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    return GestureDetector(
      onTap: onSettingsTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            UserAvatar(
              initials:    user.initials,
              streakCount: user.currentStreak,
              size:        40,
              showRing:    true,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName,
                      style: AppTextStyles.userName.copyWith(fontSize: 14)),
                  Text('Settings',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  RIGHT PANEL — Streak buddies + Today's goal
// ════════════════════════════════════════════════════════════
class _RightPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width:   280,
      color:   AppColors.backgroundLight,
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Streak buddies', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          ...MockData.streakBuddies.map((buddy) =>
              _StreakBuddyCard(buddy: buddy)),
          const SizedBox(height: 16),
          _TodaysGoalCard(),
        ],
      ),
    );
  }
}

// ── Streak buddy card (right panel) ──────────────────────────
class _StreakBuddyCard extends StatelessWidget {
  final dynamic buddy;
  const _StreakBuddyCard({required this.buddy});

  @override
  Widget build(BuildContext context) {
    final bool isAtRisk = buddy.statusLabel.contains('risk');
    final bool bothRead = buddy.statusLabel.contains('safe');

    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OverlappingAvatars(
                leftInitials:  buddy.myInitials ?? 'MA',
                rightInitials: buddy.partnerInitials,
                leftStreak:    MockData.currentUser.currentStreak,
                rightStreak:   buddy.sharedStreakDays,
                size:          36,
                rightIsActive: bothRead,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(buddy.partnerName,
                        style: AppTextStyles.userName.copyWith(fontSize: 13)),
                    Text(buddy.statusLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isAtRisk
                                ? AppColors.streakRisk
                                : AppColors.textMedium,
                            fontSize: 11)),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          color: AppColors.orange, size: 14),
                      Icon(Icons.local_fire_department_rounded,
                          color: bothRead
                              ? AppColors.orange
                              : Colors.grey.shade400,
                          size: 14),
                    ],
                  ),
                  Text('${buddy.sharedStreakDays}',
                      style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ],
              ),
            ],
          ),
          if (isAtRisk && !buddy.nudgeSentToday) ...[
            const SizedBox(height: 10),
            AppButton(
              label:  'Nudge ${buddy.partnerName.split(' ').first}',
              onTap:  () {},
              height: 38,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Today's goal ring ─────────────────────────────────────────
class _TodaysGoalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double progress =
        MockData.todayMinutesRead / MockData.dailyGoalMinutes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          SizedBox(
            width:  56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1.0, strokeWidth: 6,
                  color: AppColors.divider,
                ),
                CircularProgressIndicator(
                  value: progress, strokeWidth: 6,
                  color: AppColors.orange,
                  backgroundColor: Colors.transparent,
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's goal",
                    style: AppTextStyles.labelMedium.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '${MockData.todayMinutesRead} of '
                  '${MockData.dailyGoalMinutes} minutes. '
                  '${progress >= 0.9 ? "Almost there." : "Keep going!"}',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
