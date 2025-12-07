import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.activeIndex,
    required this.total,
    required this.onNext,
    required this.onSkip,
    this.accentColor = const Color(0xFF0A84FF),
  });

  final Widget image;
  final String title;
  final String description;
  final int activeIndex;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Color accentColor;

  double get _progressValue {
    if (total <= 0) return 0;
    return (activeIndex + 1).clamp(1, total) / total;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        /// ------------------------ IMAGE SECTION ------------------------
        Expanded(
          flex: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36.r),
              bottomRight: Radius.circular(36.r),
            ),
            child: SizedBox.expand(child: image),
          ),
        ),

        /// ------------------------ CONTENT SECTION ------------------------
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(36.r),
                topRight: Radius.circular(36.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16.r,
                  offset: Offset(0, -4.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Column(
                    key: ValueKey(activeIndex),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        description,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          height: 1.45,
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: _SlideDots(
                        count: total,
                        activeIndex: activeIndex,
                        accentColor: accentColor,
                      ),
                    ),

                    _ProgressArrowButton(
                      progress: _progressValue,
                      accent: accentColor,
                      onTap: onNext,
                    ),
                  ],
                ),

                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6F7783),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideDots extends StatelessWidget {
  const _SlideDots({
    required this.count,
    required this.activeIndex,
    required this.accentColor,
  });

  final int count;
  final int activeIndex;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.only(right: 6.w),
          height: 8.h,
          width: isActive ? 22.w : 10.w,
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
  });

  final double progress;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 62.r;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(progress: progress, accent: accent),
            ),
            Container(
              width: 48.r,
              height: 48.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                size: 26.sp,
                color: Colors.black,
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
    final stroke = 4.w;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;

    final bg = Paint()
      ..color = const Color(0xFFE4E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final fg = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);

    const pi = 3.1415926535897932;
    final sweep = 2 * pi * progress.clamp(0, 1);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
