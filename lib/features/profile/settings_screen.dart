// ============================================================
// FILE: lib/features/profile/settings_screen.dart
//
// PURPOSE: App settings — grouped into sections matching design.
//
// SECTIONS (from design):
//   ACCOUNT    — Display name, Timezone, Password
//   PRIVACY    — Post visibility, Who can message, toggles
//   NOTIFICATIONS — Reactions, Nudges, Weekly Wrapped toggles
//   READING    — Daily goal, Default translation
//   ABOUT      — Version, Terms, Rate app, Log out, Delete account
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Toggle states ─────────────────────────────────────────
  bool _allowFriendRequests   = true;
  bool _showStreak            = true;
  bool _reactionsNotif        = true;
  bool _nudgesNotif           = true;
  bool _weeklyWrappedNotif    = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:        AppColors.backgroundLight,
        elevation:               0,
        scrolledUnderElevation:  0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings',
            style: GoogleFonts.playfairDisplay(
              fontSize:   26,
              fontWeight: FontWeight.w700,
              color:      AppColors.textDark,
            )),
        titleSpacing: 0,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── ACCOUNT ──────────────────────────────────
                _SectionCard(
                  label: 'ACCOUNT',
                  children: [
                    _RowTile(label: 'Display name', value: 'Maurice'),
                    _RowTile(label: 'Timezone',     value: 'Nairobi'),
                    _RowTile(label: 'Password',     value: 'Change',
                        onTap: () {}),
                  ],
                ),
                const SizedBox(height: 16),

                // ── PRIVACY ───────────────────────────────────
                _SectionCard(
                  label: 'PRIVACY',
                  children: [
                    _RowTile(label: 'Post visibility',
                        value: 'Friends only'),
                    _RowTile(label: 'Who can message me',
                        value: 'Friends only'),
                    _ToggleTile(
                      label:    'Allow friend requests',
                      value:    _allowFriendRequests,
                      onChanged: (v) =>
                          setState(() => _allowFriendRequests = v),
                    ),
                    _ToggleTile(
                      label:    'Show my streak to friends',
                      value:    _showStreak,
                      onChanged: (v) =>
                          setState(() => _showStreak = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── NOTIFICATIONS ─────────────────────────────
                _SectionCard(
                  label: 'NOTIFICATIONS',
                  children: [
                    _ToggleTile(
                      label:    'Reactions',
                      value:    _reactionsNotif,
                      onChanged: (v) =>
                          setState(() => _reactionsNotif = v),
                    ),
                    _ToggleTile(
                      label:    'Nudges from buddies',
                      value:    _nudgesNotif,
                      onChanged: (v) =>
                          setState(() => _nudgesNotif = v),
                    ),
                    _ToggleTile(
                      label:    'Weekly Wrapped',
                      value:    _weeklyWrappedNotif,
                      onChanged: (v) =>
                          setState(() => _weeklyWrappedNotif = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── READING ───────────────────────────────────
                _SectionCard(
                  label: 'READING',
                  children: [
                    _RowTile(label: 'Daily goal',
                        value: '25 min'),
                    _RowTile(label: 'Default translation',
                        value: 'NIV'),
                  ],
                ),
                const SizedBox(height: 16),

                // ── ABOUT ─────────────────────────────────────
                _SectionCard(
                  label: 'ABOUT',
                  children: [
                    _RowTile(label: 'Version',
                        value: AppConstants.appVersion),
                    _RowTile(label: 'Terms and privacy',
                        onTap: () {}),
                    _RowTile(label: 'Rate the app',
                        onTap: () {}),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Log out ───────────────────────────────────
                _ActionTile(
                  label:     'Log out',
                  color:     AppColors.textDark,
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                  },
                ),
                const SizedBox(height: 8),

                // ── Delete account ────────────────────────────
                _ActionTile(
                  label: 'Delete account',
                  color: AppColors.error,
                  onTap: () {}, // TODO: confirm dialog
                ),
                const SizedBox(height: AppConstants.paddingXl),
              ],
            ),
          ),         // SingleChildScrollView
        ),           // ConstrainedBox
      ),             // Center
    );
  }
}

// ── Section card ──────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _SectionCard({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Orange uppercase section label
        Padding(
          padding: const EdgeInsets.only(
              left: 4, bottom: AppConstants.paddingSm),
          child: Text(label, style: AppTextStyles.sectionTitleCaps),
        ),
        Container(
          decoration: BoxDecoration(
            color:        AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Column(
            children: List.generate(children.length, (i) {
              return Column(
                children: [
                  children[i],
                  // Divider between items, not after last
                  if (i < children.length - 1)
                    const Divider(
                        height: 1, indent: 16, endIndent: 16),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Row tile (label + value or arrow) ────────────────────────
class _RowTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onTap;
  const _RowTile({required this.label, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMd, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            if (value != null)
              Text(value!,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: onTap != null
                          ? AppColors.primaryPurple
                          : AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}

// ── Toggle tile ───────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Switch(
            value:      value,
            onChanged:  onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primaryPurple
                  : AppColors.white),
            trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primaryPurple.withValues(alpha: 0.4)
                  : AppColors.divider),
          ),
        ],
      ),
    );
  }
}

// ── Action tile (Log out / Delete) ───────────────────────────
class _ActionTile extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
              color: color.withValues(alpha: 0.3), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppTextStyles.labelMedium.copyWith(color: color)),
      ),
    );
  }
}
