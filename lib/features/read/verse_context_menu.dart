// ============================================================
// FILE: lib/features/read/verse_context_menu.dart
//
// PURPOSE: Bottom sheet shown when a user long-presses a verse.
//
// THEME: Light background (white) — matches all other screens.
//        The design screenshot shows this as dark — we keep it
//        light until told otherwise.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/bible_verse.dart';

enum VerseAction { highlight, bookmark, addNote, shareAsPost, copy }

class VerseContextMenu extends StatelessWidget {
  final BibleVerse verse;
  final void Function(VerseAction action, {Color? highlightColor})? onAction;

  const VerseContextMenu({
    super.key,
    required this.verse,
    this.onAction,
  });

  static void show(
    BuildContext context, {
    required BibleVerse verse,
    void Function(VerseAction action, {Color? highlightColor})? onAction,
  }) {
    showModalBottomSheet(
      context:         context,
      backgroundColor: AppColors.white, // ← light
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXl)),
      ),
      builder: (_) => VerseContextMenu(verse: verse, onAction: onAction),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,           // ← light
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color:        AppColors.divider, // ← light divider
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Verse reference (orange)
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMd, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(verse.reference,
                  style: AppTextStyles.verseReference),
            ),
          ),

          // Highlight color circles
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMd, vertical: 8),
            child: Row(
              children: AppColors.highlightColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onAction?.call(VerseAction.highlight,
                        highlightColor: color);
                  },
                  child: Container(
                    width:  38,
                    height: 38,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          _MenuItem(
            label: 'Bookmark',
            icon:  Icons.bookmark_outline_rounded,
            onTap: () {
              Navigator.pop(context);
              onAction?.call(VerseAction.bookmark);
            },
          ),
          const Divider(height: 1),
          _MenuItem(
            label: 'Add note',
            icon:  Icons.edit_note_rounded,
            onTap: () {
              Navigator.pop(context);
              onAction?.call(VerseAction.addNote);
            },
          ),
          const Divider(height: 1),
          _MenuItem(
            label: 'Share as post',
            icon:  Icons.share_rounded,
            onTap: () {
              Navigator.pop(context);
              onAction?.call(VerseAction.shareAsPost);
            },
          ),
          const Divider(height: 1),
          _MenuItem(
            label: 'Copy',
            icon:  Icons.copy_rounded,
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(
                  text:
                      '${verse.text} — ${verse.referenceWithTranslation}'));
              onAction?.call(VerseAction.copy);
            },
          ),
          const SizedBox(height: AppConstants.paddingMd),
        ],
      ),
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:    onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMd, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textDark, size: 20), // ← dark icon
            const SizedBox(width: 14),
            Text(label,
                style: AppTextStyles.bodyMedium), // ← dark text
          ],
        ),
      ),
    );
  }
}
