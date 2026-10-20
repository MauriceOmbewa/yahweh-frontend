// ============================================================
// FILE: lib/features/share/share_verse_screen.dart
//
// PURPOSE: The "Share a verse" bottom sheet — opened when the
//          centre "+" FAB is tapped from any shell tab.
//
// WHAT IT SHOWS (matching the design):
//   ─── drag handle ────────────────────────────────────────
//   Share a verse
//   [ Search verse, e.g. John 3:16         ]  ← search field
//
//   ┌─────────────────────────────────────┐
//   │ John 3:16                     NIV   │  ← verse preview card
//   │ │ For God so loved the world...     │
//   └─────────────────────────────────────┘
//
//   [ Add a caption...                    ]  ← multiline text area
//                                     0/500
//   [ Friends only  |  Public ]            ← segmented toggle
//   [           Post           ]           ← orange button
//
// HOW TO OPEN IT:
//   ShareVerseScreen.show(context)
//
// STATE:
//   - _searchController  → typed verse reference
//   - _captionController → caption text
//   - _selectedVerse     → the verse currently previewed
//   - _isPublic          → Friends only vs Public toggle
// ============================================================

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../data/mock_data.dart';
import '../../models/bible_verse.dart';

class ShareVerseScreen extends StatefulWidget {
  const ShareVerseScreen({super.key});

  // ── Static helper — open as a bottom sheet ────────────────
  // Usage anywhere in the app: ShareVerseScreen.show(context)
  static void show(BuildContext context) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,    // Lets the sheet grow with keyboard
      backgroundColor:    Colors.transparent,
      builder: (_) => const ShareVerseScreen(),
    );
  }

  @override
  State<ShareVerseScreen> createState() => _ShareVerseScreenState();
}

class _ShareVerseScreenState extends State<ShareVerseScreen> {
  final _searchController  = TextEditingController();
  final _captionController = TextEditingController();

  // The verse currently shown in the preview card.
  // Starts with John 3:16 as the default (matches the design).
  BibleVerse? _selectedVerse = MockData.john3v16;

  // false = Friends only (default), true = Public
  bool _isPublic = false;

  // Caption character count
  int get _captionLength => _captionController.text.length;

  @override
  void initState() {
    super.initState();
    // Rebuild when caption changes so the counter updates live.
    _captionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  // ── Search: match verse from mock data ────────────────────
  // In a real app this would call a Bible API.
  // For now we match against the mock verses list.
  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) return;

    // Simple search: check if query matches any mock verse reference
    final lq = query.toLowerCase();
    final allVerses = [
      MockData.john3v16,
      MockData.psalm23v1,
      MockData.philippians4v6,
      MockData.psalm119v105,
      MockData.genesis1v1,
    ];

    final match = allVerses.where((v) =>
      v.reference.toLowerCase().contains(lq) ||
      v.book.toLowerCase().contains(lq)
    ).firstOrNull;

    if (match != null) {
      setState(() => _selectedVerse = match);
    }
  }

  // ── Post ──────────────────────────────────────────────────
  void _onPost() {
    if (_selectedVerse == null) return;
    // TODO: In a real app — send to API, then close sheet.
    // For now just close the bottom sheet.
    Navigator.pop(context);

    // Show a brief confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Posted ${_selectedVerse!.reference}',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryPurple,
        duration:        const Duration(seconds: 2),
        behavior:        SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery.of(context).viewInsets.bottom is the height of
    // the keyboard when it's open. Adding padding here makes the
    // sheet push up above the keyboard automatically.
    final double keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Rounded top corners only
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      // Padding at the bottom = keyboard height so nothing is hidden
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingLg,
          0,
          AppConstants.paddingLg,
          AppConstants.paddingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Sheet only as tall as content
          children: [
            // ── Drag handle ───────────────────────────────────
            const _DragHandle(),
            const SizedBox(height: 16),

            // ── Heading ───────────────────────────────────────
            Text('Share a verse', style: AppTextStyles.headingMedium),
            const SizedBox(height: 20),

            // ── Verse search field ────────────────────────────
            _VerseSearchField(
              controller: _searchController,
              onChanged:  _onSearchChanged,
            ),
            const SizedBox(height: 16),

            // ── Verse preview card ────────────────────────────
            // Only shown once a verse is selected.
            if (_selectedVerse != null) ...[
              _VersePreviewCard(verse: _selectedVerse!),
              const SizedBox(height: 16),
            ],

            // ── Caption text area ─────────────────────────────
            _CaptionField(
              controller:    _captionController,
              currentLength: _captionLength,
            ),
            const SizedBox(height: 20),

            // ── Friends only / Public toggle ──────────────────
            _VisibilityToggle(
              isPublic: _isPublic,
              onChanged: (val) => setState(() => _isPublic = val),
            ),
            const SizedBox(height: 20),

            // ── Post button ───────────────────────────────────
            AppButton(
              label: 'Post',
              onTap: _onPost,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SUB-WIDGETS
// ════════════════════════════════════════════════════════════

// ── Drag handle ───────────────────────────────────────────────
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          width:  40,
          height: 4,
          decoration: BoxDecoration(
            color:        AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ── Verse search field ────────────────────────────────────────
class _VerseSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _VerseSearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:      controller,
      onChanged:       onChanged,
      style:           AppTextStyles.inputText,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText:  'Search verse, e.g. John 3:16',
        hintStyle: AppTextStyles.inputHint,
        filled:    true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide:   BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(
              color: AppColors.inputBorder, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── Verse preview card ────────────────────────────────────────
// Shows the selected verse with orange reference + left border.
class _VersePreviewCard extends StatelessWidget {
  final BibleVerse verse;
  const _VersePreviewCard({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reference row: "John 3:16" (orange) + "NIV" pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(verse.reference, style: AppTextStyles.verseReference),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:        AppColors.white,
                  borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull),
                ),
                child: Text(verse.translation,
                    style: AppTextStyles.labelSmall),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Verse text with left orange border
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color:        AppColors.verseBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(verse.text,
                      style: AppTextStyles.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Caption field ─────────────────────────────────────────────
// Multiline text area with live 0/500 character counter.
class _CaptionField extends StatelessWidget {
  final TextEditingController controller;
  final int currentLength;

  const _CaptionField({
    required this.controller,
    required this.currentLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:  controller,
      maxLines:    5,
      minLines:    3,
      maxLength:   AppConstants.maxCaptionLength,
      style:       AppTextStyles.inputText,
      decoration: InputDecoration(
        hintText:       'Add a caption',
        hintStyle:      AppTextStyles.inputHint,
        filled:         true,
        fillColor:      AppColors.inputFill,
        // Hide the built-in counter — we'll show our own below
        counterText:    '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide:   BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(
              color: AppColors.inputBorder, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.paddingMd),
      ),
    );
  }
}

// ── Visibility toggle ─────────────────────────────────────────
// "Friends only" | "Public" segmented toggle.
// The selected side gets a dark navy fill; the other is white.
class _VisibilityToggle extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const _VisibilityToggle({
    required this.isPublic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:      52,
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Row(
        children: [
          // Friends only
          _ToggleOption(
            label:    'Friends only',
            isActive: !isPublic,
            onTap:    () => onChanged(false),
          ),
          // Public
          _ToggleOption(
            label:    'Public',
            isActive: isPublic,
            onTap:    () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          margin:   const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryPurple   // Active = dark navy fill
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isActive ? AppColors.white : AppColors.textMedium,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
