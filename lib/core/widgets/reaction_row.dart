// ============================================================
// FILE: lib/core/widgets/reaction_row.dart
//
// PURPOSE: The row of emoji reactions shown at the bottom of
//          every feed post card.
//
// WHAT IT LOOKS LIKE (from the designs):
//   Amen 24   Heart 18   Fire 9   Pray 31   Comment 6
//
// HOW TO USE:
//   ReactionRow(
//     amenCount:    24,
//     heartCount:   18,
//     fireCount:    9,
//     prayCount:    31,
//     commentCount: 6,
//   )
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ReactionRow extends StatelessWidget {
  final int amenCount;
  final int heartCount;
  final int fireCount;
  final int prayCount;
  final int commentCount;
  final VoidCallback? onComment; // Optional tap to open comments

  const ReactionRow({
    super.key,
    required this.amenCount,
    required this.heartCount,
    required this.fireCount,
    required this.prayCount,
    required this.commentCount,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ReactionItem(emoji: '🙏', label: 'Amen',    count: amenCount),
        const SizedBox(width: 16),
        _ReactionItem(emoji: '❤️', label: 'Heart',   count: heartCount),
        const SizedBox(width: 16),
        _ReactionItem(emoji: '🔥', label: 'Fire',    count: fireCount),
        const SizedBox(width: 16),
        _ReactionItem(emoji: '🤲', label: 'Pray',    count: prayCount),
        const SizedBox(width: 16),
        _ReactionItem(
          emoji:   '💬',
          label:   'Comment',
          count:   commentCount,
          onTap:   onComment,
        ),
      ],
    );
  }
}

// ── Single Reaction Item ──────────────────────────────────────
// A private widget (the underscore _ means "private to this file").
// It renders one emoji + label + count combination.
class _ReactionItem extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final VoidCallback? onTap;

  const _ReactionItem({
    required this.emoji,
    required this.label,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        // Only show emoji + count if count > 0 for cleaner look.
        // e.g. "Amen 24" — matches the design exactly.
        '$label ${count > 0 ? count : ""}',
        style: AppTextStyles.reactionCount.copyWith(
          // Highlight in orange if the count is non-zero.
          color: count > 0 ? AppColors.textMedium : AppColors.textLight,
        ),
      ),
    );
  }
}
