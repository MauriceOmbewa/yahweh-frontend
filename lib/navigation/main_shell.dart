// ============================================================
// FILE: lib/navigation/main_shell.dart
//
// PURPOSE: The persistent scaffold that wraps all main tabs.
//
// RESPONSIVE BEHAVIOUR:
//
//   Mobile (<700px):
//     - Full screen content area (IndexedStack)
//     - AppBottomNavBar at the bottom with centre "+" FAB
//
//   Wide (>=700px) — matches the PDF design exactly:
//     - LEFT sidebar (fixed 220px): logo, nav links, "Share a verse"
//       orange button, user avatar + Settings at the bottom
//     - CENTRE content: the active tab screen (Feed, Read, etc.)
//     - RIGHT panel (260px): streak buddies + today's goal ring
//       (only shown on Feed tab — others get full width content)
//
// HOW TABS WORK:
//   _currentIndex tracks which tab is active (0–3):
//     0 = Feed, 1 = Read, 2 = Progress, 3 = Profile
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
import '../features/share/share_verse_screen.dart';
import '../navigation/app_router.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // 0 = Feed, 1 = Read, 2 = Progress, 3 = Profile
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    FeedScreen(),
    ReadScreen(),
    ProgressScreen(),
    ProfileScreen(),
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
  // ════════════════════════════════════════════════════════
  Widget _buildMobileShell() {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap:        _onTabTapped,
        onShareTap:   _onShareTapped,
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  WIDE / WEB SHELL — 3-column layout
  // ════════════════════════════════════════════════════════
  Widget _buildWideShell() {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LEFT: Sidebar navigation ─────────────────────
          _Sidebar(
            currentIndex: _currentIndex,
            onTap:        _onTabTapped,
            onShareTap:   _onShareTapped,
          ),

          // Thin divider line between sidebar and content
          Container(width: 1, color: AppColors.divider),

          // ── CENTRE: Active screen ─────────────────────────
          Expanded(
            child: IndexedStack(
              index:    _currentIndex,
              children: _screens,
            ),
          ),

          // ── RIGHT: Context panel (Feed tab only) ──────────
          // On non-Feed tabs the right panel is hidden so the
          // content area gets the full remaining width.
          if (_currentIndex == 0) ...[
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
            icon:      Iconsax.home,
            iconFill:  Iconsax.home_1,
            label:     'Feed',
            isActive:  currentIndex == 0,
            onTap:     () => onTap(0),
          ),
          _SideNavItem(
            icon:      Iconsax.book,
            iconFill:  Iconsax.book_1,
            label:     'Read',
            isActive:  currentIndex == 1,
            onTap:     () => onTap(1),
          ),
          _SideNavItem(
            icon:      Iconsax.chart,
            iconFill:  Iconsax.chart_1,
            label:     'Progress',
            isActive:  currentIndex == 2,
            onTap:     () => onTap(2),
          ),
          _SideNavItem(
            icon:      Iconsax.people,
            iconFill:  Iconsax.people,
            label:     'Friends',
            isActive:  false,
            onTap: () => Navigator.pushNamed(context, AppRoutes.friends),
          ),
          _SideNavItem(
            icon:      Iconsax.message,
            iconFill:  Iconsax.message_tick,
            label:     'Messages',
            isActive:  false,
            onTap: () {
              // TODO: navigate to Messages (Phase 8)
            },
          ),
          _SideNavItem(
            icon:      Iconsax.user,
            iconFill:  Iconsax.user_square,
            label:     'Profile',
            isActive:  currentIndex == 3,
            onTap:     () => onTap(3),
          ),

          const SizedBox(height: 20),

          // ── Share a verse button ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
              label:  'Share a verse',
              onTap:  onShareTap,
              height: 44,
            ),
          ),

          // Push user tile to the bottom
          const Spacer(),

          // ── User avatar + Settings ─────────────────────────
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
      onTap:     onTap,
      behavior:  HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        margin:   const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:        isActive
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
                color: isActive
                    ? AppColors.primaryPurple
                    : AppColors.textMedium,
                fontWeight: isActive
                    ? FontWeight.w700
                    : FontWeight.w500,
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
      width: 280,
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Streak buddies', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),

          // ── Streak buddy cards ───────────────────────────
          ...MockData.streakBuddies.map((buddy) =>
              _StreakBuddyCard(buddy: buddy)),

          const SizedBox(height: 16),

          // ── Today's goal ring ────────────────────────────
          _TodaysGoalCard(),
        ],
      ),
    );
  }
}

// ── Streak buddy card ─────────────────────────────────────────
class _StreakBuddyCard extends StatelessWidget {
  final dynamic buddy; // StreakBuddy model

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
              // Overlapping avatars
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
              // Flame icons + streak count
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

          // Show Nudge button only when partner is at risk
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

// ── Today's goal ring card ────────────────────────────────────
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
          // Circular progress indicator
          SizedBox(
            width:  56,
            height: 56,
            child:  Stack(
              alignment: Alignment.center,
              children: [
                // Track (grey background ring)
                CircularProgressIndicator(
                  value:      1.0,
                  strokeWidth: 6,
                  color:      AppColors.divider,
                ),
                // Progress (orange filled arc)
                CircularProgressIndicator(
                  value:       progress,
                  strokeWidth: 6,
                  color:       AppColors.orange,
                  backgroundColor: Colors.transparent,
                ),
                // Percentage text in the centre
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
          Column(
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
        ],
      ),
    );
  }
}
