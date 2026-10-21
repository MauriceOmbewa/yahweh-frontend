// ============================================================
// FILE: lib/features/read/bookmarks_screen.dart
//
// PURPOSE: Shows saved bookmarks + named collections.
//          Users can CREATE collections, ADD bookmarks to them,
//          and VIEW a collection's verses.
//
// FLOWS:
//   1. Collections tab → tap "+" → _CreateCollectionDialog
//      → enter name → collection created
//
//   2. All tab → tap "⋮" on a bookmark → _AddToCollectionSheet
//      → choose existing collection or create new
//      → bookmark assigned
//
//   3. Collections tab → tap a card → _CollectionDetailScreen
//      (pushed as a new route on top)
//
// STATE: All managed locally with setState — no backend yet.
//   The screen initialises from MockData and then manages its
//   own mutable lists of bookmarks + collections.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/mock_data.dart';
import '../../models/bookmark.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';

  // ── Local mutable state ───────────────────────────────────
  // We copy MockData into local lists so the screen can add/remove
  // without touching the global mock data.
  late List<Bookmark>           _bookmarks;
  late List<BookmarkCollection> _collections;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Deep-copy mock data into mutable lists
    _bookmarks   = List.from(MockData.bookmarks);
    _collections = MockData.bookmarkCollections
        .map((c) => BookmarkCollection(
              name:          c.name,
              bookmarks:     List.from(c.bookmarks),
              previewColors: List.from(c.previewColors),
            ))
        .toList();

    _searchController.addListener(
        () => setState(() => _query = _searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtered bookmarks (search) ───────────────────────────
  List<Bookmark> get _filteredBookmarks {
    if (_query.isEmpty) return _bookmarks;
    return _bookmarks.where((b) =>
        b.verse.reference.toLowerCase().contains(_query) ||
        b.verse.text.toLowerCase().contains(_query)).toList();
  }

  // ── Create a new empty collection ────────────────────────
  void _createCollection(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _collections.add(BookmarkCollection(
        name:          name.trim(),
        bookmarks:     [],
        previewColors: [
          AppColors.highlightYellow,
          AppColors.highlightGreen,
          AppColors.highlightBlue,
          AppColors.highlightPink,
        ],
      ));
    });
  }

  // ── Add a bookmark to a collection ───────────────────────
  void _addToCollection(Bookmark bookmark, String collectionName) {
    setState(() {
      final idx = _collections.indexWhere((c) => c.name == collectionName);
      if (idx == -1) return;

      // Replace the collection with a new one that includes the bookmark
      final existing = _collections[idx];
      final updated  = List<Bookmark>.from(existing.bookmarks)..add(bookmark);

      _collections[idx] = BookmarkCollection(
        name:          existing.name,
        bookmarks:     updated,
        previewColors: existing.previewColors,
      );

      // Also update the bookmark's collectionName field
      final bIdx = _bookmarks.indexWhere((b) => b.id == bookmark.id);
      if (bIdx != -1) {
        _bookmarks[bIdx] = Bookmark(
          id:             bookmark.id,
          verse:          bookmark.verse,
          savedAt:        bookmark.savedAt,
          note:           bookmark.note,
          highlightColor: bookmark.highlightColor,
          collectionName: collectionName,
        );
      }
    });
  }

  // ── Remove a bookmark from a collection ──────────────────
  void _removeFromCollection(Bookmark bookmark, String collectionName) {
    setState(() {
      final idx = _collections.indexWhere((c) => c.name == collectionName);
      if (idx == -1) return;
      final existing = _collections[idx];
      final updated = existing.bookmarks
          .where((b) => b.id != bookmark.id)
          .toList();
      _collections[idx] = BookmarkCollection(
        name:          existing.name,
        bookmarks:     updated,
        previewColors: existing.previewColors,
      );
    });
  }

  // ── Delete a collection ───────────────────────────────────
  void _deleteCollection(String name) {
    setState(() {
      _collections.removeWhere((c) => c.name == name);
    });
  }

  // ── Show "create collection" dialog ──────────────────────
  Future<void> _showCreateCollectionDialog() async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => _CreateCollectionDialog(
        controller: ctrl,
        onConfirm:  () {
          _createCollection(ctrl.text);
          Navigator.pop(context);
        },
        existingNames: _collections.map((c) => c.name).toList(),
      ),
    );
  }

  // ── Show "add to collection" bottom sheet ─────────────────
  void _showAddToCollectionSheet(Bookmark bookmark) {
    showModalBottomSheet(
      context:         context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXl)),
      ),
      builder: (_) => _AddToCollectionSheet(
        bookmark:    bookmark,
        collections: _collections,
        onAdd:       (name) {
          _addToCollection(bookmark, name);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Added to "$name"',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.white)),
            backgroundColor: AppColors.primaryPurple,
            behavior:        SnackBarBehavior.floating,
            duration:        const Duration(seconds: 2),
          ));
        },
        onCreateNew: () async {
          Navigator.pop(context); // close sheet first
          await _showCreateCollectionDialog();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title:        Text('Bookmarks', style: AppTextStyles.headingLarge),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _TabSwitcher(controller: _tabController),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              // ── Search bar (All tab only) ──────────────────
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                child: _SearchBar(controller: _searchController),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── Tab 0: All bookmarks ─────────────────
                    _AllBookmarksList(
                      bookmarks:   _filteredBookmarks,
                      collections: _collections,
                      onAddToCollection: _showAddToCollectionSheet,
                    ),

                    // ── Tab 1: Collections ───────────────────
                    _CollectionsTab(
                      collections:    _collections,
                      onCreateNew:    _showCreateCollectionDialog,
                      onDelete:       _deleteCollection,
                      onRemoveBookmark: _removeFromCollection,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ALL BOOKMARKS LIST
// ════════════════════════════════════════════════════════════
class _AllBookmarksList extends StatelessWidget {
  final List<Bookmark>           bookmarks;
  final List<BookmarkCollection> collections;
  final void Function(Bookmark)  onAddToCollection;

  const _AllBookmarksList({
    required this.bookmarks,
    required this.collections,
    required this.onAddToCollection,
  });

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_outline_rounded,
                size: 48, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text('No bookmarks yet.',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Text('Long-press a verse while reading to bookmark it.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding:     const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd),
      itemCount:   bookmarks.length,
      itemBuilder: (_, i) => _BookmarkCard(
        bookmark:         bookmarks[i],
        onAddToCollection: () => onAddToCollection(bookmarks[i]),
      ),
    );
  }
}

// ── Single bookmark card ──────────────────────────────────────
class _BookmarkCard extends StatelessWidget {
  final Bookmark     bookmark;
  final VoidCallback onAddToCollection;

  const _BookmarkCard({
    required this.bookmark,
    required this.onAddToCollection,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = bookmark.highlightColor ?? AppColors.orange;

    return Container(
      margin:  const EdgeInsets.only(bottom: AppConstants.paddingSm),
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bookmark.verse.reference,
                    style: AppTextStyles.verseReference),
                const SizedBox(height: 6),
                Text(bookmark.verse.text,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (bookmark.note != null) ...[
                  const SizedBox(height: 4),
                  Text('Note: ${bookmark.note}',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontStyle: FontStyle.italic)),
                ],
                if (bookmark.collectionName != null) ...[
                  const SizedBox(height: 6),
                  // Show which collection it's in (if any)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:        AppColors.primaryPurple
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull),
                    ),
                    child: Text(
                      bookmark.collectionName!,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryPurple),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ⋮ menu button — opens "Add to collection" sheet
          GestureDetector(
            onTap: onAddToCollection,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.more_vert_rounded,
                  color: AppColors.textMedium, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  COLLECTIONS TAB
// ════════════════════════════════════════════════════════════
class _CollectionsTab extends StatelessWidget {
  final List<BookmarkCollection> collections;
  final VoidCallback             onCreateNew;
  final void Function(String)    onDelete;
  final void Function(Bookmark, String) onRemoveBookmark;

  const _CollectionsTab({
    required this.collections,
    required this.onCreateNew,
    required this.onDelete,
    required this.onRemoveBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid of collection cards
        collections.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.collections_bookmark_outlined,
                        size: 48, color: AppColors.textLight),
                    const SizedBox(height: 12),
                    Text('No collections yet.',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Text('Tap + to create your first collection.',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppConstants.paddingMd, AppConstants.paddingMd,
                    AppConstants.paddingMd, 80), // 80 = space for FAB
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:   2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing:  12,
                  childAspectRatio: 1.0,
                ),
                itemCount:   collections.length,
                itemBuilder: (_, i) => _CollectionCard(
                  collection:      collections[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _CollectionDetailScreen(
                        collection:      collections[i],
                        onRemoveBookmark: onRemoveBookmark,
                      ),
                    ),
                  ),
                  onDelete: () => onDelete(collections[i].name),
                ),
              ),

        // ── Floating "+" button ────────────────────────────
        Positioned(
          bottom: 24,
          right:  AppConstants.paddingMd,
          child: FloatingActionButton.extended(
            onPressed:        onCreateNew,
            backgroundColor:  AppColors.orange,
            foregroundColor:  AppColors.textDark,
            icon:  const Icon(Icons.add_rounded),
            label: Text('New collection',
                style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textDark)),
          ),
        ),
      ],
    );
  }
}

// ── Collection card ───────────────────────────────────────────
class _CollectionCard extends StatelessWidget {
  final BookmarkCollection collection;
  final VoidCallback        onTap;
  final VoidCallback        onDelete;

  const _CollectionCard({
    required this.collection,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4-colour preview mosaic
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppConstants.radiusMd)),
                    child: collection.previewColors.isEmpty
                        ? Container(color: AppColors.inputFill)
                        : GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics:    const NeverScrollableScrollPhysics(),
                            children: collection.previewColors
                                .take(4)
                                .map<Widget>(
                                    (c) => Container(color: c))
                                .toList(),
                          ),
                  ),
                  // Delete button — top right
                  Positioned(
                    top:   6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Container(
                        width:  26,
                        height: 26,
                        decoration: BoxDecoration(
                          color:  Colors.black.withValues(alpha: 0.4),
                          shape:  BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(collection.name,
                      style: AppTextStyles.labelMedium),
                  Text('${collection.verseCount} verse'
                      '${collection.verseCount == 1 ? '' : 's'}',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete collection?'),
        content: Text(
            'This will delete "${collection.name}" and remove all its bookmarks from it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:     const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  COLLECTION DETAIL SCREEN
// ════════════════════════════════════════════════════════════
class _CollectionDetailScreen extends StatelessWidget {
  final BookmarkCollection             collection;
  final void Function(Bookmark, String) onRemoveBookmark;

  const _CollectionDetailScreen({
    required this.collection,
    required this.onRemoveBookmark,
  });

  @override
  Widget build(BuildContext context) {
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(collection.name, style: AppTextStyles.headingLarge),
            Text('${collection.verseCount} verse'
                '${collection.verseCount == 1 ? '' : 's'}',
                style: AppTextStyles.bodySmall),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: collection.bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bookmark_outline_rounded,
                          size: 48, color: AppColors.textLight),
                      const SizedBox(height: 12),
                      Text('No verses in this collection yet.',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMd),
                  itemCount:   collection.bookmarks.length,
                  itemBuilder: (_, i) {
                    final b = collection.bookmarks[i];
                    return _CollectionVerseCard(
                      bookmark:  b,
                      onRemove:  () {
                        onRemoveBookmark(b, collection.name);
                        Navigator.pop(context); // close detail
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

// ── Collection verse card ─────────────────────────────────────
class _CollectionVerseCard extends StatelessWidget {
  final Bookmark     bookmark;
  final VoidCallback onRemove;

  const _CollectionVerseCard({
    required this.bookmark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = bookmark.highlightColor ?? AppColors.orange;

    return Container(
      margin:  const EdgeInsets.only(bottom: AppConstants.paddingSm),
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bookmark.verse.reference,
                    style: AppTextStyles.verseReference),
                const SizedBox(height: 6),
                Text(bookmark.verse.text,
                    style: AppTextStyles.bodyMedium),
                if (bookmark.note != null) ...[
                  const SizedBox(height: 4),
                  Text('Note: ${bookmark.note}',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
          // Remove from collection button
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.remove_circle_outline_rounded,
                  color: AppColors.textMedium, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  CREATE COLLECTION DIALOG
// ════════════════════════════════════════════════════════════
class _CreateCollectionDialog extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback          onConfirm;
  final List<String>          existingNames;

  const _CreateCollectionDialog({
    required this.controller,
    required this.onConfirm,
    required this.existingNames,
  });

  @override
  State<_CreateCollectionDialog> createState() =>
      _CreateCollectionDialogState();
}

class _CreateCollectionDialogState
    extends State<_CreateCollectionDialog> {
  String _error = '';

  void _validate() {
    final name = widget.controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a name.');
      return;
    }
    if (widget.existingNames.contains(name)) {
      setState(() => _error = 'A collection named "$name" already exists.');
      return;
    }
    setState(() => _error = '');
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
      title: Text('New collection',
          style: AppTextStyles.headingMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Give your collection a name.',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller:  widget.controller,
            autofocus:   true,
            decoration:  InputDecoration(
              hintText:  'e.g. Peace, Anxiety, Morning prayers',
              hintStyle: AppTextStyles.inputHint,
            ),
            onSubmitted: (_) => _validate(),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(_error, style: AppTextStyles.errorText),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:     const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:       _validate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: AppColors.textDark,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMd)),
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ADD TO COLLECTION SHEET
// ════════════════════════════════════════════════════════════
class _AddToCollectionSheet extends StatelessWidget {
  final Bookmark                 bookmark;
  final List<BookmarkCollection> collections;
  final void Function(String)    onAdd;
  final VoidCallback             onCreateNew;

  const _AddToCollectionSheet({
    required this.bookmark,
    required this.collections,
    required this.onAdd,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Push sheet above keyboard if open
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  color:        AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMd, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add to collection',
                    style: AppTextStyles.headingMedium),
                const SizedBox(height: 4),
                Text(
                  bookmark.verse.reference,
                  style: AppTextStyles.verseReference,
                ),
                const SizedBox(height: 16),

                // Existing collections list
                if (collections.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('No collections yet.',
                        style: AppTextStyles.bodySmall),
                  )
                else
                  ...collections.map((c) {
                    final bool alreadyAdded =
                        c.bookmarks.any((b) => b.id == bookmark.id);
                    return GestureDetector(
                      onTap: alreadyAdded ? null : () => onAdd(c.name),
                      child: Container(
                        margin: const EdgeInsets.only(
                            bottom: AppConstants.paddingSm),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMd,
                            vertical: 14),
                        decoration: BoxDecoration(
                          color: alreadyAdded
                              ? AppColors.inputFill
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusMd),
                          border: Border.all(
                              color: alreadyAdded
                                  ? AppColors.primaryPurple
                                  : AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(c.name,
                                    style:
                                        AppTextStyles.labelMedium)),
                            Text(
                              alreadyAdded ? 'Added ✓' : 'Add',
                              style: AppTextStyles.labelSmall
                                  .copyWith(
                                    color: alreadyAdded
                                        ? AppColors.primaryPurple
                                        : AppColors.textMedium,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),

                // Create new collection option
                GestureDetector(
                  onTap: onCreateNew,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        width:  36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:        AppColors.orange
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusFull),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: AppColors.orange, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text('Create new collection',
                          style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  TAB SWITCHER
// ════════════════════════════════════════════════════════════
class _TabSwitcher extends StatelessWidget {
  final TabController controller;
  const _TabSwitcher({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller:            controller,
      labelColor:            AppColors.white,
      unselectedLabelColor:  AppColors.textMedium,
      labelStyle:            AppTextStyles.labelMedium,
      indicator: BoxDecoration(
        color:        AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor:  Colors.transparent,
      tabs: const [Tab(text: 'All'), Tab(text: 'Collections')],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SEARCH BAR
// ════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style:      AppTextStyles.inputText,
      decoration: InputDecoration(
        hintText:   'Search bookmarks',
        hintStyle:  AppTextStyles.inputHint,
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.textLight, size: 20),
        filled:     true,
        fillColor:  AppColors.inputFill,
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
            vertical: 14, horizontal: 16),
      ),
    );
  }
}
