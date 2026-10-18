// ============================================================
// FILE: lib/models/bookmark.dart
//
// PURPOSE: Defines a saved/bookmarked verse.
//
// When a user long-presses a verse and taps "Bookmark",
// a Bookmark object is created. It can also have:
//   - An optional personal note ("read at dawn")
//   - An optional highlight color
//   - An optional collection name ("Peace", "Anxiety")
// ============================================================

import 'package:flutter/material.dart';
import 'bible_verse.dart';

class Bookmark {
  final String id;
  final BibleVerse verse;
  final String? note;             // Optional personal note
  final Color? highlightColor;    // The highlight color chosen
  final String? collectionName;   // e.g. "Peace", "Anxiety"
  final DateTime savedAt;

  const Bookmark({
    required this.id,
    required this.verse,
    required this.savedAt,
    this.note,
    this.highlightColor,
    this.collectionName,
  });
}

// ── BookmarkCollection ───────────────────────────────────────
// A named group of bookmarks shown on the Bookmarks screen
// (e.g. the "Peace" and "Anxiety" collections in the designs).
class BookmarkCollection {
  final String name;
  final List<Bookmark> bookmarks;
  // The colors used to render the grid preview on the collection card.
  final List<Color> previewColors;

  const BookmarkCollection({
    required this.name,
    required this.bookmarks,
    required this.previewColors,
  });

  /// Total number of verses in this collection.
  int get verseCount => bookmarks.length;
}
