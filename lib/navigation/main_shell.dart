// ============================================================
// FILE: lib/navigation/main_shell.dart
//
// PURPOSE: The persistent scaffold that wraps every main tab.
//
// THINK OF IT LIKE THIS:
//   MainShell is the "frame" of the app — it holds the bottom
//   navigation bar and swaps the content area when you tap a tab.
//   The content area shows Feed, Read, Progress, or Profile.
//
// HOW TABS WORK:
//   - We keep a list of 4 screens (one per tab).
//   - _currentIndex tracks which tab is active (0–3).
//   - IndexedStack shows only the active screen but keeps all
//     others in memory — so if you scroll down on Feed, switch
//     to Progress, then come back, Feed is still scrolled down.
//
// THE "+" FAB:
//   - The centre floating button is NOT a tab — it's an action.
//   - Tapping it opens the ShareVerseScreen as a bottom sheet.
// ============================================================

import 'package:flutter/material.dart';

import '../core/widgets/bottom_nav_bar.dart';
import '../features/feed/feed_screen.dart';
import '../features/read/read_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/share/share_verse_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // ── Current Tab Index ─────────────────────────────────────
  // 0 = Feed, 1 = Read, 2 = Progress, 3 = Profile
  int _currentIndex = 0;

  // ── Tab Screens ───────────────────────────────────────────
  // This list maps tab index → screen widget.
  // We define it as a fixed list so it's created once, not
  // every time the widget rebuilds.
  static const List<Widget> _screens = [
    FeedScreen(),      // Tab 0
    ReadScreen(),      // Tab 1
    ProgressScreen(),  // Tab 2
    ProfileScreen(),   // Tab 3
  ];

  // ── Handle tab tap ────────────────────────────────────────
  void _onTabTapped(int index) {
    // setState tells Flutter to re-render with the new index.
    setState(() => _currentIndex = index);
  }

  // ── Handle "+" FAB tap ────────────────────────────────────
  void _onShareTapped() {
    // Opens the Share a verse bottom sheet.
    ShareVerseScreen.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Tab content area ──────────────────────────────────
      // IndexedStack keeps all 4 screens alive simultaneously.
      // Only the one at _currentIndex is visible, but the others
      // maintain their scroll positions and state.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ── Bottom navigation bar ────────────────────────────
      // We set resizeToAvoidBottomInset to false on each tab
      // screen individually, but the Scaffold here handles
      // the overall layout.
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap:        _onTabTapped,
        onShareTap:   _onShareTapped,
      ),
    );
  }
}
