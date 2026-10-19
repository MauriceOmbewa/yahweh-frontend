// ============================================================
// FILE: lib/features/auth/signup_screen.dart
//
// PURPOSE: The "Create account" screen.
//
// WHAT IT DOES:
//   - User enters Email, Display name, Password
//   - Password is validated (must be >= 8 characters)
//   - "Sign up" button shows the error inline if invalid
//   - "Continue with Google" is a dummy button (no auth yet)
//   - "Have an account? Log in" navigates to LoginScreen
//   - Back arrow navigates back to WelcomeScreen
//
// STATE: This screen uses a StatefulWidget because it needs to
//   track what the user types (TextEditingControllers) and
//   whether to show the password error (bool _showPasswordError).
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../navigation/app_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // ── Controllers ───────────────────────────────────────────
  // A TextEditingController lets us READ what the user typed.
  // We create one for each field.
  final _emailController       = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController    = TextEditingController();

  // ── Local state ───────────────────────────────────────────
  // Whether to show the red password error message.
  bool _showPasswordError = false;

  // ── Dispose ───────────────────────────────────────────────
  // IMPORTANT: Always dispose controllers when the screen is
  // removed from memory. Forgetting this causes memory leaks.
  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validation & Submit ───────────────────────────────────
  void _onSignUpPressed() {
    final password = _passwordController.text;

    // Check password length — show error if too short.
    if (password.length < 8) {
      setState(() => _showPasswordError = true);
      return; // Stop here — don't proceed
    }

    // Clear error and proceed (dummy navigation for now).
    setState(() => _showPasswordError = false);

    // Navigate to timezone screen after successful sign up.
    Navigator.pushNamed(context, AppRoutes.timezone);
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
        // "Create account" heading — left-aligned, bold serif
        title: Text(
          'Create account',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        titleSpacing: 0, // Pull title close to the back arrow
      ),

      // ── Body ─────────────────────────────────────────────────
      body: SingleChildScrollView(
        // SingleChildScrollView prevents overflow when the
        // keyboard pushes content up on small phones.
        padding: const EdgeInsets.all(AppConstants.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Email field ─────────────────────────────────
            AppTextField(
              label:         'Email',
              hint:          'you@example.com',
              controller:    _emailController,
              keyboardType:  TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // ── Display name field ───────────────────────────
            AppTextField(
              label:      'Display name',
              hint:       'How friends see you',
              controller: _displayNameController,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // ── Password field ───────────────────────────────
            AppTextField(
              label:          'Password',
              hint:           'At least 8 characters',
              controller:     _passwordController,
              isPassword:     true,
              textInputAction: TextInputAction.done,
              onSubmitted:    _onSignUpPressed,
              // Show the red error text only after user attempts sign up.
              errorText: _showPasswordError
                  ? 'Password needs at least 8 characters.'
                  : null,
            ),
            const SizedBox(height: 28),

            // ── Sign up button (orange) ──────────────────────
            AppButton(
              label: 'Sign up',
              onTap: _onSignUpPressed,
            ),
            const SizedBox(height: 14),

            // ── Continue with Google (outlined, dark) ────────
            _GoogleButton(
              onTap: () {
                // TODO: Implement Google Sign-In in a future phase
              },
            ),
            const SizedBox(height: 24),

            // ── "Have an account? Log in" link ───────────────
            _AuthSwitchRow(
              question: 'Have an account?',
              actionLabel: 'Log in',
              onTap: () => Navigator.pushReplacementNamed(
                context, AppRoutes.login,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SHARED WIDGETS (used by both SignupScreen & LoginScreen)
// ════════════════════════════════════════════════════════════

// ── Google Button ─────────────────────────────────────────────
// The "G Continue with Google" outlined button.
// White background, dark border, bold "G" prefix.
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
                // Bold "G" — styled to look like Google's logo letter
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

// ── Auth Switch Row ────────────────────────────────────────────
// "Have an account? Log in" or "New here? Sign up"
// The first part is grey, the action word is bold purple.
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
          // RichText lets us style parts of a sentence differently.
          text: TextSpan(
            style: AppTextStyles.bodyMedium,
            children: [
              TextSpan(
                text:  '$question ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
              TextSpan(
                text: actionLabel,
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
