// ============================================================
// FILE: lib/features/auth/timezone_screen.dart
//
// PURPOSE: The timezone selection screen shown after sign up.
//
// WHAT IT LOOKS LIKE (from the designs):
//   - Light lavender background
//   - Back arrow + "Your timezone" heading
//   - Subtext: "Your streak resets at midnight where you are..."
//   - List of timezone options (Nairobi, Lagos, London, New York)
//     Each is a rounded card. Selected one has a purple border.
//   - "Continue" orange button pinned to the bottom
//
// STATE: Tracks which timezone is currently selected.
//   Defaults to 'Nairobi' (first in the list).
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../navigation/app_router.dart';

class TimezoneScreen extends StatefulWidget {
  const TimezoneScreen({super.key});

  @override
  State<TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends State<TimezoneScreen> {
  // The currently selected timezone city name.
  // Defaults to the first option — 'Nairobi'.
  String _selectedTimezone = 'Nairobi';

  void _onContinue() {
    // Dummy: navigate to main app shell.
    // In a real app, we'd save _selectedTimezone to the user's profile.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
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
          'Your timezone',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        titleSpacing: 0,
      ),

      // ── Body + pinned Continue button ─────────────────────
      // We use a Column with Expanded + pinned footer pattern
      // so the Continue button always stays at the bottom.
      body: Column(
        children: [
          // ── Scrollable content ──────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtext explanation
                  Text(
                    'Your streak resets at midnight where you are, '
                    'so we want your day to end when you expect it to.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Timezone option list ────────────────────
                  // Loop over each timezone from AppConstants and
                  // render a selectable card for it.
                  ...AppConstants.timezones.map(
                    (tz) => _TimezoneCard(
                      city:       tz['city']!,
                      offset:     tz['offset']!,
                      isSelected: _selectedTimezone == tz['city'],
                      onTap: () {
                        setState(() => _selectedTimezone = tz['city']!);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Pinned Continue button ───────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingLg,
              AppConstants.paddingSm,
              AppConstants.paddingLg,
              AppConstants.paddingLg,
            ),
            // White top border to separate from content
            decoration: const BoxDecoration(
              color: AppColors.backgroundLight,
            ),
            child: AppButton(
              label: 'Continue',
              onTap: _onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timezone Option Card ──────────────────────────────────────
// A single selectable card row showing a city + UTC offset.
// When selected: purple border + slightly purple background.
// When unselected: white background + light grey border.
class _TimezoneCard extends StatelessWidget {
  final String city;
  final String offset;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimezoneCard({
    required this.city,
    required this.offset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          // AnimatedContainer smoothly animates the border color
          // change when the user selects a different timezone.
          duration: AppConstants.animFast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMd,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.inputFill          // Soft lavender when selected
                : AppColors.white,             // White when not selected
            borderRadius:
                BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: isSelected
                  ? AppColors.inputBorder      // Purple border when selected
                  : AppColors.divider,         // Light grey border otherwise
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // City name — bold when selected
              Text(
                city,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              // UTC offset — right-aligned, medium grey
              Text(
                offset,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
