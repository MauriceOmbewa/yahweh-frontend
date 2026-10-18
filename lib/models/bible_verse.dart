// ============================================================
// FILE: lib/models/bible_verse.dart
//
// PURPOSE: Defines what a Bible verse looks like in the app.
//
// A BibleVerse is used in:
//   - The Bible reader screen (showing verse text)
//   - Feed posts (the quoted verse inside a card)
//   - Bookmarks (saved verses)
//   - Status verse on profile
//   - Chat (when someone shares a verse)
// ============================================================

class BibleVerse {
  final String book;        // e.g. "Genesis", "Psalm", "John"
  final int chapter;        // e.g. 1, 23, 3
  final int startVerse;     // e.g. 1
  final int? endVerse;      // Optional — if null, it's a single verse
  final String text;        // The actual verse content
  final String translation; // e.g. "NIV", "ESV", "KJV"

  const BibleVerse({
    required this.book,
    required this.chapter,
    required this.startVerse,
    required this.text,
    required this.translation,
    this.endVerse,
  });

  // ── Computed Properties ──────────────────────────────────────
  // These are values we can CALCULATE from the stored data.
  // We don't need to store them — we derive them on the fly.

  /// Returns a formatted reference string like "Psalm 23:1–2" or "John 3:16"
  String get reference {
    if (endVerse != null && endVerse != startVerse) {
      return '$book $chapter:$startVerse–$endVerse';
    }
    return '$book $chapter:$startVerse';
  }

  /// Full reference with translation: "Psalm 23:1 · NIV"
  String get referenceWithTranslation => '$reference · $translation';
}
