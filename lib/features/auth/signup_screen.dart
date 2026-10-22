// ============================================================
// FILE: lib/features/auth/signup_screen.dart
// PURPOSE: Create account — calls AuthProvider.register()
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/utils/responsive.dart';
import '../../navigation/app_router.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController       = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController    = TextEditingController();
  bool _isLoading = false;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validate locally, then call API ───────────────────────
  Future<void> _onSignUp() async {
    setState(() => _serverError = null);

    final email    = _emailController.text.trim();
    final name     = _displayNameController.text.trim();
    final password = _passwordController.text;

    // Local validation
    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      setState(() => _serverError = 'Please fill in all fields.');
      return;
    }
    if (password.length < 12) {
      setState(() => _serverError =
          'Password must be at least 12 characters.');
      return;
    }

    setState(() => _isLoading = true);
    final auth    = context.read<AuthProvider>();
    final success = await auth.register(
      email:       email,
      displayName: name,
      password:    password,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Registration succeeded — go to timezone picker
      Navigator.pushNamed(context, AppRoutes.timezone);
    } else {
      setState(() => _serverError = auth.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = Responsive.isWide(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation:        0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create account',
            style: GoogleFonts.playfairDisplay(
                fontSize: 26, fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        titleSpacing: 0,
      ),
      body: isWide ? _buildWideBody() : _buildMobileBody(),
    );
  }

  Widget _buildMobileBody() => SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child:   _form());

  Widget _buildWideBody() => Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24)),
            child: _form(),
          ),
        ),
      ));

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        AppTextField(
          label: 'Email', hint: 'you@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Display name', hint: 'How friends see you',
          controller: _displayNameController,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Password', hint: 'At least 12 characters',
          controller: _passwordController,
          isPassword: true,
          textInputAction: TextInputAction.done,
          onSubmitted: _onSignUp,
        ),

        // ── Server error ─────────────────────────────────────
        if (_serverError != null) ...[
          const SizedBox(height: 8),
          Text(_serverError!, style: AppTextStyles.errorText),
        ],
        const SizedBox(height: 24),

        AppButton(label: 'Sign up', onTap: _onSignUp,
            isLoading: _isLoading),
        const SizedBox(height: 14),
        _GoogleButton(onTap: () {}),
        const SizedBox(height: 24),
        _AuthSwitchRow(
          question: 'Have an account?', actionLabel: 'Log in',
          onTap: () => Navigator.pushReplacementNamed(
              context, AppRoutes.login),
        ),
      ],
    );
  }
}

// ── Shared auth widgets ───────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: AppConstants.buttonHeight,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(color: AppColors.divider, width: 1.5)),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('G', style: AppTextStyles.buttonLabel.copyWith(
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

class _AuthSwitchRow extends StatelessWidget {
  final String question, actionLabel;
  final VoidCallback onTap;
  const _AuthSwitchRow({required this.question,
      required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: onTap,
      child: RichText(text: TextSpan(children: [
        TextSpan(text: '$question ',
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium)),
        TextSpan(text: actionLabel,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w700)),
      ])),
    ),
  );
}
