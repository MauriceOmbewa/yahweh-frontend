// ============================================================
// FILE: lib/features/read/read_screen.dart
//
// PURPOSE: The Read tab entry — book/chapter browser + bookmarks.
//
// LAYOUT:
//   AppBar: "Read" title + bookmarks icon
//   Currently reading card (Genesis 1 — opens ChapterScreen)
//   Books of the Bible list grouped by testament
//   Tapping a book → shows its chapters → tapping chapter
//   opens ChapterScreen
// ============================================================

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import 'chapter_screen.dart';
import 'bookmarks_screen.dart';

// Sample books — in a real app fetched from Bible API
const List<Map<String, dynamic>> _oldTestament = [
  {'name': 'Genesis',  'chapters': 50},
  {'name': 'Exodus',   'chapters': 40},
  {'name': 'Psalms',   'chapters': 150},
  {'name': 'Proverbs', 'chapters': 31},
  {'name': 'Isaiah',   'chapters': 66},
];

const List<Map<String, dynamic>> _newTestament = [
  {'name': 'Matthew',      'chapters': 28},
  {'name': 'John',         'chapters': 21},
  {'name': 'Romans',       'chapters': 16},
  {'name': 'Philippians',  'chapters': 4},
  {'name': 'Revelation',   'chapters': 22},
];

class ReadScreen extends StatelessWidget {
  const ReadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:          AppColors.backgroundLight,
        elevation:                 0,
        scrolledUnderElevation:    0,
        automaticallyImplyLeading: false,
        title: Text('Read', style: AppTextStyles.headingLarge),
        actions: [
          // Bookmarks icon
          IconButton(
            icon: const Icon(Iconsax.bookmark,
                color: AppColors.textDark, size: 22),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const BookmarksScreen())),
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Continue reading card ──────────────────
                _ContinueReadingCard(
                  book:    'Genesis',
                  chapter: 1,
                  progress: 0.02, // 1 of 50 chapters
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChapterScreen(
                          book: 'Genesis', chapter: 1),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLg),

                // ── Old Testament ──────────────────────────
                Text('Old Testament',
                    style: AppTextStyles.sectionTitle),
                const SizedBox(height: AppConstants.paddingSm),
                ..._oldTestament.map((b) => _BookRow(
                      bookName:   b['name'] as String,
                      chapters:   b['chapters'] as int,
                    )),

                const SizedBox(height: AppConstants.paddingMd),

                // ── New Testament ──────────────────────────
                Text('New Testament',
                    style: AppTextStyles.sectionTitle),
                const SizedBox(height: AppConstants.paddingSm),
                ..._newTestament.map((b) => _BookRow(
                      bookName:   b['name'] as String,
                      chapters:   b['chapters'] as int,
                    )),

                const SizedBox(height: AppConstants.paddingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Continue reading card ─────────────────────────────────────
class _ContinueReadingCard extends StatelessWidget {
  final String book;
  final int    chapter;
  final double progress; // 0.0–1.0
  final VoidCallback onTap;

  const _ContinueReadingCard({
    required this.book,
    required this.chapter,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D2B82), Color(0xFF1A0F4A)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Continue reading',
              style: AppTextStyles.sectionTitleCaps),
          const SizedBox(height: 8),
          Text('$book › Chapter $chapter',
              style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.white)),
          const SizedBox(height: 4),
          Text('${(progress * 50).round()} of 50 chapters',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:            progress,
              backgroundColor:  AppColors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.orange),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label:  'Open Chapter $chapter',
            onTap:  onTap,
            height: AppConstants.buttonHeightSm,
          ),
        ],
      ),
    );
  }
}

// ── Book row ──────────────────────────────────────────────────
class _BookRow extends StatelessWidget {
  final String bookName;
  final int    chapters;

  const _BookRow({required this.bookName, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:    () => _showChapterPicker(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin:  const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMd, vertical: 14),
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Row(
          children: [
            Expanded(child: Text(bookName,
                style: AppTextStyles.labelMedium)),
            Text('$chapters chapters',
                style: AppTextStyles.bodySmall),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMedium, size: 20),
          ],
        ),
      ),
    );
  }

  // Shows a bottom sheet with chapter numbers to pick from
  void _showChapterPicker(BuildContext context) {
    showModalBottomSheet(
      context:         context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXl)),
      ),
      builder: (_) => _ChapterPickerSheet(
          book: bookName, totalChapters: chapters),
    );
  }
}

// ── Chapter picker bottom sheet ───────────────────────────────
class _ChapterPickerSheet extends StatelessWidget {
  final String book;
  final int    totalChapters;

  const _ChapterPickerSheet({
      required this.book, required this.totalChapters});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color:        AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(book, style: AppTextStyles.headingMedium),
          const SizedBox(height: 16),
          // Chapter number grid
          SizedBox(
            height: 240,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:   7,
                mainAxisSpacing:  8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: totalChapters,
              itemBuilder: (_, i) {
                final ch = i + 1;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // close sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterScreen(
                            book: book, chapter: ch),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:        AppColors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text('$ch',
                        style: AppTextStyles.labelMedium
                            .copyWith(fontSize: 13)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
        ],
      ),
    );
  }
}
