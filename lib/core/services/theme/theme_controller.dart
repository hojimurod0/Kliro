import 'package:flutter/material.dart';
import 'theme_prefs.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  ThemeMode mode = ThemeMode.system;

  Future<void> init() async {
    mode = await ThemePrefs.load();
    notifyListeners();
  }

  Future<void> setMode(ThemeMode newMode) async {
    if (mode == newMode) return;
    mode = newMode;
    notifyListeners();
    await ThemePrefs.save(newMode);
  }
}
