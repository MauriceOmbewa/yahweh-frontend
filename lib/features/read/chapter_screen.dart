// ============================================================
// FILE: lib/features/read/chapter_screen.dart
//
// PURPOSE: The full Bible reading view for a single chapter.
//
// THEME: Light background (backgroundLight) — matches all other screens.
//
// RESPONSIVE:
//   Mobile: translation pills top, scrollable verses, pinned bottom controls
//   Wide:   Left = verse content, Right = Highlight panel + Notes + Progress
//           (matches the web screenshot from the designs)
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/utils/responsive.dart';
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
  final Map<int, Color> _highlightedVerses = {};
  int _seconds = 0;
  late Timer _timer;
  int? _selectedVerseIndex;

  // Notes added by the user (index → note text)
  final Map<int, String> _notes = {
    2: 'Light before the sun. Come back to this.',
    0: 'Where it all starts.',
  };

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds  % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  List<BibleVerse> get _verses {
    if (widget.book == 'Genesis' && widget.chapter == 1) {
      return MockData.genesis1Chapter;
    }
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
    final bool isWide = Responsive.isWide(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:        AppColors.backgroundLight,
        elevation:               0,
        scrolledUnderElevation:  0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        // Translation pills in the app bar on mobile
        title: isWide ? null : _TranslationPills(
          selected: _selectedTranslation,
          onChange: (t) => setState(() => _selectedTranslation = t),
          isLight:  true,
        ),
        titleSpacing: 0,
      ),

      body: isWide
          ? _buildWideLayout()
          : _buildMobileLayout(),
    );
  }

  // ════════════════════════════════════════════════════════
  //  MOBILE LAYOUT
  // ════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLg,
              vertical:   AppConstants.paddingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BreadcrumbRow(
                  book:       widget.book,
                  chapter:    widget.chapter,
                  timerLabel: _timerLabel,
                  isLight:    true,
                ),
                const SizedBox(height: AppConstants.paddingLg),
                ..._buildVerseList(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        _BottomControls(
          isLight:    true,
          onMarkRead: _onMarkRead,
          onPrevious: () => Navigator.pop(context),
          onNext:     () {},
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  WIDE LAYOUT — matches the web screenshot exactly
  //  Left: translation pills + breadcrumb + verses + buttons
  //  Right: Highlight colors + Notes in chapter + Book progress
  // ════════════════════════════════════════════════════════
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT: Main reading area ───────────────────────
        Expanded(
          child: Column(
            children: [
              // Translation pills row
              Container(
                color: AppColors.backgroundLight,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMd, vertical: 12),
                child: _TranslationPills(
                  selected: _selectedTranslation,
                  onChange: (t) =>
                      setState(() => _selectedTranslation = t),
                  isLight: true,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLg,
                      vertical:   AppConstants.paddingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BreadcrumbRow(
                        book:       widget.book,
                        chapter:    widget.chapter,
                        timerLabel: _timerLabel,
                        isLight:    true,
                      ),
                      const SizedBox(height: AppConstants.paddingLg),
                      ..._buildVerseList(),
                      const SizedBox(height: 16),
                      // Mark as Read + Previous/Next inline on wide
                      _BottomControls(
                        isLight:    true,
                        onMarkRead: _onMarkRead,
                        onPrevious: () => Navigator.pop(context),
                        onNext:     () {},
                      ),
                      const SizedBox(height: AppConstants.paddingLg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Divider
        Container(width: 1, color: AppColors.divider),

        // ── RIGHT: Highlight + Notes + Progress ───────────
        SizedBox(
          width: 260,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Highlight label
                Text('Highlight', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                // 6 colour circles
                Wrap(
                  spacing: 8,
                  children: AppColors.highlightColors.map((c) =>
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                          color: c, shape: BoxShape.circle),
                    ),
                  ).toList(),
                ),
                const SizedBox(height: 20),

                // Notes in this chapter
                Text('Notes in this chapter',
                    style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                ..._notes.entries.map((e) {
                  final ref =
                      '${widget.book} ${widget.chapter}:${_verses[e.key].startVerse}';
                  return _NoteCard(reference: ref, note: e.value);
                }),
                const SizedBox(height: 20),

                // Book progress
                Text('${widget.book} progress',
                    style: AppTextStyles.sectionTitle),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:           1 / 50,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                  minHeight: 6,
                ),
                const SizedBox(height: 6),
                Text('1 of 50 chapters',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildVerseList() {
    return _verses.asMap().entries.map((entry) {
      final idx   = entry.key;
      final verse = entry.value;
      return _VerseBlock(
        verse:      verse,
        highlight:  _highlightedVerses[idx],
        isSelected: _selectedVerseIndex == idx,
        isLight:    true,
        onLongPress: () => _onVerseLongPress(idx),
      );
    }).toList();
  }

  void _onMarkRead() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.book} ${widget.chapter} marked as read!',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryPurple,
        behavior:        SnackBarBehavior.floating,
        duration:        const Duration(seconds: 2),
      ),
    );
  }
}

// ── Note card (right panel) ───────────────────────────────────
class _NoteCard extends StatelessWidget {
  final String reference;
  final String note;
  const _NoteCard({required this.reference, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:  AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border(
          left: BorderSide(color: AppColors.orange, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reference, style: AppTextStyles.verseReference
              .copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(note, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// ── Translation pills ─────────────────────────────────────────
class _TranslationPills extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChange;
  final bool isLight;

  const _TranslationPills({
    required this.selected,
    required this.onChange,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppConstants.bibleTranslations.map((t) {
        final bool isActive = t == selected;
        return GestureDetector(
          onTap: () => onChange(t),
          child: AnimatedContainer(
            duration: AppConstants.animFast,
            margin:   const EdgeInsets.only(right: 8),
            padding:  const EdgeInsets.symmetric(
                horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.orange
                  : (isLight
                      ? AppColors.inputFill
                      : const Color(0xFF1A1A2E)),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Text(
              t,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive
                    ? AppColors.textDark
                    : (isLight
                        ? AppColors.textMedium
                        : AppColors.white),
                fontWeight: isActive
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Breadcrumb + timer row ────────────────────────────────────
class _BreadcrumbRow extends StatelessWidget {
  final String book;
  final int    chapter;
  final String timerLabel;
  final bool   isLight;

  const _BreadcrumbRow({
    required this.book,
    required this.chapter,
    required this.timerLabel,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        isLight ? AppColors.textDark : AppColors.white;
    final Color timerBg =
        isLight ? AppColors.inputFill : const Color(0xFF1A1A2E);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$book › Chapter $chapter',
            style: AppTextStyles.labelMedium.copyWith(color: textColor)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color:        timerBg,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          child: Text(timerLabel,
              style: AppTextStyles.labelSmall.copyWith(
                  color: isLight ? AppColors.textMedium : AppColors.white)),
        ),
      ],
    );
  }
}

// ── Single verse block ────────────────────────────────────────
class _VerseBlock extends StatelessWidget {
  final BibleVerse   verse;
  final Color?       highlight;
  final bool         isSelected;
  final bool         isLight;
  final VoidCallback onLongPress;

  const _VerseBlock({
    required this.verse,
    required this.onLongPress,
    this.highlight,
    this.isSelected = false,
    this.isLight    = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color verseTextColor =
        isLight ? AppColors.textDark : AppColors.white;
    final Color selectionColor = isLight
        ? AppColors.primaryPurple.withValues(alpha: 0.06)
        : AppColors.white.withValues(alpha: 0.08);

    return GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        margin:   const EdgeInsets.only(bottom: AppConstants.paddingSm),
        padding:  const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: highlight?.withValues(alpha: 0.35) ??
              (isSelected ? selectionColor : Colors.transparent),
          borderRadius: BorderRadius.circular(6),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:  '${verse.startVerse} ',
                style: GoogleFonts.playfairDisplay(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.orange,
                ),
              ),
              TextSpan(
                text:  verse.text,
                style: GoogleFonts.playfairDisplay(
                  fontSize:   isLight ? 18 : 22,
                  fontWeight: FontWeight.w400,
                  color:      verseTextColor,
                  height:     1.7,
                ),
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
  final bool isLight;

  const _BottomControls({
    required this.onMarkRead,
    required this.onPrevious,
    required this.onNext,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _NavButton(
                label: '‹ Previous', onTap: onPrevious, isLight: isLight)),
            const SizedBox(width: 12),
            Expanded(child: _NavButton(
                label: 'Next ›', onTap: onNext, isLight: isLight)),
          ],
        ),
        const SizedBox(height: 10),
        AppButton(
          label:  'Mark as Read',
          onTap:  onMarkRead,
          height: AppConstants.buttonHeightSm,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLight;
  const _NavButton({
    required this.label,
    required this.onTap,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isLight
        ? AppColors.divider
        : AppColors.white.withValues(alpha: 0.25);
    final Color textColor =
        isLight ? AppColors.textDark : AppColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height:    AppConstants.buttonHeightSm,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:        isLight ? AppColors.white : Colors.transparent,
          border:       Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Text(label,
            style: AppTextStyles.labelMedium.copyWith(color: textColor)),
      ),
    );
  }
}
