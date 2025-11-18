import 'package:flutter/material.dart';
import 'onboarding_language_page.dart';
import 'onboarding_one_page.dart';
import 'onboarding_two_page.dart';
import 'onboarding_three_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final PageController _controller;
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _pages = [
      OnboardingLanguagePage(
        onSelected: () {
          _controller.nextPage(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        },
      ),
      const OnboardingOnePage(),
      const OnboardingTwoPage(),
      const OnboardingThreePage(),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      // TODO: Navigate to actual auth/register form
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              children: _pages,
            ),
          ),
          if (_index >= 1) const SizedBox(height: 8),
          if (_index >= 1)
            _Dots(
              count: 3,
              index: _index - 1,
              progress: _progressValue,
            ),
          if (_index >= 1) const SizedBox(height: 12),
          if (_index > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      _controller.animateToPage(
                        _pages.length - 1,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Text("O'tkazib yuborish"),
                  ),
                  const Spacer(),
                  _NextButton(
                    progress: _progressValue,
                    onTap: _next,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  double get _progressValue {
    if (_index < 1) return 0.0;
    final step = _index.clamp(1, 3); // 1..3
    return step / 3.0;
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  final double progress; // 0..1 for active item
  const _Dots({required this.count, required this.index, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isFilled = i < (index + 1); // cumulative fill 1/3, 2/3, 3/3
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
          height: 8,
          width: 22,
          decoration: BoxDecoration(
            color: isFilled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _NextButton extends StatelessWidget {
  final double progress; // 0..1
  final VoidCallback onTap;
  const _NextButton({required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Custom painted outer ring with discrete fill based on index
            CustomPaint(
              painter: _RingPainter(
                color: Theme.of(context).colorScheme.primary,
                progress: progress.clamp(0.0, 1.0),
                strokeWidth: 3,
              ),
            ),
            // Filled circular button
            Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double progress; // 0..1
  final double strokeWidth;
  _RingPainter({required this.color, required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final bg = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);

    if (progress > 0) {
      const pi = 3.1415926535897932;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final start = -pi / 2; // top
      final sweep = 2 * pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(rect, start, sweep, false, fg);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.color != color || old.progress != progress || old.strokeWidth != strokeWidth;
  }
}
