// ============================================================
// FILE: lib/features/profile/widgets/status_verse_card.dart
//
// PURPOSE: The dark purple gradient card showing a user's
//          chosen "Status Verse" on their profile.
//
// WHAT IT LOOKS LIKE:
//   ┌────────────────────────────────────────────┐
//   │ STATUS VERSE                    [Change]   │  ← only on own profile
//   │                                            │
//   │ The Lord is my shepherd;                   │
//   │ I shall not want.                          │
//   │                                            │
//   │ Psalm 23:1 · NIV                           │
//   └────────────────────────────────────────────┘
//
// PROPS:
//   verseText    → the verse body (white serif)
//   verseRef     → "Psalm 23:1 · NIV" (small white text)
//   showChange   → true on own profile (shows "Change" link)
//   onChangeTap  → callback when "Change" is tapped
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class StatusVerseCard extends StatelessWidget {
  final String verseText;
  final String verseRef;
  final bool showChange;        // true = own profile
  final VoidCallback? onChangeTap;

  const StatusVerseCard({
    super.key,
    required this.verseText,
    required this.verseRef,
    this.showChange    = false,
    this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        // Dark purple gradient — matches the design
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3D2B82), // lighter purple (top-left)
            Color(0xFF1A0F4A), // very dark purple (bottom-right)
          ],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── "STATUS VERSE" label row ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATUS VERSE',
                style: AppTextStyles.statusVerseLabel,
              ),
              // "Change" link — only on own profile
              if (showChange)
                GestureDetector(
                  onTap: onChangeTap,
                  child: Text(
                    'Change',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Verse text (white Playfair Display) ───────────
          Text(
            verseText,
            style: GoogleFonts.playfairDisplay(
              fontSize:   20,
              fontWeight: FontWeight.w500,
              color:      AppColors.white,
              height:     1.4,
            ),
          ),
          const SizedBox(height: 10),

          // ── Verse reference ───────────────────────────────
          Text(
            verseRef,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
