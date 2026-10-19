// ============================================================
// FILE: lib/features/profile/settings_screen.dart
// STATUS: STUB — full Settings screen built in Phase 9.
// ============================================================
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: AppTextStyles.headingLarge),
        titleSpacing: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings_rounded,
                size: 64, color: AppColors.primaryPurple),
            const SizedBox(height: 16),
            Text('Settings', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text('Full settings — coming in Phase 9',
                style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
