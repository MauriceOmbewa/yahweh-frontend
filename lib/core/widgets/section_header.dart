// ============================================================
// FILE: lib/core/widgets/section_header.dart
//
// PURPOSE: A bold section label used to divide content into
//          named groups on screens.
//
// USED ON:
//   - Friends screen: "Streak buddies", "Requests"
//   - Bookmarks screen: "Collections"
//   - Notifications screen: "TODAY", "YESTERDAY"
//   - Settings screen: "ACCOUNT", "PRIVACY", "NOTIFICATIONS"
//
// VARIANTS:
//   - normal  → Dark title (e.g. "Streak buddies")
//   - caps    → Orange uppercase tracking (e.g. "ACCOUNT")
//
// HOW TO USE:
//   SectionHeader(title: 'Streak buddies')
//   SectionHeader(title: 'ACCOUNT', isCaps: true)
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isCaps;    // true = orange uppercase (used in Settings)
  final Widget? trailing; // Optional widget on the right (e.g. "Mark all read")

  const SectionHeader({
    super.key,
    required this.title,
    this.isCaps   = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isCaps
                ? AppTextStyles.sectionTitleCaps
                : AppTextStyles.sectionTitle,
          ),
          ?trailing,
        ],
      ),
    );
  }
}
