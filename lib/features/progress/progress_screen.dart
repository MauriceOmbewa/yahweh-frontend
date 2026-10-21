// ============================================================
// FILE: lib/features/progress/progress_screen.dart
//
// PURPOSE: Reading stats — streak, goal ring, calendar heatmap,
//          peak hours bar chart. Shell tab index 2.
//
// SECTIONS (matching the design):
//   1. Streak card  — "12 day streak. Keep the flame lit."
//   2. Today's goal ring (68%, 17 of 25 min) + stat tiles row
//   3. Reading calendar heatmap (GridView of coloured squares)
//   4. Peak reading hours bar chart (CustomPaint)
// ============================================================

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/mock_data.dart';
import '../wrapped/wrapped_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:          AppColors.backgroundLight,
        elevation:                 0,
        scrolledUnderElevation:    0,
        automaticallyImplyLeading: false,
        title: Text('Progress', style: AppTextStyles.headingLarge),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Streak card
                _StreakCard(),
                const SizedBox(height: 16),

                // 2. Goal ring + stats row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GoalRingCard(),
                    const SizedBox(width: 12),
                    Expanded(child: _StatsColumn()),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Reading calendar
                _CalendarCard(),
                const SizedBox(height: 16),

                // 4. Peak reading hours
                _PeakHoursCard(),
                const SizedBox(height: 16),

                // 5. View Wrapped button
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WrappedScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMd),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3D2B82), Color(0xFF1A0F4A)],
                        begin:  Alignment.topLeft,
                        end:    Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLg),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Yahweh Wrapped',
                                style: AppTextStyles.labelMedium
                                    .copyWith(color: AppColors.orange)),
                            const SizedBox(height: 4),
                            Text('See your week in review',
                                style: AppTextStyles.bodySmall
                                    .copyWith(
                                        color: AppColors.white
                                            .withValues(alpha: 0.8))),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.white, size: 16),
                      ],
                    ),
                  ),
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

// ════════════════════════════════════════════════════════════
//  1. STREAK CARD
// ════════════════════════════════════════════════════════════
class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D2B82), Color(0xFF1A0F4A)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Big orange streak number
          Text(
            '${MockData.currentUser.currentStreak}',
            style: AppTextStyles.streakHero,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'day streak. Keep the flame lit.',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Longest: ${MockData.currentUser.longestStreak} days',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  2a. TODAY'S GOAL RING
// ════════════════════════════════════════════════════════════
class _GoalRingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double progress =
        MockData.todayMinutesRead / MockData.dailyGoalMinutes;
    final int pct = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular ring
          SizedBox(
            width:  72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value:       1.0,
                  strokeWidth: 8,
                  color:       AppColors.divider,
                ),
                CircularProgressIndicator(
                  value:           progress,
                  strokeWidth:     8,
                  color:           AppColors.orange,
                  backgroundColor: Colors.transparent,
                  strokeCap:       StrokeCap.round,
                ),
                Text('$pct%',
                    style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today's goal",
                  style: AppTextStyles.labelMedium),
              const SizedBox(height: 4),
              Text(
                '${MockData.todayMinutesRead} of '
                '${MockData.dailyGoalMinutes} minutes.',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                progress >= 0.9 ? 'Almost there.' : 'Keep going!',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  2b. STATS COLUMN (chapters, total time, daily avg)
// ════════════════════════════════════════════════════════════
class _StatsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatMini(
                  value: '${MockData.chaptersThisWeek}',
                  label: 'chapters\nthis week'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatMini(
                  value: '${MockData.totalHours}h',
                  label: 'total\ntime'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatMini(
                  value: '${MockData.dailyAvgMinutes}m',
                  label: 'daily\naverage'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatMini(
                  value: '${MockData.longestSessionMin}m',
                  label: 'longest\nsession'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  final String value;
  final String label;
  const _StatMini({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTextStyles.headingMedium
                  .copyWith(fontSize: 20)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(height: 1.3)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  3. READING CALENDAR HEATMAP
// ════════════════════════════════════════════════════════════
class _CalendarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reading calendar', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          // 7-column grid of coloured squares
          GridView.builder(
            shrinkWrap:  true, // Don't scroll inside the parent scroll
            physics:     const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   7,
              mainAxisSpacing:  4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: MockData.calendarIntensity.length,
            itemBuilder: (_, i) {
              final double intensity = MockData.calendarIntensity[i];
              return Container(
                decoration: BoxDecoration(
                  color:        _intensityColor(intensity),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Maps 0.0–1.0 intensity to a shade of purple
  Color _intensityColor(double intensity) {
    if (intensity == 0) return AppColors.inputFill;
    if (intensity < 0.4) return AppColors.primaryPurple.withValues(alpha: 0.25);
    if (intensity < 0.7) return AppColors.primaryPurple.withValues(alpha: 0.55);
    return AppColors.primaryPurple;
  }
}

// ════════════════════════════════════════════════════════════
//  4. PEAK READING HOURS BAR CHART
// ════════════════════════════════════════════════════════════
class _PeakHoursCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Peak reading hours', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _BarChartPainter(
                  values: MockData.peakReadingHours),
            ),
          ),
          // Hour labels: 12am, 6am, 12pm, 6pm, 11pm
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['12am', '6am', '12pm', '6pm', '11pm']
                  .map((l) => Text(l,
                      style: AppTextStyles.labelSmall
                          .copyWith(fontSize: 10)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bar chart CustomPainter ───────────────────────────────────
// Draws one vertical bar per hour (24 total).
// The two tallest bars are highlighted in orange; rest in purple.
class _BarChartPainter extends CustomPainter {
  final List<double> values; // 24 values, 0.0–1.0
  const _BarChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double barW   = size.width / values.length;
    const double gap    = 2;

    // Find the top-2 indices to highlight in orange
    final sorted = List.generate(values.length, (i) => i)
      ..sort((a, b) => values[b].compareTo(values[a]));
    final topTwo = sorted.take(2).toSet();

    for (int i = 0; i < values.length; i++) {
      final double h = maxVal > 0
          ? (values[i] / maxVal) * size.height
          : 0;

      final paint = Paint()
        ..color = topTwo.contains(i)
            ? AppColors.orange
            : AppColors.primaryPurple.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(
        i * barW + gap / 2,
        size.height - h,
        barW - gap,
        h,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.values != values;
}
