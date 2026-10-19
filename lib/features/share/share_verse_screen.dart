// ============================================================
// FILE: lib/features/share/share_verse_screen.dart
// STATUS: STUB — full share sheet built in Phase 6.
//
// This is shown as a bottom sheet when the centre "+" FAB
// is tapped. Right now it just shows a placeholder.
// ============================================================
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';

class ShareVerseScreen extends StatelessWidget {
  const ShareVerseScreen({super.key});

  // ── Static helper to show this as a bottom sheet ──────────
  // Usage: ShareVerseScreen.show(context)
  static void show(BuildContext context) {
    showModalBottomSheet(
      context:         context,
      isScrollControlled: true,      // Allows full-height sheet
      backgroundColor: Colors.transparent,
      builder:         (_) => const ShareVerseScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: const BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Only as tall as content
        children: [
          // Drag handle
          Center(
            child: Container(
              width:  40,
              height: 4,
              decoration: BoxDecoration(
                color:        AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Share a verse', style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          Text('Full UI coming in Phase 6',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          AppButton(
            label: 'Close',
            onTap: () => Navigator.pop(context),
            variant: ButtonVariant.secondary,
          ),
          const SizedBox(height: AppConstants.paddingMd),
        ],
      ),
    );
  }
}
