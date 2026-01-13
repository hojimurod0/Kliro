import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPrefs {
  static const _key = 'onboarding_completed';

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    debugPrint('OnboardingPrefs: Onboarding marked as completed');
  }

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_key) ?? false;
    debugPrint('OnboardingPrefs: Onboarding completed: $completed');
    return completed;
  }
}
