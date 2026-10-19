// ============================================================
// FILE: lib/features/friends/widgets/streak_buddy_card.dart
//
// PURPOSE: One streak buddy card in the Friends screen.
//
// WHAT IT SHOWS:
//   [MA][AN]  Amina Njeri              🔥 🔥(grey)
//             Hasn't read yet.              12
//             Streak at risk.
//   [       Nudge Amina        ]   ← only when at risk
//
// HOW IT WORKS:
//   - It receives a StreakBuddy object (from our models)
//   - It reads the status to decide what colour/text to show
//   - It shows the Nudge button only when the partner is at risk
//     AND a nudge hasn't been sent yet today
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/mock_data.dart';
import '../../../models/streak_buddy.dart';

class StreakBuddyCard extends StatelessWidget {
  final StreakBuddy buddy;
  final VoidCallback? onNudge; // Called when "Nudge" button is tapped

  const StreakBuddyCard({
    super.key,
    required this.buddy,
    this.onNudge,
  });

  @override
  Widget build(BuildContext context) {
    // ── Decide colours & text based on status ────────────────
    final bool isAtRisk  = buddy.status == StreakBuddyStatus.partnerAtRisk;
    final bool nudgeSent = buddy.status == StreakBuddyStatus.nudgeSent;
    final bool bothRead  = buddy.status == StreakBuddyStatus.bothRead;

    // Status text colour: orange/red when at risk, grey otherwise
    final Color statusColor = isAtRisk
        ? AppColors.streakRisk
        : AppColors.textMedium;

    // Right flame colour: orange when both read, grey when partner hasn't
    final Color rightFlameColor = bothRead
        ? AppColors.orange
        : Colors.grey.shade400;

    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        children: [
          // ── Top row: avatars + name + status + flames ──────
          Row(
            children: [
              // Overlapping avatars (you + partner)
              OverlappingAvatars(
                leftInitials:  buddy.myInitials ?? 'MA',
                rightInitials: buddy.partnerInitials,
                leftStreak:    MockData.currentUser.currentStreak,
                rightStreak:   buddy.sharedStreakDays,
                size:          44,
                rightIsActive: bothRead,
              ),
              const SizedBox(width: 12),

              // Name + status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buddy.partnerName,
                      style: AppTextStyles.userName,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      buddy.statusLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Flame icons + streak number (right side)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // Left flame always orange (you read)
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.orange,
                        size:  20,
                      ),
                      // Right flame: orange = both read, grey = partner hasn't
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: rightFlameColor,
                        size:  20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${buddy.sharedStreakDays}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: bothRead
                          ? AppColors.orange
                          : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Nudge button (only shown when at risk) ──────────
          // We use "if" to conditionally include this widget.
          // When isAtRisk is false, nothing is rendered here.
          if (isAtRisk) ...[
            const SizedBox(height: 12),
            AppButton(
              label:  'Nudge ${buddy.partnerName.split(' ').first}',
              onTap:  onNudge ?? () {},
              height: 44,
            ),
          ],

          // ── "Nudge sent" text (after nudge is sent) ─────────
          if (nudgeSent) ...[
            const SizedBox(height: 4),
            // Subtle hint that you already nudged them
          ],
        ],
      ),
    );
  }
}
