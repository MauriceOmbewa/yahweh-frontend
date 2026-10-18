// ============================================================
// FILE: lib/core/widgets/app_button.dart
//
// PURPOSE: A reusable button used on EVERY screen of the app.
//
// VARIANTS:
//   1. Primary   → Orange fill, dark text (e.g. "Sign up", "Log in")
//   2. Secondary → Outlined with white/dark border, white text
//   3. Text      → No background, just a tappable text link
//                  (e.g. "Skip for now, just read")
//
// HOW TO USE:
//   // Orange button (most common):
//   AppButton(label: 'Sign up', onTap: () {})
//
//   // Outlined button:
//   AppButton(label: 'Log in', onTap: () {}, variant: ButtonVariant.secondary)
//
//   // Text-only link:
//   AppButton(label: 'Skip for now', onTap: () {}, variant: ButtonVariant.text)
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

// ── Enum: Button Variants ─────────────────────────────────────
// An enum is a fixed list of options. ButtonVariant can only be
// one of these three values — no typos possible.
enum ButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  // ── Properties ───────────────────────────────────────────────
  final String label;
  final VoidCallback onTap;   // VoidCallback = a function that takes no args and returns nothing
  final ButtonVariant variant;
  final bool isLoading;       // Shows a spinner instead of the label
  final bool isFullWidth;     // true = stretches across the screen
  final IconData? leadingIcon; // Optional icon before the label (e.g. Google "G")
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant     = ButtonVariant.primary,   // Default: orange
    this.isLoading   = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.width,
    this.height      = AppConstants.buttonHeight,
  });

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Text-only variant is simpler — handle it separately.
    if (variant == ButtonVariant.text) {
      return _buildTextButton();
    }

    return SizedBox(
      width:  isFullWidth ? double.infinity : width,
      height: height,
      child: _buildFilledOrOutlinedButton(),
    );
  }

  // ── Primary & Secondary Button ────────────────────────────────
  Widget _buildFilledOrOutlinedButton() {
    final isPrimary = variant == ButtonVariant.primary;

    return Material(
      // Material is a widget that gives us the ink ripple tap effect.
      color: isPrimary ? AppColors.orange : Colors.transparent,
      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      child: InkWell(
        // InkWell is the tappable area with the ripple animation.
        onTap: isLoading ? null : onTap, // Disable tap while loading
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        child: Container(
          // For the outlined button, we need a visible border.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: isPrimary
                ? null // Primary has no border (fill provides shape)
                : Border.all(
                    color: AppColors.white,
                    width: 1.5,
                  ),
          ),
          alignment: Alignment.center,
          child: _buildButtonContent(isPrimary),
        ),
      ),
    );
  }

  // ── Button Inner Content ──────────────────────────────────────
  Widget _buildButtonContent(bool isPrimary) {
    // While loading, show a small circular spinner.
    if (isLoading) {
      return SizedBox(
        width:  20,
        height: 20,
        child:  CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            isPrimary ? AppColors.textDark : AppColors.white,
          ),
        ),
      );
    }

    // Normal state: optional icon + label text.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // Row only takes the space it needs
      children: [
        if (leadingIcon != null) ...[
          Icon(
            leadingIcon,
            size: 20,
            color: isPrimary ? AppColors.textDark : AppColors.white,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: isPrimary
              ? AppTextStyles.buttonLabel
              : AppTextStyles.buttonLabelOutlined,
        ),
      ],
    );
  }

  // ── Text Button ───────────────────────────────────────────────
  Widget _buildTextButton() {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color:                AppColors.white,
            decoration:           TextDecoration.underline,
            decorationColor:      AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
