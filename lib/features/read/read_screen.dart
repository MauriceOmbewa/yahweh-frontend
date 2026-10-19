// ============================================================
// FILE: lib/features/read/read_screen.dart
// STATUS: STUB — full Bible reader built in Phase 4.
// ============================================================
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ReadScreen extends StatelessWidget {
  const ReadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded,
                size: 64, color: AppColors.orange),
            const SizedBox(height: 16),
            Text('Read', style: AppTextStyles.headingMedium
                .copyWith(color: AppColors.white)),
            const SizedBox(height: 8),
            Text('Bible reader — coming in Phase 4',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}
