// ============================================================
// FILE: lib/features/auth/login_screen.dart
//
// PURPOSE: The "Welcome back" login screen.
//
// WHAT IT DOES:
//   - User enters Email + Password
//   - "Forgot password?" is a tappable link (dummy for now)
//   - "Log in" button navigates to the main app (/home)
//   - "Continue with Google" is a dummy button
//   - "New here? Sign up" navigates to SignupScreen
//   - Back arrow goes back to WelcomeScreen
//
// NOTE: The _GoogleButton and _AuthSwitchRow widgets are defined
//   in signup_screen.dart and re-exported here so we don't
//   duplicate code. Actually, since they're in the same feature
//   folder, we simply import that file. But to keep things
//   clean and self-contained for a beginner, we just re-declare
//   them here too — they're small enough that it's fine.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../navigation/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── Controllers ───────────────────────────────────────────
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  // ── Local state ───────────────────────────────────────────
  bool _showError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────
  void _onLoginPressed() {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    // Basic validation — both fields must be filled.
    if (email.isEmpty || password.isEmpty) {
      setState(() => _showError = true);
      return;
    }

    setState(() => _showError = false);

    // Dummy: navigate to main app shell.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false, // Remove all previous screens from the stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      // ── App Bar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Welcome back',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        titleSpacing: 0,
      ),

      // ── Body ─────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Email field ─────────────────────────────────
            AppTextField(
              label:           'Email',
              hint:            'you@example.com',
              controller:      _emailController,
              keyboardType:    TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // ── Password field ───────────────────────────────
            AppTextField(
              label:           'Password',
              hint:            'Your password',
              controller:      _passwordController,
              isPassword:      true,
              textInputAction: TextInputAction.done,
              onSubmitted:     _onLoginPressed,
              errorText:       _showError ? 'Please fill in all fields.' : null,
            ),
            const SizedBox(height: 14),

            // ── Forgot password link ─────────────────────────
            GestureDetector(
              onTap: () {
                // TODO: Implement forgot password flow
              },
              child: Text(
                'Forgot password?',
                style: AppTextStyles.labelMedium.copyWith(
                  color:      AppColors.primaryPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Log in button (orange) ───────────────────────
            AppButton(
              label: 'Log in',
              onTap: _onLoginPressed,
            ),
            const SizedBox(height: 14),

            // ── Continue with Google ─────────────────────────
            _GoogleButton(
              onTap: () {
                // TODO: Google Sign-In
              },
            ),
            const SizedBox(height: 24),

            // ── "New here? Sign up" link ─────────────────────
            _AuthSwitchRow(
              question:    'New here?',
              actionLabel: 'Sign up',
              onTap: () => Navigator.pushReplacementNamed(
                context, AppRoutes.signup,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PRIVATE WIDGETS (same design as in signup_screen.dart)
// ════════════════════════════════════════════════════════════

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: AppConstants.buttonHeight,
      child: Material(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              border: Border.all(
                color: AppColors.divider,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'G',
                  style: AppTextStyles.buttonLabel.copyWith(
                    fontSize: 18,
                    color:    AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Continue with Google',
                  style: AppTextStyles.buttonLabel.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthSwitchRow extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  const _AuthSwitchRow({
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:  '$question ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
              TextSpan(
                text:  actionLabel,
                style: AppTextStyles.bodyMedium.copyWith(
                  color:      AppColors.primaryPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
