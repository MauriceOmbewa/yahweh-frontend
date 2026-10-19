// ============================================================
// FILE: lib/features/profile/widgets/stat_tile.dart
//
// PURPOSE: A small stat box shown in a row of three on profiles.
//
// TWO STATES:
//   Locked  → shows "00" in blurred grey + "Locked" label
//             (when viewing someone who isn't your friend yet)
//
//   Unlocked → shows the actual number + label
//             (when viewing a friend, or your own profile)
//
// HOW TO USE:
//   StatTile(value: '12',  label: 'day streak')   // unlocked
//   StatTile(label: 'day streak', isLocked: true)  // locked
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;    // Ignored when isLocked = true
  final bool isLocked;

  const StatTile({
    super.key,
    required this.label,
    this.value    = '',
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical:   AppConstants.paddingMd,
          horizontal: AppConstants.paddingSm,
        ),
        decoration: BoxDecoration(
          color:        AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Value (or "00" when locked) ──────────────────
            isLocked
                ? _LockedValue()
                : Text(
                    value,
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 24,
                      color:    AppColors.textDark,
                    ),
                  ),
            const SizedBox(height: 4),

            // ── Label ────────────────────────────────────────
            Text(
              isLocked ? 'Locked' : label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Blurred "00" for locked state ────────────────────────────
// Uses an ImageFilter blur effect on just the number text.
class _LockedValue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // We achieve the "blurred number" look from the design by
    // rendering "00" with reduced opacity — simple and effective.
    return Text(
      '00',
      style: AppTextStyles.headingMedium.copyWith(
        fontSize: 24,
        color:    AppColors.textMedium.withValues(alpha: 0.4),
      ),
    );
  }
}
