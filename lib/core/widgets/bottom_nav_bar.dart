// ============================================================
// FILE: lib/core/widgets/bottom_nav_bar.dart
//
// PURPOSE: The custom bottom navigation bar shown on every
//          main app screen.
//
// WHAT IT LOOKS LIKE (from the designs):
//   [ 🏠 Feed ]  [ 📖 Read ]  [ ➕ ]  [ 📊 Progress ]  [ 👤 Profile ]
//                              ↑
//                    Big orange circle FAB in the middle.
//                    Tapping it opens "Share a verse".
//
// TABS (in order):
//   0 = Feed
//   1 = Read
//   2 = (FAB — not a real tab index)
//   3 = Progress
//   4 = Profile
//
// HOW TO USE:
//   AppBottomNavBar(
//     currentIndex: 0,         // Which tab is active
//     onTap: (index) { ... },  // What happens when a tab is tapped
//     onShareTap: () { ... },  // What happens when the "+" is tapped
//   )
// ============================================================

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;       // Active tab (0=Feed, 1=Read, 2=Progress, 3=Profile)
  final ValueChanged<int> onTap; // Called with the tapped index
  final VoidCallback onShareTap; // Called when the "+" FAB is tapped

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:     AppConstants.bottomNavHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        // Subtle top shadow to separate nav from content.
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset:     const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tab 0: Feed
          _NavItem(
            icon:      Iconsax.home,
            iconFill:  Iconsax.home_1,    // Filled variant
            label:     'Feed',
            isActive:  currentIndex == 0,
            onTap:     () => onTap(0),
          ),

          // Tab 1: Read
          _NavItem(
            icon:      Iconsax.book,
            iconFill:  Iconsax.book_1,    // Filled variant
            label:     'Read',
            isActive:  currentIndex == 1,
            onTap:     () => onTap(1),
          ),

          // Centre FAB: Share a verse
          _ShareFab(onTap: onShareTap),

          // Tab 2: Progress
          _NavItem(
            icon:      Iconsax.chart,
            iconFill:  Iconsax.chart_1,   // Filled variant
            label:     'Progress',
            isActive:  currentIndex == 2,
            onTap:     () => onTap(2),
          ),

          // Tab 3: Profile
          _NavItem(
            icon:      Iconsax.user,
            iconFill:  Iconsax.user_square, // Filled-style variant
            label:     'Profile',
            isActive:  currentIndex == 3,
            onTap:     () => onTap(3),
          ),
        ],
      ),
    );
  }
}

// ── Single Nav Tab Item ───────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;      // Outlined icon (inactive state)
  final IconData iconFill;  // Filled icon (active state)
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconFill,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? AppColors.primaryPurple : AppColors.textMedium;

    return Expanded(
      child: GestureDetector(
        onTap:     onTap,
        behavior:  HitTestBehavior.opaque, // Tap works even on transparent areas
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconFill : icon,
              color: color,
              size:  22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.navLabel.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Centre "+" FAB ────────────────────────────────────────────
// The big orange circle in the middle of the nav bar.
class _ShareFab extends StatelessWidget {
  final VoidCallback onTap;
  const _ShareFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72, // Fixed width for the centre slot
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width:  AppConstants.bottomNavFabSize,
            height: AppConstants.bottomNavFabSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.orange,
              // Lifted orange shadow to make it "pop" above the bar.
              boxShadow: [
                BoxShadow(
                  color:      Color(0x55F29A38),
                  blurRadius: 12,
                  offset:     Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.white,
              size:  28,
            ),
          ),
        ),
      ),
    );
  }
}
