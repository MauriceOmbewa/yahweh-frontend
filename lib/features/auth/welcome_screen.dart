// ============================================================
// FILE: lib/features/auth/welcome_screen.dart
//
// PURPOSE: The first screen users see when they open the app.
//
// TWO LAYOUTS (responsive):
//   • Mobile / narrow  (<= 700px wide)
//     - Full-screen deep purple background
//     - Glowing orange orb in the upper half
//     - "Yahweh" title + tagline in the lower half
//     - Sign up (orange), Log in (outlined), Skip (text link)
//
//   • Web / wide  (> 700px)
//     - Same purple background
//     - Top bar: "Yahweh" logo  +  "Log in" outlined button
//     - Left column: big tagline + subtext + Sign up / Log in buttons
//     - Right column: two preview cards (verse card + streak card)
//
// NAVIGATION (all dummy for now):
//   Sign up  → /signup
//   Log in   → /login
//   Skip     → /home
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/user_avatar.dart';
import '../../navigation/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder gives us the current available width.
    // We use it to switch between mobile and web layouts.
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 700;
        return isWide
            ? const _WideLayout()
            : const _MobileLayout();
      },
    );
  }
}

// ════════════════════════════════════════════════════════════
//  MOBILE LAYOUT
// ════════════════════════════════════════════════════════════
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: SafeArea(
        // SafeArea keeps content away from the status bar and
        // the iPhone notch/home indicator.
        child: Column(
          children: [
            // ── Upper half: Glow orb ────────────────────────
            // Expanded gives this half all remaining space above
            // the content section.
            Expanded(
              child: Center(
                child: _GlowOrb(size: 180),
              ),
            ),

            // ── Lower half: Text + Buttons ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App name — Playfair Display serif, bold white
                  Text(
                    'Yahweh',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline
                  Text(
                    'Read together. Grow together.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign up button (orange fill)
                  AppButton(
                    label:   'Sign up',
                    onTap:   () => Navigator.pushNamed(
                                    context, AppRoutes.signup),
                  ),
                  const SizedBox(height: 12),

                  // Log in button (white outlined)
                  AppButton(
                    label:   'Log in',
                    onTap:   () => Navigator.pushNamed(
                                    context, AppRoutes.login),
                    variant: ButtonVariant.secondary,
                  ),
                  const SizedBox(height: 16),

                  // Skip text link — centred
                  Center(
                    child: AppButton(
                      label:   'Skip for now, just read',
                      onTap:   () => Navigator.pushNamed(
                                      context, AppRoutes.home),
                      variant: ButtonVariant.text,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  WIDE / WEB LAYOUT
// ════════════════════════════════════════════════════════════
class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ──────────────────────────────────────
            _WideTopBar(),
            const SizedBox(height: 16),

            // ── Main content: left hero + right cards ────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 64,
                  vertical:   24,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: hero text + buttons
                    const Expanded(
                      flex: 5,
                      child: _WideHero(),
                    ),
                    const SizedBox(width: 64),

                    // Right: preview cards
                    const Expanded(
                      flex: 4,
                      child: _WidePreviewCards(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wide Top Bar ─────────────────────────────────────────────
class _WideTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo wordmark
          Text(
            'Yahweh',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),

          // Log in button — small outlined
          SizedBox(
            width:  100,
            height: 40,
            child: AppButton(
              label:      'Log in',
              onTap:      () => Navigator.pushNamed(context, AppRoutes.login),
              variant:    ButtonVariant.secondary,
              isFullWidth: false,
              height:     40,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wide Hero (left column) ───────────────────────────────────
class _WideHero extends StatelessWidget {
  const _WideHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Big serif tagline
        Text(
          'Read together.\nGrow together.',
          style: GoogleFonts.playfairDisplay(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: AppColors.white,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 20),

        // Subtext description
        Text(
          'A Bible study group in your pocket. Read a chapter,\nshare a verse, keep a streak alive with a friend.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.white.withValues(alpha: 0.75),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 36),

        // Sign up + Log in side by side
        Row(
          children: [
            SizedBox(
              width: 148,
              child: AppButton(
                label:      'Sign up',
                onTap:      () => Navigator.pushNamed(
                                    context, AppRoutes.signup),
                isFullWidth: false,
                height:     48,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 148,
              child: AppButton(
                label:      'Log in',
                onTap:      () => Navigator.pushNamed(
                                    context, AppRoutes.login),
                variant:    ButtonVariant.secondary,
                isFullWidth: false,
                height:     48,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Skip link
        AppButton(
          label:      'Skip for now, just read',
          onTap:      () => Navigator.pushNamed(context, AppRoutes.home),
          variant:    ButtonVariant.text,
          isFullWidth: false,
        ),
      ],
    );
  }
}

// ── Wide Preview Cards (right column) ────────────────────────
// Shows two floating preview cards that hint at the feed UI.
class _WidePreviewCards extends StatelessWidget {
  const _WidePreviewCards();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Card 1: Verse post preview
        _VersePreviewCard(),
        const SizedBox(height: 16),
        // Card 2: Streak buddy preview
        _StreakPreviewCard(),
      ],
    );
  }
}

// ── Verse Post Preview Card ───────────────────────────────────
class _VersePreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + name + time + NIV pill
          Row(
            children: [
              UserAvatar(
                initials:    'AN',
                streakCount: 12,
                size:        40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amina Njeri',
                        style: AppTextStyles.userName),
                    Text('2h ago',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:        AppColors.inputFill,
                  borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull),
                ),
                child: Text('NIV',
                    style: AppTextStyles.labelSmall),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Verse reference
          Text('Psalm 23:1–2',
              style: AppTextStyles.verseReference),
          const SizedBox(height: 8),

          // Verse quote with orange left border
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
                const SizedBox(width: 10),
                // Empty space — matches the design where the
                // verse text fades out on the landing page card
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reactions row (simplified)
          Row(
            children: [
              Text('Amen 24',
                  style: AppTextStyles.reactionCount),
              const Spacer(),
              Text('Pray 31',
                  style: AppTextStyles.reactionCount),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Streak Buddy Preview Card ─────────────────────────────────
class _StreakPreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        children: [
          // Overlapping avatars: MA + JK
          OverlappingAvatars(
            leftInitials:   'MA',
            rightInitials:  'JK',
            leftStreak:     9,
            rightStreak:    9,
            size:           40,
            rightIsActive:  true,
          ),
          const SizedBox(width: 14),

          // Status text
          Expanded(
            child: Text(
              'Both read today. Streak safe.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ),

          // Flame icons + streak number
          Column(
            children: [
              Row(
                children: const [
                  Icon(Icons.local_fire_department_rounded,
                      color: AppColors.orange, size: 18),
                  Icon(Icons.local_fire_department_rounded,
                      color: AppColors.orange, size: 18),
                ],
              ),
              Text(
                '9',
                style: AppTextStyles.bodyMedium.copyWith(
                  color:      AppColors.orange,
                  fontWeight: FontWeight.w800,
                  fontSize:   18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SHARED: GLOW ORB
// ════════════════════════════════════════════════════════════
// The soft glowing orange circle in the upper portion of
// the mobile screen. Built with a RadialGradient so it
// fades out softly, exactly like the design.
class _GlowOrb extends StatelessWidget {
  final double size;
  const _GlowOrb({this.size = 160});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            // Bright orange centre
            const Color(0xFFE08020),
            // Mid orange
            AppColors.orange.withValues(alpha: 0.85),
            // Fade to transparent edge
            AppColors.orange.withValues(alpha: 0.25),
            AppColors.orange.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.35, 0.65, 1.0],
        ),
      ),
    );
  }
}
