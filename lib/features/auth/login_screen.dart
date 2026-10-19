// ============================================================
// FILE: lib/features/auth/login_screen.dart
//
// PURPOSE: The "Welcome back" login screen.
//
// RESPONSIVE BEHAVIOUR:
//   Mobile  (<700px): Full-screen form.
//   Wide   (>=700px): Centred white card (max 480px).
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/utils/responsive.dart';
import '../../navigation/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool  _showError          = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _showError = false);
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = Responsive.isWide(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation:       0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Welcome back',
          style: GoogleFonts.playfairDisplay(
              fontSize: 26, fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        titleSpacing: 0,
      ),
      body: isWide ? _buildWideBody() : _buildMobileBody(),
    );
  }

  Widget _buildMobileBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child:   _formContent(),
    );
  }

  Widget _buildWideBody() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color:        AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: _formContent(),
          ),
        ),
      ),
    );
  }

  Widget _formContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        AppTextField(
          label:           'Email',
          hint:            'you@example.com',
          controller:      _emailController,
          keyboardType:    TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),

        AppTextField(
          label:           'Password',
          hint:            'Your password',
          controller:      _passwordController,
          isPassword:      true,
          textInputAction: TextInputAction.done,
          onSubmitted:     _onLoginPressed,
          errorText: _showError ? 'Please fill in all fields.' : null,
        ),
        const SizedBox(height: 14),

        // Forgot password link
        GestureDetector(
          onTap: () {}, // TODO: forgot password flow
          child: Text(
            'Forgot password?',
            style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 24),

        AppButton(label: 'Log in', onTap: _onLoginPressed),
        const SizedBox(height: 14),

        _GoogleButton(onTap: () {}),
        const SizedBox(height: 24),

        _AuthSwitchRow(
          question:    'New here?',
          actionLabel: 'Sign up',
          onTap: () => Navigator.pushReplacementNamed(
              context, AppRoutes.signup),
        ),
      ],
    );
  }
}

// ── Google Button ─────────────────────────────────────────────
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
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('G',
                    style: AppTextStyles.buttonLabel.copyWith(
                        fontSize: 18, color: AppColors.textDark)),
                const SizedBox(width: 10),
                Text('Continue with Google',
                    style: AppTextStyles.buttonLabel.copyWith(
                        color: AppColors.textDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Auth Switch Row ────────────────────────────────────────────
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
                      color: AppColors.textMedium)),
              TextSpan(
                  text:  actionLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
