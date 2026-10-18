// ============================================================
// FILE: lib/navigation/main_shell.dart
// STATUS: STUB — full shell with bottom nav built in Phase 3.
//         Exists so "Skip for now" on WelcomeScreen works.
// ============================================================

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded,
                size: 64, color: AppColors.primaryPurple),
            const SizedBox(height: 16),
            Text('Main App', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text('Feed, Read, Progress & Profile\ncoming in Phase 3',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
