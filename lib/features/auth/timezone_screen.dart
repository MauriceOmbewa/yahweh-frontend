// ============================================================
// FILE: lib/features/auth/timezone_screen.dart
// PURPOSE: Timezone selection — calls UserService.updateTimezone()
//          then navigates to the main app shell.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../navigation/app_router.dart';
import '../../services/user_service.dart';

class TimezoneScreen extends StatefulWidget {
  const TimezoneScreen({super.key});
  @override
  State<TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends State<TimezoneScreen> {
  String _selectedTimezone = 'Nairobi';
  bool   _isLoading        = false;

  Future<void> _onContinue() async {
    setState(() => _isLoading = true);
    try {
      await context.read<UserService>()
          .updateTimezone(_selectedTimezone);
    } catch (_) {
      // Non-fatal — proceed anyway, user can change in settings
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Your timezone',
            style: GoogleFonts.playfairDisplay(
                fontSize: 26, fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your streak resets at midnight where you are, '
                    'so we want your day to end when you expect it to.',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 24),
                  ...AppConstants.timezones.map(
                    (tz) => _TimezoneCard(
                      city:       tz['city']!,
                      offset:     tz['offset']!,
                      isSelected: _selectedTimezone == tz['city'],
                      onTap: () =>
                          setState(() => _selectedTimezone = tz['city']!),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingLg, AppConstants.paddingSm,
                AppConstants.paddingLg, AppConstants.paddingLg),
            child: AppButton(
              label: 'Continue', onTap: _onContinue,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimezoneCard extends StatelessWidget {
  final String city, offset;
  final bool isSelected;
  final VoidCallback onTap;
  const _TimezoneCard({required this.city, required this.offset,
      required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd, vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.inputFill : AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.inputBorder : AppColors.divider,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(city, style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: isSelected
                      ? FontWeight.w700 : FontWeight.w500)),
              Text(offset, style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
