// ============================================================
// FILE: lib/features/friends/widgets/friend_request_card.dart
//
// PURPOSE: A single friend request row in the Friends screen.
//
// WHAT IT SHOWS:
//   [TB]  Tabitha Bett    [Accept]  Decline
//
// HOW IT WORKS:
//   - Shows a UserAvatar (no ring, no overlapping)
//   - Accept = dark navy filled button
//   - Decline = plain text button
//   - Both call callbacks so the parent screen can handle the logic
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../models/user.dart';

class FriendRequestCard extends StatelessWidget {
  final User requester;         // The person who sent the request
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const FriendRequestCard({
    super.key,
    required this.requester,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
        vertical:   AppConstants.paddingMd,
      ),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        children: [
          // Avatar — no orange ring (they're not a buddy yet)
          UserAvatar(
            initials:    requester.initials,
            streakCount: requester.currentStreak,
            size:        AppConstants.avatarMd,
            showRing:    false,  // No ring for non-friends
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              requester.displayName,
              style: AppTextStyles.userName,
            ),
          ),

          // Accept button — dark navy (matches the design)
          _AcceptButton(onTap: onAccept),
          const SizedBox(width: 12),

          // Decline — plain text
          GestureDetector(
            onTap: onDecline,
            child: Text(
              'Decline',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Accept button ─────────────────────────────────────────────
// Dark navy/purple filled button — distinct from the orange primary.
class _AcceptButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AcceptButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:        AppColors.primaryPurple, // Dark navy
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Text(
          'Accept',
          style: AppTextStyles.labelMedium.copyWith(
            color:      AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
