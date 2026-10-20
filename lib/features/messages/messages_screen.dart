// ============================================================
// FILE: lib/features/messages/messages_screen.dart
//
// PURPOSE: The conversations list screen — shows all DMs.
//
// LAYOUT:
//   AppBar: "Messages" + pencil/compose icon
//   Search bar: "Search messages"
//   "Message requests 2" banner
//   List of ConversationRow widgets
//
// SHELL INTEGRATION:
//   - Index 5 in the shell's IndexedStack (wide)
//   - On mobile: navigated to via chat icon in feed app bar
//
// RESPONSIVE: Center + ConstrainedBox(680) — same pattern as all other screens
// ============================================================

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/mock_data.dart';
import '../../models/message.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery     = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _searchQuery = _searchController.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Conversation> get _filtered {
    if (_searchQuery.isEmpty) return MockData.conversations;
    return MockData.conversations
        .where((c) => c.otherUserName.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      // ── App Bar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor:          AppColors.backgroundLight,
        elevation:                 0,
        scrolledUnderElevation:    0,
        automaticallyImplyLeading: false,
        title: Text('Messages', style: AppTextStyles.headingLarge),
        actions: [
          // Compose / pencil icon — top right
          IconButton(
            icon: const Icon(Iconsax.edit, color: AppColors.textDark, size: 22),
            onPressed: () {
              // TODO: open new message composer
            },
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              // ── Search bar ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMd,
                  vertical:   AppConstants.paddingSm,
                ),
                child: _SearchBar(controller: _searchController),
              ),

              // ── Message requests banner ─────────────────────
              _MessageRequestsBanner(count: 2),

              // ── Conversation list ───────────────────────────
              Expanded(
                child: ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final conv = _filtered[index];
                    return _ConversationRow(
                      conversation: conv,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(conversation: conv),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
        hintText:  'Search messages',
        hintStyle: AppTextStyles.inputHint,
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.textLight, size: 20),
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
            vertical: 14, horizontal: 16),
      ),
    );
  }
}

// ── Message requests banner ───────────────────────────────────
class _MessageRequestsBanner extends StatelessWidget {
  final int count;
  const _MessageRequestsBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd, 4,
        AppConstants.paddingMd, 4,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMd, vertical: 14),
        decoration: BoxDecoration(
          color:        AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Row(
          children: [
            Text('Message requests',
                style: AppTextStyles.labelMedium),
            const Spacer(),
            // Orange badge with count
            Container(
              width:  28,
              height: 28,
              decoration: const BoxDecoration(
                color:  AppColors.orange,
                shape:  BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: AppTextStyles.streakNumber.copyWith(
                  color:    AppColors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Conversation row ──────────────────────────────────────────
class _ConversationRow extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationRow({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:    onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
          vertical:   10,
        ),
        child: Row(
          children: [
            // Avatar — ring shows if they're a streak buddy
            UserAvatar(
              initials:    conversation.otherUserInitials,
              streakCount: conversation.otherUserStreak,
              size:        AppConstants.avatarLg,
              showRing:    conversation.isStreakBuddy,
            ),
            const SizedBox(width: 12),

            // Name + last message preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.otherUserName,
                      style: AppTextStyles.userName),
                  const SizedBox(height: 3),
                  Text(
                    conversation.lastMessagePreview,
                    style: AppTextStyles.bodySmall,
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Time + unread dot
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(conversation.timeAgo,
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 6),
                // Orange dot for unread conversations
                if (conversation.hasUnread)
                  Container(
                    width:  10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color:  AppColors.orange,
                      shape:  BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
