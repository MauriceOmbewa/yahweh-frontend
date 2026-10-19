// ============================================================
// FILE: lib/features/profile/other_profile_screen.dart
//
// PURPOSE: Shows another user's public profile.
//
// HOW TO NAVIGATE HERE:
//   Navigator.pushNamed(
//     context,
//     AppRoutes.otherProfile,
//     arguments: someUserObject,  ← pass the User model
//   )
//
// SCREEN LAYOUT (top to bottom):
//   1. App bar: back arrow + user's first name
//   2. Large avatar (XL, centred)
//   3. Full display name + "Joined [month] [year]"
//   4. Status Verse card (purple gradient)
//   5. Locked stat tiles row × 3
//   6. "Streak stats are visible to friends." hint
//   7. Add friend (orange) + Message (outlined) buttons
//   8. "Public posts" section header
//   9. List of VerseCard widgets (their public posts)
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/widgets/verse_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/mock_data.dart';
import '../../models/user.dart';
import '../../models/post.dart';
import '../../navigation/app_router.dart';
import 'widgets/status_verse_card.dart';
import 'widgets/stat_tile.dart';

class OtherProfileScreen extends StatelessWidget {
  const OtherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Receive the User passed via Navigator arguments ──────
    // When you navigate here with:
    //   Navigator.pushNamed(context, AppRoutes.otherProfile, arguments: user)
    // ...you get it back with:
    //   ModalRoute.of(context)!.settings.arguments as User
    //
    // If no argument is passed (e.g. direct URL on web), we fall
    // back to Amina from mock data for now.
    final user = (ModalRoute.of(context)?.settings.arguments as User?)
        ?? MockData.aminaNjeri;

    // First name only for the app bar title
    final firstName = user.displayName.split(' ').first;

    // Format joined date: "Joined March 2026"
    final joinedText = 'Joined ${DateFormat('MMMM yyyy').format(user.joinedAt)}';

    // Get this user's public posts from mock feed data
    final List<Post> userPosts = MockData.feedPosts
        .where((p) => p.author.id == user.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      // ── App Bar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor:        AppColors.backgroundLight,
        elevation:               0,
        scrolledUnderElevation:  0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size:  18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // First name only — matches "< Amina" in the design
        title: Text(firstName, style: AppTextStyles.headingLarge),
        titleSpacing: 0,
      ),

      // ── Scrollable body ──────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppConstants.paddingMd),

            // ── Large avatar (centred) ────────────────────────
            UserAvatar(
              initials:    user.initials,
              streakCount: user.currentStreak,
              size:        AppConstants.avatarXl, // 88px
              showRing:    true,
              isStreakActive: user.hasReadToday,
            ),
            const SizedBox(height: 12),

            // ── Display name ─────────────────────────────────
            Text(user.displayName, style: AppTextStyles.userName.copyWith(
              fontSize: 18,
            )),
            const SizedBox(height: 4),

            // ── Joined date ───────────────────────────────────
            Text(joinedText, style: AppTextStyles.bodySmall),
            const SizedBox(height: AppConstants.paddingMd),

            // ── Status verse card ─────────────────────────────
            // If the user has no status verse set, we skip this section.
            if (user.statusVerse != null && user.statusVerseRef != null)
              StatusVerseCard(
                verseText: user.statusVerse!,
                verseRef:  user.statusVerseRef!,
              ),
            const SizedBox(height: AppConstants.paddingMd),

            // ── Locked stat tiles row ─────────────────────────
            // Three tiles side by side with small gaps between them.
            Row(
              children: const [
                StatTile(label: 'day streak',    isLocked: true),
                SizedBox(width: 8),
                StatTile(label: 'longest streak', isLocked: true),
                SizedBox(width: 8),
                StatTile(label: 'chapters read',  isLocked: true),
              ],
            ),
            const SizedBox(height: 8),

            // ── "Streak stats are visible to friends." hint ───
            Text(
              'Streak stats are visible to friends.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppConstants.paddingMd),

            // ── Add friend + Message buttons (side by side) ───
            Row(
              children: [
                // Add friend — orange fill (left, wider)
                Expanded(
                  child: AppButton(
                    label:  'Add friend',
                    onTap:  () {
                      // TODO: send friend request
                    },
                    height: AppConstants.buttonHeightSm,
                  ),
                ),
                const SizedBox(width: 12),
                // Message — outlined (right)
                Expanded(
                  child: AppButton(
                    label:   'Message',
                    onTap:   () => Navigator.pushNamed(
                      context,
                      AppRoutes.chat,
                      // TODO: pass conversation in Phase 8
                    ),
                    variant: ButtonVariant.secondary,
                    height:  AppConstants.buttonHeightSm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLg),

            // ── Public posts section ──────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: SectionHeader(title: 'Public posts'),
            ),
            const SizedBox(height: AppConstants.paddingSm),

            // Show posts or an empty state message
            if (userPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No public posts yet.',
                  style: AppTextStyles.bodySmall,
                ),
              )
            else
              ...userPosts.map(
                (post) => Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppConstants.paddingSm),
                  child: VerseCard(post: post),
                ),
              ),

            const SizedBox(height: AppConstants.paddingXl),
          ],
        ),
      ),
    );
  }
}
