import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingOnePage extends StatelessWidget {
  const OnboardingOnePage({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      image: Image.asset(
        'assets/images/image.png',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
      title: 'auth.onboarding.one_title'.tr(),
      description: 'auth.onboarding.one_desc'.tr(),
      activeIndex: 0,
      total: 3,
      onNext: onNext,
      onSkip: onSkip,
    );
  }
}
