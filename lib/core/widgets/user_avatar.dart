// ============================================================
// FILE: lib/core/widgets/user_avatar.dart
//
// PURPOSE: The circular user avatar with initials and an
//          optional orange ring + streak badge.
//
// WHAT IT LOOKS LIKE:
//   - A purple filled circle with white initials (e.g. "AN")
//   - An orange ring around it (when the user has an active streak)
//   - A small streak badge (flame + number) at the bottom
//
// SIZES: Use the size constants from AppConstants.
//   - avatarSm (36) → story circles row at top of Feed
//   - avatarMd (48) → inside feed post cards
//   - avatarLg (56) → messages list
//   - avatarXl (88) → profile screen
//
// HOW TO USE:
//   UserAvatar(initials: 'AN', streakCount: 12)
//   UserAvatar(initials: 'AN', streakCount: 12, size: AppConstants.avatarXl)
//   UserAvatar(initials: 'AN', streakCount: 0, showBadge: false)
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';
import 'streak_badge.dart';

class UserAvatar extends StatelessWidget {
  final String initials;     // e.g. "AN", "JK", "MA"
  final int streakCount;     // Streak number shown in the badge
  final double size;         // Overall diameter of the circle
  final bool showBadge;      // Whether to show the streak badge at bottom
  final bool showRing;       // Whether to show the orange ring
  final bool isStreakActive; // Controls flame and ring color
  final VoidCallback? onTap; // Optional tap handler (e.g. open profile)

  const UserAvatar({
    super.key,
    required this.initials,
    required this.streakCount,
    this.size          = AppConstants.avatarMd,
    this.showBadge     = true,
    this.showRing      = true,
    this.isStreakActive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        // The SizedBox reserves extra space for the badge that sits
        // below the circle boundary.
        width:  size + (showRing ? 6 : 0),
        height: size + (showBadge ? 14 : 0) + (showRing ? 6 : 0),
        child: Stack(
          // Stack lets us layer the badge on top of the circle.
          clipBehavior: Clip.none, // Allow children to draw outside bounds
          alignment: Alignment.topCenter,
          children: [
            // ── Orange Ring ─────────────────────────────────────
            if (showRing)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width:  size + 6,
                  height: size + 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isStreakActive
                          ? AppColors.orange
                          : Colors.grey.shade300,
                      width: 2.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: _buildCircle(),
                ),
              )
            else
              _buildCircle(),

            // ── Streak Badge ─────────────────────────────────────
            // Positioned at the very bottom centre of the avatar.
            if (showBadge)
              Positioned(
                bottom: 0,
                left:   0,
                right:  0,
                child: Center(
                  child: StreakBadge(
                    count:    streakCount,
                    isActive: isStreakActive,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── The Purple Circle with Initials ──────────────────────────
  Widget _buildCircle() {
    // Calculate font size proportional to avatar size.
    final double fontSize = size * 0.32;

    return Container(
      width:  size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.deepPurple,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.labelMedium.copyWith(
          fontSize:   fontSize,
          fontWeight: FontWeight.w800,
          color:      AppColors.white,
          height:     1.0,
        ),
      ),
    );
  }
}

// ── Overlapping Avatars ───────────────────────────────────────
// This widget shows TWO overlapping avatars — used on the
// Friends / streak buddy cards in the designs (MA + AN side by side).
//
// HOW TO USE:
//   OverlappingAvatars(leftInitials: 'MA', rightInitials: 'AN',
//     leftStreak: 12, rightStreak: 12)
class OverlappingAvatars extends StatelessWidget {
  final String leftInitials;
  final String rightInitials;
  final int leftStreak;
  final int rightStreak;
  final double size;
  final bool rightIsActive; // Is the right (partner) streak active?

  const OverlappingAvatars({
    super.key,
    required this.leftInitials,
    required this.rightInitials,
    required this.leftStreak,
    required this.rightStreak,
    this.size          = 44,
    this.rightIsActive = true,
  });

  @override
  Widget build(BuildContext context) {
    // The overlap amount — how much the right circle sits on top of the left.
    const double overlap = 16.0;

    return SizedBox(
      width:  size * 2 - overlap,
      height: size + 14, // Extra height for badge
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left avatar (you / current user) — sits behind
          Positioned(
            left: 0,
            top:  0,
            child: UserAvatar(
              initials:       leftInitials,
              streakCount:    leftStreak,
              size:           size,
              showBadge:      false,
              showRing:       true,
              isStreakActive: true,
            ),
          ),
          // Right avatar (partner) — sits on top
          Positioned(
            left: size - overlap,
            top:  0,
            child: UserAvatar(
              initials:       rightInitials,
              streakCount:    rightStreak,
              size:           size,
              showBadge:      false,
              showRing:       true,
              isStreakActive: rightIsActive,
            ),
          ),
        ],
      ),
    );
  }
}
