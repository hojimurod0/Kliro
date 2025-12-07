import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Router va boshqa fayllar importi (o'zingnikiga moslab olasan)
import '../../../../core/navigation/app_router.dart';
import 'onboarding_language_page.dart';

// ---------------- MODEL ----------------
class OnboardingModel {
  final String image;
  final String title;
  final String desc;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.desc,
  });
}

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // DATA
  final List<OnboardingModel> _data = [
    OnboardingModel(
      image: 'assets/images/image.png',
      title: 'auth.onboarding.one_title',
      desc: 'auth.onboarding.one_desc',
    ),
    OnboardingModel(
      image: 'assets/images/check.png',
      title: 'auth.onboarding.two_title',
      desc: 'auth.onboarding.two_desc',
    ),
    OnboardingModel(
      image: 'assets/images/pilot.png',
      title: 'auth.onboarding.three_title',
      desc: 'auth.onboarding.three_desc',
    ),
  ];

  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isLanguageSelected = false; // Til tanlash holati

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Til tanlanganda
  void _onLanguageSelected() {
    setState(() {
      _isLanguageSelected = true;
    });
  }

  // Keyingi sahifa
  void _next() {
    if (_currentIndex < _data.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  // O'tkazib yuborish (oxirgi sahifaga)
  void _skip() {
    _pageController.animateToPage(
      _data.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  // Tugatish
  void _finishOnboarding() {
    context.router.replace(HomeRoute());
  }

  @override
  Widget build(BuildContext context) {
    // 1. Agar til tanlanmagan bo'lsa -> Language Page
    if (!_isLanguageSelected) {
      return OnboardingLanguagePage(onSelected: _onLanguageSelected);
    }

    // 2. Asosiy Onboarding
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// ---------------- Rasm Qismi (60%) ----------------
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36.r),
                bottomRight: Radius.circular(36.r),
              ),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _data.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return Image.asset(
                    _data[index].image,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (ctx, err, stack) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),

          /// ---------------- Text va Buttonlar Qismi (40%) ----------------
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 15),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 20,
                    blurStyle: BlurStyle.normal,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TEXT SECTION (Animatsiya bilan)
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Column(
                        key: ValueKey<int>(_currentIndex), // Key muhim!
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _data[_currentIndex].title.tr(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C1C1E),
                                ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            _data[_currentIndex].desc.tr(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 15.sp,
                                  height: 1.5,
                                  color: const Color(0xFF6B6B6B),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// BUTTONS SECTION (Pastki qism)
                  /// Bu yerda logika sen so'ragandek:
                  /// Dots va Next button bir qatorda.
                  /// Skip esa Dots ning tagida.
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Chapga taqaladi
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Dots Indicator
                          _SlideDots(
                            count: _data.length,
                            activeIndex: _currentIndex,
                            accentColor: const Color(0xFF0A84FF),
                          ),

                          // 2. Next Button (Aylana progressli)
                          _ProgressArrowButton(
                            progress: (_currentIndex + 1) / _data.length,
                            accent: const Color(0xFF0A84FF),
                            onTap: _next,
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h), // Dots va Skip orasidagi joy
                      // 3. Skip Button (Dots ning tagida turadi)
                      // Oxirgi sahifada Skip kerak emasdek, lekin xohlasang olib tashla
                      Visibility(
                        visible:
                            _currentIndex !=
                            _data.length - 1, // Oxirgi page'da yashirish
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: TextButton(
                          onPressed: _skip,
                          style: TextButton.styleFrom(
                            padding:
                                EdgeInsets.zero, // Ortiqcha joyni olib tashlash
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.centerLeft, // Chapga tekislash
                            foregroundColor: const Color(0xFF6F7783),
                          ),
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h), // Bottom safe area uchun ozgina joy
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- WIDGETLAR (O'zgarmadi, lekin optimallashtirildi) ----------------

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
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(right: 6.w),
          height: 8.h,
          // Aktiv bo'lsa uzunroq
          width: isActive ? 24.w : 8.w,
          decoration: BoxDecoration(
            color: isActive ? accentColor : const Color(0xFFD9E0EA),
            borderRadius: BorderRadius.circular(100),
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
            // Orqa kulrang doira
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE4E8F0), width: 4.w),
              ),
            ),
            // Progress
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, child) {
                return CustomPaint(
                  size: Size(size, size),
                  painter: _RingPainter(progress: value, accent: accent),
                );
              },
            ),
            // Icon
            Container(
              width: 48.r,
              height: 48.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 30.sp,
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

    final fg = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.1415926535897932 / 2;
    final sweep = 2 * 3.1415926535897932 * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
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
