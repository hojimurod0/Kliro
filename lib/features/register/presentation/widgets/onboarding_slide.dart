import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.onNext,
    required this.onSkip,
    required this.activeIndex,
    required this.total,
    this.accentColor = const Color(0xFF0A84FF),
  });

  final Widget image;
  final String title;
  final String description;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int activeIndex;
  final int total;
  final Color accentColor;

  double get _progressValue {
    if (total <= 0) return 0;
    return (activeIndex + 1).clamp(1, total) / total;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 600;

    // Responsive values
    final horizontalPadding = isSmallScreen
        ? 16.w
        : (isLargeScreen ? 32.w : 24.w);
    final verticalPadding = isSmallScreen
        ? 20.h
        : (isLargeScreen ? 32.h : 28.h);
    final titleFontSize =
        isSmallScreen ? 18.sp : (isLargeScreen ? 24.sp : 20.sp);
    final descriptionFontSize =
        isSmallScreen ? 13.sp : (isLargeScreen ? 16.sp : 14.sp);
    final borderRadius = isSmallScreen ? 32.r : 40.r;
    final topSpacing = isSmallScreen ? 8.h : 10.h;

    return Container(
      color: const Color(0xFFEFF3F9),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: SizedBox.expand(child: image),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(top: topSpacing),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(borderRadius),
                          topRight: Radius.circular(borderRadius),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x15000000),
                            blurRadius: 24.r,
                            offset: Offset(0, -8.h),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          verticalPadding,
                          horizontalPadding,
                          isSmallScreen ? 16.h : 20.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1C1C1E),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8.h : 10.h),
                            Flexible(
                              child: Text(
                                description,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: descriptionFontSize,
                                  color: const Color(0xFF6B6B6B),
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _SlideDots(
                                        count: total,
                                        activeIndex: activeIndex,
                                        accentColor: accentColor,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      SizedBox(
                                        height:
                                            isSmallScreen ? 10.h : 12.h,
                                      ),
                                      TextButton(
                                        onPressed: onSkip,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          alignment: Alignment.centerLeft,
                                          foregroundColor: const Color(
                                            0xFF6F7783,
                                          ),
                                          textStyle: TextStyle(
                                            fontSize: isSmallScreen
                                                ? 13.sp
                                                : 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        child: Text(
                                          'auth.onboarding.skip'.tr(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _ProgressArrowButton(
                                  progress: _progressValue,
                                  accent: accentColor,
                                  onTap: onNext,
                                  isSmallScreen: isSmallScreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideDots extends StatelessWidget {
  const _SlideDots({
    required this.count,
    required this.activeIndex,
    required this.accentColor,
    this.isSmallScreen = false,
  });

  final int count;
  final int activeIndex;
  final Color accentColor;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final dotHeight = isSmallScreen ? 7.h : 8.h;
    final activeWidth = isSmallScreen ? 20.w : 22.w;
    final inactiveWidth = isSmallScreen ? 9.w : 10.w;
    final margin = isSmallScreen ? 5.w : 6.w;

    return Row(
      children: List.generate(count, (i) {
        final bool isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: EdgeInsets.only(right: margin),
          height: dotHeight,
          width: isActive ? activeWidth : inactiveWidth,
          decoration: BoxDecoration(
            color: isActive ? accentColor : const Color(0xFFD9E0EA),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _ProgressArrowButton extends StatelessWidget {
  const _ProgressArrowButton({
    required this.progress,
    required this.accent,
    required this.onTap,
    this.isSmallScreen = false,
  });

  final double progress;
  final Color accent;
  final VoidCallback onTap;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final buttonSize = isSmallScreen ? 56.r : 62.r;
    final innerSize = isSmallScreen ? 44.r : 48.r;
    final iconSize = isSmallScreen ? 22.sp : 24.sp;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(buttonSize, buttonSize),
              painter: _RingPainter(progress: progress, accent: accent),
            ),
            Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x15000000),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_right,
                color: const Color(0xFF1C1C1E),
                size: iconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 4.w;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFE4E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      const pi = 3.1415926535897932;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final start = -pi / 2;
      final sweep = 2 * pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(rect, start, sweep, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}
