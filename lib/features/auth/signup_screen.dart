// ============================================================
// FILE: lib/features/auth/signup_screen.dart
// STATUS: STUB — full UI built in Phase 2.
//         Exists so WelcomeScreen can navigate here.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../navigation/app_router.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create account', style: AppTextStyles.headingLarge),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign Up Screen', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text('Full UI coming in Phase 2', style: AppTextStyles.bodySmall),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
              child: Text('Have an account? Log in',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryPurple)),
            ),
          ],
        ),
      ),
    );
  }
}
