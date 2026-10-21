// ============================================================
// FILE: lib/features/wrapped/wrapped_screen.dart
//
// PURPOSE: The "Yahweh Wrapped" weekly story slides.
//
// RESPONSIVE:
//   Mobile: Full-screen PageView, tap left/right to navigate,
//           progress bar at top.
//
//   Wide:   Carousel layout matching the web screenshot —
//           centre card is large, side cards peek in at 60% scale,
//           prev/next arrow buttons on the sides,
//           "Share your Wrapped" button below the carousel.
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/utils/responsive.dart';
import '../../data/mock_data.dart';

class WrappedScreen extends StatefulWidget {
  const WrappedScreen({super.key});

  @override
  State<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends State<WrappedScreen> {
  final _pageController = PageController(
    viewportFraction: 0.7, // lets side cards peek in on wide
  );
  int _currentPage      = 0;
  static const int _totalPages = 6;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: AppConstants.animNormal,
        curve:    Curves.easeInOut,
      );
    }
  }

  void _goPrev() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.animNormal,
        curve:    Curves.easeInOut,
      );
    }
  }

  List<Widget> get _slides => [
    _SlideYourWeek(),
    _SlideDaysShowedUp(),
    _SlidePeakHour(),
    _SlideTopBook(),
    _SlideStreakAchievement(),
    _SlideWrappedSummary(onDone: () => Navigator.pop(context)),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWide = Responsive.isWide(context);

    return Scaffold(
      // Dark background behind the cards on both layouts —
      // this is intentional: it's the "cinematic" Wrapped experience,
      // not a regular app screen.
      backgroundColor: const Color(0xFF0F0A1E),
      body: isWide ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

  // ════════════════════════════════════════════════════════
  //  MOBILE: full-screen tap-to-advance
  // ════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return GestureDetector(
      onTapUp: (details) {
        final double halfW = MediaQuery.of(context).size.width / 2;
        if (details.globalPosition.dx < halfW) {
          _goPrev();
        } else {
          _goNext();
        }
      },
      child: Stack(
        children: [
          PageView(
            controller:    _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children:      _slides,
          ),
          Positioned(
            top:   MediaQuery.of(context).padding.top + 12,
            left:  16,
            right: 16,
            child: _ProgressBar(current: _currentPage, total: _totalPages),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  WIDE: Carousel with prev/next arrows + side cards
  // ════════════════════════════════════════════════════════
  Widget _buildWideLayout() {
    return SafeArea(
      child: Column(
        children: [
          // Progress bar at top
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: _ProgressBar(current: _currentPage, total: _totalPages),
          ),

          // Carousel row — arrows + PageView
          Expanded(
            child: Row(
              children: [
                // Left arrow
                _ArrowButton(
                  icon:      Icons.chevron_left_rounded,
                  onTap:     _goPrev,
                  enabled:   _currentPage > 0,
                ),

                // Sliding cards
                Expanded(
                  child: PageView.builder(
                    controller:    _pageController,
                    onPageChanged: (i) =>
                        setState(() => _currentPage = i),
                    itemCount:     _totalPages,
                    itemBuilder:   (_, i) {
                      // Scale down non-active cards slightly
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (_, child) {
                          double scale = 0.88;
                          if (_pageController.position.haveDimensions) {
                            final double diff =
                                (_pageController.page! - i).abs();
                            scale = (1 - diff * 0.12).clamp(0.88, 1.0);
                          } else if (i == 0) {
                            scale = 1.0;
                          }
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _slides[i],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Right arrow
                _ArrowButton(
                  icon:    Icons.chevron_right_rounded,
                  onTap:   _goNext,
                  enabled: _currentPage < _totalPages - 1,
                ),
              ],
            ),
          ),

          // Share button below carousel
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingXl, 8,
                AppConstants.paddingXl, AppConstants.paddingLg),
            child: AppButton(
              label:  'Share your Wrapped',
              onTap:  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:  Text('Sharing coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              height: AppConstants.buttonHeightSm,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Arrow button ──────────────────────────────────────────────
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _ArrowButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width:  52,
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color:  enabled
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          size: 28,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PROGRESS BAR
// ════════════════════════════════════════════════════════════
class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i <= current
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SLIDE BASE
// ════════════════════════════════════════════════════════════
class _SlideBase extends StatelessWidget {
  final List<Color> gradientColors;
  final Widget child;

  const _SlideBase({
    required this.gradientColors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

class _SlideLabel extends StatelessWidget {
  final String text;
  const _SlideLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.sectionTitleCaps.copyWith(
        color:         Colors.white.withValues(alpha: 0.6),
        letterSpacing: 2.0,
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  const _BigStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.wrappedStat),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.wrappedLabel),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SLIDE 0 — YOUR WEEK
// ════════════════════════════════════════════════════════════
class _SlideYourWeek extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SlideBase(
      gradientColors: const [Color(0xFF2D1B69), Color(0xFF1A0F4A)],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _SlideLabel(text: 'YOUR WEEK'),
          const SizedBox(height: 32),
          _BigStat(value: '${MockData.chaptersThisWeek}', label: 'chapters'),
          const SizedBox(height: 32),
          _BigStat(value: '${MockData.totalHours}h', label: 'with scripture'),
          const SizedBox(height: 32),
          const _BigStat(value: '6/7', label: 'days read'),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SLIDE 1 — DAYS YOU SHOWED UP
// ════════════════════════════════════════════════════════════
class _SlideDaysShowedUp extends StatelessWidget {
  static const List<bool>   _days   = [true, true, true, false, true, true, true];
  static const List<String> _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final int readCount = _days.where((d) => d).length;
    return _SlideBase(
      gradientColors: const [Color(0xFF2D1B69), Color(0xFF1A0F4A)],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _SlideLabel(text: 'DAYS YOU SHOWED UP'),
          const SizedBox(height: 24),
          Text(_numberToWords(readCount),
              style: AppTextStyles.wrappedStat.copyWith(fontSize: 40),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (i) =>
                _DayCircle(label: _labels[i], isRead: _days[i])),
          ),
          const SizedBox(height: 24),
          Text(_missedDayText(),
              style: AppTextStyles.wrappedLabel.copyWith(fontSize: 15),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String _numberToWords(int n) {
    const words = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven'];
    if (n < words.length) return '${words[n]} days out of seven';
    return '$n days out of seven';
  }

  String _missedDayText() {
    const fullDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final missed = <String>[];
    for (int i = 0; i < _days.length; i++) {
      if (!_days[i]) missed.add(fullDays[i]);
    }
    return missed.isEmpty ? 'Perfect week! 🔥' : 'Only ${missed.join(' & ')} got away from you.';
  }
}

class _DayCircle extends StatelessWidget {
  final String label;
  final bool   isRead;
  const _DayCircle({required this.label, required this.isRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  44, height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isRead ? AppColors.orange : Colors.grey.shade700,
        shape: BoxShape.circle,
      ),
      child: isRead
          ? const Icon(Icons.check_rounded, color: AppColors.textDark, size: 20)
          : Center(child: Text(label,
              style: AppTextStyles.labelMedium
                  .copyWith(color: Colors.grey.shade400))),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SLIDE 2 — YOUR PEAK HOUR
// ════════════════════════════════════════════════════════════
class _SlidePeakHour extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SlideBase(
      gradientColors: const [Color(0xFF3D2B82), Color(0xFF1A0F4A)],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _SlideLabel(text: 'YOUR PEAK HOUR'),
          const SizedBox(height: 32),
          SizedBox(
            width: 160, height: 160,
            child: CustomPaint(painter: _ClockPainter()),
          ),
          const SizedBox(height: 24),
          Text('9 PM', style: AppTextStyles.wrappedStat.copyWith(fontSize: 56)),
          const SizedBox(height: 12),
          Text('Night owl mode',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 8),
          Text('Most of your reading happens after dinner.',
              style: AppTextStyles.wrappedLabel.copyWith(fontSize: 14),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color       = AppColors.orange
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap   = StrokeCap.round,
    );

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi - math.pi / 2;
      canvas.drawLine(
        Offset(center.dx + radius * math.cos(angle),
               center.dy + radius * math.sin(angle)),
        Offset(center.dx + (radius - 10) * math.cos(angle),
               center.dy + (radius - 10) * math.sin(angle)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..strokeWidth = 1.5,
      );
    }
    canvas.drawCircle(center, 5, Paint()..color = AppColors.orange);
  }

  @override
  bool shouldRepaint(_ClockPainter old) => false;
}

// ════════════════════════════════════════════════════════════
//  SLIDE 3 — YOUR TOP BOOK
// ════════════════════════════════════════════════════════════
class _SlideTopBook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double progress = 0.46;
    return _SlideBase(
      gradientColors: const [Color(0xFF7A2000), Color(0xFF3D1000)],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingXl),
        child: Column(
          mainAxisAlignment:  MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SlideLabel(text: 'YOUR TOP BOOK'),
            const SizedBox(height: 24),
            Text('Psalms',
                style: AppTextStyles.wrappedStat.copyWith(color: AppColors.white)),
            const SizedBox(height: 12),
            Text('${MockData.chaptersThisWeek} chapters this week',
                style: AppTextStyles.wrappedLabel),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:            progress,
                backgroundColor:  Colors.grey.shade700,
                valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 10),
            Text("You're ${(progress * 100).round()}% through the book.",
                style: AppTextStyles.wrappedLabel.copyWith(
                    color: AppColors.orange, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SLIDE 4 — STREAK ACHIEVEMENT
// ════════════════════════════════════════════════════════════
class _SlideStreakAchievement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SlideBase(
      gradientColors: const [Color(0xFF4A1500), Color(0xFF1A0F4A)],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: AppColors.orange, size: 96),
          const SizedBox(height: 24),
          Text('7-day streak',
              style: AppTextStyles.wrappedStat.copyWith(
                  fontSize: 44, color: AppColors.white)),
          const SizedBox(height: 12),
          Text('A full week. The flame is yours.',
              style: AppTextStyles.wrappedLabel.copyWith(color: AppColors.orange),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Dot(color: AppColors.orange,                          size: 10),
              _Dot(color: AppColors.orange.withValues(alpha: 0.6),   size: 7),
              _Dot(color: Colors.white,                              size: 8),
              _Dot(color: AppColors.orange,                          size: 12),
              _Dot(color: Colors.white.withValues(alpha: 0.5),       size: 6),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;
  const _Dot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

// ════════════════════════════════════════════════════════════
//  SLIDE 5 — WRAPPED SUMMARY
// ════════════════════════════════════════════════════════════
class _SlideWrappedSummary extends StatelessWidget {
  final VoidCallback onDone;
  const _SlideWrappedSummary({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return _SlideBase(
      gradientColors: const [Color(0xFF2D1B69), Color(0xFF1A0F4A)],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingLg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF29A38), Color(0xFFE08020)],
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yahweh Wrapped',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.textDark)),
                  Text('Week of 12 Oct',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  Text('${MockData.chaptersThisWeek}',
                      style: AppTextStyles.streakHero.copyWith(
                          color: AppColors.textDark, fontSize: 48)),
                  Text('chapters',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text('7-day streak · Night owl',
                      style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Share your Wrapped',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:  Text('Sharing coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onDone,
              child: Text('Done',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
