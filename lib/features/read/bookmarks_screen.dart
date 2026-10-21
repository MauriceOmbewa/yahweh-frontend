// ============================================================
// FILE: lib/features/read/bookmarks_screen.dart
//
// PURPOSE: Shows all saved bookmarks + named collections.
//
// LAYOUT:
//   AppBar: back arrow + "Bookmarks"
//   [All] [Collections] tab switcher
//   Search bar "Search bookmarks"
//   — All tab: list of bookmarked verse cards (with note)
//   — Collections tab: 2-column grid of collection cards
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(
        () => setState(() => _query = _searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Bookmark> get _filteredBookmarks {
    if (_query.isEmpty) return MockData.bookmarks;
    return MockData.bookmarks.where((b) =>
        b.verse.reference.toLowerCase().contains(_query) ||
        b.verse.text.toLowerCase().contains(_query)).toList();
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
        title: Text('Bookmarks', style: AppTextStyles.headingLarge),
        titleSpacing: 0,
        // All / Collections tab bar inside the appbar bottom
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
              // Search bar
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                child: _SearchBar(controller: _searchController),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All bookmarks
                    _AllBookmarksList(bookmarks: _filteredBookmarks),
                    // Collections grid
                    _CollectionsGrid(
                        collections: MockData.bookmarkCollections),
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

// ── Tab switcher (All / Collections) ─────────────────────────
class _TabSwitcher extends StatelessWidget {
  final TabController controller;
  const _TabSwitcher({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller:      controller,
      labelColor:      AppColors.white,
      unselectedLabelColor: AppColors.textMedium,
      labelStyle:      AppTextStyles.labelMedium,
      indicator: BoxDecoration(
        color:        AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      indicatorSize:  TabBarIndicatorSize.tab,
      dividerColor:   Colors.transparent,
      tabs: const [Tab(text: 'All'), Tab(text: 'Collections')],
    );
  }
}

// ── All bookmarks list ────────────────────────────────────────
class _AllBookmarksList extends StatelessWidget {
  final List<Bookmark> bookmarks;
  const _AllBookmarksList({required this.bookmarks});

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return Center(
          child: Text('No bookmarks yet.', style: AppTextStyles.bodySmall));
    }
    return ListView.builder(
      padding:     const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd),
      itemCount:   bookmarks.length,
      itemBuilder: (_, i) => _BookmarkCard(bookmark: bookmarks[i]),
    );
  }
}

// ── Single bookmark card ──────────────────────────────────────
class _BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  const _BookmarkCard({required this.bookmark});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bookmark.verse.reference,
              style: AppTextStyles.verseReference),
          const SizedBox(height: 6),
          Text(bookmark.verse.text,
              style: AppTextStyles.bodyMedium,
              maxLines: 2, overflow: TextOverflow.ellipsis),
          if (bookmark.note != null) ...[
            const SizedBox(height: 4),
            Text('Note: ${bookmark.note}',
                style: AppTextStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

// ── Collections grid ──────────────────────────────────────────
class _CollectionsGrid extends StatelessWidget {
  final List<dynamic> collections; // BookmarkCollection list
  const _CollectionsGrid({required this.collections});

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) {
      return Center(
          child: Text('No collections yet.', style: AppTextStyles.bodySmall));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 12,
        mainAxisSpacing:  12,
        childAspectRatio: 1.1,
      ),
      itemCount:   collections.length,
      itemBuilder: (_, i) =>
          _CollectionCard(collection: collections[i]),
    );
  }
}

// ── Collection card ───────────────────────────────────────────
class _CollectionCard extends StatelessWidget {
  final dynamic collection; // BookmarkCollection
  const _CollectionCard({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4-color preview grid
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusMd)),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap:     true,
                physics:        const NeverScrollableScrollPhysics(),
                children: (collection.previewColors as List)
                    .take(4)
                    .map<Widget>((c) => Container(color: c))
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collection.name,
                    style: AppTextStyles.labelMedium),
                Text('${collection.verseCount} verses',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────
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
