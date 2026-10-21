// ============================================================
// FILE: lib/features/profile/profile_screen.dart
//
// PURPOSE: The logged-in user's own profile screen.
//
// LAYOUT (top to bottom):
//   AppBar: settings gear icon (top right)
//   XL avatar centred + streak badge
//   Display name + "Joined Month Year"
//   "MY STATUS VERSE" card (purple gradient) + "Change" link
//   Stat tiles row: day streak | longest streak | chapters read
//   Achievement badges row (flame, book, check icons)
//   "My posts" section + list of VerseCard widgets
//
// DIFFERS FROM OtherProfileScreen:
//   - "MY STATUS VERSE" label (not "STATUS VERSE")
//   - "Change" link visible on the status verse card
//   - Stat tiles are UNLOCKED (show real numbers)
//   - No "Add friend" / "Message" buttons
//   - Shows own posts only
// ============================================================

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/widgets/verse_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/mock_data.dart';
import '../../navigation/app_router.dart';
import 'widgets/status_verse_card.dart';
import 'widgets/stat_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user      = MockData.currentUser;
    final joinedText = 'Joined ${DateFormat('MMMM yyyy').format(user.joinedAt)}';

    final myPosts = MockData.feedPosts
        .where((p) => p.author.id == user.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:          AppColors.backgroundLight,
        elevation:                 0,
        scrolledUnderElevation:    0,
        automaticallyImplyLeading: false,
        actions: [
          // Settings gear — top right
          IconButton(
            icon: const Icon(Iconsax.setting_2,
                color: AppColors.textDark, size: 22),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── XL Avatar ──────────────────────────────
                UserAvatar(
                  initials:       user.initials,
                  streakCount:    user.currentStreak,
                  size:           AppConstants.avatarXl,
                  showRing:       true,
                  isStreakActive: user.hasReadToday,
                ),
                const SizedBox(height: 12),

                // ── Name + joined date ──────────────────────
                Text(user.displayName,
                    style: AppTextStyles.userName
                        .copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(joinedText, style: AppTextStyles.bodySmall),
                const SizedBox(height: AppConstants.paddingMd),

                // ── Edit profile button ─────────────────────
                OutlinedButton(
                  onPressed: () {}, // TODO: edit profile
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.divider, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                  ),
                  child: Text('Edit profile',
                      style: AppTextStyles.labelMedium),
                ),
                const SizedBox(height: AppConstants.paddingMd),

                // ── Status verse card ───────────────────────
                if (user.statusVerse != null)
                  StatusVerseCard(
                    verseText:   user.statusVerse!,
                    verseRef:    user.statusVerseRef ?? '',
                    showChange:  true,
                    onChangeTap: () {}, // TODO: change status verse
                  ),
                const SizedBox(height: AppConstants.paddingMd),

                // ── Stat tiles (unlocked — own profile) ────
                Row(
                  children: [
                    StatTile(
                      label: 'day streak',
                      value: '${user.currentStreak}',
                    ),
                    const SizedBox(width: 8),
                    StatTile(
                      label: 'longest streak',
                      value: '${user.longestStreak}',
                    ),
                    const SizedBox(width: 8),
                    StatTile(
                      label: 'chapters read',
                      value: '${user.chaptersRead}',
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMd),

                // ── Achievement badges ──────────────────────
                _BadgesRow(badges: MockData.badges),
                const SizedBox(height: AppConstants.paddingLg),

                // ── My posts ───────────────────────────────
                const Align(
                  alignment: Alignment.centerLeft,
                  child: SectionHeader(title: 'My posts'),
                ),
                const SizedBox(height: AppConstants.paddingSm),

                if (myPosts.isEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 24),
                    child: Text('No posts yet.',
                        style: AppTextStyles.bodySmall),
                  )
                else
                  ...myPosts.map((post) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppConstants.paddingSm),
                        child: VerseCard(post: post),
                      )),

                const SizedBox(height: AppConstants.paddingXl),
              ],
            ),
          ),         // SingleChildScrollView
        ),           // ConstrainedBox
      ),             // Center
    );
  }
}

// ── Achievement badges row ────────────────────────────────────
class _BadgesRow extends StatelessWidget {
  final List<Map<String, dynamic>> badges;
  const _BadgesRow({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: badges.map((b) => _Badge(data: b)).toList(),
    );
  }
}

class _Badge extends StatelessWidget {
  final Map<String, dynamic> data;
  const _Badge({required this.data});

  @override
  Widget build(BuildContext context) {
    final bool earned  = data['earned'] as bool;
    final Color color  = Color(data['color'] as int);
    final String label = data['label'] as String;
    final String icon  = data['icon']  as String;

    final IconData iconData = switch (icon) {
      'flame'  => Icons.local_fire_department_rounded,
      'book'   => Icons.menu_book_rounded,
      'check'  => Icons.check_circle_rounded,
      'fire'   => Icons.whatshot_rounded,
      'people' => Icons.people_rounded,
      _        => Icons.star_rounded,
    };

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Opacity(
        opacity: earned ? 1.0 : 0.35, // Dim unearned badges
        child: Column(
          children: [
            Container(
              width:  52,
              height: 52,
              decoration: BoxDecoration(
                color:  color,
                shape:  BoxShape.circle,
              ),
              child: Icon(iconData, color: AppColors.white, size: 24),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10),
                textAlign: TextAlign.center,
                maxLines:  2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
