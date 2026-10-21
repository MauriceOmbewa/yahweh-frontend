// ============================================================
// FILE: lib/features/friends/friends_screen.dart
//
// PURPOSE: The Friends screen — shows streak buddies and
//          incoming friend requests.
//
// HOW THIS SCREEN IS STRUCTURED:
//
//   Scaffold
//   └── Column
//       ├── AppBar  ("Friends")
//       └── Expanded
//           └── SingleChildScrollView
//               ├── Search bar
//               ├── SectionHeader "Streak buddies"
//               ├── StreakBuddyCard × 3    ← from widgets/
//               ├── SectionHeader "Requests"
//               └── FriendRequestCard × 1  ← from widgets/
//
// STATE: This screen is Stateful because:
//   - The search field needs a TextEditingController
//   - Tapping "Nudge" / "Accept" / "Decline" changes local state
//     (in a real app this would go to a Provider/backend)
// ============================================================

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/section_header.dart';
import '../../data/mock_data.dart';
import '../../models/streak_buddy.dart';
import 'widgets/streak_buddy_card.dart';
import 'widgets/friend_request_card.dart';

class FriendsScreen extends StatefulWidget {
  /// On mobile: called when the back arrow is tapped (returns to Feed).
  /// On wide: null — no back arrow shown.
  final VoidCallback? onBack;

  const FriendsScreen({super.key, this.onBack});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  // ── Search controller ─────────────────────────────────────
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Local buddy list (so we can mutate nudge state) ───────
  // We copy MockData into local state so "Nudge" taps update the UI.
  late List<StreakBuddy> _buddies;
  late List<dynamic> _requests; // Using dynamic since it's a User list

  @override
  void initState() {
    super.initState();
    // initState runs ONCE when the screen first appears.
    // Copy the mock data into local mutable lists.
    _buddies  = List.from(MockData.streakBuddies);
    _requests = List.from(MockData.friendRequests);

    // Listen to search field changes and rebuild the filtered list.
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Handle nudge tap ──────────────────────────────────────
  void _onNudge(int index) {
    setState(() {
      // Replace the buddy at this index with a copy that has
      // nudgeSentToday = true and status = nudgeSent.
      _buddies[index] = StreakBuddy(
        id:               _buddies[index].id,
        userId:           _buddies[index].userId,
        partnerName:      _buddies[index].partnerName,
        partnerInitials:  _buddies[index].partnerInitials,
        myInitials:       _buddies[index].myInitials,
        sharedStreakDays: _buddies[index].sharedStreakDays,
        status:           StreakBuddyStatus.nudgeSent, // ← changed
        nudgeSentToday:   true,
      );
    });
  }

  // ── Handle accept/decline ─────────────────────────────────
  void _onAccept(int index) {
    setState(() => _requests.removeAt(index));
    // In a real app: call API to accept the friend request
  }

  void _onDecline(int index) {
    setState(() => _requests.removeAt(index));
    // In a real app: call API to decline
  }

  // ── Filtered buddy list ───────────────────────────────────
  List<StreakBuddy> get _filteredBuddies {
    if (_searchQuery.isEmpty) return _buddies;
    return _buddies
        .where((b) => b.partnerName.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      // ── App Bar ─────────────────────────────────────────────
      // No back arrow — this is a top-level screen accessed from
      // the sidebar (web) or a dedicated nav button.
      appBar: AppBar(
        backgroundColor:        AppColors.backgroundLight,
        elevation:               0,
        scrolledUnderElevation:  0,
        // Show back arrow on mobile (onBack provided), hide on wide sidebar
        automaticallyImplyLeading: false,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textDark, size: 18),
                onPressed: widget.onBack,
              )
            : null,
        title: Text('Friends', style: AppTextStyles.headingLarge),
      ),

      // ── Scrollable body ──────────────────────────────────────
      // Center + ConstrainedBox caps the content at 680px on wide
      // screens so it doesn't stretch uncomfortably on a browser.
      // On mobile the ConstrainedBox has no effect (screen < 680px).
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ────────────────────────────────────
            _SearchBar(controller: _searchController),
            const SizedBox(height: AppConstants.paddingMd),

            // ── Streak buddies section ────────────────────────
            const SectionHeader(title: 'Streak buddies'),
            const SizedBox(height: AppConstants.paddingSm),

            // Map over filtered buddies and render a card for each.
            // The "index" variable lets us pass the right index to
            // the nudge handler.
            ..._filteredBuddies.asMap().entries.map((entry) {
              final index = entry.key;
              final buddy = entry.value;
              return StreakBuddyCard(
                buddy:   buddy,
                onNudge: () => _onNudge(index),
              );
            }),

            // Show a message if search found nothing
            if (_filteredBuddies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No buddies found for "$_searchQuery"',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),

            const SizedBox(height: AppConstants.paddingMd),

            // ── Requests section ──────────────────────────────
            if (_requests.isNotEmpty) ...[
              const SectionHeader(title: 'Requests'),
              const SizedBox(height: AppConstants.paddingSm),

              ..._requests.asMap().entries.map((entry) {
                final index     = entry.key;
                final requester = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppConstants.paddingSm),
                  child: FriendRequestCard(
                    requester: requester,
                    onAccept:  () => _onAccept(index),
                    onDecline: () => _onDecline(index),
                  ),
                );
              }),
            ],

            // Bottom padding so last card isn't flush with nav bar
            const SizedBox(height: AppConstants.paddingXl),
          ],        // Column children
        ),          // Column
      ),            // SingleChildScrollView
        ),          // ConstrainedBox
      ),            // Center
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────
// A styled rounded search input at the top of the screen.
// Private to this file — only used here.
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      style:        AppTextStyles.inputText,
      decoration: InputDecoration(
        hintText:    'Search by name',
        hintStyle:   AppTextStyles.inputHint,
        prefixIcon:  const Icon(
          Icons.search_rounded,
          color: AppColors.textLight,
          size:  20,
        ),
        // Override the default InputDecoration to match our style
        filled:      true,
        fillColor:   AppColors.inputFill,
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
            color: AppColors.inputBorder,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
    );
  }
}
