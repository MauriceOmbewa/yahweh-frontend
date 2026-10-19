// ============================================================
// FILE: lib/features/progress/progress_screen.dart
// STATUS: STUB — full progress screen built in Phase 5.
// ============================================================
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart_rounded,
                size: 64, color: AppColors.primaryPurple),
            const SizedBox(height: 16),
            Text('Progress', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text('Streaks & stats — coming in Phase 5',
                style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
