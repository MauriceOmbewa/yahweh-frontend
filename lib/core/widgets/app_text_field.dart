// ============================================================
// FILE: lib/core/widgets/app_text_field.dart
//
// PURPOSE: A reusable styled text input field.
//
// Used on: Sign up, Log in, search bars, caption input, etc.
//
// HOW TO USE:
//   // Basic field:
//   AppTextField(label: 'Email', hint: 'you@example.com', controller: _emailController)
//
//   // Password field (hides text):
//   AppTextField(label: 'Password', hint: 'At least 8 characters',
//     controller: _passwordController, isPassword: true)
//
//   // With error message shown below:
//   AppTextField(label: 'Password', hint: '...', controller: _ctrl,
//     errorText: 'Password needs at least 8 characters.')
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  // ── Properties ───────────────────────────────────────────────
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;       // Obscures text for password fields
  final String? errorText;     // Red message shown below the field
  final TextInputType keyboardType; // Keyboard type (email, text, number, etc.)
  final TextInputAction textInputAction; // What the "done/next" key does
  final VoidCallback? onSubmitted; // Called when user presses done/next
  final int maxLines;          // 1 = single line, >1 = multiline (e.g. caption)
  final int? maxLength;        // Optional character limit

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword       = false,
    this.errorText,
    this.keyboardType     = TextInputType.text,
    this.textInputAction  = TextInputAction.next,
    this.onSubmitted,
    this.maxLines         = 1,
    this.maxLength,
  });

  // AppTextField uses State because it needs to track whether
  // the password is currently visible or hidden.
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // This is "local state" — it only affects this one widget.
  // _isObscured starts as true for password fields.
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align label to the left
      children: [
        // ── Field Label ─────────────────────────────────────────
        Text(widget.label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),

        // ── Input Field ─────────────────────────────────────────
        TextField(
          controller:      widget.controller,
          obscureText:     widget.isPassword && _isObscured,
          keyboardType:    widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines:        widget.isPassword ? 1 : widget.maxLines,
          maxLength:       widget.maxLength,
          style:           AppTextStyles.inputText,
          onSubmitted:     (_) => widget.onSubmitted?.call(),
          decoration: InputDecoration(
            hintText:  widget.hint,
            hintStyle: AppTextStyles.inputHint,
            // Counter text is the "0/500" shown on multiline fields.
            // We show it only when maxLength is set.
            counterText: widget.maxLength != null ? null : '',

            // ── Password Toggle Icon ───────────────────────────
            // Show an eye icon on password fields so users can
            // toggle visibility.
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMedium,
                      size: 20,
                    ),
                    onPressed: () {
                      // setState tells Flutter to re-render this widget
                      // with the new _isObscured value.
                      setState(() => _isObscured = !_isObscured);
                    },
                  )
                : null,
          ),
        ),

        // ── Error Message ────────────────────────────────────────
        // Only shows when errorText is not null.
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(widget.errorText!, style: AppTextStyles.errorText),
        ],
      ],
    );
  }
}
