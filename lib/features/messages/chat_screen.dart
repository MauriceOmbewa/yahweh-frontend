// ============================================================
// FILE: lib/features/messages/chat_screen.dart
//
// PURPOSE: A single conversation / DM thread.
//
// LAYOUT:
//   AppBar: back + avatar + name + "Streak buddy · X days" subtitle
//   Chat bubble list (reversed so newest is at bottom)
//   Bottom bar: book-icon button + text field + send button
//
// MESSAGE TYPES (from MessageType enum):
//   text       → left (grey) or right (dark navy) bubble
//   verseShare → inline verse card with orange left border
//   nudge      → centred orange system text
//
// RESPONSIVE: Full-screen push — no ConstrainedBox needed here
//   because chat UIs naturally fill the screen width.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/user_avatar.dart';
import '../../models/message.dart';
import '../../features/share/share_verse_screen.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController  = ScrollController();

  // Local copy of messages so we can add new ones
  late List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.conversation.messages);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Send a text message ───────────────────────────────────
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(
        id:       'new_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'user_ma', // current user
        type:     MessageType.text,
        text:     text,
        sentAt:   DateTime.now(),
        isFromMe: true,
      ));
    });

    _messageController.clear();

    // Scroll to bottom after adding a message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppConstants.animNormal,
          curve:    Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      // ── App Bar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor:        AppColors.backgroundLight,
        elevation:               0,
        scrolledUnderElevation:  0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            // Small avatar in the app bar header
            UserAvatar(
              initials:    conv.otherUserInitials,
              streakCount: conv.otherUserStreak,
              size:        36,
              showBadge:   false,
              showRing:    conv.isStreakBuddy,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conv.otherUserName,
                      style: AppTextStyles.userName),
                  // Orange streak buddy subtitle — only if buddy
                  if (conv.isStreakBuddy)
                    Text(
                      'Streak buddy · ${conv.sharedStreakDays} days together',
                      style: AppTextStyles.bodySmall.copyWith(
                        color:    AppColors.orange,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Chat bubble list ──────────────────────────────────
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller:  _scrollController,
              padding:     const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMd,
                vertical:   AppConstants.paddingSm,
              ),
              itemCount:   _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(_messages[index]);
              },
            ),
          ),

          // ── Compose bar ─────────────────────────────────────
          _ComposeBar(
            controller:   _messageController,
            onSend:       _sendMessage,
            onShareVerse: () => ShareVerseScreen.show(context),
          ),
        ],
      ),
    );
  }

  // ── Route each message to the right widget ────────────────
  Widget _buildMessageItem(Message msg) {
    switch (msg.type) {
      case MessageType.verseShare:
        return _VerseShareBubble(message: msg);
      case MessageType.nudge:
        return _NudgeSystemMessage(text: msg.text ?? '');
      case MessageType.text:
        return _TextBubble(message: msg);
    }
  }
}

// ════════════════════════════════════════════════════════════
//  MESSAGE WIDGETS
// ════════════════════════════════════════════════════════════

// ── Plain text bubble ─────────────────────────────────────────
class _TextBubble extends StatelessWidget {
  final Message message;
  const _TextBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isFromMe;

    return Align(
      // Right-align my messages, left-align theirs
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:  const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          // Bubble never wider than 75% of screen
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          // My messages: dark navy. Theirs: light lavender.
          color: isMe
              ? AppColors.primaryPurple
              : AppColors.inputFill,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Text(
          message.text ?? '',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isMe ? AppColors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

// ── Verse share bubble ────────────────────────────────────────
// Appears as a white card with orange left border in the chat.
class _VerseShareBubble extends StatelessWidget {
  final Message message;
  const _VerseShareBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final verse = message.verse;
    if (verse == null) return const SizedBox.shrink();

    return Align(
      alignment: message.isFromMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color:        AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reference (orange)
            Text(
              '${verse.reference} · ${verse.translation}',
              style: AppTextStyles.verseReference.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 8),
            // Verse text with orange left border
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      verse.text,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nudge system message ──────────────────────────────────────
// Centred orange text — "You nudged Amina to keep the streak alive"
class _NudgeSystemMessage extends StatelessWidget {
  final String text;
  const _NudgeSystemMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color:        AppColors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color:      AppColors.orange,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ── Compose bar ───────────────────────────────────────────────
// The input row pinned to the bottom of the screen.
class _ComposeBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onShareVerse;

  const _ComposeBar({
    required this.controller,
    required this.onSend,
    required this.onShareVerse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left:   AppConstants.paddingMd,
        right:  AppConstants.paddingMd,
        top:    8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Book icon — opens Share a verse sheet
          GestureDetector(
            onTap: onShareVerse,
            child: Container(
              width:  40,
              height: 40,
              decoration: BoxDecoration(
                color:        AppColors.inputFill,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primaryPurple,
                size:  20,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: TextField(
              controller:      controller,
              style:           AppTextStyles.inputText,
              textInputAction: TextInputAction.send,
              onSubmitted:     (_) => onSend(),
              decoration: InputDecoration(
                hintText:  'Message ${controller.text.isEmpty ? '' : ''}',
                hintStyle: AppTextStyles.inputHint,
                filled:    true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  borderSide:   BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  borderSide:   BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  borderSide: const BorderSide(
                      color: AppColors.inputBorder, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button — orange circle
          GestureDetector(
            onTap: onSend,
            child: Container(
              width:  40,
              height: 40,
              decoration: const BoxDecoration(
                color:  AppColors.orange,
                shape:  BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white,
                size:  20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
