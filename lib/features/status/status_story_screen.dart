// ============================================================
// FILE: lib/features/status/status_story_screen.dart
//
// PURPOSE: WhatsApp-style 24-hour status story viewer.
//
// HOW IT WORKS (exactly like WhatsApp):
//   1. In the Feed, friend avatar circles have an orange ring
//      when they have an active status (posted < 24h ago).
//   2. Tap a circle → this screen opens full-screen.
//   3. A thin progress bar at the top counts down the story
//      (5 seconds per story, then auto-advances).
//   4. The story shows the friend's status verse in a beautiful
//      full-screen card with their name + time posted.
//   5. Tap left = previous story, tap right = next story.
//   6. When all stories are seen → screen closes.
//
// STATUS EXPIRY:
//   - Each status has a `postedAt` DateTime.
//   - If DateTime.now().difference(postedAt).inHours >= 24,
//     the status is expired and the circle shows NO orange ring.
//   - The `StatusStory.isActive` getter handles this.
//
// OPENING:
//   StatusStoryScreen.show(context, users: MockData.friends)
//   — or tap a specific user's circle to start from their story.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user.dart';

// ── StatusStory model ─────────────────────────────────────────
// Each user can have one active status (their status verse).
class StatusStory {
  final User      author;
  final String    verseText;
  final String    verseReference;
  final DateTime  postedAt;

  const StatusStory({
    required this.author,
    required this.verseText,
    required this.verseReference,
    required this.postedAt,
  });

  // ── Is this status still active? (posted < 24h ago) ───────
  bool get isActive =>
      DateTime.now().difference(postedAt).inHours < 24;

  // ── Human-readable time ────────────────────────────────────
  String get timeAgo {
    final diff = DateTime.now().difference(postedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    return 'Expired';
  }

  // ── How much of the 24 hours has elapsed (0.0–1.0) ────────
  // Used to show the "expiry" bar on the status card.
  double get expiryProgress =>
      (DateTime.now().difference(postedAt).inMinutes / (24 * 60))
          .clamp(0.0, 1.0);
}

// ── Mock statuses (one per friend) ───────────────────────────
// In a real app these come from the backend.
// We create them here so they have varying ages to show
// the 24h expiry behaviour.
List<StatusStory> buildMockStatuses(List<User> friends) {
  return friends
      .where((u) => u.statusVerse != null)
      .map((u) => StatusStory(
            author:         u,
            verseText:      u.statusVerse!,
            verseReference: u.statusVerseRef ?? '',
            // Vary the age so some look recent and some look older
            postedAt: DateTime.now().subtract(
              Duration(hours: friends.indexOf(u) * 3 + 1),
            ),
          ))
      .toList();
}

// ════════════════════════════════════════════════════════════
//  STATUS STORY SCREEN
// ════════════════════════════════════════════════════════════
class StatusStoryScreen extends StatefulWidget {
  final List<StatusStory> stories;
  final int               initialIndex; // which story to start from

  const StatusStoryScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  // ── Static helper to open ─────────────────────────────────
  static void show(
    BuildContext context, {
    required List<StatusStory> stories,
    int initialIndex = 0,
  }) {
    if (stories.isEmpty) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context2, anim1, anim2) => StatusStoryScreen(
          stories:      stories,
          initialIndex: initialIndex,
        ),
        // Slide up from bottom — like WhatsApp
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end:   Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve:  Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  State<StatusStoryScreen> createState() => _StatusStoryScreenState();
}

class _StatusStoryScreenState extends State<StatusStoryScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _progressController;

  // How long each story is shown before auto-advancing
  static const Duration _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _progressController = AnimationController(
      vsync:    this,
      duration: _storyDuration,
    );

    _startStory();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  // ── Start the timer for the current story ──────────────────
  void _startStory() {
    _progressController.reset();
    _progressController.forward().then((_) {
      // Auto-advance when timer reaches the end
      if (mounted) _goNext();
    });
  }

  void _goNext() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _startStory();
    } else {
      // All stories seen — close
      Navigator.pop(context);
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _startStory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Tap left half → previous, right half → next
        onTapUp: (details) {
          final double halfW = MediaQuery.of(context).size.width / 2;
          if (details.globalPosition.dx < halfW) {
            _goPrev();
          } else {
            _goNext();
          }
        },
        // Long-press pauses the timer
        onLongPressStart: (_) => _progressController.stop(),
        onLongPressEnd:   (_) => _progressController.forward(),
        child: Stack(
          children: [
            // ── Story background card ──────────────────────
            _StoryCard(story: story),

            // ── Top overlay: progress bars + header ────────
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bars — one per story
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: _StoryProgressBars(
                      total:          widget.stories.length,
                      currentIndex:   _currentIndex,
                      progressCtrl:   _progressController,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Author header row
                  _StoryHeader(
                    story:   story,
                    onClose: () => Navigator.pop(context),
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

// ── Progress bars ─────────────────────────────────────────────
class _StoryProgressBars extends StatelessWidget {
  final int                total;
  final int                currentIndex;
  final AnimationController progressCtrl;

  const _StoryProgressBars({
    required this.total,
    required this.currentIndex,
    required this.progressCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: i < currentIndex
                  // Fully watched stories → full white bar
                  ? Container(height: 3, color: Colors.white)
                  : i == currentIndex
                      // Current story → animated fill
                      ? AnimatedBuilder(
                          animation: progressCtrl,
                          builder: (context3, _) => LinearProgressIndicator(
                            value:           progressCtrl.value,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 3,
                          ),
                        )
                      // Future stories → dim bar
                      : Container(
                          height: 3,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Story header: avatar + name + time + close ────────────────
class _StoryHeader extends StatelessWidget {
  final StatusStory  story;
  final VoidCallback onClose;

  const _StoryHeader({required this.story, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width:  44,
            height: 44,
            decoration: BoxDecoration(
              color:  AppColors.deepPurple,
              shape:  BoxShape.circle,
              border: Border.all(color: AppColors.orange, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              story.author.initials,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),

          // Name + time posted
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(story.author.displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Row(
                  children: [
                    Text(story.timeAgo,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12)),
                    const SizedBox(width: 8),
                    // 24h expiry indicator
                    _ExpiryPill(progress: story.expiryProgress),
                  ],
                ),
              ],
            ),
          ),

          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 24h expiry pill ───────────────────────────────────────────
// Shows how much of the 24 hours has elapsed.
// Green → recent, Yellow → halfway, Red → almost expired.
class _ExpiryPill extends StatelessWidget {
  final double progress; // 0.0 = just posted, 1.0 = about to expire
  const _ExpiryPill({required this.progress});

  @override
  Widget build(BuildContext context) {
    final Color color = progress < 0.5
        ? Colors.greenAccent
        : progress < 0.8
            ? Colors.orangeAccent
            : Colors.redAccent;

    final String label = progress < 0.5
        ? 'Recent'
        : progress < 0.8
            ? '${((1 - progress) * 24).round()}h left'
            : 'Expiring soon';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border:       Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              color:    color,
              fontSize: 10,
              fontWeight: FontWeight.w600)),
    );
  }
}

// ── Story card (main content) ─────────────────────────────────
class _StoryCard extends StatelessWidget {
  final StatusStory story;
  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D1B69), Color(0xFF0F0A1E)],
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "STATUS VERSE" label
              Text(
                'STATUS VERSE',
                style: AppTextStyles.statusVerseLabel,
              ),
              const SizedBox(height: 24),

              // Verse text — large serif, centred
              Text(
                story.verseText,
                style: GoogleFonts.playfairDisplay(
                  fontSize:   26,
                  fontWeight: FontWeight.w600,
                  color:      Colors.white,
                  height:     1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Reference
              Text(
                story.verseReference,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
