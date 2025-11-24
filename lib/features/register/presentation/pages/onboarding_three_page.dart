import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingThreePage extends StatelessWidget {
  const OnboardingThreePage({
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
        'assets/images/pilot.png',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
      title: 'auth.onboarding.three_title'.tr(),
      description: 'auth.onboarding.three_desc'.tr(),
      onNext: onNext,
      onSkip: onSkip,
      activeIndex: 2,
      total: 3,
    );
  }
}
