// ============================================================
// FILE: lib/features/profile/profile_screen.dart
// STATUS: STUB — full profile screen built in Phase 9.
// ============================================================
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_rounded,
                size: 64, color: AppColors.primaryPurple),
            const SizedBox(height: 16),
            Text('Profile', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text('Your profile — coming in Phase 9',
                style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
