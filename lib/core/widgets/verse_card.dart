// ============================================================
// FILE: lib/core/widgets/verse_card.dart
//
// PURPOSE: The main post card shown in the Feed, on Profiles,
//          and anywhere a shared verse appears.
//
// WHAT IT LOOKS LIKE (from the designs):
//   ┌──────────────────────────────────────────┐
//   │  [Avatar]  Amina Njeri          [NIV]    │
//   │            2h ago                        │
//   │                                          │
//   │  Psalm 23:1–2  ← orange reference        │
//   │  │ The Lord is my shepherd; I shall      │
//   │  │ not want. He makes me lie down...     │
//   │    ← orange left border on verse         │
//   │                                          │
//   │  Needed this one after a long week.      │
//   │                                          │
//   │  Amen 24  Heart 18  Fire 9  Pray 31  💬 6│
//   └──────────────────────────────────────────┘
//
// HOW TO USE:
//   VerseCard(post: MockData.feedPosts[0])
//   VerseCard(post: somePost, onTap: () { /* open detail */ })
// ============================================================

import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';
import 'user_avatar.dart';
import 'reaction_row.dart';

class VerseCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const VerseCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row: Avatar + Name + Time + Translation ──
            _CardHeader(post: post),
            const SizedBox(height: 12),

            // ── Verse Reference (orange) ─────────────────────────
            Text(post.verse.reference, style: AppTextStyles.verseReference),
            const SizedBox(height: 8),

            // ── Quoted Verse with Orange Left Border ─────────────
            _VerseQuote(text: post.verse.text),
            const SizedBox(height: 10),

            // ── Caption (optional) ───────────────────────────────
            if (post.caption != null && post.caption!.isNotEmpty) ...[
              Text(post.caption!, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 12),
            ],

            // ── Reaction Row ──────────────────────────────────────
            ReactionRow(
              amenCount:    post.amenCount,
              heartCount:   post.heartCount,
              fireCount:    post.fireCount,
              prayCount:    post.prayCount,
              commentCount: post.commentCount,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card Header ───────────────────────────────────────────────
// Shows avatar, name, time, and translation pill.
// Private — only used inside VerseCard.
class _CardHeader extends StatelessWidget {
  final Post post;
  const _CardHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar with streak badge
        UserAvatar(
          initials:    post.author.initials,
          streakCount: post.author.currentStreak,
          size:        AppConstants.avatarMd,
        ),
        const SizedBox(width: 10),

        // Name + timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.author.displayName, style: AppTextStyles.userName),
              const SizedBox(height: 2),
              Text(post.timeAgo, style: AppTextStyles.bodySmall),
            ],
          ),
        ),

        // Translation pill (e.g. "NIV")
        _TranslationPill(translation: post.verse.translation),
      ],
    );
  }
}

// ── Translation Pill ─────────────────────────────────────────
// The small grey rounded rectangle showing "NIV" in the top right.
class _TranslationPill extends StatelessWidget {
  final String translation;
  const _TranslationPill({required this.translation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(translation, style: AppTextStyles.labelSmall),
    );
  }
}

// ── Verse Quote Block ─────────────────────────────────────────
// The verse text with the orange vertical left border.
class _VerseQuote extends StatelessWidget {
  final String text;
  const _VerseQuote({required this.text});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      // IntrinsicHeight makes the left border match the height of
      // however many lines the verse text takes.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Orange left border bar
          Container(
            width: 3,
            decoration: BoxDecoration(
              color:        AppColors.verseBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          // Verse text
          Expanded(
            child: Text(text, style: AppTextStyles.verseText),
          ),
        ],
      ),
    );
  }
}
