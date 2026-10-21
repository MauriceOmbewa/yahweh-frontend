// ============================================================
// FILE: lib/features/read/chapter_screen.dart
//
// PURPOSE: The full Bible reading view for a single chapter.
//
// WHAT IT SHOWS (matching the design):
//   - Translation pills: NIV | ESV | KJV | NLT | NKJV
//   - Breadcrumb + reading timer: "Genesis › Chapter 1   04:12"
//   - Large numbered verse text (Playfair Display serif)
//   - Long-press any verse → VerseContextMenu bottom sheet
//   - Highlighted verses shown with background color
//   - Mark as Read orange button (pinned to bottom)
//   - ‹ Previous  /  Next › navigation buttons
//
// STATE:
//   - _selectedTranslation — which pill is active
//   - _highlightedVerses   — Map<verseIndex, Color>
//   - _seconds             — reading timer (counts up)
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../data/mock_data.dart';
import '../../models/bible_verse.dart';
import 'verse_context_menu.dart';

class ChapterScreen extends StatefulWidget {
  final String book;
  final int    chapter;

  const ChapterScreen({
    super.key,
    required this.book,
    required this.chapter,
  });

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  String _selectedTranslation = 'NIV';

  // Map: verse index → highlight color
  final Map<int, Color> _highlightedVerses = {};

  // Reading timer
  int _seconds = 0;
  late Timer _timer;

  // The currently long-pressed verse (for selection UI)
  int? _selectedVerseIndex;

  @override
  void initState() {
    super.initState();
    // Start counting seconds from the moment the chapter opens.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Format seconds → "MM:SS"
  String get _timerLabel {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds  % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Get verses for current book/chapter from mock data.
  // In a real app this would call a Bible API.
  List<BibleVerse> get _verses {
    if (widget.book == 'Genesis' && widget.chapter == 1) {
      return MockData.genesis1Chapter;
    }
    // Fallback: show genesis for any chapter not in mock data
    return MockData.genesis1Chapter;
  }

  void _onVerseLongPress(int index) {
    setState(() => _selectedVerseIndex = index);
    VerseContextMenu.show(
      context,
      verse: _verses[index],
      onAction: (action, {highlightColor}) {
        setState(() => _selectedVerseIndex = null);
        if (action == VerseAction.highlight && highlightColor != null) {
          setState(() => _highlightedVerses[index] = highlightColor);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,

      body: SafeArea(
        child: Column(
          children: [
            // ── Translation pills ────────────────────────────
            _TranslationPills(
              selected:  _selectedTranslation,
              onChange:  (t) => setState(() => _selectedTranslation = t),
            ),

            // ── Chapter content (scrollable) ─────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLg,
                  vertical:   AppConstants.paddingMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumb + timer row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.book} › Chapter ${widget.chapter}',
                          style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.white),
                        ),
                        // Timer pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusFull),
                          ),
                          child: Text(_timerLabel,
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingLg),

                    // Verse list
                    ..._verses.asMap().entries.map((entry) {
                      final idx   = entry.key;
                      final verse = entry.value;
                      return _VerseBlock(
                        verse:      verse,
                        highlight:  _highlightedVerses[idx],
                        isSelected: _selectedVerseIndex == idx,
                        onLongPress: () => _onVerseLongPress(idx),
                      );
                    }),

                    const SizedBox(height: 80), // Space for pinned buttons
                  ],
                ),
              ),
            ),

            // ── Pinned bottom controls ────────────────────────
            _BottomControls(
              onMarkRead: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.book} ${widget.chapter} marked as read!',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.white),
                    ),
                    backgroundColor: AppColors.primaryPurple,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              onPrevious: () => Navigator.pop(context),
              onNext: () {}, // TODO: load next chapter
            ),
          ],
        ),
      ),
    );
  }
}

// ── Translation pills ─────────────────────────────────────────
class _TranslationPills extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChange;

  const _TranslationPills({
      required this.selected, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd, vertical: 12),
      child: Row(
        children: AppConstants.bibleTranslations.map((t) {
          final bool isActive = t == selected;
          return GestureDetector(
            onTap: () => onChange(t),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color:        isActive ? AppColors.orange : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                t,
                style: AppTextStyles.labelSmall.copyWith(
                  color:      isActive ? AppColors.textDark : AppColors.white,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Single verse block ────────────────────────────────────────
class _VerseBlock extends StatelessWidget {
  final BibleVerse  verse;
  final Color?      highlight;   // null = no highlight
  final bool        isSelected;
  final VoidCallback onLongPress;

  const _VerseBlock({
    required this.verse,
    required this.onLongPress,
    this.highlight,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        margin:   const EdgeInsets.only(bottom: AppConstants.paddingSm),
        padding:  const EdgeInsets.symmetric(
            horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          // Highlight color when selected or highlighted
          color: highlight?.withValues(alpha: 0.25) ??
              (isSelected
                  ? AppColors.white.withValues(alpha: 0.08)
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(6),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              // Verse number (small orange superscript-style)
              TextSpan(
                text:  '${verse.startVerse} ',
                style: GoogleFonts.playfairDisplay(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.orange,
                ),
              ),
              // Verse text
              TextSpan(
                text:  verse.text,
                style: AppTextStyles.verseLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom controls ───────────────────────────────────────────
class _BottomControls extends StatelessWidget {
  final VoidCallback onMarkRead;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _BottomControls({
    required this.onMarkRead,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingSm,
        AppConstants.paddingMd,
        AppConstants.paddingMd,
      ),
      child: Column(
        children: [
          // Previous / Next row
          Row(
            children: [
              Expanded(
                child: _NavButton(
                  label:    '‹ Previous',
                  onTap:    onPrevious,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NavButton(
                  label:    'Next ›',
                  onTap:    onNext,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Mark as Read
          AppButton(
            label:  'Mark as Read',
            onTap:  onMarkRead,
            height: AppConstants.buttonHeightSm,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppConstants.buttonHeightSm,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
              color: AppColors.white.withValues(alpha: 0.25), width: 1),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Text(label,
            style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.white)),
      ),
    );
  }
}
