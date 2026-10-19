// ============================================================
// FILE: lib/core/utils/responsive.dart
//
// PURPOSE: A single place that defines breakpoints and helper
//          widgets for responsive layouts.
//
// BREAKPOINTS (matching the designs):
//   - Mobile:  < 700px  → phone layout (bottom nav, full width)
//   - Wide:   >= 700px  → web/tablet layout (sidebar, centred cards)
//
// HOW TO USE:
//   // Check in a widget:
//   if (Responsive.isWide(context)) { ... }
//
//   // Wrap a screen to get both layouts:
//   Responsive(
//     mobile: MobileWidget(),
//     wide:   WideWidget(),
//   )
// ============================================================

import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget wide;

  const Responsive({
    super.key,
    required this.mobile,
    required this.wide,
  });

  // ── Breakpoint check ──────────────────────────────────────
  /// Returns true when the screen is wide enough for the web layout.
  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) return wide;
        return mobile;
      },
    );
  }
}

// ── AuthCard wrapper ──────────────────────────────────────────
// On wide screens, auth forms sit inside a centred white card.
// On mobile, they fill the whole screen normally.
//
// HOW TO USE:
//   AuthCardWrapper(child: myFormContent)
class AuthCardWrapper extends StatelessWidget {
  final Widget child;
  const AuthCardWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Responsive.isWide(context)) {
      // Mobile: just return child as-is
      return child;
    }

    // Wide: centre a fixed-width white card on the lavender background
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            elevation:    0,
            color:        Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 40, vertical: 40),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
