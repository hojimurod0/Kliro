import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../core/navigation/app_router.dart';
import 'onboarding_language_page.dart';
import 'onboarding_one_page.dart';
import 'onboarding_two_page.dart';
import 'onboarding_three_page.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;
  late final List<Widget> _pages;
  int _index = 1; // OnboardingOnePage dan boshlash
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 1); // Birinchi onboarding sahifasidan boshlash
    _pages = [
      OnboardingLanguagePage(
        onSelected: () {
          _controller.nextPage(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        },
      ),
      OnboardingOnePage(onNext: _next, onSkip: _skipToLast),
      OnboardingTwoPage(onNext: _next, onSkip: _skipToLast),
      OnboardingThreePage(onNext: _next, onSkip: _skipToLast),
    ];
    // 3 soniyadan keyin avtomatik ikkinchi sahifaga o'tish
    _startAutoNavigation();
  }

  void _startAutoNavigation() {
    // Birinchi sahifada 3 soniya kutish
    _autoTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _index == 1) {
        _goToPage(2); // Ikkinchi sahifaga
      }
    });
  }

  void _scheduleNextPage(int currentPageIndex) {
    _autoTimer?.cancel();
    // Faqat onboarding sahifalari uchun (1, 2, 3)
    if (currentPageIndex >= 1 && currentPageIndex < 3) {
      _autoTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _index == currentPageIndex) {
          _goToPage(currentPageIndex + 1);
        }
      });
    }
  }

  void _goToPage(int pageIndex) {
    if (!_controller.hasClients) return;
    _controller.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    // Joriy sahifa indeksini aniqlash
    final currentPage = _controller.hasClients ? (_controller.page?.round() ?? _index) : _index;
    final isLastPage = currentPage >= _pages.length - 1;
    
    debugPrint('_next called: currentPage=$currentPage, _index=$_index, isLastPage=$isLastPage');
    
    if (!isLastPage) {
      if (_controller.hasClients) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    } else {
      // Oxirgi sahifada bo'lsa, home page'ga o'tish
      debugPrint('Navigating to HomePage from onboarding');
      // Bir oz kutib, keyin navigation qilish
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        try {
          debugPrint('Attempting navigation to HomeRoute...');
          context.router.replace( HomeRoute());
          debugPrint('Navigation successful');
        } catch (e, stackTrace) {
          debugPrint('Navigation error: $e');
          debugPrint('Stack trace: $stackTrace');
          // Ikkinchi urinish
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            try {
              debugPrint('Retrying navigation...');
              context.router.replace(HomeRoute());
            } catch (e2) {
              debugPrint('Retry navigation error: $e2');
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: PageView(
        controller: _controller,
        onPageChanged: (i) {
          setState(() => _index = i);
          // Avtomatik navigatsiyani keyingi sahifa uchun rejalashtirish
          _scheduleNextPage(i);
        },
        physics: _index == 0
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        children: _pages,
      ),
    );
  }

  void _skipToLast() {
    if (!_controller.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSkip();
      });
      return;
    }
    _performSkip();
  }

  void _performSkip() {
    _controller.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }
}
