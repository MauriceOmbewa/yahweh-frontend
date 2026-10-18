// ============================================================
// FILE: lib/core/widgets/streak_badge.dart
//
// PURPOSE: The small flame 🔥 + number badge shown on every
//          user avatar throughout the app.
//
// WHAT IT LOOKS LIKE: A small pill/capsule at the bottom of
//   an avatar circle with a flame icon and a streak number.
//   Orange flame = active streak. Grey flame = streak at risk.
//
// HOW TO USE:
//   StreakBadge(count: 12)              // Orange — active streak
//   StreakBadge(count: 12, isActive: false) // Grey — streak at risk
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StreakBadge extends StatelessWidget {
  final int count;       // The streak number to show
  final bool isActive;   // true = orange flame, false = grey flame

  const StreakBadge({
    super.key,
    required this.count,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    // Choose the flame color based on whether the streak is active.
    final Color flameColor = isActive ? AppColors.orange : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        // White background so it stands out on top of the purple avatar.
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(20),
        // A subtle shadow to lift it off the avatar.
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset:     const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Only as wide as content
        children: [
          // Flame icon
          Icon(
            Icons.local_fire_department_rounded,
            size:  12,
            color: flameColor,
          ),
          const SizedBox(width: 2),
          // Streak number
          Text(
            '$count',
            style: AppTextStyles.streakNumber.copyWith(
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
