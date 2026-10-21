// ============================================================
// FILE: lib/features/read/chapter_screen.dart
//
// PURPOSE: The full Bible reading view for a single chapter.
//
// THEME:
//   Mobile: Light background (matches rest of app)
//   Wide:   DARK (matches screenshot 4 — the reading experience
//           gets the dark cinematic feel on big screens)
//
// VERSE INTERACTION:
//   Mobile: long-press → VerseContextMenu bottom sheet
//   Wide:   single TAP → selects verse, right panel becomes
//           active (highlight circles apply instantly, bookmark
//           and note work in-place, no bottom sheet needed)
//
// WIDE RIGHT PANEL (live when a verse is selected):
//   - Highlight section: 6 colour circles, clicking applies
//     the highlight to the selected verse immediately
//   - Notes in this chapter: shows all saved notes
//   - Book progress bar
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/utils/responsive.dart';
import '../../data/mock_data.dart';
import '../../models/bible_verse.dart';
import 'verse_context_menu.dart';

// ── Dark palette used on the wide reader ─────────────────────
const Color _darkBg       = Color(0xFF0F0A1E);
const Color _darkSurface  = Color(0xFF1A1433);
const Color _darkBorder   = Color(0xFF2A2448);
const Color _darkText     = Color(0xFFE8E0FF);
const Color _darkSubtext  = Color(0xFF9A8EC8);

class ChapterScreen extends StatefulWidget {
  final String book;
  final int    chapter;
  const ChapterScreen({super.key, required this.book, required this.chapter});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  String _selectedTranslation = 'NIV';

  // verse index → highlight colour
  final Map<int, Color> _highlights = {};

  // verse index → note text
  final Map<int, String> _notes = {
    2: 'Light before the sun. Come back to this.',
    0: 'Where it all starts.',
  };

  // Which verse is currently selected (wide: tap, mobile: long-press)
  int? _selectedVerseIndex;

  // Reading timer
  int _seconds = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) =>
        setState(() => _seconds++));
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

  List<BibleVerse> get _verses => MockData.genesis1Chapter;

  // ── Verse tap (wide) — just selects, right panel reacts ───
  void _onVerseTap(int index) {
    setState(() => _selectedVerseIndex = index);
  }

  // ── Verse long-press (mobile) — opens bottom sheet ────────
  void _onVerseLongPress(int index) {
    setState(() => _selectedVerseIndex = index);
    VerseContextMenu.show(
      context,
      verse: _verses[index],
      onAction: (action, {highlightColor}) {
        if (action == VerseAction.highlight && highlightColor != null) {
          setState(() => _highlights[index] = highlightColor);
        }
        if (action == VerseAction.copy) {
          Clipboard.setData(ClipboardData(text: _verses[index].text));
        }
        setState(() => _selectedVerseIndex = null);
      },
    );
  }

  // ── Apply highlight from right panel ──────────────────────
  void _applyHighlight(Color color) {
    if (_selectedVerseIndex == null) return;
    setState(() => _highlights[_selectedVerseIndex!] = color);
  }

  // ── Bookmark selected verse ────────────────────────────────
  void _bookmarkSelected() {
    if (_selectedVerseIndex == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_verses[_selectedVerseIndex!].reference} bookmarked'),
      backgroundColor: AppColors.primaryPurple,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Add note to selected verse ─────────────────────────────
  void _addNote() {
    if (_selectedVerseIndex == null) return;
    final idx = _selectedVerseIndex!;
    final ctrl = TextEditingController(text: _notes[idx]);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_verses[idx].reference,
            style: AppTextStyles.verseReference),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Add a note…'),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _notes[idx] = ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onMarkRead() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${widget.book} ${widget.chapter} marked as read!',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
      backgroundColor: AppColors.primaryPurple,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = Responsive.isWide(context);

    return Scaffold(
      // Wide = dark reader, mobile = light
      backgroundColor: isWide ? _darkBg : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:       isWide ? _darkBg : AppColors.backgroundLight,
        elevation:              0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isWide ? _darkText : AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: isWide ? null : _TranslationPills(
          selected: _selectedTranslation,
          onChange: (t) => setState(() => _selectedTranslation = t),
          dark: false,
        ),
        titleSpacing: 0,
      ),

      body: isWide ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

  // ════════════════════════════════════════════════════════
  //  MOBILE LAYOUT — light, long-press for context menu
  // ════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLg,
                vertical:   AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BreadcrumbRow(
                    book: widget.book, chapter: widget.chapter,
                    timerLabel: _timerLabel, dark: false),
                const SizedBox(height: AppConstants.paddingLg),
                ..._buildVerseList(dark: false, tapToSelect: false),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        _BottomControls(
          dark:       false,
          onMarkRead: _onMarkRead,
          onPrevious: () => Navigator.pop(context),
          onNext:     () {},
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  WIDE LAYOUT — dark, tap to select + right panel
  // ════════════════════════════════════════════════════════
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT: Reading area ───────────────────────────
        Expanded(
          child: Column(
            children: [
              // Translation pills
              Container(
                color: _darkBg,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMd, vertical: 12),
                child: _TranslationPills(
                  selected: _selectedTranslation,
                  onChange: (t) =>
                      setState(() => _selectedTranslation = t),
                  dark: true,
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
                          book: widget.book, chapter: widget.chapter,
                          timerLabel: _timerLabel, dark: true),
                      const SizedBox(height: AppConstants.paddingLg),
                      ..._buildVerseList(dark: true, tapToSelect: true),
                      const SizedBox(height: 16),
                      _BottomControls(
                        dark:       true,
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

        // ── Divider ──────────────────────────────────────
        Container(width: 1, color: _darkBorder),

        // ── RIGHT PANEL ───────────────────────────────────
        _RightPanel(
          selectedVerse: _selectedVerseIndex != null
              ? _verses[_selectedVerseIndex!]
              : null,
          selectedIndex:      _selectedVerseIndex,
          highlights:         _highlights,
          notes:              _notes,
          verses:             _verses,
          book:               widget.book,
          chapter:            widget.chapter,
          onHighlight:        _applyHighlight,
          onBookmark:         _bookmarkSelected,
          onAddNote:          _addNote,
          onShare: () {
            if (_selectedVerseIndex == null) return;
            // TODO: open share sheet pre-filled with selected verse
          },
          onCopy: () {
            if (_selectedVerseIndex == null) return;
            Clipboard.setData(ClipboardData(
                text: _verses[_selectedVerseIndex!].text));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Copied to clipboard'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ));
          },
        ),
      ],
    );
  }

  List<Widget> _buildVerseList({
    required bool dark,
    required bool tapToSelect,
  }) {
    return _verses.asMap().entries.map((entry) {
      final idx   = entry.key;
      final verse = entry.value;
      return _VerseBlock(
        verse:       verse,
        highlight:   _highlights[idx],
        isSelected:  _selectedVerseIndex == idx,
        dark:        dark,
        onTap:       tapToSelect ? () => _onVerseTap(idx) : null,
        onLongPress: tapToSelect ? null  : () => _onVerseLongPress(idx),
      );
    }).toList();
  }
}

// ════════════════════════════════════════════════════════════
//  RIGHT PANEL
// ════════════════════════════════════════════════════════════
class _RightPanel extends StatelessWidget {
  final BibleVerse?      selectedVerse;
  final int?             selectedIndex;
  final Map<int, Color>  highlights;
  final Map<int, String> notes;
  final List<BibleVerse> verses;
  final String           book;
  final int              chapter;
  final ValueChanged<Color> onHighlight;
  final VoidCallback        onBookmark;
  final VoidCallback        onAddNote;
  final VoidCallback        onShare;
  final VoidCallback        onCopy;

  const _RightPanel({
    required this.selectedVerse,
    required this.selectedIndex,
    required this.highlights,
    required this.notes,
    required this.verses,
    required this.book,
    required this.chapter,
    required this.onHighlight,
    required this.onBookmark,
    required this.onAddNote,
    required this.onShare,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selectedVerse != null;

    return Container(
      width: 260,
      color: _darkSurface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Highlight ──────────────────────────────────
            Text('Highlight',
                style: AppTextStyles.sectionTitle
                    .copyWith(color: _darkText)),
            const SizedBox(height: 6),

            // Hint when nothing selected
            if (!hasSelection)
              Text('Tap a verse to select it',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: _darkSubtext)),

            const SizedBox(height: 10),

            // Colour circles — active when verse selected
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppColors.highlightColors.map((c) {
                // Is this colour already applied to selected verse?
                final bool applied =
                    hasSelection && highlights[selectedIndex] == c;
                return GestureDetector(
                  onTap: hasSelection ? () => onHighlight(c) : null,
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    width:    36,
                    height:   36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: applied
                          ? Border.all(
                              color: AppColors.white,
                              width: 3)
                          : null,
                      boxShadow: hasSelection
                          ? [BoxShadow(
                              color: c.withValues(alpha: 0.4),
                              blurRadius: 6)]
                          : null,
                    ),
                    child: applied
                        ? const Icon(Icons.check_rounded,
                            color: Colors.black54, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),

            // ── Actions (when verse selected) ──────────────
            if (hasSelection) ...[
              const SizedBox(height: 16),
              _PanelActionRow(
                icon:  Icons.bookmark_outline_rounded,
                label: 'Bookmark',
                onTap: onBookmark,
              ),
              _PanelActionRow(
                icon:  Icons.edit_note_rounded,
                label: 'Add note',
                onTap: onAddNote,
              ),
              _PanelActionRow(
                icon:  Icons.share_rounded,
                label: 'Share as post',
                onTap: onShare,
              ),
              _PanelActionRow(
                icon:  Icons.copy_rounded,
                label: 'Copy',
                onTap: onCopy,
              ),
            ],

            const Divider(color: _darkBorder, height: 32),

            // ── Notes in this chapter ──────────────────────
            Text('Notes in this chapter',
                style: AppTextStyles.sectionTitle
                    .copyWith(color: _darkText)),
            const SizedBox(height: 12),

            if (notes.isEmpty)
              Text('No notes yet.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: _darkSubtext))
            else
              ...notes.entries.map((e) {
                final ref =
                    '$book $chapter:${verses[e.key].startVerse}';
                return _DarkNoteCard(reference: ref, note: e.value);
              }),

            const Divider(color: _darkBorder, height: 32),

            // ── Book progress ──────────────────────────────
            Text('$book progress',
                style: AppTextStyles.sectionTitle
                    .copyWith(color: _darkText)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:           1 / 50,
                backgroundColor: _darkBorder,
                valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text('1 of 50 chapters',
                style: AppTextStyles.bodySmall
                    .copyWith(color: _darkSubtext)),
          ],
        ),
      ),
    );
  }
}

// ── Panel action row ──────────────────────────────────────────
class _PanelActionRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final VoidCallback onTap;
  const _PanelActionRow(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:    onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: _darkSubtext, size: 18),
            const SizedBox(width: 10),
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: _darkText)),
          ],
        ),
      ),
    );
  }
}

// ── Dark note card ────────────────────────────────────────────
class _DarkNoteCard extends StatelessWidget {
  final String reference;
  final String note;
  const _DarkNoteCard({required this.reference, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:  _darkBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: const Border(
            left: BorderSide(color: AppColors.orange, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reference,
              style: AppTextStyles.verseReference.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(note,
              style: AppTextStyles.bodySmall
                  .copyWith(color: _darkSubtext)),
        ],
      ),
    );
  }
}

// ── Translation pills ─────────────────────────────────────────
class _TranslationPills extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChange;
  final bool dark;

  const _TranslationPills({
    required this.selected,
    required this.onChange,
    required this.dark,
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
            padding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.orange
                  : (dark ? _darkSurface : AppColors.inputFill),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Text(t,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isActive
                      ? AppColors.textDark
                      : (dark ? _darkSubtext : AppColors.textMedium),
                  fontWeight:
                      isActive ? FontWeight.w800 : FontWeight.w500,
                )),
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
  final bool   dark;

  const _BreadcrumbRow({
    required this.book,
    required this.chapter,
    required this.timerLabel,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$book › Chapter $chapter',
            style: AppTextStyles.labelMedium.copyWith(
                color: dark ? _darkText : AppColors.textDark)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: dark ? _darkSurface : AppColors.inputFill,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          child: Text(timerLabel,
              style: AppTextStyles.labelSmall.copyWith(
                  color: dark ? _darkSubtext : AppColors.textMedium)),
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
  final bool         dark;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _VerseBlock({
    required this.verse,
    this.highlight,
    this.isSelected  = false,
    this.dark        = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // When a highlight colour is applied, use it as the background.
    // When just selected (no highlight yet), use a subtle selection tint.
    final Color? bg = highlight != null
        ? highlight!.withValues(alpha: dark ? 0.30 : 0.35)
        : (isSelected
            ? (dark
                ? AppColors.white.withValues(alpha: 0.07)
                : AppColors.primaryPurple.withValues(alpha: 0.06))
            : null);

    return GestureDetector(
      onTap:      onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        margin:   const EdgeInsets.only(bottom: AppConstants.paddingSm),
        padding:  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(6),
          // Selected verse gets a subtle left orange accent on wide
          border: isSelected && dark
              ? const Border(
                  left: BorderSide(color: AppColors.orange, width: 3))
              : null,
        ),
        child: RichText(
          text: TextSpan(
            children: [
              // Verse number — orange superscript style
              TextSpan(
                text:  '${verse.startVerse} ',
                style: GoogleFonts.playfairDisplay(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.orange,
                ),
              ),
              // Verse body text
              TextSpan(
                text:  verse.text,
                style: GoogleFonts.playfairDisplay(
                  fontSize:   dark ? 20 : 18,
                  fontWeight: FontWeight.w400,
                  color:      dark ? _darkText : AppColors.textDark,
                  height:     1.75,
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
  final bool dark;

  const _BottomControls({
    required this.onMarkRead,
    required this.onPrevious,
    required this.onNext,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _NavButton(
                label: '‹ Previous', onTap: onPrevious, dark: dark)),
            const SizedBox(width: 12),
            Expanded(child: _NavButton(
                label: 'Next ›', onTap: onNext, dark: dark)),
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
  final bool dark;
  const _NavButton(
      {required this.label, required this.onTap, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height:    AppConstants.buttonHeightSm,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:  dark ? _darkSurface : AppColors.white,
          border: Border.all(
              color: dark
                  ? _darkBorder
                  : AppColors.divider,
              width: 1.5),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Text(label,
            style: AppTextStyles.labelMedium.copyWith(
                color: dark ? _darkText : AppColors.textDark)),
      ),
    );
  }
}
